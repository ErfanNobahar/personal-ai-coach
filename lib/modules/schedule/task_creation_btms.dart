import 'package:flutter/material.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/modules/schedule/cubit/schedule_cubit.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskCreationBtms extends StatelessWidget {
  static void show(BuildContext context, {ScheduleCubit? cubit}) {
    U.BottomSheet.show(
      context,
      maxwidth: double.infinity,
      maxHeight: 644,
      useRootNavigator: true,
      child: BlocProvider.value(
        value: cubit ?? ScheduleCubit(repo: context.read<BusinessRepository>()),
        child: TaskCreationBtms(),
      ),
    );
  }

  const TaskCreationBtms({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ScheduleCubit>();
    return ListView(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: U.Text(
            text: 'new Task',
            textWeight: U.TextWeight.semiBold,
            textSize: U.TextSize.s16,
          ),
        ),
        SizedBox(height: 15),
        Divider(height: 2),
        SizedBox(height: 10),
        U.Text(
          text: 'Task Title',
          textWeight: U.TextWeight.semiBold,
          textSize: U.TextSize.s14,
        ),
        SizedBox(height: 8),
        U.TextInput(
          controller: cubit.taskTitleCtrl,
          onEditingComplete: () {
            FocusScope.of(context).nextFocus();
          },
        ),
        SizedBox(height: 15),
        U.Text(
          text: 'Task Description',
          textWeight: U.TextWeight.semiBold,
          textSize: U.TextSize.s14,
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: U.TextInput(
            maxLines: null,
            hint: 'Task description',
            controller: cubit.taskDescriptionCtrl,
            onEditingComplete: () {
              FocusScope.of(context).nextFocus();
            },
          ),
        ),
        SizedBox(height: 15),
        U.DateTimePicker(
          initialDate: DateTime.now(),
          firstDate: DateTime.parse('${DateTime.now().year.toString()}-01-01'),
          lastDate: DateTime.parse(
            '${(DateTime.now().year + 1).toString()}-01-01',
          ),
        ),
      ],
    );
  }
}
