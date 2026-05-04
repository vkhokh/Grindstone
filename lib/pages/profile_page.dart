import 'package:dp/colors.dart';
import 'package:dp/models/user_profile.dart';
import 'package:dp/pages/current_training_page.dart';
import 'package:dp/pages/login_page.dart';
import 'package:dp/pages/main_page.dart';
import 'package:dp/pages/progress_page.dart';
import 'package:dp/pages/training_archive_page.dart';
import 'package:dp/services/auth_service.dart';
import 'package:dp/services/user_session_storage.dart';
import 'package:dp/widgets/user_profile_form.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  UserProfileData _profile = const UserProfileData.empty();
  UserGender? _selectedGender;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  final ImagePicker _imagePicker = ImagePicker();

  String? _nameError;
  String? _heightError;
  String? _weightError;
  String? _genderError;

  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Colors.black;
  static const Color _cardColor = Color(0xFFFFFBF5);
  static const Color _softTileColor = Color(0xFFFCF7EF);
  static const Color _borderSoft = Color(0xFFE8E2D6);
  static const Color _navBackground = Color(0xFFF2EAD9);

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_refreshState);
    _heightController.addListener(_refreshState);
    _weightController.addListener(_refreshState);
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.removeListener(_refreshState);
    _heightController.removeListener(_refreshState);
    _weightController.removeListener(_refreshState);
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final cachedProfile = await UserSessionStorage.loadProfile();
    if (mounted) {
      setState(() {
        _profile = cachedProfile;
        _selectedGender = cachedProfile.gender;
        _fillControllers(cachedProfile);
        _isEditing = !cachedProfile.isComplete;
      });
    }

    try {
      final remoteProfile = await AuthService.instance.fetchProfile(cache: true);
      if (remoteProfile != null && mounted) {
        setState(() {
          _profile = remoteProfile;
          _selectedGender = remoteProfile.gender;
          _fillControllers(remoteProfile);
          _isEditing = !remoteProfile.isComplete;
        });
      }
    } catch (_) {
      // ignore remote fetch errors and keep cached data
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fillControllers(UserProfileData profile) {
    _nameController.text = profile.name;
    _heightController.text = _formatNumber(profile.heightCm);
    _weightController.text = _formatNumber(profile.weightKg);
  }

  void _refreshState() {
    if (mounted) {
      setState(() {});
    }
  }

  double? _parseHeight() {
    final value = _heightController.text.trim().replaceAll(',', '.');
    if (value.isEmpty) return null;

    final parsed = double.tryParse(value);
    if (parsed == null || parsed <= 0) return null;

    return parsed;
  }

  double? _parseWeight() {
    final value = _weightController.text.trim().replaceAll(',', '.');
    if (value.isEmpty) return null;

    final parsed = double.tryParse(value);
    if (parsed == null || parsed <= 0) return null;

    return parsed;
  }

  bool _validateForm() {
    final name = _nameController.text.trim();
    final height = _parseHeight();
    final weight = _parseWeight();

    String? newNameError;
    String? newHeightError;
    String? newWeightError;
    String? newGenderError;

    if (name.isEmpty) {
      newNameError = 'Введите имя';
    } else if (name.length < 2) {
      newNameError = 'Имя должно быть не короче 2 символов';
    }

    if (_selectedGender == null) {
      newGenderError = 'Выберите пол';
    }

    if (height == null) {
      newHeightError = 'Введите рост';
    } else if (height < 100 || height > 250) {
      newHeightError = 'Рост должен быть от 100 до 250 см';
    }

    if (weight == null) {
      newWeightError = 'Введите вес';
    } else if (weight < 30 || weight > 300) {
      newWeightError = 'Вес должен быть от 30 до 300 кг';
    }

    setState(() {
      _nameError = newNameError;
      _genderError = newGenderError;
      _heightError = newHeightError;
      _weightError = newWeightError;
    });

    return newNameError == null &&
        newGenderError == null &&
        newHeightError == null &&
        newWeightError == null;
  }

  bool get _isFormValid {
    final name = _nameController.text.trim();
    final height = _parseHeight();
    final weight = _parseWeight();

    return name.isNotEmpty &&
        name.length >= 2 &&
        _selectedGender != null &&
        height != null &&
        height >= 100 &&
        height <= 250 &&
        weight != null &&
        weight >= 30 &&
        weight <= 300;
  }

  Future<void> _saveProfile() async {
    final height = _parseHeight();
    final weight = _parseWeight();

    if (!_validateForm() ||
        height == null ||
        weight == null ||
        _selectedGender == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedProfile = UserProfileData(
      name: _nameController.text.trim(),
      gender: _selectedGender,
      heightCm: height,
      weightKg: weight,
      photoBase64: _profile.photoBase64,
    );

    try {
      await AuthService.instance.saveProfile(updatedProfile);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось сохранить профиль. Попробуйте снова.'),
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
      return;
    }

    if (!mounted) return;

    setState(() {
      _profile = updatedProfile;
      _isSaving = false;
      _isEditing = false;
    });
  }

  void _startEditing() {
    setState(() {
      _fillControllers(_profile);
      _selectedGender = _profile.gender;
      _isEditing = true;
      _nameError = null;
      _heightError = null;
      _weightError = null;
      _genderError = null;
    });
  }

  void _cancelEditing() {
    setState(() {
      _fillControllers(_profile);
      _selectedGender = _profile.gender;
      _isEditing = false;
      _nameError = null;
      _heightError = null;
      _weightError = null;
      _genderError = null;
    });
  }

  Future<void> _logout() async {
    await AuthService.instance.signOut();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  String _formatNumber(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  String _formatMetric(double? value, String unit) {
    if (value == null) return 'Не указано';
    return '${_formatNumber(value)} $unit';
  }

  Future<void> _pickAndUploadPhoto() async {
    if (_isUploadingPhoto) return;

    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 900,
      imageQuality: 75,
    );

    if (pickedImage == null) return;

    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final bytes = await pickedImage.readAsBytes();

      if (bytes.length > 700000) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Фото больше 0.7 МБ. Выберите файл поменьше.'),
            ),
          );
        }
        return;
      }

      final base64 = base64Encode(bytes);

      final updatedProfile = UserProfileData(
        name: _profile.name,
        gender: _profile.gender,
        heightCm: _profile.heightCm,
        weightKg: _profile.weightKg,
        photoBase64: base64,
      );

      await AuthService.instance.saveProfile(updatedProfile);

      if (!mounted) return;

      setState(() {
        _profile = updatedProfile;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Фото профиля обновлено')),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось загрузить фото. Попробуйте снова.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  Future<void> _startNewTraining() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_training');

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CurrentWorkoutScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildProfileHero(),
                    const SizedBox(height: 18),
                    if (_isEditing) ...[
                      _buildEditCard(),
                      const SizedBox(height: 18),
                      _buildEditActions(),
                    ] else ...[
                      _buildInfoCard(),
                      const SizedBox(height: 18),
                      _buildProfileActions(),
                    ],
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Профиль',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Здесь можно обновить и настроить данные о себе',
          style: TextStyle(
            fontSize: 15,
            color: _textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHero() {
    final title = _isEditing
        ? (_profile.isComplete ? 'Редактирование профиля' : 'Заполните профиль')
        : (_profile.name.isEmpty ? 'Профиль' : _profile.name);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isEditing
                ? 'Можно обновить данные ниже.'
                : 'Данные используются для персонализации тренировки.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: _textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    Uint8List? photoBytes;
    final encoded = _profile.photoBase64;
    if (encoded != null && encoded.isNotEmpty) {
      try {
        photoBytes = base64Decode(encoded);
      } catch (_) {
        photoBytes = null;
      }
    }

    Widget buildPlaceholder() {
      return const Icon(
        Icons.person_outline_rounded,
        size: 52,
        color: _textPrimary,
      );
    }

    Widget buildImage() {
      if (_isUploadingPhoto) {
        return const Center(child: CircularProgressIndicator());
      }

      if (photoBytes != null) {
        return Image.memory(
          photoBytes!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => buildPlaceholder(),
        );
      }

      return Image.asset(
        'assets/images/icon_user.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => buildPlaceholder(),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 116,
          height: 116,
          decoration: const BoxDecoration(
            color: _softTileColor,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(6),
          child: ClipOval(child: buildImage()),
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: Material(
            color: elevatedButtonBackgroundColor,
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: _isUploadingPhoto ? null : _pickAndUploadPhoto,
              icon: Icon(
                _isUploadingPhoto
                    ? Icons.hourglass_top_rounded
                    : Icons.camera_alt_outlined,
                size: 20,
              ),
              color: Colors.white,
              tooltip: 'Загрузить фото',
              constraints: const BoxConstraints.tightFor(width: 42, height: 42),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: UserProfileForm(
        nameController: _nameController,
        heightController: _heightController,
        weightController: _weightController,
        selectedGender: _selectedGender,
        nameErrorText: _nameError,
        heightErrorText: _heightError,
        weightErrorText: _weightError,
        genderErrorText: _genderError,
        onGenderSelected: (gender) {
          setState(() {
            _selectedGender = gender;
            _genderError = null;
          });
        },
        onNameChanged: (_) {
          if (_nameError != null) {
            setState(() {
              _nameError = null;
            });
          }
        },
        onHeightChanged: (_) {
          if (_heightError != null) {
            setState(() {
              _heightError = null;
            });
          }
        },
        onWeightChanged: (_) {
          if (_weightError != null) {
            setState(() {
              _weightError = null;
            });
          }
        },
      ),
    );
  }

  Widget _buildEditActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: _isFormValid && !_isSaving ? _saveProfile : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: elevatedButtonBackgroundColor,
              foregroundColor: elevatedButtonForegroundColor,
              disabledBackgroundColor:
                  elevatedButtonBackgroundColor.withOpacity(0.45),
              disabledForegroundColor:
                  elevatedButtonForegroundColor.withOpacity(0.75),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              _isSaving ? 'Сохранение...' : 'Сохранить',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _isSaving ? null : _logout,
            icon: const Icon(Icons.logout),
            label: const Text(
              'Выйти из аккаунта',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _textPrimary,
              side: BorderSide(color: _borderSoft),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        if (_profile.isComplete) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isSaving ? null : _cancelEditing,
            child: const Text(
              'Отмена',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProfileInfoRow(
            label: 'Пол',
            value: _profile.gender?.label ?? 'Не указано',
          ),
          const SizedBox(height: 16),
          _ProfileInfoRow(
            label: 'Рост',
            value: _formatMetric(_profile.heightCm, 'см'),
          ),
          const SizedBox(height: 16),
          _ProfileInfoRow(
            label: 'Вес',
            value: _formatMetric(_profile.weightKg, 'кг'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: _startEditing,
            style: ElevatedButton.styleFrom(
              backgroundColor: elevatedButtonBackgroundColor,
              foregroundColor: elevatedButtonForegroundColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Редактировать',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text(
              'Выйти из аккаунта',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _textPrimary,
              side: BorderSide(color: _borderSoft),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: _navBackground,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTab(
                icon: Icons.home_rounded,
                label: 'Домой',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                  );
                },
              ),
            ),
            Expanded(
              child: _buildTab(
                icon: Icons.view_list_rounded,
                label: 'Тренировки',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrainingArchivePage(),
                    ),
                  );
                },
              ),
            ),
            _buildFloatingButton(),
            Expanded(
              child: _buildTab(
                icon: Icons.bar_chart_rounded,
                label: 'Прогресс',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProgressPage(),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: _buildTab(
                icon: Icons.person_rounded,
                label: 'Профиль',
                isActive: true,
                onTap: null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback? onTap,
  }) {
    final color =
        isActive ? elevatedButtonBackgroundColor : const Color(0xFF6F6F74);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? elevatedButtonBackgroundColor.withOpacity(0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return GestureDetector(
      onTap: _startNewTraining,
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: elevatedButtonBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: elevatedButtonBackgroundColor.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    const textPrimary = Color(0xFF1A1A1A);
    const textSecondary = Color(0xFF8E8E93);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
      ],
    );
  }
}
