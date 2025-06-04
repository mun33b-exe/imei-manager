import 'package:flutter/material.dart';

class AppTheme {
  // Color palette based on your image
  static const primaryColor = Color(0xFF021024); // Dark navy blue
  static const secondaryColor = Color(0xFF052659); // Deep blue
  static const accentColor = Color(0xFF5DA0CA); // Medium blue
  static const lightBlue = Color(0xFF70A0CA); // Light blue
  static const surfaceColor = Color(0xFFC1EAFF); // Very light blue

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      tertiary: lightBlue,
      surface: surfaceColor,
      onSurface: primaryColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      surfaceContainerLowest: Color(0xFFF8FCFF),
      onSurfaceVariant: primaryColor,
      outline: Color(0xFF70A0CA),
    ),

    // AppBar theme for IMEI registration screens
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Input fields for IMEI numbers and user data
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: lightBlue.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      hintStyle: TextStyle(color: primaryColor.withOpacity(0.6), fontSize: 16),
      labelStyle: const TextStyle(
        color: primaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Cards for registration status, device info, etc.
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: lightBlue.withOpacity(0.2), width: 1),
      ),
    ),

    // Icons throughout the app
    iconTheme: const IconThemeData(color: primaryColor, size: 24),

    // Text styles for different content
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: primaryColor, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, color: primaryColor, height: 1.4),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        color: accentColor,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Primary buttons for registration actions
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: primaryColor.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Secondary buttons
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: accentColor, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Text buttons for minor actions
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // Bottom navigation bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: accentColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Progress indicators
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: accentColor,
      linearTrackColor: lightBlue,
    ),

    // Floating action button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
      elevation: 6,
    ),
  );
  // Dark theme for the app
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: accentColor,
      secondary: lightBlue,
      tertiary: surfaceColor,
      surface: Color(0xFF1A1A1A),
      onSurface: Colors.white,
      onPrimary: primaryColor,
      surfaceContainerLowest: Color(0xFF121212),
      onSurfaceVariant: Colors.white70,
      outline: lightBlue,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Input fields for dark theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: lightBlue.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Text styles for dark theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white, height: 1.4),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        color: accentColor,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Primary buttons for dark theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: accentColor.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Icons for dark theme
    iconTheme: const IconThemeData(color: Colors.white, size: 24),
  );
}
