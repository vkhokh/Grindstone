import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isRegister = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 30.0, right: 30.0),
        child: SizedBox.expand(
          child: Column(
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
              Transform.translate(
                offset: Offset(0, -40),
                child: Padding(
                  padding: EdgeInsets.only(top: 5, bottom: 0),
                  child: Text(
                    "GRINDSTONE",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 30, bottom: 20),
                child: SizedBox(
                  width: 288,
                  height: 56,
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Почта'),
                    controller: emailController,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: SizedBox(
                  width: 288,
                  height: 56,
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Логин'),
                    controller: passwordController,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => UnimplementedError,
                style: ElevatedButton.styleFrom(fixedSize: Size(185, 60)),
                child: Text('ВОЙТИ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
