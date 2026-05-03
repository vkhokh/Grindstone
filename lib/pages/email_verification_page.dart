import 'package:dp/colors.dart';
import 'package:dp/pages/login_page.dart';
import 'package:dp/pages/main_page.dart';
import 'package:dp/pages/user_info_page.dart';
import 'package:dp/services/auth_service.dart';
import 'package:dp/services/user_session_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage>
    with WidgetsBindingObserver {
  bool _isChecking = false;
  bool _isSending = false;

  String get _email =>
      FirebaseAuth.instance.currentUser?.email?.trim() ?? 'вашу почту';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkVerificationStatus(showPendingMessage: false);
    }
  }

  Future<void> _checkVerificationStatus({
    bool showPendingMessage = true,
  }) async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    try {
      final isVerified = await AuthService.instance
          .isCurrentUserEmailVerified();
      if (!mounted) return;

      if (!isVerified) {
        if (showPendingMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Почта пока не подтверждена. Проверьте письмо.'),
            ),
          );
        }
        return;
      }

      final needsProfileSetup = await AuthService.instance
          .resolveNeedsProfileSetup();
      await UserSessionStorage.setLoggedIn(true);

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              needsProfileSetup ? const UserInfoPage() : const MainPage(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final message = switch (e.code) {
        'user-not-found' => 'Сессия истекла. Войдите снова.',
        _ => 'Не удалось проверить подтверждение почты. Попробуйте ещё раз.',
      };

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      if (e.code == 'user-not-found') {
        await _goToLogin();
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      await AuthService.instance.sendCurrentUserEmailVerification();
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Письмо отправлено на $_email')));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final message = switch (e.code) {
        'too-many-requests' =>
          'Слишком много попыток. Попробуйте отправить письмо позже.',
        'user-not-found' => 'Сессия истекла. Войдите снова.',
        _ => 'Не удалось отправить письмо. Попробуйте ещё раз.',
      };

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      if (e.code == 'user-not-found') {
        await _goToLogin();
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _goToLogin() async {
    await AuthService.instance.signOut();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset('assets/images/logo.png', height: 260),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Подтвердите почту',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Мы отправили письмо на $_email. '
                    'Откройте ссылку из письма, затем вернитесь сюда.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.45,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Что делать дальше',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '1. Откройте письмо от Firebase Auth.\n'
                          '2. Нажмите на ссылку подтверждения.\n'
                          '3. Вернитесь в приложение и нажмите "Я подтвердил почту".',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isChecking ? null : _checkVerificationStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: elevatedButtonBackgroundColor,
                        foregroundColor: elevatedButtonForegroundColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isChecking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Я подтвердил почту',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 54,
                    child: OutlinedButton(
                      onPressed: _isSending ? null : _resendVerificationEmail,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF111827),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Отправить письмо ещё раз',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: _goToLogin,
                    child: const Text(
                      'Выйти в экран входа',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
