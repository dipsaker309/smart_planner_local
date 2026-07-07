import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_utils.dart';
import 'app_card.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  void _goToPreviousDay() {
    onDateChanged(
      selectedDate.subtract(const Duration(days: 1)),
    );
  }

  void _goToNextDay() {
    onDateChanged(
      selectedDate.add(const Duration(days: 1)),
    );
  }

  void _goToToday() {
    onDateChanged(AppDateUtils.today());
  }

  bool get _isToday {
    return AppDateUtils.dateKey(selectedDate) ==
        AppDateUtils.dateKey(AppDateUtils.today());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.gap12,
        vertical: AppSpacing.gap8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _goToPreviousDay,
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous day',
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _isToday ? 'Today' : AppDateUtils.formatShortDate(selectedDate),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.gap4),
                Text(
                  AppDateUtils.formatFullDate(selectedDate),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _goToNextDay,
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next day',
          ),
          if (!_isToday) ...[
            const SizedBox(width: AppSpacing.gap4),
            TextButton(
              onPressed: _goToToday,
              child: const Text('Today'),
            ),
          ],
        ],
      ),
    );
  }
}