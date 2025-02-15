import 'package:flutter/material.dart';

class AppTheme {
  static bool isDarkMode = false;

  // Couleurs communes
  static const primaryGreen = Color(0xFF2E7D32);
  static const secondaryGreen = Color(0xFF4CAF50);
  static const errorRed = Color(0xFFD32F2F);
  static const warningOrange = Color(0xFFF57C00);
  static const successGreen = Color(0xFF388E3C);

  // Thème clair
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    dividerColor: Colors.grey[200],
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: secondaryGreen,
      error: errorRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.black87, fontSize: 28, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.black87, fontSize: 14),
      labelLarge: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    ),
  );

  // Thème sombre
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    dividerColor: Colors.white24,
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: secondaryGreen,
      error: errorRed,
      surface: Color(0xFF1E1E1E),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
      labelLarge: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    ),
  );

  // Styles spécifiques pour le ProfilePage
  static BoxDecoration getProfileHeaderDecoration(bool isDarkMode) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [
                Colors.green.shade900,
                Colors.green.shade800,
                Colors.green.shade700,
              ]
            : [
                Colors.green.shade900,
                Colors.green.shade700,
                Colors.green.shade500,
              ],
      ),
    );
  }

  static BoxDecoration getCardDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
          spreadRadius: isDarkMode ? 1 : 2,
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration getStatsItemDecoration(Color color, bool isDarkMode) {
    return BoxDecoration(
      color: color.withOpacity(isDarkMode ? 0.15 : 0.1),
      borderRadius: BorderRadius.circular(12),
    );
  }

  static TextStyle getStatValueStyle(Color color) {
    return TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static TextStyle getStatLabelStyle(bool isDarkMode) {
    return TextStyle(
      color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    );
  }

  static Color getDividerColor(bool isDarkMode) {
    return isDarkMode ? Colors.white12 : Colors.grey.shade200;
  }

  static Color getIconBackgroundColor(Color baseColor, bool isDarkMode) {
    return isDarkMode 
        ? baseColor.withOpacity(0.15) 
        : baseColor.withOpacity(0.1);
  }
}