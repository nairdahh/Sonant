import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎨 Sonant Color Palette 2025
  // Harmonious purple + warm coffee latte tones
  // Both colors share warm undertones for perfect harmony

  // ═══════════════════════════════════════════════════════════════
  // PRIMARY - Beautiful Muted Purple (mov)
  // ═══════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF6B5B95); // Muted purple - main
  static const Color primaryLight = Color(0xFF8B7BB5); // Lighter purple
  static const Color primaryDark = Color(0xFF4A3D6E); // Darker purple
  static const Color primaryMuted = Color(0xFFE8E4F0); // Very soft purple bg

  // ═══════════════════════════════════════════════════════════════
  // SECONDARY - Warm Light Wood (lemn deschis, portocaliu-galben cald)
  // Warm golden wood tones, not too dark
  // ═══════════════════════════════════════════════════════════════
  static const Color secondary = Color(0xFFC89560); // Warm light wood - main
  static const Color secondaryLight = Color(0xFFD9AA7A); // Lighter warm wood
  static const Color secondaryDark = Color(0xFFB5824A); // Deeper wood tone
  static const Color secondaryMuted = Color(0xFFFAF5F0); // Very soft warm bg

  // ═══════════════════════════════════════════════════════════════
  // LIGHT MODE - Clean whites with warm undertones
  // ═══════════════════════════════════════════════════════════════
  static const Color backgroundLight = Color(0xFFFCFBFA); // Warm white
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceAltLight = Color(0xFFF8F6F4); // Subtle warm gray

  // ═══════════════════════════════════════════════════════════════
  // DARK MODE - Easy on the eyes, not pure black
  // ═══════════════════════════════════════════════════════════════
  static const Color backgroundDark = Color(0xFF1A1A1E); // Soft dark
  static const Color surfaceDark = Color(0xFF242428); // Card dark
  static const Color surfaceAltDark = Color(0xFF2E2E34); // Elevated dark

  // Current mode colors (will be switched based on theme)
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color surfaceAlt = surfaceAltLight;

  // ═══════════════════════════════════════════════════════════════
  // SEMANTIC COLORS - Muted to match palette
  // ═══════════════════════════════════════════════════════════════
  static const Color success = Color(0xFF7A9E7E); // Muted sage green
  static const Color error = Color(0xFFC67B7B); // Muted rose red
  static const Color warning = Color(0xFFD4A960); // Warm gold

  // ═══════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFF2A2A2E); // Near black, warm
  static const Color textSecondary = Color(0xFF6B6B70); // Medium gray
  static const Color textMuted = Color(0xFF9B9BA0); // Light gray
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on primary
  static const Color textOnSecondary = Color(0xFFFFFFFF); // White on secondary

  // Dark mode text colors
  static const Color textPrimaryDark = Color(0xFFEDEDF0);
  static const Color textSecondaryDark = Color(0xFFB6B6BD);
  static const Color textMutedDark = Color(0xFF8C8C93);

  // ═══════════════════════════════════════════════════════════════
  // HIGHLIGHT FOR TTS - Super soft purple tint
  // ═══════════════════════════════════════════════════════════════
  static const Color highlight = Color(0xFFE8E4F0); // Soft lavender
  static const Color highlightAlt = Color(0xFFF5F0EB); // Soft latte

  // ═══════════════════════════════════════════════════════════════
  // BORDERS & SHADOWS
  // ═══════════════════════════════════════════════════════════════
  static const Color border = Color(0xFFE8E6E3); // Warm light gray
  static const Color borderDark = Color(0xFF3A3A40); // Dark mode border
  static const Color shadow = Color(0x08000000); // 3% black

  // ═══════════════════════════════════════════════════════════════
  // LEGACY ALIASES (for compatibility)
  // ═══════════════════════════════════════════════════════════════
  static const Color espresso = secondaryDark;
  static const Color warmPaper = background;
  static const Color softCream = surface;
  static const Color caramel = secondary;
  static const Color accent = secondary; // Alias
  static const Color sage = success;
  static const Color clay = error;
  static const Color charcoal = textPrimary;

  // ═══════════════════════════════════════════════════════════════
  // DESIGN CONSTANTS
  // ═══════════════════════════════════════════════════════════════
  static const double maxContentWidth = 900.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXL = 24.0;

  // Subtle shadow for cards and components
  static const List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: shadow,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: shadow,
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static final ThemeData themeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: textOnPrimary,
      secondary: accent,
      onSecondary: textOnPrimary,
      tertiary: success,
      error: error,
      onError: textOnPrimary,
      surface: surface,
      onSurface: textPrimary,
      outline: border,
    ),
    textTheme: _textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textPrimary),
      titleTextStyle: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: textOnPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 0,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: border, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusLarge),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(
        color: textMuted,
        fontSize: 15,
      ),
      labelStyle: GoogleFonts.inter(
        color: textSecondary,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: textSecondary,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primary,
      inactiveTrackColor: border,
      thumbColor: primary,
      overlayColor: primary.withValues(alpha: 0.1),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: GoogleFonts.inter(color: surface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: border,
      thickness: 1,
      space: 1,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(borderRadiusXL),
        ),
      ),
      elevation: 0,
    ),
    iconTheme: const IconThemeData(
      color: textSecondary,
      size: 24,
    ),
  );

  static final ThemeData darkThemeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: textOnPrimary,
      secondary: accent,
      onSecondary: textOnPrimary,
      tertiary: success,
      error: error,
      onError: textOnPrimary,
      surface: surfaceDark,
      onSurface: textPrimaryDark,
      outline: borderDark,
    ),
    textTheme: _textThemeDark,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textPrimaryDark),
      titleTextStyle: GoogleFonts.inter(
        color: textPrimaryDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: textOnPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 0,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: borderDark, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusLarge),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceAltDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(
        color: textMutedDark,
        fontSize: 15,
      ),
      labelStyle: GoogleFonts.inter(
        color: textSecondaryDark,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: textSecondaryDark,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primary,
      inactiveTrackColor: borderDark,
      thumbColor: primary,
      overlayColor: primary.withValues(alpha: 0.1),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimaryDark,
      contentTextStyle: GoogleFonts.inter(color: surfaceDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: borderDark,
      thickness: 1,
      space: 1,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(borderRadiusXL),
        ),
      ),
      elevation: 0,
    ),
    iconTheme: const IconThemeData(
      color: textSecondaryDark,
      size: 24,
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // FONT RECOMMENDATIONS
  // ═══════════════════════════════════════════════════════════════
  //
  // 📖 SERIF (For Book Reading - bodyLarge)
  // ════════════════════════════════════════════════════════════
  // 1. Crimson Text - Classic, elegant, inspired by Garamond
  // 2. Literata - Modern serif optimized for screens, Google's choice
  // 3. Lora - Beautiful, highly legible, great for long reading
  //
  // 🎨 SANS-SERIF (For UI - displays, headlines, labels)
  // ════════════════════════════════════════════════════════════
  // 1. Inter - Modern, clean, excellent readability (CURRENT)
  // 2. Manrope - Geometric, modern, great for UI
  // 3. Plus Jakarta Sans - Soft, friendly, very trendy
  //
  // Current choices: Inter (UI) + Crimson Text (Reading)
  // ════════════════════════════════════════════════════════════

  static TextTheme get _textTheme {
    return TextTheme(
      // Display - for hero text
      displayLarge: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      // Headlines
      headlineLarge: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      headlineMedium: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      headlineSmall: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      // Titles
      titleLarge: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      titleMedium: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.inter(
        color: textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      // Body text - for reading books
      // SERIF OPTIONS: crimsonText (current), literata, or lora
      bodyLarge: GoogleFonts.crimsonText(
        color: textPrimary,
        fontSize: 18,
        height: 1.7,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.inter(
        color: textSecondary,
        fontSize: 13,
        height: 1.4,
      ),
      // Labels
      labelLarge: GoogleFonts.inter(
        color: textOnPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelMedium: GoogleFonts.inter(
        color: textSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      labelSmall: GoogleFonts.inter(
        color: textMuted,
        fontWeight: FontWeight.w500,
        fontSize: 11,
        letterSpacing: 0.5,
      ),
    );
  }

  static TextTheme get _textThemeDark {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        color: textPrimaryDark,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.inter(
        color: textPrimaryDark,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.inter(
        color: textPrimaryDark,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.inter(
        color: textPrimaryDark,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      headlineMedium: GoogleFonts.inter(
        color: textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      headlineSmall: GoogleFonts.inter(
        color: textPrimaryDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.inter(
        color: textPrimaryDark,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      titleMedium: GoogleFonts.inter(
        color: textPrimaryDark,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.inter(
        color: textSecondaryDark,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.crimsonText(
        color: textPrimaryDark,
        fontSize: 18,
        height: 1.7,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.inter(
        color: textPrimaryDark,
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.inter(
        color: textSecondaryDark,
        fontSize: 13,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.inter(
        color: textOnPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelMedium: GoogleFonts.inter(
        color: textSecondaryDark,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      labelSmall: GoogleFonts.inter(
        color: textMutedDark,
        fontWeight: FontWeight.w500,
        fontSize: 11,
        letterSpacing: 0.5,
      ),
    );
  }
}
