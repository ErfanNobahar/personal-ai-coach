import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_ai_coach/domains/business_repository/models/ai_response.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:personal_ai_coach/modules/schedule/task_creation_dlg.dart';
import 'package:personal_ai_coach/tool_kit/tool_kit.dart' as T;
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class TaskConfiramtionCard extends StatelessWidget {
  final ChatResponse response;
  const TaskConfiramtionCard({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          // height: 44,
          decoration: BoxDecoration(
            border: Border.all(
              color: U.Theme.secondaryButton.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(15),
            color: U.Theme.onSecondaryBackground,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              U.Text(
                text: 'Your task is ready do want to proceed',
                textWeight: U.TextWeight.bold,
                textSize: U.TextSize.s14,
              ),
              SizedBox(height: 5),
              SizedBox(
                width: 144,
                child: Divider(color: U.Theme.secondaryBorder, thickness: 3),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  U.Text(text: 'Title:', textSize: U.TextSize.s14),
                  SizedBox(width: 8),
                  U.Text(text: response.proposedAction!.task!.title),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  U.Text(text: 'Scheduled Date:', textSize: U.TextSize.s14),
                  SizedBox(width: 8),
                  U.Text(
                    text: T.DateFormater.formatString(
                      response.proposedAction!.date,
                    ),
                  ),
                  SizedBox(width: 8),
                  U.Text(
                    text:
                        ', ${response.proposedAction!.task!.scheduledStartTime}',
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  U.Text(text: 'Description:', textSize: U.TextSize.s14),
                  SizedBox(width: 8),
                  Flexible(
                    child: U.Text(
                      text: response.proposedAction!.task!.description,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  U.Text(text: 'Estimated Duration:', textSize: U.TextSize.s14),
                  SizedBox(width: 8),
                  U.Text(
                    text: response.proposedAction!.task!.estimatedMinutes
                        .toString(),
                  ),
                ],
              ),
              SizedBox(height: 20),
              U.OutlineButton(
                foregroundColor: U.OutLineButtonForeground.primary,
                title: 'Edit',
                onTap: () async {
                  final res = await GoRouter.of(context).pushNamed(
                    TaskCreationPage.route,
                    extra: DayTask(
                      roadmapId: '',
                      date: T.DateFormater.formatString(
                        response.proposedAction!.date,
                      ),
                      status: DayTaskStatus.pending,
                      scheduledTimeSlot: '',
                      scheduledTimeLabel: '',
                      primaryTask: PrimaryTask(
                        id: '',
                        title: response.proposedAction!.task!.title,
                        description: response.proposedAction!.task!.description,
                        estimatedMinutes:
                            response.proposedAction!.task!.estimatedMinutes,
                        scheduledStartTime:
                            response.proposedAction!.task!.scheduledStartTime,
                        scheduledEndTime: '',
                        type: response.proposedAction!.task!.type,
                        whyItMatters:
                            response.proposedAction!.task!.whyItMatters,
                        suggestedSearches:
                            response.proposedAction!.task!.suggestedSearches,
                      ),
                      supportingTasks: [],
                    ),
                  );
                },
                leading: Icon(Icons.edit, color: U.Theme.primaryText),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: U.Button(title: 'accept', onTap: () async {}),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: U.OutlineButton(title: 'clarify', onTap: () {}),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
