import 'package:flutter/material.dart';

/// Brand palette aligned with [AppAssets.fellowayLogo] and sunset backgrounds.
abstract final class FellowayColors {
  static const brandYellow = Color(0xFFFDB813);
  static const brandOrange = Color(0xFFD15F32);
  static const brandTerracotta = Color(0xFFC0502E);
  static const brandCream = Color(0xFFFFF4D2);
  static const brandDark = Color(0xFF3E2723);
  static const brandDeep = Color(0xFF2D1B24);

  static ColorScheme get lightScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: brandOrange,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFFFE0B2),
        onPrimaryContainer: brandDark,
        secondary: brandTerracotta,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFFFCCBC),
        onSecondaryContainer: brandDark,
        tertiary: brandYellow,
        onTertiary: brandDark,
        tertiaryContainer: Color(0xFFFFF3CD),
        onTertiaryContainer: brandDark,
        error: Color(0xFFB3261E),
        onError: Colors.white,
        surface: Color(0xFFFFF8F0),
        onSurface: brandDark,
        onSurfaceVariant: Color(0xFF5D4037),
        outline: Color(0xFF8D6E63),
        outlineVariant: Color(0xFFD7CCC8),
        shadow: Colors.black26,
        surfaceTint: brandOrange,
      );
}
