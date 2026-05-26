import 'package:flutter/material.dart';

import 'felloway_colors.dart';

/// Semantic text colors for dark gradient / blur UI (white + opacity).
@immutable
class FellowayTextColors extends ThemeExtension<FellowayTextColors> {
  const FellowayTextColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.accent,
  });

  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color accent;

  static const FellowayTextColors onGradient = FellowayTextColors(
    primary: Color(0xF5FFFFFF),
    secondary: Color(0xBDFFFFFF),
    tertiary: Color(0x94FFFFFF),
    accent: FellowayColors.brandYellow,
  );

  @override
  FellowayTextColors copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? accent,
  }) {
    return FellowayTextColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      accent: accent ?? this.accent,
    );
  }

  @override
  FellowayTextColors lerp(ThemeExtension<FellowayTextColors>? other, double t) {
    if (other is! FellowayTextColors) return this;
    return FellowayTextColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}

extension FellowayTextColorsContext on BuildContext {
  FellowayTextColors get fellowayTextColors =>
      Theme.of(this).extension<FellowayTextColors>()!;
}
