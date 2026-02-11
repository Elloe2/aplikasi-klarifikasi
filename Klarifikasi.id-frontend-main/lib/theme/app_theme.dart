/// ============================================================================
/// APP THEME - KLARIFIKASI.ID FRONTEND
/// ============================================================================
/// File konfigurasi tema aplikasi dengan desain dark mode dan gradient.
/// Mengatur color scheme, typography, dan component styling untuk konsistensi UI.
///
/// Fitur Utama:
/// - Dark theme dengan gradient backgrounds
/// - Custom color palette untuk brand identity
/// - Responsive component styling
/// - Material 3 design system integration
/// - Cross-platform consistency (Web & Android)
///
/// Color Philosophy:
/// - Primary Green (#92D332): Brand utama, trust, dan growth
/// - Dark Blues: Professional, calm, dan trustworthy
/// - Gradients: Modern, depth, dan visual appeal
/// ============================================================================
library;

import 'package:flutter/material.dart'; // Flutter Material Design framework

/// === APP THEME CLASS ===
/// Singleton class untuk mengelola tema aplikasi.
/// Menggunakan private constructor untuk mencegah instantiation.
///
/// Responsibilities:
/// - Color palette definition
/// - Gradient configurations
/// - ThemeData construction
/// - Component styling consistency
///
/// Design Principles:
/// - Dark-first approach untuk modern look
/// - High contrast untuk readability
/// - Consistent spacing dan typography
/// - Accessible color combinations
class AppTheme {
  // Private constructor untuk singleton pattern
  AppTheme._();

  // === SPOTIFY-INSPIRED COLOR PALETTE ===
  // Dark theme dengan subtle surfaces dan better contrast
  static const Color backgroundDark = Color(
    0xFF121212,
  ); // Spotify's dark background
  static const Color surfaceDark = Color(0xFF1E1E1E); // Card backgrounds
  static const Color surfaceElevated = Color(0xFF2A2A2A); // Elevated surfaces
  static const Color outlineDark = Color(0xFF3A3A3A); // Subtle borders
  static const Color subduedGray = Color(
    0xFFB3B3B3,
  ); // Secondary text (Spotify's gray)
  static const Color mutedGray = Color(0xFF535353); // Muted elements

  // === SPOTIFY-INSPIRED GREEN PALETTE ===
  // Green yang lebih vibrant dan accessible seperti Spotify
  /// Warna dasar brand yang diambil dari Spotify green sebagai identitas utama
  static const Color primarySeedColor = Color(0xFF1DB954);

  /// Varian lebih terang untuk hover state atau gradient highlight
  static const Color primaryLight = Color(0xFF1ED760);

  /// Varian lebih gelap untuk kontras pada gradient dan border
  static const Color primaryDark = Color(0xFF1AA34A);

  /// Aksen hijau sekunder untuk konsistensi di komponen sekunder
  static const Color secondaryAccentColor = Color(0xFF1DB954);

  /// Aksen hijau tersier yang digunakan sebagai highlight tambahan
  static const Color tertiaryAccentColor = Color(0xFF1ED760);

  // === GRADIENT DEFINITIONS ===
  // Pre-defined gradients untuk konsistensi visual di seluruh aplikasi

