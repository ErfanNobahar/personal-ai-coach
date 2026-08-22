import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_ai_coach/modules/ai_task_manager/cubit/ai_task_manager_cubit.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class MessageField extends StatelessWidget {
  final ChattingStatus isDisabled;
  final void Function() onSubmit;

  const MessageField({
    super.key,
    required this.onSubmit,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      // color: U.Theme.field,
      child: Container(
        padding: EdgeInsets.only(top: 10, left: 10, bottom: 10, right: 10),
        decoration: BoxDecoration(
          color: isDisabled == ChattingStatus.clarifing
              ? U.Theme.outlineHigh.withValues(alpha: 0.7)
              : U.Theme.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            Expanded(
              child: U.TextInput(
                disabled: isDisabled == ChattingStatus.disabled,
                maxLines: null,
                minLines: null,
                expandOnMultiline: true,
                // color: U.Theme.white,
                expands: true,
                borderRadius: 50.0,
                controller: context.read<AiTaskManagerCubit>().messageCtrl,
                onEditingComplete: onSubmit,
              ),
            ),
            SizedBox(width: 16),
            U.IconButton(
              isDisabled: isDisabled == ChattingStatus.disabled,
              icon: U.Icons.subtract,
              onTapped: () async {
               isDisabled == ChattingStatus.enabled?
                await context.read<AiTaskManagerCubit>().onMessageSent():
                await context.read<AiTaskManagerCubit>().onClarified();
              },
              size: 22,
              isPrimary: false,
            ),
          ],
        ),
      ),
    );
  }
}
