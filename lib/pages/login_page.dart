import 'package:dp/colors.dart';
import 'package:dp/pages/main_page.dart';
import 'package:dp/pages/registration_page.dart';
import 'package:dp/pages/user_info_page.dart';
import 'package:dp/services/auth_service.dart';
import 'package:dp/services/user_session_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool _isSubmitting = false;

  String? emailError;
  String? passwordError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(value);
  }

  bool _validateForm() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    String? newEmailError;
    String? newPasswordError;

    if (email.isEmpty) {
      newEmailError = 'Введите почту';
    } else if (!_isValidEmail(email)) {
      newEmailError = 'Введите корректную почту';
    }

    if (password.isEmpty) {
      newPasswordError = 'Введите пароль';
    }

    setState(() {
      emailError = newEmailError;
      passwordError = newPasswordError;
    });

    return newEmailError == null && newPasswordError == null;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_validateForm()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      await AuthService.instance.signIn(email: email, password: password);

      try {
        await AuthService.instance.fetchProfile(cache: true);
      } catch (_) {
        // Не ломаем вход, если профиль временно не подтянулся.
      }

      final needsProfileSetup = await UserSessionStorage.needsProfileSetup();

      if (!mounted) return;

      final nextPage =
          needsProfileSetup ? const UserInfoPage() : const MainPage();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    } on FirebaseAuthException catch (e) {
      final message = _mapFirebaseError(e);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось выполнить вход. Повторите попытку.'),
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
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'Неверный e-mail или пароль';
      case 'invalid-email':
        return 'Некорректный e-mail';
      case 'user-disabled':
        return 'Аккаунт отключен';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      default:
        return 'Ошибка входа: ${e.code}';
    }
  }

  String _mapResetPasswordError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Некорректный e-mail';
      case 'user-not-found':
        return 'Пользователь с таким e-mail не найден';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      default:
        return 'Не удалось отправить письмо для сброса пароля';
    }
  }

Future<void> _showForgotPasswordDialog() async {
  final email = emailController.text.trim();

  final result = await showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (_) => ForgotPasswordDialog(initialEmail: email),
  );

  if (!mounted) return;

  if (result != null && result.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Письмо для сброса пароля отправлено на $result',
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFF5A623);
    const Color textPrimary = Color(0xFF111827);

    return Scaffold(
      backgroundColor: backGroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 340,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                    'Создавай тренировки\nи отслеживай прогресс',
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
                    textInputAction: TextInputAction.next,
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
                    textInputAction: TextInputAction.done,
                    onChanged: (_) {
                      if (passwordError != null) {
                        setState(() {
                          passwordError = null;
                        });
                      }
                    },
                    onSubmitted: (_) => _submit(),
                    suffixIcon: IconButton(
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
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
  onPressed: _isSubmitting ? null : _showForgotPasswordDialog,
  child: const Text(
    'Забыли пароль?',
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  ),
),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
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
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'Войти',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        const Text(
                          'Ещё нет аккаунта? ',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RegistrationPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Зарегистрироваться',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
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
    ValueChanged<String>? onSubmitted,
    TextInputAction? textInputAction,
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
            onSubmitted: onSubmitted,
            textInputAction: textInputAction,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: hintTextForegroundColor,
              ),
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
class ForgotPasswordDialog extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordDialog({
    super.key,
    required this.initialEmail,
  });

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  late final TextEditingController _emailController;
  bool _isSending = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(value);
  }

  String _mapResetPasswordError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Некорректный e-mail';
      case 'user-not-found':
        return 'Пользователь с таким e-mail не найден';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      default:
        return 'Не удалось отправить письмо для сброса пароля';
    }
  }

  Future<void> _submit() async {
    if (_isSending) return;

    final email = _emailController.text.trim();

    String? validationError;
    if (email.isEmpty) {
      validationError = 'Введите почту';
    } else if (!_isValidEmail(email)) {
      validationError = 'Введите корректную почту';
    }

    setState(() {
      _errorText = validationError;
    });

    if (validationError != null) return;

    setState(() {
      _isSending = true;
    });

    try {
      await AuthService.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      Navigator.of(context).pop(email);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = _mapResetPasswordError(e);
        _isSending = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Произошла ошибка. Повторите попытку';
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Сброс пароля',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Введите e-mail, и мы отправим письмо для восстановления пароля.',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Почта',
              errorText: _errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            onChanged: (_) {
              if (_errorText != null) {
                setState(() {
                  _errorText = null;
                });
              }
            },
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 8),
          const Text(
            'Проверьте папку "Спам", если письмо не пришло сразу.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSending
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isSending ? null : _submit,
          child: _isSending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Отправить'),
        ),
      ],
    );
  }
}