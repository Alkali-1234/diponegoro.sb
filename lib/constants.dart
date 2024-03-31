import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: const Color.fromRGBO(0, 0, 0, 0.25),
    secondary: const Color.fromRGBO(255, 255, 255, 0.125),
    tertiary: const Color.fromRGBO(255, 255, 255, 0.25),
    primaryContainer: const Color.fromRGBO(255, 255, 255, 0.07),
    onPrimary: const Color.fromRGBO(255, 255, 255, 1),
    onSecondary: const Color.fromRGBO(255, 255, 255, 1),
    background: const Color.fromRGBO(30, 30, 30, 1.0),
    error: Colors.red,
  ),
  textTheme: GoogleFonts.montserratTextTheme(const TextTheme(
    displayLarge: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1.0),
      fontSize: 40,
      fontWeight: FontWeight.bold,
      letterSpacing: -1.5,
    ),
    displayMedium: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1.0),
      fontSize: 24,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1.0),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
  )),
  useMaterial3: true,
);
