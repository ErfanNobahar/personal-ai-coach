import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';
import 'package:personal_ai_coach/modules/ai_insight/cubit/ai_insight_cubit.dart';
import 'package:personal_ai_coach/modules/ai_insight/overview_card.dart';
import 'package:personal_ai_coach/ui_kit/chart.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class Overview extends StatelessWidget {
  Overview({super.key});
  final first = U.Theme.primary;
  final second = U.Theme.secondaryButton;
  final third = U.Theme.onBackground;
  final List<String> days = ['T', 'W', 'Th', 'F', 'S', 'S'];
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiInsightCubit, AiInsightState>(
      builder: (context, state) {
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OverviewCard(tasks: state.weeklyTasks),
            ),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TaskBarChart(
                data: [
                  ...List.generate(
                    7 - state.weeklyTasks.length,
                    (index) => DayTasks(days[index], [
                      // TaskSegment(3  , first), // completed
                      // TaskSegment(1, second), // pending
                      // TaskSegment(1, third), // skipped
                    ]),
                  ),
                  ...state.weeklyTasks.map(
                    (e) => DayTasks('M', [
                      TaskSegment(
                        state.weeklyTasks.getDetails.completed.toDouble(),
                        first,
                      ), // completed
                      TaskSegment(
                        state.weeklyTasks.getDetails.skipped.toDouble(),
                        second,
                      ), // pending
                      TaskSegment(
                        state.weeklyTasks.getDetails.pending.toDouble(),
                        third,
                      ), // skipped
                    ]),
                  ),
                  // DayTasks('M', [
                  //   TaskSegment(3, first), // completed
                  //   TaskSegment(1, second), // pending
                  //   TaskSegment(1, third), // skipped
                  // ]),
                  // DayTasks('T', [
                  //   TaskSegment(4, first),
                  //   TaskSegment(2, second),
                  //   TaskSegment(1, third),
                  // ]),
                  // DayTasks('W', [
                  //   TaskSegment(2, first),
                  //   TaskSegment(1, second),
                  // ]),
                  // DayTasks('T', [
                  //   TaskSegment(3, first),
                  //   TaskSegment(2, second),
                  //   TaskSegment(2, third),
                  // ]),
                  // DayTasks('F', [
                  //   TaskSegment(4, first),
                  //   TaskSegment(2, second),
                  //   TaskSegment(2, third),
                  // ]),
                  // DayTasks('S', [
                  //   TaskSegment(3, first),
                  //   TaskSegment(2, second),
                  //   TaskSegment(1, third),
                  // ]),
                  // DayTasks('S', [
                  //   TaskSegment(2, first),
                  //   TaskSegment(1, second),
                  // ]),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
