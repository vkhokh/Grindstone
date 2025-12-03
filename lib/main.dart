import 'package:flutter/material.dart';
import 'package:dp/theme/theme.dart';
import 'pages/start_page.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grindstone',
      theme: mainTheme,
      home: StartPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}