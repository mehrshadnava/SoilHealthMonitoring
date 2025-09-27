import 'package:flutter/material.dart';
// Remove this line: import 'colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.green,
    primaryColor: Colors.green[700],
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      color: Colors.green[700],
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.green,
    primaryColor: Colors.green[700],
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      color: Colors.green[700],
      elevation: 0,
    ),
  );
}