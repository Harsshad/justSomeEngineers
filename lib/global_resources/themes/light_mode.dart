import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    background: const Color(0xFFDFD7C2),
    surface: const Color(0xFFDFD7C2),
    primary: const Color(0xFFF7DB4C),
    secondary: const Color(0xFF2A2824),
    tertiary: Colors.black,
    inversePrimary: Colors.grey[200],
  ),
   drawerTheme: const DrawerThemeData(
    backgroundColor: Color.fromARGB(255, 240, 217, 104), // Custom drawer color
  ),
);
