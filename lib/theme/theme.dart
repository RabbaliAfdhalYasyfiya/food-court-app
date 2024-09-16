import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  fontFamily: 'SF Pro Text',
  useMaterial3: true,
  dividerColor: Colors.black26,
  primaryColor: Colors.black,
  splashColor: Colors.blueAccent.shade400,
  indicatorColor: Colors.blueAccent.shade400,
  colorScheme: ColorScheme.light(
    brightness: Brightness.light,
    surface: Colors.white,
    onSurface: Colors.grey.shade50,
    onPrimary: Colors.grey.shade200,
    primary: Colors.blueAccent.shade400,
    secondary: Colors.grey.shade100,
    error: Colors.red.shade400,
    primaryFixed: Colors.greenAccent.shade400,
    outline: Colors.black12,
  ),
);

ThemeData darkMode = ThemeData(
  fontFamily: 'SF Pro Text',
  useMaterial3: true,
  primaryColor: Colors.blueAccent.shade400,
  scaffoldBackgroundColor: Colors.black,
  brightness: Brightness.dark,
);
