import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/modules/ai_task_manager/cubit/ai_task_manager_cubit.dart';
import 'package:personal_ai_coach/modules/ai_task_manager/message_field.dart';
import 'package:personal_ai_coach/modules/chat/chat_bubble.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class TaskMangerPage extends StatelessWidget {
  static String route = '/taskmanager';

  const TaskMangerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AiTaskManagerCubit(repo: context.read<BusinessRepository>()),
      child: BlocBuilder<AiTaskManagerCubit, AiTaskManagerState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: U.Theme.afternoonPallet.getColors,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Align(
                      alignment: AlignmentGeometry.topCenter,
                      child: U.Text(text: 'manage any of your tasks!'),
                    ),
                    SizedBox(height: 15),
                    if (state.messages.isNotEmpty)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.separated(
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ChatBubble(
                                    rtl: state.messages[index].role == 'user',
                                    text: state.messages[index].content,
                                  ),
                                  if(index== state.messages.length-1)
                                    SizedBox(height: 190),
                                ],
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                                  if (index == state.messages.length -1) {
                                    return SizedBox(height: 115);
                                  }
                                  return SizedBox(height: 12);
                                },
                          ),
                        ),
                      ),
                    // SizedBox(height: 115),
                  ],
                ),
                Positioned(
                  bottom: 120,
                  right: 0,
                  left: 0,
                  child: Expanded(child: MessageField(onSubmit: () {})),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
