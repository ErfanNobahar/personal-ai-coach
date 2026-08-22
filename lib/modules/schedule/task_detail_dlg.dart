import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:personal_ai_coach/modules/home/cubit/home_cubit.dart';
import 'package:personal_ai_coach/modules/schedule/task_creation_dlg.dart';
import 'package:personal_ai_coach/modules/task/cubit/task_cubit.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class TaskDetailDialog extends StatelessWidget {
  const TaskDetailDialog({super.key, required this.isReadonly});
  final bool isReadonly;
  static const double _maxHeight = 480;
  static const double _maxWidth = 333;

  static Future<dynamic> show(
    BuildContext context, {
    bool isReadonly = false,
    required DayTask task,
    HomeCubit? cubit,
  }) {
    return U.Dialog.show(
      useRootNavigator: true,
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                TaskCubit(task: task, repo: context.read<BusinessRepository>()),
          ),
          BlocProvider.value(value: cubit ?? HomeCubit()),
        ],
        child: TaskDetailDialog(isReadonly: isReadonly),
      ),
      maxHeight: _maxHeight,
      maxWidth: _maxWidth,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder gives us the REAL constraints coming from U.Dialog.show,
    // instead of trusting them blindly. If they're unbounded/infinite for
    // any reason, we clamp to a safe fixed size ourselves so nothing below
    // ever lays out with an infinite or zero constraint.
    return LayoutBuilder(
      builder: (context, constraints) {
        final double safeHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : _maxHeight;
        final double safeWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : _maxWidth;

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: safeHeight,
            maxWidth: safeWidth,
          ),
          child: SizedBox(
            width: safeWidth,
            child: BlocBuilder<TaskCubit, TaskState>(
              builder: (context, state) {
                final task = state.task;

                if (task == null) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: U.Theme.primary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.task_alt_rounded,
                                size: 16,
                                color: U.Theme.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            U.Text(
                              text: 'Task details',
                              textSize: U.TextSize.s16,
                              textWeight: U.TextWeight.bold,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Title + Date
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 65,
                              fit: FlexFit.tight,
                              child: _InfoCard(
                                icon: Icons.edit_note_rounded,
                                label: 'Title',
                                child: U.Text(
                                  text: task.primaryTask.title,
                                  textWeight: U.TextWeight.semiBold,
                                  textSize: U.TextSize.s14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              flex: 35,
                              fit: FlexFit.tight,
                              child: _InfoCard(
                                icon: Icons.calendar_today_rounded,
                                label: 'Date',
                                child: U.Text(
                                  text: task.date,
                                  textWeight: U.TextWeight.semiBold,
                                  textSize: U.TextSize.s14,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Description
                        _InfoCard(
                          icon: Icons.notes_rounded,
                          label: 'Description',
                          child: U.Text(
                            text: task.primaryTask.description,
                            textWeight: U.TextWeight.md,
                            textSize: U.TextSize.s14,
                            color: U.Theme.primaryText,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Status
                        _InfoCard(
                          icon: Icons.flag_rounded,
                          label: 'Status',
                          child: _StatusPill(status: task.status),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: U.Theme.field,
                            border: Border.all(
                              color: U.Theme.outline.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _TimingBlock(
                                  icon: Icons.schedule_rounded,
                                  label: 'Start time',
                                  value: task
                                      .primaryTask
                                      .scheduledStartTime, // TODO: swap for your actual field
                                ),
                              ),
                              Container(
                                width: 1.3,
                                height: 36,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 17,
                                ),
                                color: U.Theme.primaryBorder.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                              Expanded(
                                child: _TimingBlock(
                                  icon: Icons.timelapse_rounded,
                                  label: 'Duration',
                                  value: task.primaryTask.estimatedMinutes
                                      .toString(), // TODO: swap for your actual field
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (!isReadonly)
                          Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 65,
                                    fit: FlexFit.tight,
                                    child: U.Button(
                                      disabled:
                                          task.status ==
                                              DayTaskStatus.completed ||
                                          task.status == DayTaskStatus.skipped,
                                      leading: Icon(
                                        Icons.done_rounded,
                                        color: U.Theme.white,
                                      ),
                                      title: 'Mark as Done',
                                      onTap: () async {
                                        await context
                                            .read<TaskCubit>()
                                            .onStatusChanged(
                                              task.copyWith(
                                                status: DayTaskStatus.completed,
                                              ),
                                            );
                                        context
                                            .read<HomeCubit>()
                                            .onItemsRefreshed();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    flex: 35,
                                    fit: FlexFit.tight,
                                    child: U.OutlineButton(
                                      leading: Icon(
                                        Icons.edit_outlined,
                                        size: 16,
                                        color: U.Theme.primaryText,
                                      ),
                                      title: 'Edit',
                                      onTap: () {
                                        GoRouter.of(context).pop();
                                        GoRouter.of(context).pushNamed(
                                          TaskCreationPage.route,
                                          extra: task,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Destructive action, visually separated
                              U.OutlineButton(
                                disabled:
                                    task.status == DayTaskStatus.completed ||
                                    task.status == DayTaskStatus.skipped,
                                leading: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red.shade400,
                                ),
                                title: 'Delete Task',
                                onTap: () async {
                                  await context
                                      .read<TaskCubit>()
                                      .onTaskDeleted();
                                  context.read<HomeCubit>().onItemsRefreshed();
                                  GoRouter.of(context).pop(true);
                                },
                              ),
                            ],
                          ),

                        // Primary actions
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: U.Theme.field,
        border: Border.all(color: U.Theme.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: U.Theme.quaternaryText),
              const SizedBox(width: 6),
              U.Text(
                text: label,
                color: U.Theme.quaternaryText,
                textSize: U.TextSize.s12,
                textWeight: U.TextWeight.sm,
              ),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final DayTaskStatus status;

  const _StatusPill({required this.status});

  Color get _color {
    switch (status) {
      case DayTaskStatus.completed:
        return const Color(0xFF2FB380);
      case DayTaskStatus.skipped:
        return const Color(0xFFE0625C);
      default:
        return U.Theme.primary;
    }
  }

  IconData get _icon {
    switch (status) {
      case DayTaskStatus.completed:
        return Icons.check_circle_rounded;
      case DayTaskStatus.skipped:
        return Icons.cancel_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 13, color: _color),
          const SizedBox(width: 6),
          U.Text(
            text: status.get,
            textWeight: U.TextWeight.semiBold,
            textSize: U.TextSize.s14,
            color: _color,
          ),
        ],
      ),
    );
  }
}

class _TimingBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TimingBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: U.Theme.quaternaryText),
            const SizedBox(width: 6),
            U.Text(
              text: label,
              color: U.Theme.quaternaryText,
              textSize: U.TextSize.s12,
              textWeight: U.TextWeight.sm,
            ),
          ],
        ),
        const SizedBox(height: 6),
        U.Text(
          text: value,
          textWeight: U.TextWeight.semiBold,
          textSize: U.TextSize.s14,
        ),
      ],
    );
  }
}
