import 'package:dp/models/user_profile.dart';
import 'package:dp/pages/main_page.dart';
import 'package:dp/services/user_session_storage.dart';
import 'package:dp/widgets/user_profile_form.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_refreshState);
    _heightController.addListener(_refreshState);
    _weightController.addListener(_refreshState);
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

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _selectedGender != null &&
        _parseHeight() != null &&
        _parseWeight() != null;
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

  void _refreshState() {
    setState(() {});
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

    await UserSessionStorage.saveProfile(
      UserProfileData(
        name: _nameController.text.trim(),
        gender: _selectedGender,
        heightCm: height,
        weightKg: weight,
      ),
    );
    await UserSessionStorage.setLoggedIn(true);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/icon_user.png',
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 10),
              Text(
                'Расскажите о себе',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Эти данные появятся в профиле и их можно будет изменить позже.',
                textAlign: TextAlign.center,
                style: GoogleFonts.barlow(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
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
              const SizedBox(height: 32),
              SizedBox(
                width: 265,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isFormValid && !_isSaving ? _saveProfile : null,
                  child: Text(_isSaving ? 'Сохранение...' : 'Продолжить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
