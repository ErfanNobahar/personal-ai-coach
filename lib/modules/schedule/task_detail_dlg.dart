import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:personal_ai_coach/modules/schedule/task_creation_dlg.dart';
import 'package:personal_ai_coach/modules/task/cubit/task_cubit.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class TaskDetailDialog extends StatelessWidget {
  const TaskDetailDialog({super.key});

  static Future<dynamic> show(BuildContext context, {required DayTask task}) {
    return U.Dialog.show(
      useRootNavigator: true,
      BlocProvider(
        create: (context) =>
            TaskCubit(task: task, repo: context.read<BusinessRepository>()),
        child: TaskDetailDialog(),
      ),
      maxHeight: 454,
      maxWidth: 333,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(11.0),
      child: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          print('object');
          print(state.task!.status.get);
          return ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              U.Text(text: 'Task details', textSize: U.TextSize.s16),
              SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 70,
                    child: Container(
                      padding: EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          width: 1,
                          color: U.Theme.secondaryButton,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          U.Text(
                            textWeight: U.TextWeight.sm,
                            text: 'title',
                            color: U.Theme.quaternaryText,
                          ),
                          SizedBox(height: 5),
                          U.Text(text: state.task!.primaryTask.title),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    flex: 30,
                    child: Container(
                      padding: EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          width: 1,
                          color: U.Theme.secondaryButton,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          U.Text(
                            text: 'date',
                            color: U.Theme.quaternaryText,
                            textWeight: U.TextWeight.sm,
                          ),
                          SizedBox(height: 5),
                          U.Text(text: state.task!.date),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(11),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(width: 1, color: U.Theme.secondaryButton),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    U.Text(
                      text: 'description',
                      color: U.Theme.quaternaryText,
                      textSize: U.TextSize.s12,
                      textWeight: U.TextWeight.sm,
                    ),
                    SizedBox(height: 5),
                    U.Text(
                      text: state.task!.primaryTask.description,
                      textWeight: U.TextWeight.semiBold,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      width: 1,
                      color: U.Theme.secondaryButton,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      U.Text(text: 'Status', textWeight: U.TextWeight.sm),
                      SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_rounded, size: 14),
                          SizedBox(width: 7),
                          U.Text(
                            text: state.task!.status.get,
                            textWeight: U.TextWeight.semiBold,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 23),
              Row(
                children: [
                  Expanded(
                    flex: 70,
                    child: U.Button(
                      disabled:
                          (state.task!.status == DayTaskStatus.completed ||
                          state.task!.status == DayTaskStatus.skipped),
                      leading: Icon(Icons.done, color: U.Theme.white),
                      title: 'Mark as Done',
                      onTap: () {
                        context.read<TaskCubit>().onStatusChanged(
                          state.task!.copyWith(status: DayTaskStatus.completed),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 30,
                    child: U.OutlineButton(
                      title: 'Edit',
                      onTap: () {
                        GoRouter.of(context).pop();
                        TaskCreationDialolg.show(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
