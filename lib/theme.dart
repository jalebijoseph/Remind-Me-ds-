import 'package:flutter/material.dart';

/// Shared light color scheme
const ColorScheme _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFFB8E0FF),
  onPrimary: Colors.black,
  secondary: Color(0xFFFFD6E8),
  onSecondary: Colors.black,
  tertiary: Color(0xFFC8F7DC),
  onTertiary: Colors.black,
  error: Color(0xFFB3261E),
  onError: Colors.white,
  background: Color(0xFFFFFBFE),
  onBackground: Colors.black,
  surface: Color(0xFFFFFBFE),
  onSurface: Colors.black,
  surfaceVariant: Color(0xFFE7E0EC),
  onSurfaceVariant: Color(0xFF49454F),
  outline: Color(0xFF79747E),
  shadow: Colors.black,
  inverseSurface: Color(0xFF313033),
  onInverseSurface: Colors.white,
  inversePrimary: Color(0xFF4F5FB8),
);

/// Shared dark color scheme
const ColorScheme _darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF6FA8FF),
  onPrimary: Colors.black,
  secondary: Color(0xFFFF8FC4),
  onSecondary: Colors.black,
  tertiary: Color(0xFF7BE0B8),
  onTertiary: Colors.black,
  error: Color(0xFFF2B8B5),
  onError: Colors.black,
  background: Color(0xFF101018),
  onBackground: Colors.white,
  surface: Color(0xFF101018),
  onSurface: Colors.white,
  surfaceVariant: Color(0xFF49454F),
  onSurfaceVariant: Color(0xFFE6E0E9),
  outline: Color(0xFF938F99),
  shadow: Colors.black,
  inverseSurface: Color(0xFFE6E0E9),
  onInverseSurface: Colors.black,
  inversePrimary: Color(0xFFB8C3FF),
);

final ThemeData lightPastelTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFFFFBFE),
  colorScheme: _lightColorScheme,
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
    bodyMedium: TextStyle(fontSize: 16),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFB8E0FF),
    foregroundColor: Colors.black,
    elevation: 0,
    centerTitle: false,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFFFD6E8),
    foregroundColor: Colors.black,
  ),
);

final ThemeData darkPastelTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF101018),
  colorScheme: _darkColorScheme,
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
    bodyMedium: TextStyle(fontSize: 16),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1C2333),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFFF8FC4),
    foregroundColor: Colors.black,
  ),
);
