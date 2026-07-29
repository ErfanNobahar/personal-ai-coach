import 'package:flutter/material.dart';
import 'package:personal_ai_coach/modules/schedule/cubit/schedule_cubit.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskCreationBtms extends StatelessWidget {
  static show(
    BuildContext context, {
    required Widget child,
    required ScheduleCubit cubit,
  }) {
    U.BottomSheet.show(
      context,
      useRootNavigator: true,
      child: BlocProvider.value(value: cubit, child: child),
    );
  }

  const TaskCreationBtms({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ScheduleCubit>();
    return Column(
      children: [
        U.Text(
          text: 'new Task',
          textWeight: U.TextWeight.semiBold,
          textSize: U.TextSize.s16,
        ),
        SizedBox(height: 15),
        Divider(height: 2),
        U.Text(text: 'task description', textWeight: U.TextWeight.semiBold),
        SizedBox(height: 8),
        U.TextInput(
          controller: cubit.taskTitleCtrl,
          onEditingComplete: () {
            FocusScope.of(context).nextFocus();
          },
        ),
        SizedBox(height: 8),
        U.TextInput(
          maxLines: null,
          hint: 'Task description',
          controller: cubit.taskDescriptionCtrl,
          onEditingComplete: () {
            FocusScope.of(context).nextFocus();
          },
        ),
      ],
    );
  }
}
