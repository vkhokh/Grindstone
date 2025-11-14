import 'package:flutter/material.dart';
import 'package:dp/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPageButton extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final bool obscure;
  const LoginPageButton({
    super.key,
    required this.text,
    required this.controller,
    required this.obscure,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288,
      height: 56,
      decoration: BoxDecoration(
        color: buttonInnerColor,
        border: Border.all(color: buttonOutlineBorderColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: text,
          helperStyle: GoogleFonts.barlow(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        obscureText: obscure,
      ),
    );
  }
}
