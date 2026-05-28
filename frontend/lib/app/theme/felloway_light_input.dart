import 'package:flutter/material.dart';

import 'felloway_text_colors.dart';
import 'felloway_typography.dart';

/// Styles for filled/light [TextField] surfaces (dark text on white fill).
@immutable
class FellowayLightInput extends ThemeExtension<FellowayLightInput> {
  const FellowayLightInput({
    required this.textStyle,
    required this.labelStyle,
    required this.hintStyle,
  });

  final TextStyle textStyle;
  final TextStyle labelStyle;
  final TextStyle hintStyle;

  static final FellowayLightInput standard = FellowayLightInput(
    textStyle: TextStyle(
      color: FellowayTextColors.onLightSurface.primary,
      fontFamily: FellowayTypography.fontFamily,
      fontSize: 16,
    ),
    labelStyle: TextStyle(
      color: FellowayTextColors.onLightSurface.secondary,
      fontFamily: FellowayTypography.fontFamily,
    ),
    hintStyle: TextStyle(
      color: FellowayTextColors.onLightSurface.tertiary,
      fontFamily: FellowayTypography.fontFamily,
    ),
  );

  static InputDecoration decoration(
    BuildContext context, {
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    int? maxLines,
  }) {
    final input = context.fellowayLightInput;
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      labelStyle: input.labelStyle,
      hintStyle: input.hintStyle,
      border: const OutlineInputBorder(),
    );
  }

  @override
  FellowayLightInput copyWith({
    TextStyle? textStyle,
    TextStyle? labelStyle,
    TextStyle? hintStyle,
  }) {
    return FellowayLightInput(
      textStyle: textStyle ?? this.textStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      hintStyle: hintStyle ?? this.hintStyle,
    );
  }

  @override
  FellowayLightInput lerp(ThemeExtension<FellowayLightInput>? other, double t) {
    if (other is! FellowayLightInput) return this;
    return FellowayLightInput(
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t)!,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t)!,
      hintStyle: TextStyle.lerp(hintStyle, other.hintStyle, t)!,
    );
  }
}

extension FellowayLightInputContext on BuildContext {
  FellowayLightInput get fellowayLightInput =>
      Theme.of(this).extension<FellowayLightInput>() ?? FellowayLightInput.standard;
}
