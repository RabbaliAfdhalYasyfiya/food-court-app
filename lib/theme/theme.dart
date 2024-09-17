import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  fontFamily: 'SF Pro Text',
  useMaterial3: true,
  dividerColor: Colors.black26,
  primaryColor: Colors.blueAccent.shade400,
  splashColor: Colors.blueAccent.shade400,
  indicatorColor: Colors.blueAccent.shade400,
  scaffoldBackgroundColor: Colors.white,
  canvasColor: Colors.grey.shade100,
  textTheme: const TextTheme(
    labelLarge: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.w600,
      fontSize: 17,
    ),
    labelSmall: TextStyle(
      color: Colors.black38,
      fontWeight: FontWeight.w400,
      fontSize: 15,
    ),
    titleLarge: TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.w500,
      height: 1.05,
    ),
    titleMedium: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w500,
      fontSize: 17,
    ),
    titleSmall: TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    displayMedium: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w500,
      fontSize: 17,
      height: 1,
    ),
    displaySmall: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w500,
      fontSize: 15,
    ),
    bodyMedium: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w400,
      fontSize: 17,
    ),
    bodySmall: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w300,
      fontSize: 14,
      height: 1.25,
    ),
    headlineLarge: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w500,
      fontSize: 18,
      height: 1,
    ),
    headlineMedium: TextStyle(
      color: Colors.black45,
      fontWeight: FontWeight.w500,
      fontSize: 15,
    ),
    headlineSmall: TextStyle(
      color: Colors.black45,
      fontWeight: FontWeight.w400,
      fontSize: 13,
      height: 1,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.blueAccent.shade400,
    elevation: 2,
    disabledElevation: 5,
  ),
  cardTheme: const CardTheme(
    margin: EdgeInsets.all(0),
    elevation: 3,
    shadowColor: Colors.black45,
    color: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    scrolledUnderElevation: 0,
    shadowColor: Colors.transparent,
    backgroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    elevation: 7,
    shadowColor: Colors.black,
    overlayColor: WidgetStatePropertyAll(Colors.blueAccent.shade400.withOpacity(0.25)),
    indicatorColor: Colors.blueAccent.shade400.withOpacity(0.15),
    labelTextStyle: const WidgetStatePropertyAll(
      TextStyle(
        color: Colors.black,
        fontSize: 13,
      ),
    ),
  ),
  colorScheme: ColorScheme.light(
    onPrimary: Colors.grey.shade200,
    onSecondary: Colors.grey.shade100,
    onTertiary: Colors.grey.shade50,
    outline: Colors.grey.shade300,
    primary: Colors.black,
    secondary: Colors.black45,
  ),
);

ThemeData darkMode = ThemeData(
  fontFamily: 'SF Pro Text',
  useMaterial3: true,
  dividerColor: Colors.white54,
  splashColor: Colors.grey.shade900,
  primaryColor: Colors.blueAccent.shade400,
  scaffoldBackgroundColor: Colors.grey.shade900,
  canvasColor: Colors.black45,
  textTheme: const TextTheme(
    labelLarge: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      color: Colors.white54,
      fontWeight: FontWeight.w600,
      fontSize: 17,
    ),
    labelSmall: TextStyle(
      color: Colors.white38,
      fontWeight: FontWeight.w400,
      fontSize: 15,
    ),
    titleLarge: TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.w500,
      height: 1.05,
    ),
    titleMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
      fontSize: 17,
    ),
    titleSmall: TextStyle(
      color: Colors.white54,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    displayMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
      fontSize: 17,
      height: 1,
    ),
    displaySmall: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
      fontSize: 15,
    ),
    bodyMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w400,
      fontSize: 17,
    ),
    bodySmall: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w300,
      fontSize: 14,
      height: 1.25,
    ),
    headlineLarge: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
      fontSize: 18,
      height: 1,
    ),
    headlineMedium: TextStyle(
      color: Colors.white54,
      fontWeight: FontWeight.w500,
      fontSize: 15,
    ),
    headlineSmall: TextStyle(
      color: Colors.white54,
      fontWeight: FontWeight.w400,
      fontSize: 13,
      height: 1,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.blueAccent.shade400,
    elevation: 2,
    disabledElevation: 5,
  ),
  cardTheme: CardTheme(
    margin: const EdgeInsets.all(0),
    elevation: 3,
    shadowColor: Colors.black45,
    color: Colors.grey.shade900,
  ),
  appBarTheme: AppBarTheme(
    scrolledUnderElevation: 0,
    shadowColor: Colors.transparent,
    backgroundColor: Colors.grey.shade900,
    elevation: 0,
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.grey.shade900,
    elevation: 7,
    shadowColor: Colors.white,
    overlayColor: WidgetStatePropertyAll(Colors.blueAccent.shade400.withOpacity(0.25)),
    indicatorColor: Colors.blueAccent.shade400.withOpacity(0.15),
    labelTextStyle: const WidgetStatePropertyAll(
      TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
    ),
  ),
  colorScheme: ColorScheme.dark(
    onPrimary: Colors.grey.shade700,
    onSecondary: Colors.grey.shade600,
    onTertiary: Colors.grey.shade500,
    outline: Colors.grey.shade700,
    primary: Colors.white,
    secondary: Colors.white54,
  ),
);
