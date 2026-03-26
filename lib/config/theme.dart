import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════════

class AppSpacing {
  const AppSpacing._();

  static const double xs = 2;
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 20;
  static const double xxxl = 24;
  static const double section = 28;
  static const double hero = 36;
}

class AppRadius {
  const AppRadius._();

  static const double xs = 3;
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 10;
  static const double xl = 12;
  static const double xxl = 16;
  static const double chip = 8;
  static const double card = 12;
  static const double panel = 16;

  static BorderRadius circular(double radius) => BorderRadius.circular(radius);
}

class AppOpacity {
  const AppOpacity._();

  static const double disabled = 0.3;
  static const double subtle = 0.04;
  static const double faded = 0.12;
  static const double muted = 0.25;
  static const double tint = 0.1;
  static const double overlay = 0.08;
  static const double hover = 0.15;
  static const double half = 0.5;
}

class AppBreakpoints {
  const AppBreakpoints._();

  static const double compact = 480;
  static const double medium = 700;
  static const double expanded = 800;
}

class AppDimensions {
  const AppDimensions._();

  static const double maxContentWidth = 1200;
  static const double sidebarWidth = 220;
  static const double chartHeight = 220;
  static const double comparisonChartHeight = 200;
  static const double sliderThumbRadius = 8;
  static const double sliderTrackHeight = 4;
  static const double barHeight = 22;
  static const double progressBarHeight = 6;
}

// ═══════════════════════════════════════════════════════════════════
// COLORS
// ═══════════════════════════════════════════════════════════════════

class AppColors {
  const AppColors._();

  // Primary
  static const accent = Color(0xFF0066FF);
  static const accentLight = Color(0xFFE6F0FF);

  // ETF indicator
  static const etf = Color(0xFFFF6B35);
  static const etfLight = Color(0xFFFFF3ED);

  // Surfaces
  static const card = Color(0xFFF7F8FA);
  static const border = Color(0xFFE5E7EB);
  static const bg = Color(0xFFFFFFFF);

  // Text
  static const text = Color(0xFF1A1A2E);
  static const label = Color(0xFF4A4A6A);
  static const muted = Color(0xFF8B8BA7);
  static const gray = Color(0xFF6B7280);

  // Semantic
  static const success = Color(0xFF10B981);
  static const successBg = Color(0xFFECFDF5);
  static const successBorder = Color(0xFFA7F3D0);
  static const successText = Color(0xFF065F46);
  static const successTextLight = Color(0xFF047857);
  static const danger = Color(0xFFEF4444);
  static const dangerBg = Color(0xFFFEF2F2);
  static const dangerBorder = Color(0xFFFECACA);
  static const dangerText = Color(0xFF991B1B);
  static const dangerTextLight = Color(0xFFB91C1C);

  // Warning
  static const warnBg = Color(0xFFFFFBEB);
  static const warnBorder = Color(0xFFFDE68A);
  static const warnText = Color(0xFF92400E);
}

// ═══════════════════════════════════════════════════════════════════
// PADDING PRESETS
// ═══════════════════════════════════════════════════════════════════

class AppPadding {
  const AppPadding._();

  static const page = EdgeInsets.symmetric(horizontal: AppSpacing.xl);
  static const card = EdgeInsets.all(14.0);
  static const panel = EdgeInsets.all(20.0);
  static const section = EdgeInsets.symmetric(vertical: AppSpacing.xxxl);
  static const chip = EdgeInsets.symmetric(horizontal: 12, vertical: 7);
  static const button = EdgeInsets.symmetric(horizontal: 20, vertical: 12);
  static const buttonSm = EdgeInsets.symmetric(horizontal: 16, vertical: 10);
}

// ═══════════════════════════════════════════════════════════════════
// THEME
// ═══════════════════════════════════════════════════════════════════

class AppTheme {
  const AppTheme._();

  static ThemeData get theme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.dmSans(
          fontSize: 30, fontWeight: FontWeight.w800,
          color: AppColors.text, letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.dmSans(
          fontSize: 22, fontWeight: FontWeight.w800,
          color: AppColors.text,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w700,
          color: AppColors.label,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16, color: AppColors.text,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 15, color: AppColors.label,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 14, color: AppColors.muted,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 15, fontWeight: FontWeight.w600,
          color: AppColors.label, letterSpacing: 0.3,
        ),
        labelSmall: GoogleFonts.dmMono(
          fontSize: 13, fontWeight: FontWeight.w500,
          color: AppColors.muted,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          padding: AppPadding.button,
          textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          padding: AppPadding.buttonSm,
          textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.accent,
        overlayColor: AppColors.accent.withValues(alpha: AppOpacity.tint),
        trackHeight: AppDimensions.sliderTrackHeight,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: AppDimensions.sliderThumbRadius,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );
  }

  // ─── TEXT STYLE HELPERS ───────────────────────────────────────────

  static TextStyle get mono => GoogleFonts.dmMono(
    fontWeight: FontWeight.w700, color: AppColors.text,
  );

  static TextStyle get monoAccent => GoogleFonts.dmMono(
    fontWeight: FontWeight.w700, color: AppColors.accent,
  );

  static TextStyle get monoSmall => GoogleFonts.dmMono(
    fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text,
  );
}
