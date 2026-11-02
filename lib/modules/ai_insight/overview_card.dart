import 'package:flutter/widgets.dart';
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class OverviewCard extends StatelessWidget {
  final List<SpecificTasks> tasks;
  const OverviewCard({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final details = tasks.getDetails;

    // Safe percentage: 0 when there are no tasks, otherwise rounded.
    final int percent = details.taskCount == 0
        ? 0
        : ((details.completed * 100) / details.taskCount).round();

    return Container(
      height: 155,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: U.Theme.outlineHigh.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          U.Text(
            color: U.Theme.secondaryText,
            text: 'Tasks Completed this week:  $percent%',
            textWeight: U.TextWeight.bold,
            textSize: U.TextSize.s14,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              U.Text(
                color: U.Theme.secondaryText,
                text: 'completed: ${details.completed}',
              ),
              U.Text(
                color: U.Theme.secondaryText,
                text: 'skipped: ${details.skipped}',
              ),
              U.Text(
                color: U.Theme.secondaryText,
                text: 'pending: ${details.pending}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
