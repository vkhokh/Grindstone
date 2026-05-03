import 'package:dp/colors.dart';
import 'package:dp/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dp/pages/email_verification_page.dart';
import 'package:dp/utils/input_limits.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool _isSubmitting = false;

  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(value);
  }

  bool _validateForm() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    String? newEmailError;
    String? newPasswordError;
    String? newConfirmPasswordError;

    if (email.isEmpty) {
      newEmailError = 'Введите почту';
    } else if (!_isValidEmail(email)) {
      newEmailError = 'Введите корректную почту';
    }

    if (password.isEmpty) {
      newPasswordError = 'Введите пароль';
    } else if (password.length < 6) {
      newPasswordError = 'Пароль должен быть не короче 6 символов';
    }

    if (confirmPassword.isEmpty) {
      newConfirmPasswordError = 'Повторите пароль';
    } else if (password != confirmPassword) {
      newConfirmPasswordError = 'Пароли не совпадают';
    }

    setState(() {
      emailError = newEmailError;
      passwordError = newPasswordError;
      confirmPasswordError = newConfirmPasswordError;
    });

    return newEmailError == null &&
        newPasswordError == null &&
        newConfirmPasswordError == null;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_validateForm()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      await AuthService.instance.signUp(email: email, password: password);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EmailVerificationPage()),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Registration error: ${e.code} ${e.message}');
      final message = _mapFirebaseError(e);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      debugPrint('Registration error (unknown): $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось создать аккаунт. Попробуйте снова.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Этот e-mail уже используется';
      case 'invalid-email':
        return 'Некорректный e-mail';
      case 'weak-password':
        return 'Пароль слишком простой';
      default:
        return e.message != null && e.message!.trim().isNotEmpty
            ? 'Ошибка регистрации: ${e.message}'
            : 'Ошибка регистрации: ${e.code}';
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color textPrimary = Color(0xFF111827);

    return Scaffold(
      backgroundColor: backGroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset('assets/images/logo.png', height: 340),
                ),
                const SizedBox(height: 0),
                const Text(
                  'GRINDSTONE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Создай аккаунт и начни\nотслеживать свои тренировки',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 32),
                _buildInputField(
                  controller: emailController,
                  hintText: 'Почта',
                  keyboardType: TextInputType.emailAddress,
                  errorText: emailError,
                  maxLength: AppInputLimits.email,
                  onChanged: (_) {
                    if (emailError != null) {
                      setState(() {
                        emailError = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  controller: passwordController,
                  hintText: 'Пароль',
                  obscureText: obscurePassword,
                  errorText: passwordError,
                  maxLength: AppInputLimits.password,
                  onChanged: (_) {
                    if (passwordError != null) {
                      setState(() {
                        passwordError = null;
                      });
                    }
                  },
                  suffixIcon: IconButton(
                    splashRadius: 20,
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: hintTextForegroundColor,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  controller: confirmPasswordController,
                  hintText: 'Повторите пароль',
                  obscureText: obscureConfirmPassword,
                  errorText: confirmPasswordError,
                  maxLength: AppInputLimits.password,
                  onChanged: (_) {
                    if (confirmPasswordError != null) {
                      setState(() {
                        confirmPasswordError = null;
                      });
                    }
                  },
                  suffixIcon: IconButton(
                    splashRadius: 20,
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: hintTextForegroundColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: elevatedButtonBackgroundColor,
                      foregroundColor: elevatedButtonForegroundColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Зарегистрироваться',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Уже есть аккаунт? Войти',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? errorText,
    ValueChanged<String>? onChanged,
    int? maxLength,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: inputInnerColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError ? Colors.red : inputOutlineBorderColor,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            maxLength: maxLength,
            buildCounter: hiddenMaxLengthCounter,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: hintTextForegroundColor),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
