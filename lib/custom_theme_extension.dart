import 'package:flutter/material.dart';

extension CustomThemeData on ThemeData {
  TextStyle get expansionTileLeading => textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold) ?? TextStyle();
  TextStyle get expansionTileTitle => textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold) ?? TextStyle();
  TextStyle get listTileLeading => textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold) ?? TextStyle();
  TextStyle get listTileTitle => textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold) ?? TextStyle();
  TextStyle get listTileSubtitle => textTheme.bodySmall ?? TextStyle();
}
