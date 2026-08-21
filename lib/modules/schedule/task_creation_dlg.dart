import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:personal_ai_coach/modules/home/cubit/home_cubit.dart';
import 'package:personal_ai_coach/modules/schedule/cubit/schedule_cubit.dart';
import 'package:personal_ai_coach/modules/schedule/schedule_page.dart';
import 'package:personal_ai_coach/modules/schedule/task_detail_dlg.dart';
import 'package:personal_ai_coach/ui_kit/duration_picker_dlg.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

/// Full-screen page for creating a new task.
///
/// Routed via go_router instead of shown as a modal dialog, since it
/// owns a full Scaffold, its own AppBar, and needs to react to
/// ScheduleCubit state changes that are shared across the app (see
/// BusinessRepository's reactive stream for how state stays in sync
/// with other screens/instances of ScheduleCubit).
class TaskCreationPage extends StatelessWidget {
  static String route = '/taskcreationpage';

  final DayTask? task;
  final ScheduleCubit? cubit;
  const TaskCreationPage({super.key, this.task, this.cubit});

  /// Helper to compute the picker's initial end-time offset.
  ///
  /// If no duration has been set yet, defaults to a 60-minute block;
  /// otherwise uses the task's existing estimated duration.
  int _calculateEndTime(int estimatedMinutes) {
    if (estimatedMinutes == 0) {
      return 60;
    }
    return estimatedMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value:
              cubit ??
              ScheduleCubit(
                repo: context.read<BusinessRepository>(),
                initialTask: task,
              ),
        ),
      ],
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: (previous, current) => current.selectedIndex == 1,
        listener: (context, state) {
          print('objectsssssssssssss');
          context.read<ScheduleCubit>().onRefresh();
        },
        child: BlocBuilder<ScheduleCubit, ScheduleState>(
          builder: (context, state) {
            final cubit = context.read<ScheduleCubit>();
            return Scaffold(
              body: Stack(
                children: [
                  ListView(
                    children: [
                      U.AppBar(title: 'newTask', blur: true),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13.0),
                        child: Divider(height: 2),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: U.Text(
                          text: 'Task Title',
                          textWeight: U.TextWeight.semiBold,
                          textSize: U.TextSize.s14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: U.TextInput(
                          hint: 'Task title',
                          color: U.Theme.white,
                          controller: cubit.taskTitleCtrl,
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: U.Text(
                          text: 'Task Description',
                          textWeight: U.TextWeight.semiBold,
                          textSize: U.TextSize.s14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: SizedBox(
                          height: 160,
                          child: U.TextInput(
                            color: U.Theme.white,
                            maxLines: null,
                            hint: 'Task description',
                            controller: cubit.taskDescriptionCtrl,
                            onEditingComplete: () {
                              FocusScope.of(context).nextFocus();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: U.Text(
                          text: 'Select Time',
                          textWeight: U.TextWeight.semiBold,
                          textSize: U.TextSize.s16,
                          color: U.Theme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0,vertical: 5),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: U.Theme.surfaceHigh.withValues(alpha: 0.6)),
                            color: U.Theme.white,
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: U.DateTimePicker(
                                  onDateChanged: cubit.onDateChanged,
                                  initialDate: state.task == null
                                      ? DateTime.now()
                                      : DateFormat(
                                          'MMM d, y',
                                        ).parse(state.task!.date),
                                  firstDate: DateTime.parse(
                                    '${DateTime.now().year.toString()}-01-01',
                                  ),
                                  lastDate: DateTime.parse(
                                    '${(DateTime.now().year + 1).toString()}-01-01',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: U.OutlineButton(
                                  foregroundColor:
                                      U.OutLineButtonForeground.primary,
                                  color: U.OutLineButtonColor.primary,
                                  disabled:
                                      state
                                              .task
                                              ?.primaryTask
                                              .scheduledStartTime ==
                                          '' ||
                                      state
                                              .task
                                              ?.primaryTask
                                              .scheduledStartTime ==
                                          null,
                                  trailing:
                                      (state
                                                  .task
                                                  ?.primaryTask
                                                  .scheduledStartTime ==
                                              null ||
                                          state
                                                  .task
                                                  ?.primaryTask
                                                  .estimatedMinutes ==
                                              0)
                                      ? null
                                      : U.DurationText(
                                          state
                                              .task!
                                              .primaryTask
                                              .estimatedMinutes,
                                        ),
                                  title:
                                      (state
                                                  .task
                                                  ?.primaryTask
                                                  .estimatedMinutes ==
                                              0 ||
                                          state.task?.primaryTask == null)
                                      ? 'Estimated minutes'
                                      : 'Estimated Duration:',
                                  onTap: () async {
                                    final startHour = int.parse(
                                      state.task!.primaryTask.scheduledStartTime
                                          .split(':')[0],
                                    );
                                    final startMinutes = startHour * 60;

                                    final result = await showDurationTimePicker(
                                      context: context,
                                      occupiedSlots: state.occupiedTimes,
                                      initialSlot: TimeSlot(
                                        startMinutes: startMinutes,
                                        endMinutes:
                                            startMinutes +
                                            _calculateEndTime(
                                              state
                                                  .task!
                                                  .primaryTask
                                                  .estimatedMinutes,
                                            ),
                                      ),
                                    );
                                    if (result != null && context.mounted) {
                                      context
                                          .read<ScheduleCubit>()
                                          .onEstimatedTimeAssigned(result);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 0),
                      Container(
                        padding: const EdgeInsets.all(10),
                        color: U.Theme.onBackground,
                        child: U.Button(
                          title: 'Create Task',
                          onTap: () async {
                            final res = await context
                                .read<ScheduleCubit>()
                                .onTaskCreated();
                            print('33333333333');
                            await Future.delayed(Duration(seconds: 2));
                            if (res && context.mounted) {
                              await TaskDetailDialog.show(
                                context,
                                task: state.task!,
                              );
                              context.read<HomeCubit>().onItemsRefreshed();
                              GoRouter.of(context).goNamed(SchedulePage.route);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 185),
                    ],
                  ),
                  // Positioned(
                  //   bottom: 80,
                  //   right: 0,
                  //   left: 0,
                  //   child: Container(
                  //     padding: const EdgeInsets.all(10),
                  //     color: U.Theme.onBackground,
                  //     child: U.Button(
                  //       title: 'Create Task',
                  //       onTap: () async {
                  //         final res = await context
                  //             .read<ScheduleCubit>()
                  //             .onTaskCreated();
                  //         if (res && context.mounted) {
                  //           context.read<HomeCubit>().onItemsRefreshed();
                  //           GoRouter.of(context).pop();
                  //         }
                  //       },
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
