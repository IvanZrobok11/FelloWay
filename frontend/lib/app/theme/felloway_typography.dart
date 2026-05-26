import 'package:flutter/material.dart';

import 'felloway_text_colors.dart';

/// App type scale (Onest). See specs/014-mobile-typography/data-model.md.
@immutable
class FellowayTypography extends ThemeExtension<FellowayTypography> {
  const FellowayTypography({
    required this.screenTitle,
    required this.sectionLabel,
    required this.menuRow,
    required this.bodySupporting,
    required this.tabLabel,
    required this.tabLabelSelected,
  });

  final TextStyle screenTitle;
  final TextStyle sectionLabel;
  final TextStyle menuRow;
  final TextStyle bodySupporting;
  final TextStyle tabLabel;
  final TextStyle tabLabelSelected;

  static const String fontFamily = 'Onest';

  /// Builds the full scale for gradient UI (light theme on dark backgrounds).
  static FellowayTypography create({required FellowayTextColors colors}) {
    const family = fontFamily;
    return FellowayTypography(
      screenTitle: TextStyle(
        fontFamily: family,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 32 / 28,
        letterSpacing: -0.56,
        color: colors.primary,
      ),
      sectionLabel: TextStyle(
        fontFamily: family,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 22 / 17,
        letterSpacing: -0.17,
        color: colors.primary,
      ),
      menuRow: TextStyle(
        fontFamily: family,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 22 / 16,
        color: colors.primary,
      ),
      bodySupporting: TextStyle(
        fontFamily: family,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        letterSpacing: 0.14,
        color: colors.secondary,
      ),
      tabLabel: TextStyle(
        fontFamily: family,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 14 / 12,
        letterSpacing: 0.24,
        color: colors.secondary,
      ),
      tabLabelSelected: TextStyle(
        fontFamily: family,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 14 / 12,
        letterSpacing: 0.24,
        color: colors.accent,
      ),
    );
  }

  /// App bar uses a slightly smaller title than in-content screen titles.
  TextStyle appBarTitleStyle() {
    return screenTitle.copyWith(fontSize: 24, height: 28 / 24);
  }

  /// Material 3 [TextTheme] mapped from Felloway roles.
  static TextTheme buildOnestTextTheme({
    required ColorScheme scheme,
    required FellowayTextColors colors,
  }) {
    final typo = create(colors: colors);
    final base = Typography.material2021(platform: TargetPlatform.android).black
        .apply(
          fontFamily: fontFamily,
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        );

    return base.copyWith(
      headlineMedium: typo.screenTitle,
      titleMedium: typo.sectionLabel,
      titleLarge: typo.sectionLabel.copyWith(fontSize: 20),
      bodyLarge: typo.menuRow,
      bodyMedium: typo.bodySupporting,
      labelSmall: typo.tabLabel,
      labelLarge: typo.menuRow,
    );
  }

  @override
  FellowayTypography copyWith({
    TextStyle? screenTitle,
    TextStyle? sectionLabel,
    TextStyle? menuRow,
    TextStyle? bodySupporting,
    TextStyle? tabLabel,
    TextStyle? tabLabelSelected,
  }) {
    return FellowayTypography(
      screenTitle: screenTitle ?? this.screenTitle,
      sectionLabel: sectionLabel ?? this.sectionLabel,
      menuRow: menuRow ?? this.menuRow,
      bodySupporting: bodySupporting ?? this.bodySupporting,
      tabLabel: tabLabel ?? this.tabLabel,
      tabLabelSelected: tabLabelSelected ?? this.tabLabelSelected,
    );
  }

  @override
  FellowayTypography lerp(ThemeExtension<FellowayTypography>? other, double t) {
    if (other is! FellowayTypography) return this;
    return FellowayTypography(
      screenTitle: TextStyle.lerp(screenTitle, other.screenTitle, t)!,
      sectionLabel: TextStyle.lerp(sectionLabel, other.sectionLabel, t)!,
      menuRow: TextStyle.lerp(menuRow, other.menuRow, t)!,
      bodySupporting: TextStyle.lerp(bodySupporting, other.bodySupporting, t)!,
      tabLabel: TextStyle.lerp(tabLabel, other.tabLabel, t)!,
      tabLabelSelected: TextStyle.lerp(
        tabLabelSelected,
        other.tabLabelSelected,
        t,
      )!,
    );
  }
}

extension FellowayTypographyContext on BuildContext {
  FellowayTypography get fellowayTypography =>
      Theme.of(this).extension<FellowayTypography>()!;
}
