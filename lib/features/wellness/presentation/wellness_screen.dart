import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/date_selector.dart';
import '../application/wellness_controller.dart';

class WellnessScreen extends ConsumerWidget {
  const WellnessScreen({super.key});

  Future<void> _addCustomWater(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final amount = await _showNumberInputDialog(
      context: context,
      title: 'Add water',
      label: 'Amount in ml',
      initialValue: '',
      confirmText: 'Add',
    );

    if (amount == null) {
      return;
    }

    await ref.read(wellnessControllerProvider.notifier).addWater(amount);
  }

  Future<void> _editWaterTotal(
    BuildContext context,
    WidgetRef ref,
    int currentTotal,
  ) async {
    final total = await _showNumberInputDialog(
      context: context,
      title: 'Edit water total',
      label: 'Total water in ml',
      initialValue: currentTotal.toString(),
      confirmText: 'Save',
    );

    if (total == null) {
      return;
    }

    await ref.read(wellnessControllerProvider.notifier).setWaterTotal(total);
  }

  Future<void> _editWaterTarget(
    BuildContext context,
    WidgetRef ref,
    int currentTarget,
  ) async {
    final target = await _showNumberInputDialog(
      context: context,
      title: 'Edit water target',
      label: 'Daily target in ml',
      initialValue: currentTarget.toString(),
      confirmText: 'Save',
    );

    if (target == null) {
      return;
    }

    await ref.read(wellnessControllerProvider.notifier).updateWaterTarget(target);
  }

  Future<void> _confirmResetWater(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset water?'),
          content: const Text(
            'This will reset water intake to 0 ml for the selected date.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (shouldReset != true) {
      return;
    }

    await ref.read(wellnessControllerProvider.notifier).resetWater();
  }

  Future<int?> _showNumberInputDialog({
    required BuildContext context,
    required String title,
    required String label,
    required String initialValue,
    required String confirmText,
  }) async {
    final controller = TextEditingController(text: initialValue);

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              labelText: label,
              suffixText: 'ml',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = int.tryParse(controller.text.trim());

                if (value == null) {
                  Navigator.of(context).pop();
                  return;
                }

                Navigator.of(context).pop(value);
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    controller.dispose();

    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wellnessControllerProvider);
    final controller = ref.read(wellnessControllerProvider.notifier);

    ref.listen(wellnessControllerProvider, (previous, next) {
      final message = next.message;

      if (message == null || message.isEmpty) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );

      ref.read(wellnessControllerProvider.notifier).clearMessage();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            DateSelector(
              selectedDate: state.selectedDate,
              onDateChanged: controller.loadForDate,
            ),
            const SizedBox(height: AppSpacing.gap16),
            _WaterTrackerCard(
              totalMl: state.water.totalMl,
              targetMl: state.water.targetMl,
              progress: state.water.progress,
              progressPercent: state.water.progressPercent,
              feedbackTitle: state.water.feedbackTitle,
              feedbackMessage: state.water.feedbackMessage,
              onAdd250: () => controller.addWater(250),
              onAdd500: () => controller.addWater(500),
              onAddGlass: () => controller.addWater(300),
              onAddCustom: () => _addCustomWater(context, ref),
              onEditTotal: () => _editWaterTotal(
                context,
                ref,
                state.water.totalMl,
              ),
              onEditTarget: () => _editWaterTarget(
                context,
                ref,
                state.water.targetMl,
              ),
              onReset: () => _confirmResetWater(context, ref),
            ),
            const SizedBox(height: AppSpacing.gap16),
            _UpcomingWellnessCard(),
            const SizedBox(height: AppSpacing.bottomScrollPadding),
          ],
        ),
      ),
    );
  }
}

class _WaterTrackerCard extends StatelessWidget {
  const _WaterTrackerCard({
    required this.totalMl,
    required this.targetMl,
    required this.progress,
    required this.progressPercent,
    required this.feedbackTitle,
    required this.feedbackMessage,
    required this.onAdd250,
    required this.onAdd500,
    required this.onAddGlass,
    required this.onAddCustom,
    required this.onEditTotal,
    required this.onEditTarget,
    required this.onReset,
  });

  final int totalMl;
  final int targetMl;
  final double progress;
  final int progressPercent;
  final String feedbackTitle;
  final String feedbackMessage;
  final VoidCallback onAdd250;
  final VoidCallback onAdd500;
  final VoidCallback onAddGlass;
  final VoidCallback onAddCustom;
  final VoidCallback onEditTotal;
  final VoidCallback onEditTarget;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final safeProgress = progress.clamp(0, 1).toDouble();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                child: const Icon(Icons.water_drop_rounded),
              ),
              const SizedBox(width: AppSpacing.gap12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Water Intake',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.gap4),
                    Text(
                      'Track how much water you drink each day.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit_total') {
                    onEditTotal();
                  }

                  if (value == 'edit_target') {
                    onEditTarget();
                  }

                  if (value == 'reset') {
                    onReset();
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: 'edit_total',
                      child: Text('Edit total'),
                    ),
                    PopupMenuItem(
                      value: 'edit_target',
                      child: Text('Edit target'),
                    ),
                    PopupMenuItem(
                      value: 'reset',
                      child: Text('Reset water'),
                    ),
                  ];
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.gap20),
          Text(
            '$totalMl / $targetMl ml',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppSpacing.gap8),
          LinearProgressIndicator(
            value: safeProgress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: AppSpacing.gap8),
          Text(
            '$progressPercent% of daily target',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.gap20),
          Wrap(
            spacing: AppSpacing.gap8,
            runSpacing: AppSpacing.gap8,
            children: [
              _QuickWaterButton(
                label: '+250 ml',
                onPressed: onAdd250,
              ),
              _QuickWaterButton(
                label: '+500 ml',
                onPressed: onAdd500,
              ),
              _QuickWaterButton(
                label: '+1 glass',
                onPressed: onAddGlass,
              ),
              _QuickWaterButton(
                label: 'Custom',
                icon: Icons.edit_rounded,
                onPressed: onAddCustom,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.gap20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.gap16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(
                color: colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.insights_rounded,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.gap12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedbackTitle,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.gap4),
                      Text(
                        feedbackMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickWaterButton extends StatelessWidget {
  const _QuickWaterButton({
    required this.label,
    required this.onPressed,
    this.icon = Icons.add_rounded,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _UpcomingWellnessCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coming next',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.gap12),
          _UpcomingItem(
            icon: Icons.bedtime_rounded,
            title: 'Sleep tracker',
            subtitle: 'Sleep time, wake time, duration, and feeling.',
            color: colorScheme.tertiary,
          ),
          const SizedBox(height: AppSpacing.gap12),
          _UpcomingItem(
            icon: Icons.fitness_center_rounded,
            title: 'Workout tracker',
            subtitle: 'Plan workouts, mark done, and track activity.',
            color: colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.gap12),
          _UpcomingItem(
            icon: Icons.fastfood_rounded,
            title: 'Treat food insights',
            subtitle: 'Separate regular food and treat/junk calories.',
            color: colorScheme.error,
          ),
        ],
      ),
    );
  }
}

class _UpcomingItem extends StatelessWidget {
  const _UpcomingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color,
        ),
        const SizedBox(width: AppSpacing.gap12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.gap4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}