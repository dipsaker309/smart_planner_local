import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/date_selector.dart';
import '../../../shared/widgets/empty_state.dart';
import '../application/planner_controller.dart';
import 'widgets/task_form_sheet.dart';
import 'widgets/task_tile.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  Future<void> _openAddTaskSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return TaskFormSheet(
          onSubmit: ({
            required String title,
            required String description,
          }) {
            return ref.read(plannerControllerProvider.notifier).addTask(
                  title: title,
                  description: description,
                );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plannerState = ref.watch(plannerControllerProvider);
    final controller = ref.read(plannerControllerProvider.notifier);

    ref.listen(plannerControllerProvider, (previous, next) {
      final message = next.message;

      if (message == null || message.isEmpty) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      controller.clearMessage();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Planner'),
        actions: [
          IconButton(
            onPressed: controller.rolloverFromPreviousDay,
            icon: const Icon(Icons.redo_rounded),
            tooltip: 'Rollover unfinished tasks from yesterday',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTaskSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          children: [
            DateSelector(
              selectedDate: plannerState.selectedDate,
              onDateChanged: controller.loadTasksForDate,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (plannerState.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (plannerState.tasks.isEmpty) {
                    return const EmptyState(
                      icon: Icons.checklist_rounded,
                      message: 'No tasks for this date.\nTap + Task to add one.',
                    );
                  }

                  return ListView.builder(
                    itemCount: plannerState.tasks.length,
                    itemBuilder: (context, index) {
                      final task = plannerState.tasks[index];

                      return TaskTile(
                        task: task,
                        onProgressChanged: (progress) {
                          controller.updateProgress(
                            taskId: task.id,
                            progress: progress,
                          );
                        },
                        onDelete: () {
                          controller.deleteTask(task.id);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}