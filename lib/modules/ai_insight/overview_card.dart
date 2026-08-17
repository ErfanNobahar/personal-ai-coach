import 'package:flutter/widgets.dart';
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class OverviewCard extends StatelessWidget {
  final List<SpecificTasks> tasks;
  const OverviewCard({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: U.Theme.primaryBorder.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          U.Text(
            text:
                'Tasks Completed this week:  % ${((tasks.getDetails.completed * 100) ~/ tasks.getDetails.taskCount).toString()}',
            textWeight: U.TextWeight.bold,
            textSize: U.TextSize.s14,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              U.Text(text: 'completed: ${tasks.getDetails.completed}'),
              U.Text(text: 'skipped: ${tasks.getDetails.skipped}'),
              U.Text(text: 'pending: ${tasks.getDetails.pending}'),
            ],
          ),
        ],
      ),
    );
  }
}
