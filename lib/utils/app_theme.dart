import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF7DD3FC);
  static const Color secondary = Color(0xFF60A5FA);
  static const Color bg = Color(0xFF0B142B);
  static const Color ink = Color(0xFFF0F7FF);
  static const Color muted = Color(0xFFB5C7E3);

  static const Color surface = Color(0xFF142544);
  static const Color border = Color(0xFF334F78);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        secondary: secondary,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle:
            TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ink),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: bg,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF334F78)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: surface,
        shadowColor: const Color(0x24091C42),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF334F78)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        indicatorColor: primary.withValues(alpha: .12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500)),
      ),
    );
  }
}

