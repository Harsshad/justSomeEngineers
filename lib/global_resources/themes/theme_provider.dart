
import 'package:codefusion/global_resources/themes/dark_mode.dart';
import 'package:codefusion/global_resources/themes/light_mode.dart';
import 'package:flutter/material.dart';


class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = darkMode;
  // ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  // void toggleTheme() {
  //   if (_themeData == lightMode) {
  //     themeData = darkMode;
  //   }else{
  //     themeData = lightMode;
  //   }
  // }

  void toggleTheme() {
    if (_themeData == darkMode) {
      themeData = lightMode;
    }else{
      themeData = darkMode;
    }
  }
}
