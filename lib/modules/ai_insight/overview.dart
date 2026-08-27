import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:personal_ai_coach/modules/ai_insight/cubit/ai_insight_cubit.dart';
import 'package:personal_ai_coach/modules/ai_insight/overview_card.dart';
import 'package:personal_ai_coach/ui_kit/chart.dart';
import 'package:personal_ai_coach/tool_kit/tool_kit.dart' as T;
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class Overview extends StatelessWidget {
  Overview({super.key});
  final first = U.Theme.primary;
  final second = U.Theme.secondaryButton;
  final third = U.Theme.divider;
  final List<String> days = ['M', 'T', 'W', 'Th', 'F', 'S', 'S'];
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiInsightCubit, AiInsightState>(
      builder: (context, state) {
        print('state.weeklyTasks.length');
        print(state.weeklyTasks.length);
        // print(T.DateFormater.dateFromString(state.weeklyTasks[0].day));
        return state.loading
            ? CircularProgressIndicator()
            : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Divider(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        U.Image.icon(path: U.Icons.week, size: 22),
                        SizedBox(width: 8),

                        U.Text(
                          text: 'Current weeks analystics:',
                          textSize: U.TextSize.s16,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OverviewCard(tasks: state.weeklyTasks),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 9.0,
                      horizontal: 13,
                    ),
                    child: Row(
                      children: [
                        U.Image.icon(path: U.Icons.chart, size: 26),
                        SizedBox(width: 8),

                        U.Text(
                          text: 'this weeks chart:',
                          textSize: U.TextSize.s16,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TaskBarChart(
                      data: [
                        ...List.generate(7, (index) {
                          // print('state.weeklyTasks.length');

                          final List<SpecificTasks> task = state.weeklyTasks;
                          Map<int, SpecificTasks> maped = {};
                          for (var i = 0; i < task.length; i++) {
                            maped.addEntries(
                              <int, SpecificTasks>{
                                T.DateFormater.dateFromString(
                                  task[i].day,
                                ).weekday -1: task[i],
                              }.entries,
                            );
                          }
                          // print(
                          //   index -
                          //       T.DateFormater.dateFromString(
                          //         state.weeklyTasks[index].day,
                          //       ).weekday,
                          // );
                          // print(
                          //   (index + 1 > state.weeklyTasks.length ||
                          //       T.DateFormater.dateFromString(
                          //             state.weeklyTasks[index].day,
                          //           ).weekday !=
                          //           index + 1),
                          // );
                          final bool condition = maped.entries.where((e) {
                            print('${e.key} vsssssss $index');
                            return e.key == index;
                          }).isEmpty;
                          print(maped.entries.where((e) => e.key == index));
                          print('==================================');
                          return (condition
                              // index + 1 > state.weeklyTasks.length &&
                              // T.DateFormater.dateFromString(
                              //       state.weeklyTasks[0].day,
                              //     ).weekday !=
                              //     index + 1
                              )
                              ? DayTasks(days[index], [TaskSegment(1, second)])
                              : DayTasks(
                                  days[index
                                  // index -
                                  //   T.DateFormater.dateFromString(
                                  //     state.weeklyTasks[index].day,
                                  //   ).weekday
                                  ],

                                  [
                                    TaskSegment(
                                      maped[index]!.tasks.getDetails.completed
                                          .toDouble(),
                                      // state
                                      //     .weeklyTasks[index -
                                      //         T.DateFormater.dateFromString(
                                      //           state.weeklyTasks[index].day,
                                      //         ).weekday]
                                      //     .tasks
                                      //     .getDetails
                                      //     .completed
                                      //     .toDouble(),
                                      first,
                                    ), // completed
                                    TaskSegment(
                                      maped[index]!.tasks.getDetails.skipped
                                          .toDouble(),

                                      // state
                                      //     .weeklyTasks[index -
                                      //         T.DateFormater.dateFromString(
                                      //           state.weeklyTasks[index].day,
                                      //         ).weekday]
                                      //     .tasks
                                      //     .getDetails
                                      //     .skipped
                                      //     .toDouble(),
                                      second,
                                    ), // pending
                                    TaskSegment(
                                      maped[index]!.tasks.getDetails.pending
                                          .toDouble(),
                                      // state
                                      //     .weeklyTasks[index -
                                      //         T.DateFormater.dateFromString(
                                      //           state.weeklyTasks[index].day,
                                      //         ).weekday]
                                      //     .tasks
                                      //     .getDetails
                                      //     .pending
                                      //     .toDouble(),
                                      third,
                                    ), // skipped
                                  ],
                                );
                        }),
                        // ...state.weeklyTasks.map(
                        //   (e) => DayTasks(
                        //     days[T.DateFormater.dateFromString(e.day).weekday -
                        //         1],
                        //     [
                        //       TaskSegment(
                        //         e.tasks.getDetails.completed.toDouble(),
                        //         first,
                        //       ), // completed
                        //       TaskSegment(
                        //         e.tasks.getDetails.skipped.toDouble(),
                        //         second,
                        //       ), // pending
                        //       TaskSegment(
                        //         e.tasks.getDetails.pending.toDouble(),
                        //         third,
                        //       ), // skipped
                        //     ],
                        //   ),
                        // ),
                        // // DayTasks('M', [
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
                  SizedBox(height: 140),
                ],
              );
      },
    );
  }
}
