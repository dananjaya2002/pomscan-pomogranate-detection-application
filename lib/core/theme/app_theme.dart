/// Central design system for PomeScan.
///
/// Uses a dark-green + pomegranate-red palette, Material 3.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppColors {
  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0A1A10);
  static const Color surface = Color(0xFF152A1C);
  static const Color surfaceVariant = Color(0xFF1C3826);
  static const Color cardBorder = Color(0xFF2A4D35);

  // ── Primary (deep green) ───────────────────────────────────────────────────
  static const Color primary = Color(0xFF2D6A4F);
  static const Color primaryLight = Color(0xFF40916C);
  static const Color primaryDark = Color(0xFF1B4332);

  // ── Accent (pomegranate red) ───────────────────────────────────────────────
  static const Color accent = Color(0xFFC0392B);
  static const Color accentLight = Color(0xFFE74C3C);
  static const Color accentMuted = Color(0xFF922B21);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color ripe = Color(0xFF4CAF50);
  static const Color semiRipe = Color(0xFFFF9800);
  static const Color unripe = Color(0xFFF44336);

  // ── Neutral ────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFECF0F1);
  static const Color textSecondary = Color(0xFF95A5A6);
  static const Color textMuted = Color(0xFF566573);
  static const Color divider = Color(0xFF1E3A28);

  // ── Info card accents ──────────────────────────────────────────────────────
  static const Color diseasesAccent = Color(0xFFC0392B);
  static const Color plantationAccent = Color(0xFF27AE60);
  static const Color harvestingAccent = Color(0xFFD4AC0D);
}

abstract final class AppDimens {
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 24.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double cardElevation = 0.0;
}

abstract final class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: AppDimens.cardElevation,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimens.radiusMedium),
          ),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          height: 1.5,
        ),
        bodySmall: TextStyle(color: AppColors.textMuted, fontSize: 11),
        labelLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.surfaceVariant,
        thumbColor: AppColors.primaryLight,
        overlayColor: Color(0x2040916C),
        valueIndicatorColor: AppColors.primary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.primaryLight
                  : AppColors.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.primaryDark
                  : AppColors.surfaceVariant,
        ),
      ),
    );
  }

  // ── Reusable gradient helpers ──────────────────────────────────────────────

  static BoxDecoration cardDecoration({Color? borderColor}) => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
    border: Border.all(color: borderColor ?? AppColors.cardBorder, width: 1),
  );

  static LinearGradient greenGradient = const LinearGradient(
    colors: [AppColors.primaryDark, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient redGradient = const LinearGradient(
    colors: [AppColors.accentMuted, AppColors.accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
