import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    background: Colors.black87,
    primary: Colors.blueGrey.shade900,
    secondary: Colors.white,
    tertiary: Colors.grey[800],
    inversePrimary: Colors.blueGrey[700], 
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: Colors.blueGrey[700], // Custom drawer color
  ),
);
