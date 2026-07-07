import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../data/local/models/food_log_model.dart';
import '../../../../shared/widgets/app_card.dart';

class FoodLogTile extends StatelessWidget {
  const FoodLogTile({
    super.key,
    required this.log,
    required this.onEdit,
    required this.onDelete,
  });

  final FoodLogModel log;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _formatQuantity(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.gap12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            child: const Icon(Icons.restaurant_rounded),
          ),
          const SizedBox(width: AppSpacing.gap12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.foodName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.gap4),
                Text(
                  '${_formatQuantity(log.quantity)} ${log.unit}'
                  ' • ${AppDateUtils.formatTime(log.consumedAt)}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                if (log.note.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.gap4),
                  Text(
                    log.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.gap8),
          Text(
            '${log.calculatedCalories.round()}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.tertiary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(width: AppSpacing.gap4),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded),
            tooltip: 'Food log options',
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              }

              if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}