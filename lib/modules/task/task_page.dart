import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:personal_ai_coach/modules/task/cubit/task_cubit.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;
import 'package:personal_ai_coach/tool_kit/tool_kit.dart' as T;
// Adjust these imports to match your actual project structure

class TaskDetailPage extends StatelessWidget {
  static String route = '/taskdetail';

  final String? milestoneTitle;
  final DayTask? initialTask;

  const TaskDetailPage({
    super.key,
    required this.milestoneTitle,
    this.initialTask,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskCubit(task: initialTask),
      child: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: U.Theme.background,
            // appBar: AppBar(
            //   backgroundColor: U.Theme.background,
            //   elevation: 0,
            //   iconTheme: IconThemeData(color: U.Theme.primaryText),
            //   title: Text(
            //     'Today\'s Task',
            //     style: TextStyle(
            //       color: U.Theme.primaryText,
            //       fontWeight: FontWeight.bold,
            //       fontSize: 18,
            //     ),
            //   ),
            // ),
            body: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 77),
                        milestoneTitle != null
                            ? _MilestoneBreadcrumb(
                                milestoneTitle: milestoneTitle!,
                              )
                            : SizedBox(),
                        const SizedBox(height: 16),
                        _StatusBadge(status: state.task!.status),
                        const SizedBox(height: 12),
                        Text(
                          state.task!.date,
                          style: TextStyle(
                            color: U.Theme.primaryText,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _MetaRow(
                          estimatedMinutes:
                              state.task!.primaryTask.estimatedMinutes,
                          type: state.task!.primaryTask.type,
                        ),
                        const SizedBox(height: 24),

                        _SectionCard(
                          title: 'What to do',
                          child: Text(
                            state.task!.primaryTask.description,
                            style: TextStyle(
                              color: U.Theme.primaryText,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _WhyItMattersCard(
                          text: state.task!.primaryTask.whyItMatters,
                        ),

                        if (state
                            .task!
                            .primaryTask
                            .suggestedSearches
                            .isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(
                            'Helpful resources',
                            style: TextStyle(
                              color: U.Theme.tertiaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: state.task!.primaryTask.suggestedSearches
                                .map(
                                  (s) => _SearchChip(
                                    query: s.query,
                                    onTap: () => T.Launcher.url(
                                      'https://www.google.com/search?q=${Uri.encodeComponent(s.query)} ',
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],

                        if (state.task!.supportingTasks.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Optional extras',
                            style: TextStyle(
                              color: U.Theme.tertiaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...state.task!.supportingTasks.map(
                            (t) => _SupportingTaskTile(task: t),
                          ),
                        ],

                        const SizedBox(height: 32),
                        _ActionButtons(
                          onComplete: () {},
                          onSkip: () {},
                          onReschedule: () {},
                        ),
                        SizedBox(height: 110),
                      ],
                    ),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: U.AppBar(title: 'todays task', blur: true),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MilestoneBreadcrumb extends StatelessWidget {
  final String milestoneTitle;
  const _MilestoneBreadcrumb({required this.milestoneTitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.map_outlined, size: 14, color: U.Theme.quaternaryText),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Part of: $milestoneTitle',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: U.Theme.quaternaryText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _bg {
    switch (status) {
      case 'completed':
        return U.Theme.surface;
      case 'skipped':
        return U.Theme.tertiaryButton;
      default:
        return U.Theme.onBackground;
    }
  }

  String get _label {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'skipped':
        return 'Skipped';
      case 'partial':
        return 'Partially done';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: U.Theme.primaryText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final int estimatedMinutes;
  final String type;
  const _MetaRow({required this.estimatedMinutes, required this.type});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.schedule, size: 16, color: U.Theme.secondaryButton),
        const SizedBox(width: 4),
        Text(
          '$estimatedMinutes min',
          style: TextStyle(
            color: U.Theme.secondaryButton,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(color: U.Theme.outline),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            type,
            style: TextStyle(
              color: U.Theme.tertiaryText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: U.Theme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: U.Theme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: U.Theme.tertiaryText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _WhyItMattersCard extends StatelessWidget {
  final String text;
  const _WhyItMattersCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: U.Theme.onBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: U.Theme.outlineHigh, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 14, color: U.Theme.outlineHigh),
              const SizedBox(width: 6),
              Text(
                'Why this matters',
                style: TextStyle(
                  color: U.Theme.outlineHigh,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              color: U.Theme.primaryText,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  const _SearchChip({required this.query, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: U.Theme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: U.Theme.primaryBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 14, color: U.Theme.primary),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(
                query,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: U.Theme.primaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportingTaskTile extends StatelessWidget {
  final SupportingTask task;
  const _SupportingTaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: U.Theme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: U.Theme.outline),
      ),
      child: Row(
        children: [
          Icon(Icons.circle_outlined, size: 16, color: U.Theme.secondaryButton),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                color: U.Theme.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${task.estimatedMinutes}m',
            style: TextStyle(
              color: U.Theme.quaternaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final VoidCallback onReschedule;

  const _ActionButtons({
    required this.onComplete,
    required this.onSkip,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        U.Button(
          title: 'Mark as compelete',
          onTap: onComplete,
          buttonColor: U.ButtonColor.primary,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: U.OutlineButton(
                title: 'reschedule',
                onTap: onReschedule,
                color: U.OutLineButtonColor.secondary,
                foregroundColor: U.OutLineButtonForeground.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: U.OutlineButton(
                title: 'skip',
                onTap: onSkip,
                color: U.OutLineButtonColor.secondary,
                foregroundColor: U.OutLineButtonForeground.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
