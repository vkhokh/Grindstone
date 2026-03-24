import 'package:dp/colors.dart';
import 'package:dp/pages/login_page.dart';
import 'package:dp/pages/main_page.dart';
import 'package:dp/services/user_session_storage.dart';
import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StatefulWidget> createState() => StartPageState();
}

class StartPageState extends State<StartPage> {
  double _opacity = 1.0;
  Widget? _nextPage;

  @override
  void initState() {
    super.initState();
    _prepareNavigation();
  }

  Future<void> _prepareNavigation() async {
    final isLoggedIn = await UserSessionStorage.isLoggedIn();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }

    setState(() {
      _nextPage = isLoggedIn ? const MainPage() : const LoginPage();
      _opacity = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 1000),
        onEnd: () {
          if (_opacity == 0.0 && _nextPage != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => _nextPage!),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          child: Image.asset(
            'assets/images/logo.png',
            height: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
