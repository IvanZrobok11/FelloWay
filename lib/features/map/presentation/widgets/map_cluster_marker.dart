import 'package:flutter/material.dart';

class MapClusterMarker extends StatelessWidget {
  const MapClusterMarker({
    super.key,
    required this.label,
    required this.isCluster,
    required this.scale,
    this.onTap,
  });

  final String label;
  final bool isCluster;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isCluster
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondaryContainer;
    final fg = isCluster
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSecondaryContainer;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: 1,
        duration: const Duration(milliseconds: 220),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(isCluster ? 18 : 12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(isCluster ? 18 : 12),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isCluster ? 12 : 10,
                vertical: isCluster ? 8 : 6,
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: isCluster ? 12 : 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
