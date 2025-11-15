import 'package:dp/theme/theme.dart';
import 'package:flutter/material.dart';
import 'pages/start_page.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: StartPage(), theme: mainTheme);
  }
}
