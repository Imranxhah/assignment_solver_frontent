import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The [AppTheme] defines light and dark themes for the app.
abstract final class AppTheme {
  // The FlexColorScheme defined light mode ThemeData.
  static ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.shadOrange,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
      elevatedButtonRadius: 12.0,
      elevatedButtonSchemeColor: SchemeColor.primary,
      outlinedButtonRadius: 12.0,
      outlinedButtonSchemeColor: SchemeColor.primary,
      textButtonRadius: 12.0,
      cardRadius: 16.0,
      dialogRadius: 20.0,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    // ✅ FIXED: Using Poppins for BOTH light and dark mode
    fontFamily: GoogleFonts.poppins().fontFamily,
    // Enhanced text theme with Google Fonts
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
            fontSize: 57, fontWeight: FontWeight.w600, letterSpacing: -0.25),
        displayMedium: TextStyle(
            fontSize: 45, fontWeight: FontWeight.w600, letterSpacing: 0),
        displaySmall: TextStyle(
            fontSize: 36, fontWeight: FontWeight.w600, letterSpacing: 0),
        headlineLarge: TextStyle(
            fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: 0),
        headlineMedium: TextStyle(
            fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 0),
        headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0), // ✅ Reduced from 24 to 20
        titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0), // ✅ Reduced from 22 to 20
        titleMedium: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
        titleSmall: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        bodyLarge: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
        bodyMedium: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
        bodySmall: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
        labelLarge: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        labelMedium: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        labelSmall: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    ),
  );

  // The FlexColorScheme defined dark mode ThemeData.
  static ThemeData dark = FlexThemeData.dark(
    scheme: FlexScheme.shadOrange,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
      elevatedButtonRadius: 12.0,
      elevatedButtonSchemeColor: SchemeColor.primary,
      outlinedButtonRadius: 12.0,
      outlinedButtonSchemeColor: SchemeColor.primary,
      textButtonRadius: 12.0,
      cardRadius: 16.0,
      dialogRadius: 20.0,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    // ✅ FIXED: Using Poppins consistently
    fontFamily: GoogleFonts.poppins().fontFamily,
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
            fontSize: 57, fontWeight: FontWeight.w600, letterSpacing: -0.25),
        displayMedium: TextStyle(
            fontSize: 45, fontWeight: FontWeight.w600, letterSpacing: 0),
        displaySmall: TextStyle(
            fontSize: 36, fontWeight: FontWeight.w600, letterSpacing: 0),
        headlineLarge: TextStyle(
            fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: 0),
        headlineMedium: TextStyle(
            fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 0),
        headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0), // ✅ Reduced from 24 to 20
        titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0), // ✅ Reduced from 22 to 20
        titleMedium: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
        titleSmall: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        bodyLarge: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
        bodyMedium: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
        bodySmall: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
        labelLarge: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        labelMedium: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        labelSmall: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    ),
  );

  // Custom color constants for direct use
  static const Color primaryColor = Color(0xFFE65100);
  static const Color secondaryColor = Color(0xFFFF6F00);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);
  static const Color warningColor = Color(0xFFFB8C00);
}
