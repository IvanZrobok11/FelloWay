import 'package:felloway_client/app/theme/felloway_text_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('onGradient tokens match data model alpha values', () {
    const colors = FellowayTextColors.onGradient;
    expect(colors.primary.alpha, closeTo((0.96 * 255).round(), 2));
    expect(colors.secondary.alpha, closeTo((0.74 * 255).round(), 2));
    expect(colors.tertiary.alpha, closeTo((0.58 * 255).round(), 2));
    expect(colors.accent, const Color(0xFFFDB813));
  });
}
