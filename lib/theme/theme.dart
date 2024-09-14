import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  fontFamily: 'SF Pro Text',
  useMaterial3: true,
  primaryColor: Colors.blueAccent.shade400,

  scaffoldBackgroundColor: Colors.white,
  brightness: Brightness.light,
  dividerTheme: const DividerThemeData(
    color: Colors.black54,
  ),
  
  colorScheme: ColorScheme.light(
    primary: const Color.fromARGB(255, 9, 14, 21),
    onPrimary: Colors.blueAccent.shade700,
    secondary: Colors.blueAccent,
    onSecondary: Colors.blueAccent.shade100,
    error: Colors.red.shade600,
    onError: Colors.redAccent,
    surface: Colors.white,
    onSurface: Colors.black87,
  ),
);


ThemeData darkMode = ThemeData(
  fontFamily: 'SF Pro Text',
  useMaterial3: true,
  primaryColor: Colors.blueAccent.shade400,
  scaffoldBackgroundColor: Colors.black,
  brightness: Brightness.dark,
);
