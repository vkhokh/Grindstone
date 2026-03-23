import 'package:dp/models/user_profile.dart';
import 'package:dp/pages/main_page.dart';
import 'package:dp/services/user_session_storage.dart';
import 'package:dp/widgets/user_profile_form.dart';
import 'package:flutter/material.dart';
import 'package:dp/colors.dart';

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

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _selectedGender != null &&
        _parseHeight() != null &&
        _parseWeight() != null;
  }

  Future<void> _saveProfile() async {
    if (!_validateForm()) return;

    final height = _parseHeight()!;
    final weight = _parseWeight()!;

    setState(() => _isSaving = true);

    await UserSessionStorage.saveProfile(
      UserProfileData(
        name: _nameController.text.trim(),
        gender: _selectedGender!,
        heightCm: height,
        weightKg: weight,
      ),
    );

    await UserSessionStorage.setLoggedIn(true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
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
              Image.asset(
                'assets/images/icon_user.png',
                height: 140,
              ),
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