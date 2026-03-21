import 'package:dp/colors.dart';
import 'package:dp/models/user_profile.dart';
import 'package:dp/pages/current_training_page.dart';
import 'package:dp/pages/login_page.dart';
import 'package:dp/pages/main_page.dart';
import 'package:dp/services/user_session_storage.dart';
import 'package:dp/widgets/user_profile_form.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final profile = await UserSessionStorage.loadProfile();
    if (!mounted) {
      return;
    }

    setState(() {
      _profile = profile;
      _selectedGender = profile.gender;
      _fillControllers(profile);
      _isEditing = !profile.isComplete;
      _isLoading = false;
    });
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
    final value = _heightController.text.trim();
    if (value.isEmpty) {
      return null;
    }

    final parsed = double.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return null;
    }

    return parsed;
  }

  double? _parseWeight() {
    final value = _weightController.text.trim().replaceAll(',', '.');
    if (value.isEmpty) {
      return null;
    }

    final parsed = double.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return null;
    }

    return parsed;
  }

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _selectedGender != null &&
        _parseHeight() != null &&
        _parseWeight() != null;
  }

  Future<void> _saveProfile() async {
    final height = _parseHeight();
    final weight = _parseWeight();
    if (!_isFormValid || height == null || weight == null || _selectedGender == null) {
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
    );

    await UserSessionStorage.saveProfile(updatedProfile);

    if (!mounted) {
      return;
    }

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
    });
  }

  void _cancelEditing() {
    setState(() {
      _fillControllers(_profile);
      _selectedGender = _profile.gender;
      _isEditing = false;
    });
  }

  Future<void> _logout() async {
    await UserSessionStorage.logout();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  String _formatNumber(double? value) {
    if (value == null) {
      return '';
    }
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  String _formatMetric(double? value, String unit) {
    if (value == null) {
      return 'Не указано';
    }
    return '${_formatNumber(value)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/icon_user.png',
                      height: 150,
                      width: 150,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _isEditing
                          ? (_profile.isComplete
                                ? 'Редактирование профиля'
                                : 'Заполните профиль')
                          : (_profile.name.isEmpty ? 'Профиль' : _profile.name),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_isEditing)
                      Text(
                        'Эти данные отображаются в вашем профиле.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.barlow(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      )
                    else
                      Text(
                        'Здесь можно посмотреть и изменить ваши данные.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.barlow(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    const SizedBox(height: 28),
                    if (_isEditing) ...[
                      UserProfileForm(
                        nameController: _nameController,
                        heightController: _heightController,
                        weightController: _weightController,
                        selectedGender: _selectedGender,
                        onGenderSelected: (gender) {
                          setState(() {
                            _selectedGender = gender;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 220,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isFormValid && !_isSaving
                              ? _saveProfile
                              : null,
                          child: Text(_isSaving ? 'Сохранение...' : 'Сохранить'),
                        ),
                      ),
                      if (_profile.isComplete) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _isSaving ? null : _cancelEditing,
                          child: Text(
                            'Отмена',
                            style: GoogleFonts.barlow(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ] else ...[
                      _ProfileInfoCard(
                        gender: _profile.gender?.label ?? 'Не указано',
                        height: _formatMetric(_profile.heightCm, 'см'),
                        weight: _formatMetric(_profile.weightKg, 'кг'),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 220,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _startEditing,
                          child: const Text('Редактировать'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 265,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: Text(
                          'Выйти из аккаунта',
                          style: GoogleFonts.barlow(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: elevatedButtonForegroundColor,
                          side: BorderSide(
                            color: elevatedButtonForegroundColor,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 225, 216, 195),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Row(
            children: [
              _buildTab(Icons.home, 'Домой', false, onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                );
              }),
              const Spacer(),
              _buildTab(Icons.view_list, 'Тренировки', false, onTap: () {}),
              const Spacer(),
              _buildFloatingButton(context),
              const Spacer(),
              _buildTab(Icons.bar_chart, 'Прогресс', false, onTap: () {}),
              const Spacer(),
              _buildTab(Icons.person, 'Профиль', true, onTap: null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
    IconData icon,
    String label,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    final color = isActive ? elevatedButtonBackgroundColor : Colors.grey[700];
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.barlow(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('current_training');

          if (!context.mounted) {
            return;
          }

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CurrentWorkoutScreen(),
            ),
          );
        },
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                elevatedButtonBackgroundColor.withOpacity(0.9),
                elevatedButtonBackgroundColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: elevatedButtonBackgroundColor.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.fitness_center, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({
    required this.gender,
    required this.height,
    required this.weight,
  });

  final String gender;
  final String height;
  final String weight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.42),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: inputOutlineBorderColor, width: 2),
      ),
      child: Column(
        children: [
          _ProfileInfoRow(label: 'Пол', value: gender),
          const SizedBox(height: 16),
          _ProfileInfoRow(label: 'Рост', value: height),
          const SizedBox(height: 16),
          _ProfileInfoRow(label: 'Вес', value: weight),
        ],
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
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.barlow(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.barlow(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
