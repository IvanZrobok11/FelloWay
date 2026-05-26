import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';

import '../../../app/theme/felloway_text_colors.dart';
import '../domain/event.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.summary,
    required this.isGuest,
    required this.onTap,
  });

  final EventSummary summary;
  final bool isGuest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final lightText = FellowayTextColors.onLightSurface;
    final cover = summary.imageUrls.isNotEmpty ? summary.imageUrls.first : null;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final maxW = MediaQuery.sizeOf(context).width;
    final cacheW = (maxW * dpr).round().clamp(1, 1200);
    final cacheH = ((maxW * 9 / 16) * dpr).round().clamp(1, 800);
    final semanticLabel =
        '${summary.title}, ${summary.city}, ${_formatDate(summary.startsAt)}';

    return Semantics(
      button: true,
      label: semanticLabel,
      hint: l10n.eventCardOpenHint,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: cover != null
                    ? Image.network(
                        cover,
                        fit: BoxFit.cover,
                        cacheWidth: cacheW,
                        cacheHeight: cacheH,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (context, error, stackTrace) =>
                            ColoredBox(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.event, size: 48),
                            ),
                      )
                    : ColoredBox(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.event, size: 48),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: lightText.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${summary.city} · ${_formatDate(summary.startsAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: lightText.secondary,
                      ),
                    ),
                    if (summary.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        children: summary.tags
                            .take(4)
                            .map(
                              (t) => Chip(
                                label: Text(
                                  t,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: lightText.secondary,
                                  ),
                                ),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (isGuest)
                      Text(
                        l10n.eventCardGuestHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: lightText.secondary,
                        ),
                      )
                    else if (summary.attendeePreview.isNotEmpty)
                      Text(
                        l10n.eventCardAttendeeTeaser,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: lightText.secondary,
                        ),
                      ),
                    if (!isGuest && summary.attendeePreview.isNotEmpty)
                      const SizedBox(height: 4),
                    if (!isGuest && summary.attendeePreview.isNotEmpty)
                      Text(
                        summary.attendeePreview
                            .map((a) => '${a.displayName} (${a.city})')
                            .take(3)
                            .join(', '),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: lightText.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }
}
