import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_ai_coach/modules/ai_task_manager/cubit/ai_task_manager_cubit.dart';
import 'package:personal_ai_coach/modules/ai_task_manager/message_field.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class TaskMangerPage extends StatelessWidget {
  static String route = '/taskmanager';

  const TaskMangerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AiTaskManagerCubit(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: U.Theme.afternoonPallet.getColors,
          ),
        ),
        child: Stack(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Align(
                    alignment: AlignmentGeometry.topCenter,
                    child: U.Text(text: 'manage any of your tasks!'),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
            Positioned(
              bottom: 120,
              right: 0,
              left: 0,
              child: Expanded(child: MessageField(onSubmit: () {})),
            ),
          ],
        ),
      ),
    );
  }
}
