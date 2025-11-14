import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/start_page.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: StartPage());
  }
}

class MainAppTopBar extends StatelessWidget {
  const MainAppTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "G R I N D  NN E",
          style: GoogleFonts.lato(),
          textAlign: TextAlign.center,
        ),
      ),
      //body: const StartPage(),
    );
  }
}
