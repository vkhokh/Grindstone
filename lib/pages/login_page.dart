<<<<<<< HEAD
<<<<<<< HEAD
import 'package:dp/pages/main_page.dart';
=======
import 'package:dp/pages/create_menu.dart';
>>>>>>> 501f3efad1c0acb174a65ceb780141ade399a91d
=======
import 'package:dp/colors.dart';
import 'package:dp/pages/main_page.dart';
import 'package:dp/pages/registration_page.dart';
>>>>>>> f47928e7bc282a3de350f7946ac0373929267a4a
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
    } else if (password.length < 6) {
      newPasswordError = 'Пароль должен быть не короче 6 символов';
    }

    setState(() {
      emailError = newEmailError;
      passwordError = newPasswordError;
    });

    return newEmailError == null && newPasswordError == null;
  }

  void _submit() {
    if (!_validateForm()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MainPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFF5A623);
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
<<<<<<< HEAD
              ),
              ElevatedButton(
                onPressed: () {
<<<<<<< HEAD
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                  );
=======
                  Navigator.push(context, MaterialPageRoute(builder:(context) => const TrainingScreen(),
                  ));
>>>>>>> 501f3efad1c0acb174a65ceb780141ade399a91d
                },
                style: ElevatedButton.styleFrom(fixedSize: Size(185, 60)),
                child: Text('ВОЙТИ'),
              ),
            ],
=======
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
                  onChanged: (_) {
                    if (passwordError != null) {
                      setState(() {
                        passwordError = null;
                      });
                    }
                  },
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
                const SizedBox(height: 24),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'ВОЙТИ',
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
                              builder: (context) => const RegistrationPage(),
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
>>>>>>> f47928e7bc282a3de350f7946ac0373929267a4a
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
