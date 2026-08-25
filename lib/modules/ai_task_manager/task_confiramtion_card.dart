import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_ai_coach/domains/business_repository/models/ai_response.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:personal_ai_coach/modules/ai_task_manager/cubit/ai_task_manager_cubit.dart';
import 'package:personal_ai_coach/modules/home/cubit/home_cubit.dart';
import 'package:personal_ai_coach/modules/schedule/cubit/schedule_cubit.dart';
import 'package:personal_ai_coach/modules/schedule/task_creation_dlg.dart';
import 'package:personal_ai_coach/modules/schedule/task_detail_dlg.dart';
import 'package:personal_ai_coach/tool_kit/tool_kit.dart' as T;
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class TaskConfiramtionCard extends StatelessWidget {
  final List<DayTask> tasks;
  final int modifiedKeys;
  const TaskConfiramtionCard({
    super.key,
    required this.tasks,
    required this.modifiedKeys,
  });

  @override
  Widget build(BuildContext context) {
    print('<>>>>>>>>>>>>>>>>>>>>>>>>>><<><><><><><><><><><><>');
    print(tasks);
    return Column(
      children: [
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          // height: 44,
          decoration: BoxDecoration(
            border: Border.all(
              color: U.Theme.secondaryButton.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(15),
            color: U.Theme.onSecondaryBackground,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              U.Text(
                text: 'Your task is ready do want to proceed',
                textWeight: U.TextWeight.bold,
                textSize: U.TextSize.s14,
              ),
              SizedBox(height: 5),
              SizedBox(
                width: 144,
                child: Divider(color: U.Theme.secondaryBorder, thickness: 3),
              ),
              SizedBox(height: 15),
              tasks.length == 1
                  ? Column(
                      children: [
                        Row(
                          children: [
                            U.Text(text: 'Title:', textSize: U.TextSize.s14),
                            SizedBox(width: 8),
                            U.Text(text: tasks[0].primaryTask.title),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            U.Text(
                              text: 'Scheduled Date:',
                              textSize: U.TextSize.s14,
                            ),
                            SizedBox(width: 8),
                            U.Text(
                              text: T.DateFormater.formatString(tasks[0].date),
                            ),
                            SizedBox(width: 8),
                            U.Text(
                              text:
                                  ', ${tasks[0].primaryTask.scheduledStartTime}',
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            U.Text(
                              text: 'Description:',
                              textSize: U.TextSize.s14,
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: U.Text(
                                text: tasks[0].primaryTask.description,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            U.Text(
                              text: 'Estimated Duration:',
                              textSize: U.TextSize.s14,
                            ),
                            SizedBox(width: 8),
                            U.Text(
                              text: tasks[0].primaryTask.estimatedMinutes
                                  .toString(),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        ...tasks.asMap().entries.map(
                          (e) => _TaskTile(
                            modifiedKeys: modifiedKeys,
                            index: e.key,
                            task: e.value,
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 20),
              tasks.length == 1
                  ? U.OutlineButton(
                      foregroundColor: U.OutLineButtonForeground.primary,
                      title: 'Edit',
                      onTap: () async {
                        final res = await GoRouter.of(
                          context,
                        ).pushNamed(TaskCreationPage.route, extra: tasks[0]);
                      },
                      leading: Icon(Icons.edit, color: U.Theme.primaryText),
                    )
                  : SizedBox(),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: U.Button(
                      title: 'Accept',
                      onTap: () async {
                        context.read<AiTaskManagerCubit>().onAddtaskConfirmed();
                      },
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: U.OutlineButton(
                      title: 'clarify',
                      onTap: () {
                        context.read<AiTaskManagerCubit>().onClarified();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  final int index;
  final DayTask task; // replace `dynamic` with your actual task entry type
  final int modifiedKeys;
  const _TaskTile({
    required this.index,
    required this.task,
    required this.modifiedKeys,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ScheduleCubit>();
    print('1111111111111111111111111111111111');
    print(task);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => TaskDetailDialog.show(
            context,
            isEditonly: true,
            task: task,
            scheduleCubit: cubit,
            cubit: context.read<HomeCubit>(),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: U.Theme.field,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: U.Theme.primaryBorder.withValues(alpha: 0.40),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: U.Theme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: U.Text(
                    text: '${index + 1}',
                    textSize: U.TextSize.s12,
                    textWeight: U.TextWeight.bold,
                    color: U.Theme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: U.Text(
                    text: task.primaryTask.title,
                    textSize: U.TextSize.s14,
                    textWeight: U.TextWeight.md,
                    color: U.Theme.primaryText,
                  ),
                ),
                const SizedBox(width: 12),
                _RemoveButton(
                  onTap: () => context.read<AiTaskManagerCubit>().onItemRemoved(
                    modifiedKeys,
                    task,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RemoveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: U.Theme.secondaryBorder.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            size: 15,
            color: U.Theme.secondaryBorder,
          ),
        ),
      ),
    );
  }
}
