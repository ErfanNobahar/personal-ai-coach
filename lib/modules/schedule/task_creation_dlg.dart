import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/modules/schedule/cubit/schedule_cubit.dart';
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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ScheduleCubit>();
    return Scaffold(
      body: ListView(
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: U.Text(text: 'Select Time',),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: U.DateTimePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.parse(
                '${DateTime.now().year.toString()}-01-01',
              ),
              lastDate: DateTime.parse(
                '${(DateTime.now().year + 1).toString()}-01-01',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
