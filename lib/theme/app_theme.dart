import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeType { 
  system,
  pureBlack,
  pureWhite,
  airbnbUpi
}

class AppTheme {
  static const Map<AppThemeType, ThemeColors> _themeColors = {
    // System Theme (adapts to device theme)
    AppThemeType.system: ThemeColors(
      primary: Color(0xFF007AFF), // iOS blue
      secondary: Color(0xFF5856D6),
      accent: Color(0xFF00D856),
      background: Color(0xFF000000),
      surface: Color(0xFF1C1C1E),
      xColor: Color(0xFF007AFF),
      oColor: Color(0xFF00D856),
      gradientStart: Color(0xFF000000),
      gradientEnd: Color(0xFF1C1C1E),
    ),
    // Pure Black Theme
    AppThemeType.pureBlack: ThemeColors(
      primary: Color(0xFFFFFFFF),
      secondary: Color(0xFFE0E0E0),
      accent: Color(0xFF00D856), // UPI Green
      background: Color(0xFF000000),
      surface: Color(0xFF121212),
      xColor: Color(0xFFFFFFFF),
      oColor: Color(0xFF00D856),
      gradientStart: Color(0xFF000000),
      gradientEnd: Color(0xFF000000),
    ),
    // Pure White Theme
    AppThemeType.pureWhite: ThemeColors(
      primary: Color(0xFF000000),
      secondary: Color(0xFF424242),
      accent: Color(0xFFFF5A5F), // Airbnb Red
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFF5F5F5),
      xColor: Color(0xFF000000),
      oColor: Color(0xFFFF5A5F),
      gradientStart: Color(0xFFFFFFFF),
      gradientEnd: Color(0xFFFFFFFF),
    ),
    // Airbnb Red + UPI Green Theme
    AppThemeType.airbnbUpi: ThemeColors(
      primary: Color(0xFFFF5A5F), // Airbnb Red
      secondary: Color(0xFF00D856), // UPI Green
      accent: Color(0xFFFFFFFF),
      background: Color(0xFF000000),
      surface: Color(0xFF1A1A1A),
      xColor: Color(0xFFFF5A5F),
      oColor: Color(0xFF00D856),
      gradientStart: Color(0xFF000000),
      gradientEnd: Color(0xFF1A1A1A),
    ),
  };

  static ThemeData getTheme(AppThemeType type, [Brightness? brightness]) {
    ThemeColors colors;
    Brightness themeBrightness;
    
    // Handle system theme with light/dark variants
    if (type == AppThemeType.system) {
      themeBrightness = brightness ?? Brightness.dark;
      if (themeBrightness == Brightness.light) {
        // System Light Mode - use white background
        colors = const ThemeColors(
          primary: Color(0xFF000000),
          secondary: Color(0xFF424242),
          accent: Color(0xFF007AFF),
          background: Color(0xFFFFFFFF),
          surface: Color(0xFFF5F5F5),
          xColor: Color(0xFF000000),
          oColor: Color(0xFF007AFF),
          gradientStart: Color(0xFFFFFFFF),
          gradientEnd: Color(0xFFFFFFFF),
        );
      } else {
        // System Dark Mode - use black background
        colors = const ThemeColors(
          primary: Color(0xFFFFFFFF),
          secondary: Color(0xFFE0E0E0),
          accent: Color(0xFF007AFF),
          background: Color(0xFF000000),
          surface: Color(0xFF1C1C1E),
          xColor: Color(0xFFFFFFFF),
          oColor: Color(0xFF007AFF),
          gradientStart: Color(0xFF000000),
          gradientEnd: Color(0xFF000000),
        );
      }
    } else {
      // Use predefined theme colors
      colors = _themeColors[type]!;
      if (type == AppThemeType.pureWhite) {
        themeBrightness = Brightness.light;
      } else {
        themeBrightness = Brightness.dark;
      }
    }
    
    return ThemeData(
      brightness: themeBrightness,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.background,
      textTheme: GoogleFonts.poppinsTextTheme(
        themeBrightness == Brightness.dark 
            ? ThemeData.dark().textTheme 
            : ThemeData.light().textTheme
      ),
      useMaterial3: true,
      extensions: [colors],
    );
  }

  static ThemeColors getColors(BuildContext context) {
    return Theme.of(context).extension<ThemeColors>()!;
  }
}

class ThemeColors extends ThemeExtension<ThemeColors> {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color xColor;
  final Color oColor;
  final Color gradientStart;
  final Color gradientEnd;

  const ThemeColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.xColor,
    required this.oColor,
    required this.gradientStart,
    required this.gradientEnd,
  });

  @override
  ThemeColors copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? surface,
    Color? xColor,
    Color? oColor,
    Color? gradientStart,
    Color? gradientEnd,
  }) {
    return ThemeColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      xColor: xColor ?? this.xColor,
      oColor: oColor ?? this.oColor,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
    );
  }

  @override
  ThemeColors lerp(ThemeExtension<ThemeColors>? other, double t) {
    if (other is! ThemeColors) return this;
    return ThemeColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      xColor: Color.lerp(xColor, other.xColor, t)!,
      oColor: Color.lerp(oColor, other.oColor, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
    );
  }
}
