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
                padding: EdgeInsets.only(top: 5, bottom: 20),
                child: Text(
                  "G R I N D S T O N E",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.barlow(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
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
                // child: Container(
                //   width: 288,
                //   height: 56,
                //   decoration: BoxDecoration(
                //     color: buttonInnerColor,
                //     border: Border.all(
                //       color: buttonOutlineBorderColor,
                //       width: 2,
                //     ),
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: TextField(
                //     controller: emailController,
                //     decoration: InputDecoration(
                //       labelText: 'Почта',
                //       helperStyle: GoogleFonts.barlow(
                //         fontWeight: FontWeight.bold,
                //         fontSize: 15,
                //       ),
                //     ),
                //   ),
                // ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: LoginPageText(
                  text: 'Пароль',
                  controller: passwordController,
                  obscure: true,
                ),
                // child: Container(
                //   width: 288,
                //   height: 56,
                //   decoration: BoxDecoration(
                //     color: buttonInnerColor,
                //     border: Border.all(
                //       color: buttonOutlineBorderColor,
                //       width: 2,
                //     ),
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: TextField(
                //     controller: passwordController,
                //     decoration: InputDecoration(
                //       labelText: 'Пароль',
                //       helperStyle: GoogleFonts.barlow(
                //         fontWeight: FontWeight.bold,
                //         fontSize: 15,
                //       ),
                //     ),
                //     obscureText: true,
                //   ),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
