import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/domains/business_repository/models/roadmap.dart';
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:personal_ai_coach/modules/roadmap/cubit/roadmap_cubit.dart';
import 'package:personal_ai_coach/modules/task/task_page.dart';
import 'package:personal_ai_coach/ui_kit/stepper.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class RoadmapPage extends StatelessWidget {
  static String route = '/roadmap';
  final Roadmap? roadMap;
  final String? goal;
  final WeeklyTasks? tasks;
  const RoadmapPage({super.key, required this.roadMap, this.goal, this.tasks});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoadmapCubit(
        initialRoadmap: roadMap,
        repo: context.read<BusinessRepository>(),
        weeklyTasks: tasks,
      ),
      child: BlocBuilder<RoadmapCubit, RoadmapState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: U.Theme.afternoonPallet.getColors,
                begin: AlignmentGeometry.topCenter,
                end: AlignmentGeometry.bottomCenter,
              ),
            ),
            child: ListView(
              children: [
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        U.Text(
                          text: state.roadmap!.goal,
                          textSize: U.TextSize.s18,
                          textWeight: U.TextWeight.bold,
                          color: U.Theme.primaryText,
                        ),
                        U.Text(
                          isCentered: true,
                          text:
                              'we have prepared a roadmap for you to achieve your goal',
                          textSize: U.TextSize.s18,
                          textWeight: U.TextWeight.bold,
                          color: U.Theme.primaryText,
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: U.Stepper(
                    primary: false,
                    id: 1,
                    count: state.count,
                    onExapndedCountChanged: context
                        .read<RoadmapCubit>()
                        .onExpandedCountChanged,
                    // isMoveable: true,
                    useDashedLine: true,
                    items: [
                      ...state.roadmap!.milestones.expand(
                        (item) => [
                          StepperItem(
                            padding: EdgeInsets.zero,
                            itemBackground: U.Theme.secondaryText.withValues(
                              alpha: 1.0,
                            ),
                            subTitle: '${item.title}',
                            inProgress: item.order == 1,
                            isDisabled: item.weeklyObjectives.isEmpty,
                            isDone: false,
                            title: item.title,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: U.Stepper(
                                id: 2,
                                primary: false,

                                // count: state.count,
                                onExapndedCountChanged: context
                                    .read<RoadmapCubit>()
                                    .onExpandedCountChanged,
                                // isMoveable: true,
                                items: [
                                  ...item.weeklyObjectives.expand(
                                    (weeklyobjectives) => [
                                      StepperItem(
                                        loading: state.loading,
                                        padding: EdgeInsets.zero,

                                        itemBackground: U.Theme.white
                                            .withValues(alpha: 0.93),
                                        subTitle:
                                            "week: ${weeklyobjectives.week.toString()}",
                                        inProgress: weeklyobjectives.week == 2,
                                        isDone: weeklyobjectives.week == 1,
                                        title: weeklyobjectives.focus,
                                        onTap: weeklyobjectives.week > 2
                                            ? null
                                            : () {
                                                // print('heyyyyyyyyyyyyyyyy');
                                                // print(
                                                //   'currentMilestone: ${item.toMap()} currentWeek: ${e.week.toString()} ',
                                                // );
                                                context
                                                    .read<RoadmapCubit>()
                                                    .onWeeklyTasksCreated(
                                                      'user goal and state: ${roadMap!.goal} currentMilestone: ${item.toMap().toString()} currentWeek: ${weeklyobjectives.week.toString()} ',
                                                      weeklyobjectives.week,
                                                    );
                                              },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // U.Text(
                                                    //   text:
                                                    //       "week: ${e.week.toString()}",
                                                    // ),
                                                    // SizedBox(height: 5),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 10.0,
                                                          ),
                                                      child: U.Text(
                                                        text: weeklyobjectives
                                                            .outcome,
                                                      ),
                                                    ),
                                                    // if (state.loading)
                                                    //   Column(
                                                    //     children: [
                                                    //       SizedBox(height: 5),
                                                    //       CircularProgressIndicator(),
                                                    //     ],
                                                    //   ),
                                                    U.Stepper(
                                                      id: 3,
                                                      primary: false,
                                                      onExapndedCountChanged:
                                                          context
                                                              .read<
                                                                RoadmapCubit
                                                              >()
                                                              .onExpandedCountChanged,
                                                      // isMoveable: true,
                                                      items: [
                                                        ...weeklyobjectives.weeklyTasks.days.map(
                                                          (e) => StepperItem(
                                                            itemBackground: U
                                                                .Theme
                                                                .white
                                                                .withValues(
                                                                  alpha: 0.93,
                                                                ),
                                                            padding:
                                                                EdgeInsets.zero,
                                                            isDone: false,
                                                            title: e.date,
                                                            child: Row(
                                                              // mainAxisAlignment:
                                                              //     MainAxisAlignment
                                                              //         .spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                      color: U
                                                                          .Theme
                                                                          .background
                                                                          .withValues(
                                                                            alpha:
                                                                                0.7,
                                                                          ),
                                                                      border: Border.all(
                                                                        width:
                                                                            0.7,
                                                                        color: U
                                                                            .Theme
                                                                            .primaryBorder
                                                                            .withValues(
                                                                              alpha: 0.6,
                                                                            ),
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                    child: Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                            8.0,
                                                                          ),
                                                                      child: U.Text(
                                                                        softWrap:
                                                                            true,
                                                                        color: U
                                                                            .Theme
                                                                            .primaryText,
                                                                        text: e
                                                                            .primaryTask
                                                                            .description,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    for (var element
                                                                        in state
                                                                            .roadmap!
                                                                            .milestones[0]
                                                                            .weeklyObjectives[0]
                                                                            .weeklyTasks
                                                                            .days) {
                                                                      print(
                                                                        '  e.iddddd/////////////////////////////////////////////////////////////',
                                                                      );
                                                                      print(
                                                                        element
                                                                            .toMap(),
                                                                      );
                                                                    }

                                                                    // GoRouter.of(
                                                                    //   context,
                                                                    // ).pushNamed(
                                                                    //   SchedulePage.route,
                                                                    //   extra: [
                                                                    //     SpecificTasks(
                                                                    //       day: '1',
                                                                    //       tasks: state.weeklyTasks!.days,
                                                                    //     ),

                                                                    //     SpecificTasks(
                                                                    //       day: e.date,
                                                                    //       tasks: state.weeklyTasks!.days,
                                                                    //     ),
                                                                    //     SpecificTasks(
                                                                    //       day: e.date,
                                                                    //       tasks: state.weeklyTasks!.days,
                                                                    //     ),
                                                                    //     SpecificTasks(
                                                                    //       day: e.date,
                                                                    //       tasks: [],
                                                                    //     ),
                                                                    //   ],
                                                                    // );

                                                                    // List<
                                                                    //   SpecificTasks
                                                                    // >
                                                                    // tasks = state
                                                                    //     .weeklyTasks!
                                                                    //     .days
                                                                    //     .asMap()
                                                                    //     .entries
                                                                    //     .map(
                                                                    //       (
                                                                    //         e,
                                                                    //       ) => SpecificTasks(
                                                                    //         day:
                                                                    //             e.key.toString(),
                                                                    //         tasks: [
                                                                    //           e.value,
                                                                    //         ],
                                                                    //       ),
                                                                    //     )
                                                                    //     .toList();
                                                                    // final list = tasks
                                                                    //     .map(
                                                                    //       (
                                                                    //         e,
                                                                    //       ) => e
                                                                    //           .toMap(),
                                                                    //     )
                                                                    //     .toList();

                                                                    // print(
                                                                    //   'dayasssssssssssssss',
                                                                    // );
                                                                    // print(
                                                                    //   list,
                                                                    // );
                                                                    // final List<
                                                                    //   SpecificTasks
                                                                    // >
                                                                    // specificList =
                                                                    //     List.from(
                                                                    //           list,
                                                                    //         )
                                                                    //         .map(
                                                                    //           (
                                                                    //             e,
                                                                    //           ) => SpecificTasks.fromMap(
                                                                    //             e
                                                                    //           ),
                                                                    //         )
                                                                    //         .toList();
                                                                    // print(
                                                                    //   specificList.length,
                                                                    // );

                                                                    // print(
                                                                    //   'dayasssssssssssssss',
                                                                    // );
                                                                    // print(
                                                                    //   e.primaryTask.scheduledStartTime,
                                                                    // );
                                                                    // print(
                                                                    //   e.primaryTask.scheduledEndTime,
                                                                    // );
                                                                    GoRouter.of(
                                                                      context,
                                                                    ).pushNamed(
                                                                      TaskDetailPage
                                                                          .route,
                                                                      extra: {
                                                                        'milestone':
                                                                            item.title,
                                                                        'task':
                                                                            e,
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                      color: U
                                                                          .Theme
                                                                          .divider
                                                                          .withValues(
                                                                            alpha:
                                                                                0.6,
                                                                          ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            50,
                                                                          ),
                                                                    ),
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                          4,
                                                                        ),
                                                                    child: const Icon(
                                                                      Icons
                                                                          .arrow_right_sharp,
                                                                      size: 21,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 121),
              ],
            ),
          );
        },
      ),
    );
  }
}
