import 'package:dp/buttons.dart';
import 'package:dp/textfields.dart';
import 'package:dp/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        child: SizedBox.expand(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0, bottom: 0),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 300,
                  width: 300,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 1, bottom: 20),
                child: Text(
                  "GRINDSTONE",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.barlow(
                    fontWeight: FontWeight.bold,
                    fontSize: 37,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30, bottom: 20),
                child: LoginPageText(
                  text: 'Почта',
                  controller: emailController,
                  obscure: false,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 30),
                child: LoginPageText(
                  text: 'Пароль',
                  controller: passwordController,
                  obscure: true,
                ),
              ),
              ElevatedButton(
                onPressed: () => UnimplementedError,
                style: ElevatedButton.styleFrom(
                  backgroundColor: loginButtonBackgroundColor,
                  foregroundColor: loginButtonForegroundColor,
                  fixedSize: Size(185, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: LoginPageButtonText(text: 'ВОЙТИ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
