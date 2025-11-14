import 'package:dp/colors.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // final TextEditingController nameController = TextEditingController();

  bool isRegister = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      body: Padding(
        padding: EdgeInsets.only(left: 30.0, right: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 50),
              child: Image.asset(
                'assets/images/logo.png',
                height: 200,
                width: 200,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 20),
              child: Text("G R I N D S T O N E", textAlign: TextAlign.center),
            ),
            Container(
              width: 288,
              height: 56,
              decoration: BoxDecoration(
                color: buttonInnerColor,
                border: Border.all(color: buttonOutlineBorderColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Почта'),
              ),
            ),
            Container(
              width: 288,
              height: 56,
              decoration: BoxDecoration(
                color: buttonInnerColor,
                border: Border.all(color: buttonOutlineBorderColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Пароль'),
                obscureText: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
