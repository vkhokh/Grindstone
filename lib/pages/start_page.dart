import 'package:dp/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:dp/colors.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StatefulWidget> createState() => StartPageState();
}

class StartPageState extends State<StartPage> {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _opacity = 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 1000),
      child: Scaffold(
        backgroundColor: backGroundColor,
        body: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 50, vertical: 10),
          child: Image.asset(
            'assets/images/logo.png',
            height: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      ),
      onEnd: () {
        if (_opacity == 0.0) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      },
    );
  }
}
