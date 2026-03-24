import 'package:dp/colors.dart';
import 'package:dp/models/user_profile.dart';
import 'package:dp/pages/login_page.dart';
import 'package:dp/pages/main_page.dart';
import 'package:dp/pages/user_info_page.dart';
import 'package:dp/services/auth_service.dart';
import 'package:dp/services/user_session_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final user = FirebaseAuth.instance.currentUser;
    final hasSession = user != null;
    UserProfileData? profile;

    if (hasSession) {
      try {
        profile = await AuthService.instance.fetchProfile(cache: true);
      } catch (_) {
        // ignore fetch errors; allow app to continue
      }
      await UserSessionStorage.setLoggedIn(true);
    } else {
      await UserSessionStorage.logout();
    }

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      if (!hasSession) {
        _nextPage = const LoginPage();
      } else if (profile == null || !profile.isComplete) {
        _nextPage = const UserInfoPage();
      } else {
        _nextPage = const MainPage();
      }
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
