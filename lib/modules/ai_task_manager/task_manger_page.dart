import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/domains/business_repository/models/ai_response.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:personal_ai_coach/modules/ai_task_manager/cubit/ai_task_manager_cubit.dart';
import 'package:personal_ai_coach/modules/ai_task_manager/message_field.dart';
import 'package:personal_ai_coach/modules/ai_task_manager/task_confiramtion_card.dart';
import 'package:personal_ai_coach/modules/ai_task_manager/task_deletion_card.dart';
import 'package:personal_ai_coach/modules/chat/chat_bubble.dart';
import 'package:personal_ai_coach/modules/schedule/cubit/schedule_cubit.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class TaskMangerPage extends StatelessWidget {
  static String route = '/taskmanager';

  const TaskMangerPage({super.key});

  Widget getAction(
    String action,
    ChatResponse response, {
    required int key,
    bool disabled = false,
    List<DayTask> tasks = const [],
  }) {
    Widget temp;
    print('++++++++++++++++++++++++++++++++++++++++');
    print(action);
    switch (action) {
      case 'add_task':
        temp = TaskConfiramtionCard(
          modifiedKeys: key,
          isDiabled: disabled,
          tasks: tasks,
        );
      case 'delete_task':
        temp = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
          child: TaskDeletionCard(
            response: response,
            isdisabled: disabled,
            tasks: tasks,
          ),
        );

      case 'reschedule_task':
        temp = TaskConfiramtionCard(
          isDiabled: disabled,
          modifiedKeys: key,
          tasks: tasks,
        );
      default:
        temp = SizedBox();
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AiTaskManagerCubit(repo: context.read<BusinessRepository>()),
        ),
        BlocProvider(
          create: (context) =>
              ScheduleCubit(repo: context.read<BusinessRepository>()),
        ),
      ],
      child: BlocListener<ScheduleCubit, ScheduleState>(
        listenWhen: (previous, current) {
          print('${previous.task} vsssss ${current.task}');
          return previous.task != current.task;
        },
        listener: (context, state) {
          context.read<AiTaskManagerCubit>().onTaskEdited(state.task!);
        },
        child: BlocBuilder<AiTaskManagerCubit, AiTaskManagerState>(
          builder: (context, state) {
            print('state.modifiedTasksssssssssssssss');
            print(state.modifiedTasks);
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
                      if (state.messages.isNotEmpty)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: ListView.separated(
                              itemCount: state.messages.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    if (index == 0) SizedBox(height: 70),
                                    ChatBubble(
                                      rtl: state.messages[index].role == 'user',
                                      text: state.messages[index].content,
                                    ),

                                    if (state.actions.keys
                                            .where((e) => e == index)
                                            .toList()
                                            .isNotEmpty &&
                                        state.actions.isNotEmpty)
                                      getAction(
                                        key: index,
                                        state
                                            .actions[index]!
                                            .proposedAction!
                                            .actionType,
                                        state.actions[index]!,
                                        disabled:
                                            index !=
                                                state
                                                    .actions
                                                    .entries
                                                    .last
                                                    .key ||
                                            state.isGoalAchieved,
                                        tasks: state.modifiedTasks[index]!,
                                      ),
                                    if (index == state.messages.length - 1)
                                      Column(
                                        children: [
                                          if (state.isGoalAchieved) ...[
                                            SizedBox(height: 17),
                                            Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 18,
                                                    ),
                                                child: U.Text(
                                                  isCentered: true,
                                                  text:
                                                      'You have proceeded with your actions, tap to proceed with other actions',
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 7),
                                            U.Button(
                                              title: 'reset',
                                              onTap: context
                                                  .read<AiTaskManagerCubit>()
                                                  .onChatRseted,
                                            ),
                                            SizedBox(height: 12),
                                          ],
                                          SizedBox(height: 190),
                                        ],
                                      ),
                                  ],
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                    if (index == state.messages.length - 1) {
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
                  U.AppBar(title: 'Enhance with AI!', blur: true),
                  Positioned(
                    bottom: 90,
                    right: 0,
                    left: 0,
                    child: Expanded(
                      child: MessageField(
                        isExapnded: state.isExpanded,
                        isDisabled: state.chattingStatus,
                        onSubmit: () {},
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
