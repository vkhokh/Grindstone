import 'package:dp/pages/main_page.dart';
import 'package:dp/pages/registration_page.dart';
import 'package:dp/services/user_session_storage.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
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
                padding: const EdgeInsets.only(top: 30, bottom: 20),
                child: SizedBox(
                  width: 288,
                  height: 56,
                  child: TextField(
                    decoration: const InputDecoration(hintText: 'Почта'),
                    controller: emailController,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: SizedBox(
                  width: 288,
                  height: 56,
                  child: TextField(
                    decoration: const InputDecoration(hintText: 'Пароль'),
                    controller: passwordController,
                    obscureText: true,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(fixedSize: const Size(185, 60)),
                child: const Text('ВОЙТИ'),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextButton(
                  onPressed: () {
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
                      color: Color.fromARGB(255, 101, 115, 126),
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.grey,
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
