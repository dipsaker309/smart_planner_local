import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    this.title,
    this.subtitle,
    this.message,
    this.actionLabel,
    this.onAction,
    this.iconSize = 64,
  });

  final IconData icon;
  final String? title;
  final String? subtitle;

  /// Backward-compatible old field.
  /// Existing calls like EmptyState(message: '...') will still work.
  final String? message;

  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ?? _titleFromMessage();
    final resolvedSubtitle = subtitle ?? _subtitleFromMessage();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.65),
            ),
            const SizedBox(height: AppSpacing.gap16),
            Text(
              resolvedTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (resolvedSubtitle.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.gap4),
              Text(
                resolvedSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.gap24),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _titleFromMessage() {
    if (message == null || message!.trim().isEmpty) {
      return 'Nothing here yet';
    }

    final parts = message!.split('\n');

    return parts.first.trim();
  }

  String _subtitleFromMessage() {
    if (message == null || message!.trim().isEmpty) {
      return '';
    }

    final parts = message!.split('\n');

    if (parts.length <= 1) {
      return '';
    }

    return parts.sublist(1).join('\n').trim();
  }
}