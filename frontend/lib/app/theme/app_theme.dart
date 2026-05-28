import 'package:flutter/material.dart';

import 'felloway_colors.dart';
import 'felloway_light_input.dart';
import 'felloway_text_colors.dart';
import 'felloway_typography.dart';

abstract final class AppTheme {
  static const _textOnGradient = FellowayTextColors.onGradient;

  static ThemeData light() {
    final scheme = FellowayColors.lightScheme;
    final typography = FellowayTypography.create(colors: _textOnGradient);
    final textTheme = FellowayTypography.buildOnestTextTheme(
      scheme: scheme,
      colors: _textOnGradient,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: FellowayTypography.fontFamily,
      scaffoldBackgroundColor: Colors.transparent,
      extensions: [_textOnGradient, typography, FellowayLightInput.standard],
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: FellowayColors.brandDark.withValues(alpha: 0.55),
        foregroundColor: _textOnGradient.primary,
        iconTheme: IconThemeData(color: _textOnGradient.primary),
        titleTextStyle: typography.appBarTitleStyle(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: FellowayColors.brandDark.withValues(alpha: 0.82),
        indicatorColor: FellowayColors.brandYellow.withValues(alpha: 0.35),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? _textOnGradient.accent
                : _textOnGradient.secondary,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return selected ? typography.tabLabelSelected : typography.tabLabel;
        }),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: _textOnGradient.primary,
        titleTextStyle: typography.menuRow,
        subtitleTextStyle: typography.bodySupporting,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface.withValues(alpha: 0.94),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: typography.menuRow.copyWith(color: scheme.onPrimary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _textOnGradient.primary,
          textStyle: typography.menuRow,
          side: BorderSide(
            color: _textOnGradient.secondary.withValues(alpha: 0.9),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface.withValues(alpha: 0.92),
        labelStyle: FellowayLightInput.standard.labelStyle,
        hintStyle: FellowayLightInput.standard.hintStyle,
        floatingLabelStyle: FellowayLightInput.standard.labelStyle,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface.withValues(alpha: 0.9),
        selectedColor: scheme.primaryContainer,
        labelStyle: typography.bodySupporting.copyWith(color: scheme.onSurface),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: FellowayColors.brandDark,
        contentTextStyle: typography.menuRow,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