  /// Modern primary gradient dengan subtle depth
  /// Digunakan untuk: Primary buttons, highlights, success states
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primarySeedColor, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Modern secondary gradient untuk subtle accents
  /// Digunakan untuk: Secondary buttons, info states, subtle highlights
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryAccentColor, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Modern accent gradient untuk special highlights
  /// Digunakan untuk: Links, tertiary buttons, special highlights
  static const LinearGradient accentGradient = LinearGradient(
    colors: [tertiaryAccentColor, secondaryAccentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Modern minimalist background gradient
  /// Digunakan untuk: Scaffold background, main screens
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, surfaceDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Modern card gradient dengan subtle elevation
  /// Digunakan untuk: Cards, containers, elevated surfaces
  static const LinearGradient cardGradient = LinearGradient(
    colors: [surfaceElevated, surfaceDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// History card gradient dengan orientasi vertikal
  /// Digunakan khusus untuk history list items
  /// Digunakan untuk: Search history cards, list items
  static const LinearGradient historyCardGradient = LinearGradient(
    colors: [surfaceDark, surfaceDark], // Solid untuk consistency
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// History accent gradient untuk highlight elements
  /// Menggunakan primary color untuk emphasis
  /// Digunakan untuk: History badges, accent elements
  static const LinearGradient historyAccentGradient = LinearGradient(
    colors: [primarySeedColor, primarySeedColor], // Primary green accent
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Error gradient untuk error states dan warnings
  /// Menggunakan red colors untuk attention-grabbing
  /// Digunakan untuk: Error messages, warning states, destructive actions
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFD32F2F)], // Red gradient untuk errors
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Modern subtle shadows untuk depth tanpa overwhelming
  static const List<BoxShadow> cardShadows = [
    BoxShadow(
      color: Color(0x1A000000), // Very subtle black shadow
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Modern elevation shadows untuk different levels
  static const List<BoxShadow> elevatedShadows = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  // === THEME DATA CONSTRUCTION ===

  /// Main theme getter yang mengembalikan fully configured ThemeData
  /// Menggunakan Material 3 dengan custom color scheme dan component styling
  static final ThemeData light = _buildLightTheme();

  /// === PRIVATE THEME BUILDER ===
  /// Method internal untuk constructing ThemeData dengan semua konfigurasi.
  /// Menggunakan Material 3 design system dengan customizations.
  ///
  /// Returns: Fully configured ThemeData untuk aplikasi
  ///
  /// Features:
  /// - Material 3 design system
  /// - Custom color scheme dari seed colors
  /// - Dark theme dengan white text
  /// - Custom component themes untuk consistency
  static ThemeData _buildLightTheme() {
    // Color scheme dari seed colors dengan dark brightness
    final lightScheme = ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      secondary: secondaryAccentColor,
      tertiary: tertiaryAccentColor,
      surface: backgroundDark,
      brightness: Brightness.dark,
    );

    return ThemeData(
      // === MATERIAL 3 SETUP ===
      useMaterial3: true, // Enable Material 3 design system
      colorScheme: lightScheme, // Custom color scheme
      // === BASIC CONFIGURATION ===
      scaffoldBackgroundColor:
          backgroundDark, // Pure black untuk modern minimalist look
      // === TYPOGRAPHY SYSTEM ===
      // SpotifyMix font dengan hierarchy yang optimal
      textTheme: TextTheme(
        // Display styles untuk hero text dengan SpotifyMix
        displayLarge: TextStyle(
          fontFamily: 'SpotifyMix',
          fontSize: 48,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.5,
          color: Colors.white,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontFamily: 'SpotifyMix',
          fontSize: 40,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          color: Colors.white,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontFamily: 'SpotifyMix',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: Colors.white,
          height: 1.3,
        ),

        // Headline styles untuk section headers dengan SpotifyMix
        headlineLarge: TextStyle(
          fontFamily: 'SpotifyMix',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
          color: Colors.white,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'SpotifyMix',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: Colors.white,
          height: 1.4,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'SpotifyMix',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: Colors.white,
          height: 1.4,
        ),

        // Title styles untuk card headers dengan SpotifyMix
        titleLarge: TextStyle(
          fontFamily: 'SpotifyMix',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: Colors.white,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontFamily: 'SpotifyMix',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: Colors.white,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontFamily: 'SpotifyMix',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: Colors.white,
          height: 1.5,
        ),

        // Body styles untuk content dengan SpotifyMix
        bodyLarge: TextStyle(
          fontFamily: 'SpotifyMix',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: Colors.white,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'SpotifyMix',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: subduedGray, // Spotify's secondary text color
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontFamily: 'SpotifyMix',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: mutedGray, // Spotify's muted text color
          height: 1.4,
        ),

        // Label styles untuk UI elements dengan SpotifyMix
        labelLarge: TextStyle(
          fontFamily: 'SpotifyMix',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: Colors.white,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontFamily: 'SpotifyMix',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: Colors.white.withValues(alpha: 0.8),
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontFamily: 'SpotifyMix',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: Colors.white.withValues(alpha: 0.7),
          height: 1.4,
        ),
      ),

      // === APP BAR THEME ===
      // Transparent app bar dengan white text
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, // Transparent background
        foregroundColor: Colors.white, // White text dan icons
        elevation: 0, // No shadow untuk flat design
      ),

      // === SPOTIFY-INSPIRED NAVIGATION THEME ===
      // Clean navigation bar seperti Spotify
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: backgroundDark, // Dark background seperti Spotify
        indicatorColor: Colors.transparent, // No indicator untuk clean look
        elevation: 0, // No elevation
        height: 70, // Compact height seperti Spotify
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        // Spotify-style icon theming
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? Colors
                      .white // White untuk selected (seperti Spotify)
                : subduedGray, // Gray untuk unselected
            size: 24,
          );
        }),

        // Spotify-style label theming
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontWeight: FontWeight.w400, // Regular weight seperti Spotify
            fontSize: 11,
            color: states.contains(WidgetState.selected)
                ? Colors
                      .white // White untuk selected
                : subduedGray, // Gray untuk unselected
          );
        }),
      ),

      // === BUTTON THEMES ===
      // Modern button system dengan better interaction states

      /// Primary filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
              backgroundColor: primarySeedColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.white.withValues(alpha: 0.1);
                }
                if (states.contains(WidgetState.hovered)) {
                  return Colors.white.withValues(alpha: 0.05);
                }
                return Colors.transparent;
              }),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return primarySeedColor.withValues(alpha: 0.3);
                }
                return primarySeedColor;
              }),
            ),
      ),

      /// Secondary outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              foregroundColor: primarySeedColor,
              side: BorderSide(color: primarySeedColor, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return primarySeedColor.withValues(alpha: 0.1);
                }
                if (states.contains(WidgetState.hovered)) {
                  return primarySeedColor.withValues(alpha: 0.05);
                }
                return Colors.transparent;
              }),
              side: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return BorderSide(
                    color: primarySeedColor.withValues(alpha: 0.3),
                  );
                }
                return BorderSide(color: primarySeedColor, width: 1.5);
              }),
            ),
      ),

      /// Text button theme
      textButtonTheme: TextButtonThemeData(
        style:
            TextButton.styleFrom(
              foregroundColor: primarySeedColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return primarySeedColor.withValues(alpha: 0.1);
                }
                if (states.contains(WidgetState.hovered)) {
                  return primarySeedColor.withValues(alpha: 0.05);
                }
                return Colors.transparent;
              }),
            ),
      ),

      // === INPUT DECORATION THEME ===
      // Modern input field styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outlineDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primarySeedColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.red.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        errorStyle: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),

      // === SNACKBAR THEME ===
      // Modern notification styling
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated, // Elevated surface background
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating, // Floating style
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Modern rounded corners
        ),
        actionTextColor: primarySeedColor, // Modern green untuk action
      ),
    );
  }
}
