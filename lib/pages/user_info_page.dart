import 'package:dp/models/user_profile.dart';
import 'package:dp/pages/main_page.dart';
import 'package:dp/services/auth_service.dart';
import 'package:dp/services/user_session_storage.dart';
import 'package:dp/widgets/user_profile_form.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dp/colors.dart';
import 'dart:convert';
import 'dart:typed_data';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  UserGender? _selectedGender;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _photoBase64;
  final ImagePicker _imagePicker = ImagePicker();

  String? _nameError;
  String? _heightError;
  String? _weightError;
  String? _genderError;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_refreshState);
    _heightController.addListener(_refreshState);
    _weightController.addListener(_refreshState);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _refreshState() {
    setState(() {});
  }

  Future<void> _pickAndUploadPhoto() async {
    if (_isUploadingPhoto) return;

    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 900,
      imageQuality: 75,
    );

    if (pickedImage == null) return;

    setState(() => _isUploadingPhoto = true);

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

      final encoded = base64Encode(bytes);

      if (!mounted) return;

      setState(() {
        _photoBase64 = encoded;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Фото добавлено')),
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
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  double? _parseHeight() {
    final value = _heightController.text.trim().replaceAll(',', '.');
    if (value.isEmpty) {
      return null;
    }
    return double.tryParse(value);
  }

  double? _parseWeight() {
    final value = _weightController.text.trim().replaceAll(',', '.');
    if (value.isEmpty) {
      return null;
    }
    return double.tryParse(value);
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

  Widget _buildAvatar() {
    Uint8List? photoBytes;
    if (_photoBase64 != null && _photoBase64!.isNotEmpty) {
      try {
        photoBytes = base64Decode(_photoBase64!);
      } catch (_) {
        photoBytes = null;
      }
    }

    Widget placeholder() => const Icon(
          Icons.person_outline_rounded,
          size: 64,
          color: Colors.black87,
        );

    Widget avatarImage() {
      if (_isUploadingPhoto) {
        return const Center(child: CircularProgressIndicator());
      }

      if (photoBytes != null) {
        return Image.memory(
          photoBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => placeholder(),
        );
      }

      return Image.asset(
        'assets/images/icon_user.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => placeholder(),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: ClipOval(child: avatarImage()),
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
              constraints: const BoxConstraints.tightFor(width: 44, height: 44),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!_validateForm()) return;

    final height = _parseHeight()!;
    final weight = _parseWeight()!;

    setState(() => _isSaving = true);

    final profile = UserProfileData(
      name: _nameController.text.trim(),
      gender: _selectedGender!,
      heightCm: height,
      weightKg: weight,
      photoBase64: _photoBase64,
    );

    try {
      await AuthService.instance.saveProfile(profile);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось сохранить профиль. Попробуйте снова.'),
          ),
        );
        setState(() => _isSaving = false);
      }
      return;
    }

    await UserSessionStorage.setLoggedIn(true);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(),
              const SizedBox(height: 12),
              const Text(
                'Расскажите о себе',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Эти данные появятся в профиле и их можно будет изменить позже.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),

              UserProfileForm(
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

              const SizedBox(height: 30),

              SizedBox(
                width: 265,
                height: 60,
                child: ElevatedButton(
                  onPressed: !_isSaving ? _saveProfile : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: elevatedButtonBackgroundColor,
                    foregroundColor: elevatedButtonForegroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _isSaving ? 'Сохранение...' : 'Продолжить',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

