import 'package:flutter/material.dart';

const Color primaryColor = Color(0xff1F205B);
const Color accentColor = Color(0xFFEBA3C8);
const Color backgroundColor = Color(0xdd021526);
const Color textColor = Color(0xFFFDFDFE);
const Color secondaryColor = Color(0xFF3C3D78);

extension CustomThemeData on ThemeData {
  TextStyle get expansionTileLeading =>
      textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold) ??
      const TextStyle();

  TextStyle get expansionTileTitle =>
      textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold) ??
      const TextStyle();

  TextStyle get listTileLeading =>
      textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold) ??
      const TextStyle();

  TextStyle get listTileTitle =>
      textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold) ??
      const TextStyle();

  TextStyle get listTileSubtitle => textTheme.bodySmall ?? const TextStyle();
}

ThemeData buildTheme() {
  return ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
      bodySmall: TextStyle(color: textColor),
      headlineLarge: TextStyle(color: textColor),
      headlineMedium: TextStyle(color: textColor),
      headlineSmall: TextStyle(color: textColor),
      labelSmall: TextStyle(color: Colors.grey),
    ),
    dialogBackgroundColor: backgroundColor,
    cardTheme: const CardTheme(
      color: secondaryColor,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: accentColor,
      textTheme: ButtonTextTheme.primary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      titleTextStyle: TextStyle(color: textColor, fontSize: 20),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor,
    ),
    cardColor: secondaryColor,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primaryColor,
      primaryContainer: backgroundColor,
      secondary: accentColor,
      secondaryContainer: secondaryColor,
      surface: backgroundColor,
      onPrimary: backgroundColor,
      onSecondary: textColor,
      onSurface: textColor,
    ),
  );
}
