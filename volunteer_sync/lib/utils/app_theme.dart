import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color primaryLightColor = Color(0xFF80E27E);
  static const Color primaryDarkColor = Color(0xFF087F23);
  
  // Secondary colors
  static const Color secondaryColor = Color(0xFF2196F3);
  static const Color secondaryLightColor = Color(0xFF6EC6FF);
  static const Color secondaryDarkColor = Color(0xFF0069C0);
  
  // Background colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  
  // Text colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  
  // Error colors
  static const Color errorColor = Color(0xFFD32F2F);
  
  // Other UI colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Event category colors
  static const Color environmentalColor = Color(0xFF4CAF50);
  static const Color humanitarianColor = Color(0xFFE91E63);
  static const Color educationalColor = Color(0xFF2196F3);
  static const Color animalWelfareColor = Color(0xFFFF9800);
  static const Color communityServiceColor = Color(0xFFFFEB3B);
  static const Color healthcareSupportColor = Color(0xFF9C27B0);
  static const Color disasterReliefColor = Color(0xFFF44336);
  static const Color artsAndCultureColor = Color(0xFF3F51B5);
  static const Color sportsAndRecreationColor = Color(0xFF009688);
  static const Color technologyColor = Color(0xFF607D8B);
  
  // Theme data
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      primaryColorLight: primaryLightColor,
      primaryColorDark: primaryDarkColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        color: primaryColor,
        elevation: 0,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimaryColor),
        displayMedium: TextStyle(color: textPrimaryColor),
        displaySmall: TextStyle(color: textPrimaryColor),
        headlineMedium: TextStyle(color: textPrimaryColor),
        headlineSmall: TextStyle(color: textPrimaryColor),
        titleLarge: TextStyle(color: textPrimaryColor),
        bodyLarge: TextStyle(color: textPrimaryColor),
        bodyMedium: TextStyle(color: textPrimaryColor),
        bodySmall: TextStyle(color: textSecondaryColor),
      ),
    );
  }
}
