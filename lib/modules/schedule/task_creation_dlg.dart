import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/modules/schedule/cubit/schedule_cubit.dart';
import 'package:personal_ai_coach/ui_kit/duration_picker_dlg.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class TaskCreationDialolg extends StatelessWidget {
  static Future<dynamic> show(
    BuildContext context, {
    ScheduleCubit? scheduleCubit,
  }) {
    return U.Dialog.show(
      radius: 15,
      isFullScreen: true,
      pading: EdgeInsets.all(18),
      BlocProvider.value(
        value:
            scheduleCubit ??
            ScheduleCubit(repo: context.read<BusinessRepository>()),
        child: TaskCreationDialolg(),
      ),
      maxHeight: MediaQuery.of(context).size.height,
      maxWidth: MediaQuery.of(context).size.width,
      context: context,
    );
  }

  const TaskCreationDialolg({super.key});

  int calculateEndTime(int time, int s) {
    if (time == 0) {
      print('time');
      print(time);
      print(s + 60);
      return 60;
    } else {
      print('timeeeeeeeeeeeeeeee');
      print(time);
      print(s + 60);
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ScheduleCubit>();
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  U.AppBar(title: 'newTask', blur: true),
                  // Center(
                  //   child: U.Text(
                  //     text: 'new Task',
                  //     textWeight: U.TextWeight.semiBold,
                  //     textSize: U.TextSize.s16,
                  //   ),
                  // ),
                  // SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Divider(height: 2),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: U.Text(
                      text: 'Task Title',
                      textWeight: U.TextWeight.semiBold,
                      textSize: U.TextSize.s14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: U.TextInput(
                      color: U.Theme.onBackground,
                      controller: cubit.taskTitleCtrl,
                      onEditingComplete: () {
                        FocusScope.of(context).nextFocus();
                      },
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: U.Text(
                      text: 'Task Description',
                      textWeight: U.TextWeight.semiBold,
                      textSize: U.TextSize.s14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: SizedBox(
                      height: 160,
                      child: U.TextInput(
                        color: U.Theme.onBackground,
                        maxLines: null,
                        hint: 'Task description',
                        controller: cubit.taskDescriptionCtrl,
                        onEditingComplete: () {
                          FocusScope.of(context).nextFocus();
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: U.Theme.secondaryButton.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18.0,
                            ),
                            child: U.Text(
                              text: 'Select Time',
                              textWeight: U.TextWeight.bold,
                              textSize: U.TextSize.s16,
                              color: U.Theme.primaryText,
                            ),
                          ),
                          SizedBox(height: 10),
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
                          SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: U.OutlineButton(
                              foregroundColor:
                                  U.OutLineButtonForeground.primary,
                              color: U.OutLineButtonColor.primary,
                              // size: U.OutlineButtonSize.small,
                              disabled:
                                  state.task?.primaryTask.scheduledStartTime ==
                                      '' ||
                                  state.task?.primaryTask.scheduledStartTime ==
                                      null,
                              trailing:
                                  (state.task?.primaryTask.scheduledStartTime ==
                                          null ||
                                      state
                                              .task
                                              ?.primaryTask
                                              .estimatedMinutes ==
                                          0)
                                  ? null
                                  : U.DurationText(
                                      state.task!.primaryTask.estimatedMinutes,
                                    ),
                              title:
                                  (state.task?.primaryTask.estimatedMinutes ==
                                          0 ||
                                      state.task?.primaryTask == null)
                                  ? 'Estimated minutes'
                                  : 'Estimated Duration:',
                              onTap: () async {
                                final result = await showDurationTimePicker(
                                  context: context,
                                  occupiedSlots: state.occupiedTimes,
                                  //  const [

                                  // TimeSlot(startMinutes: 4 * 60, endMinutes: 5 * 60 + 30), // 4:00-5:30 AM
                                  // TimeSlot(startMinutes: 13 * 60, endMinutes: 14 * 60),    // 1:00-2:00 PM
                                  // ],
                                  initialSlot: TimeSlot(
                                    startMinutes:
                                        int.parse(
                                          state
                                              .task!
                                              .primaryTask
                                              .scheduledStartTime
                                              .split(':')[0],
                                        ) *
                                        60,
                                    endMinutes:
                                        int.parse(
                                              state
                                                  .task!
                                                  .primaryTask
                                                  .scheduledStartTime
                                                  .split(':')[0],
                                            ) *
                                            60 +
                                        calculateEndTime(
                                          state
                                              .task!
                                              .primaryTask
                                              .estimatedMinutes,
                                          int.parse(
                                                state
                                                    .task!
                                                    .primaryTask
                                                    .scheduledStartTime
                                                    .split(':')[0],
                                              ) *
                                              60,
                                        ),
                                  ),
                                );
                                if (result != null) {
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
                  SizedBox(height: 75),
                ],
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                  padding: EdgeInsets.all(10),
                  color: U.Theme.onBackground,
                  child: U.Button(
                    title: 'Create Task',
                    onTap: () async {
                      final res = await context
                          .read<ScheduleCubit>()
                          .onTaskCreated();
                      if (res) GoRouter.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
