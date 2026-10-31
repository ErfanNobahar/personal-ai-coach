import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_ai_coach/modules/ai_task_manager/cubit/ai_task_manager_cubit.dart';
import 'package:personal_ai_coach/modules/chat/cubit/chat_cubit.dart';
import 'package:personal_ai_coach/modules/roadmap/roadmap_page.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class GoalTextfield extends StatelessWidget {
  final bool isExapnded;
  final ChattingStatus isDisabled;
  final void Function() onSubmit;

  const GoalTextfield({
    required this.onSubmit,
    required this.isDisabled,
    required this.isExapnded,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      // color: U.Theme.field,
      child: Container(
        padding: EdgeInsets.only(top: 10, left: 10, bottom: 10, right: 10),
        decoration: BoxDecoration(
          color: isDisabled == ChattingStatus.clarifing
              ? U.Theme.outlineHigh.withValues(alpha: 0.7)
              : U.Theme.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(isExapnded ? 20 : 50),
        ),
        child: Row(
          children: [
            Expanded(
              child: U.TextInput(
                onExpanded: () {
                  // cubit.onExpanded();
                },
                disabled: isDisabled == ChattingStatus.disabled,
                maxLines: null,
                minLines: null,
                expandOnMultiline: true,
                // color: U.Theme.white,
                expands: true,
                borderRadius: 50.0,
                controller: cubit.goalCtrl,
                onEditingComplete: onSubmit,
              ),
            ),
            SizedBox(width: 16),
            U.IconButton(
              isDisabled: isDisabled == ChattingStatus.disabled,
              icon: U.Icons.subtract,
              onTapped: () async {
                // isDisabled == ChattingStatus.enabled
                // ?
                await cubit.onGoalCreated();
                // : await cubit.onClarified();
              },
              size: 22,
              isPrimary: false,
            ),
          ],
        ),
      ),
    );
    //  Container(
    //   decoration: BoxDecoration(
    //     border: Border.all(width: 1, color: U.Theme.secondaryButton),
    //     borderRadius: BorderRadius.circular(20),
    //     color: U.Theme.background.withValues(alpha: 0.9),
    //   ),
    //   height: 272,
    //   child: Padding(
    //     padding: const EdgeInsets.all(12.0),
    //     child: Stack(
    //       children: [
    //         TextField(
    //           controller: context.read<ChatCubit>().goalCtrl,
    //           maxLines: null,
    //           minLines: null,
    //           expands: true,
    //           decoration: InputDecoration(
    //             contentPadding: EdgeInsets.zero,
    //             isDense: true,
    //             border: InputBorder.none,
    //           ),
    //         ),
    //         Positioned(
    //           bottom: 0,
    //           left: 0,
    //           right: 0,
    //           child: Container(
    //             color: U.Theme.background,
    //             child: Row(
    //               children: [
    //                 // U.IconButton(icon: U.Icons.wrong, onTapped: () {}, size: 22),
    //                 U.OutlineIconButton(onTap: () {}, path: U.Icons.wrong),
    //                 Spacer(),
    //                 U.Button(
    //                   title: 'send',
    //                   onTap: () async {
    //                     final res = await context
    //                         .read<ChatCubit>()
    //                         .onRoadmapGenrated();
    //                     GoRouter.of(context).pushNamed(
    //                       RoadmapPage.route,
    //                       extra: {
    //                         'goal': context.read<ChatCubit>().state.goal,
    //                         'roadMap': res.roadmap,
    //                         'tasks': res.tasks,
    //                       },
    //                     );
    //                   },
    //                   // async {
    //                   // final res = await context
    //                   // .read<ChatCubit>()
    //                   // .onGoalCreated(
    //                   // message: Message(
    //                   // role: 'user',
    //                   // content: context
    //                   // .read<ChatCubit>()
    //                   // .goalCtrl
    //                   // .text,
    //                   // ),
    //                   // );
    //                   // },
    //                   buttonColor: U.ButtonColor.primary,
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
