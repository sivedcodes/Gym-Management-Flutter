import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COLOR PALETTE
// Total Fit Gym 2026 dark athletic theme:
// near-black surfaces · electric yellow primary · Sora + Inter type.
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppColors {
  static const black = Color(0xFF08080A);
  static const surface = Color(0xFF101014);
  static const card = Color(0xFF16161C);
  static const cardHi = Color(0xFF1D1D24);
  static const yellow = Color(0xFFFFC400);
  static const yellowSoft = Color(0xFFFFD54D);
  static const white = Color(0xFFF6F6F8);
  static const grey = Color(0xFF9CA0AE);
  static const faint = Color(0xFF5C606E);
  static const line = Color(0x1FFFFFFF); // white 12 %
  static const green = Color(0xFF34D399);
  static const red = Color(0xFFFF6B6B);
  static const blue = Color(0xFF60A5FA);
}

/// Backwards-compatible alias (legacy imports use AppThemeColors.*).
typedef AppThemeColors = AppColors;

// ─────────────────────────────────────────────────────────────────────────────
// BORDER RADIUS SCALE
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppRadius {
  static const double s = 12;
  static const double m = 16;
  static const double l = 20;
  static const double xl = 28;
}

// ─────────────────────────────────────────────────────────────────────────────
// MATERIAL THEME
// All text-style decisions live in tokens.dart (AppText.*).
// This file only configures ThemeData — not duplicating style values.
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppTheme {
  // ── Colour shortcuts (kept for backward-compat; prefer AppColors.*) ──
  static const black = AppColors.black;
  static const surface = AppColors.surface;
  static const card = AppColors.card;
  static const yellow = AppColors.yellow;
  static const yellowDark = Color(0xFFE0A800);
  static const white = AppColors.white;
  static const grey = AppColors.grey;
  static const red = AppColors.red;
  static const green = AppColors.green;

  // ── Radius shortcuts (kept for backward-compat; prefer AppRadius.*) ──
  static const double radiusS = AppRadius.s;
  static const double radiusM = AppRadius.m;
  static const double radiusL = AppRadius.xl;

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final body = GoogleFonts.interTextTheme(base.textTheme);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.black,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.yellow,
        onPrimary: AppColors.black,
        secondary: AppColors.yellowSoft,
        onSecondary: AppColors.black,
        surface: AppColors.surface,
        onSurface: AppColors.white,
        error: AppColors.red,
        onError: AppColors.white,
      ),
      textTheme: body.copyWith(
        displayLarge: GoogleFonts.sora(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: AppColors.white,
        ),
        displayMedium: GoogleFonts.sora(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: AppColors.white,
        ),
        displaySmall: GoogleFonts.sora(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        headlineSmall: GoogleFonts.sora(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        titleLarge: GoogleFonts.sora(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        titleMedium: GoogleFonts.sora(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        titleSmall: GoogleFonts.sora(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        bodyLarge: GoogleFonts.inter(fontSize: 14, color: AppColors.white),
        bodyMedium: GoogleFonts.inter(fontSize: 13, color: AppColors.white),
        bodySmall: GoogleFonts.inter(fontSize: 12, color: AppColors.white),
        labelLarge: GoogleFonts.sora(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.sora(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: AppColors.yellow,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.l)),
          side: BorderSide(color: AppColors.line, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow,
          foregroundColor: AppColors.black,
          minimumSize: const Size(48, 56),
          textStyle: GoogleFonts.sora(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.m),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.yellow,
          side: const BorderSide(color: Color(0x66FFC400), width: 1.2),
          minimumSize: const Size(48, 56),
          textStyle: GoogleFonts.sora(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.m),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.yellow),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.faint, fontSize: 12),
        labelStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
        floatingLabelStyle: const TextStyle(
          color: AppColors.yellow,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        helperStyle: const TextStyle(color: AppColors.grey, fontSize: 11),
        prefixStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        suffixStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        iconColor: AppColors.grey,
        prefixIconColor: AppColors.grey,
        suffixIconColor: AppColors.grey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: BorderSide(color: AppColors.line.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: const BorderSide(color: AppColors.yellow, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.black,
        indicatorColor: const Color(0x33FFC400),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.cardHi,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.xl)),
          side: BorderSide(color: AppColors.line),
        ),
        titleTextStyle: GoogleFonts.sora(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.white,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
          side: BorderSide(color: AppColors.line),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardHi,
        contentTextStyle: const TextStyle(color: AppColors.white, fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          side: const BorderSide(color: AppColors.line),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    );
  }
}
