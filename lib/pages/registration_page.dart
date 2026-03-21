import 'package:dp/pages/user_info_page.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final double fieldWidth = 320;
  final double fieldHeight = 56;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 0),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 300,
                  width: 300,
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 0),
                  child: Text(
                    'GRINDSTONE',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: SizedBox(
                  width: fieldWidth,
                  height: fieldHeight,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Почта',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 13,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    controller: emailController,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 20),
                child: SizedBox(
                  width: fieldWidth,
                  height: fieldHeight,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Пароль',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 13,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    controller: passwordController,
                    obscureText: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 30),
                child: SizedBox(
                  width: fieldWidth,
                  height: fieldHeight,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Повторите пароль',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 13,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    controller: confirmPasswordController,
                    obscureText: true,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserInfoPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(fixedSize: const Size(265, 60)),
                child: const Text(
                  'Зарегистрироваться',
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
