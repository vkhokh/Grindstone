import 'package:dp/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final mainTheme = ThemeData(
  scaffoldBackgroundColor: backGroundColor,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(
        elevatedButtonBackgroundColor,
      ),
      foregroundColor: WidgetStateProperty.all<Color>(
        elevatedButtonForegroundColor,
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        GoogleFonts.barlow(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: elevatedButtonForegroundColor,
        ),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    helperStyle: GoogleFonts.barlow(fontWeight: FontWeight.bold, fontSize: 15),
    filled: true,
    fillColor: inputInnerColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 2, color: inputOutlineBorderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 4, color: inputOutlineBorderColor),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 2, color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 2, color: inputOutlineBorderColor),
    ),
    hintStyle: GoogleFonts.barlow(
      color: hintTextForegroundColor,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.barlow(fontWeight: FontWeight.bold, fontSize: 37),
  ),
);
