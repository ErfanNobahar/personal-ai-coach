import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_ai_coach/modules/chat/cubit/chat_cubit.dart';
import 'package:personal_ai_coach/modules/roadmap/roadmap_page.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class GoalTextfield extends StatelessWidget {
  const GoalTextfield({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: U.Theme.secondaryButton),
        borderRadius: BorderRadius.circular(20),
        color: U.Theme.background.withValues(alpha: 0.9),
      ),
      height: 272,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            TextField(
              controller: context.read<ChatCubit>().goalCtrl,
              maxLines: null,
              minLines: null,
              expands: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                isDense: true,
                border: InputBorder.none,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: U.Theme.background,
                child: Row(
                  children: [
                    // U.IconButton(icon: U.Icons.wrong, onTapped: () {}, size: 22),
                    U.OutlineIconButton(onTap: () {}, path: U.Icons.wrong),
                    Spacer(),
                    U.Button(
                      title: 'send',
                      onTap: () async {
                        final res = await context
                            .read<ChatCubit>()
                            .onRoadmapGenrated();
                        GoRouter.of(context).pushNamed(
                          RoadmapPage.route,
                          extra: {
                            'goal': context.read<ChatCubit>().state.goal,
                            'roadMap': res.roadmap,
                            'tasks': res.tasks,
                          },
                        );
                      },
                      // async {
                      // final res = await context
                      // .read<ChatCubit>()
                      // .onGoalCreated(
                      // message: Message(
                      // role: 'user',
                      // content: context
                      // .read<ChatCubit>()
                      // .goalCtrl
                      // .text,
                      // ),
                      // );
                      // },
                      buttonColor: U.ButtonColor.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
