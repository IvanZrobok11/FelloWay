import 'package:flutter/material.dart';

import 'app_assets.dart';

/// Full-screen artwork behind transparent scaffolds.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.intro,
    required this.child,
  });

  final bool intro;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final asset = intro ? AppAssets.introBackground : AppAssets.mainBackground;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          asset,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: intro
                  ? [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.12),
                      Colors.black.withValues(alpha: 0.5),
                    ]
                  : [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.42),
                    ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
