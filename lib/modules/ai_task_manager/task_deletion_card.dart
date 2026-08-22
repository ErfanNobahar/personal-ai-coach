import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_ai_coach/domains/business_repository/models/ai_response.dart';
import 'package:personal_ai_coach/modules/ai_task_manager/cubit/ai_task_manager_cubit.dart';
import 'package:personal_ai_coach/modules/home/cubit/home_cubit.dart';
import 'package:personal_ai_coach/modules/schedule/task_detail_dlg.dart';
import 'package:personal_ai_coach/tool_kit/tool_kit.dart' as T;
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class TaskDeletionCard extends StatelessWidget {
  final ChatResponse response;

  const TaskDeletionCard({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    return _EntranceAnimation(
      child: BlocBuilder<AiTaskManagerCubit, AiTaskManagerState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: U.Theme.onSecondaryBackground,
                border: Border.all(
                  color: U.Theme.outline.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: U.Theme.shadow.withValues(alpha: 0.24),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: warning icon + message
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: U.Theme.secondaryBorder.withValues(
                            alpha: 0.18,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.priority_high_rounded,
                          size: 16,
                          color: U.Theme.secondaryBorder,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: U.Text(
                            text:
                                'Are you sure you want to continue with the deletion?',
                            textWeight: U.TextWeight.bold,
                            textSize: U.TextSize.s16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Container(
                    height: 1.7,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          U.Theme.secondaryBorder.withValues(alpha: 0.8),
                          U.Theme.secondaryBorder.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Section label
                  Row(
                    children: [
                      U.Image.icon(path: U.Icons.task, size: 16),
                      const SizedBox(width: 8),
                      U.Text(
                        text: 'SELECTED TASKS',
                        textWeight: U.TextWeight.semiBold,
                        textSize: U.TextSize.s12,
                        color: U.Theme.quaternaryText,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: U.Theme.outline.withValues(alpha: 0.25),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Task list
                  ...state.modifiedTasks.asMap().entries.map(
                    (e) => _TaskTile(index: e.key, task: e.value),
                  ),
                  const SizedBox(height: 11),
                  Divider(color: U.Theme.secondaryBorder,),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: U.Button(title: 'accept', onTap: () async {},buttonColor: U.ButtonColor.secondary,),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: U.OutlineButton(title: 'clarify', onTap: () {},foregroundColor: U.OutLineButtonForeground.primary,color: U.OutLineButtonColor.secondary,),
                      ),
                    ],
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

class _TaskTile extends StatelessWidget {
  final int index;
  final dynamic task; // replace `dynamic` with your actual task entry type

  const _TaskTile({required this.index, required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => TaskDetailDialog.show(
            context,
            isReadonly: true,
            task: task,
            cubit: context.read<HomeCubit>(),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: U.Theme.field,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: U.Theme.primaryBorder.withValues(alpha: 0.40),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: U.Theme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: U.Text(
                    text: '${index + 1}',
                    textSize: U.TextSize.s12,
                    textWeight: U.TextWeight.bold,
                    color: U.Theme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: U.Text(
                    text: task.primaryTask.title,
                    textSize: U.TextSize.s14,
                    textWeight: U.TextWeight.md,
                    color: U.Theme.primaryText,
                  ),
                ),
                const SizedBox(width: 8),
                _RemoveButton(
                  onTap: () {
                    // TODO: swap for your cubit's actual removal method
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: U.Theme.onSecondaryBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: U.Theme.shadow.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: U.Theme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: U.Text(
                        text: '${index + 1}',
                        textSize: U.TextSize.s14,
                        textWeight: U.TextWeight.bold,
                        color: U.Theme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: U.Text(
                        text: task.primaryTask.title,
                        textWeight: U.TextWeight.bold,
                        textSize: U.TextSize.s16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: U.Theme.outline.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                // TODO: swap in real task details (description, due date, etc.)
                U.Text(
                  text:
                      'This task will be permanently removed from your list once you confirm the deletion.',
                  textSize: U.TextSize.s14,
                  color: U.Theme.quaternaryText,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: U.Theme.outline.withValues(alpha: 0.6),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: U.Text(
                          text: 'Close',
                          textWeight: U.TextWeight.semiBold,
                          textSize: U.TextSize.s14,
                          color: U.Theme.primaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: U.Theme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        onPressed: () {},
                        child: U.Text(
                          text: 'Remove',
                          textWeight: U.TextWeight.semiBold,
                          textSize: U.TextSize.s14,
                          color: U.Theme.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RemoveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: U.Theme.secondaryBorder.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            size: 15,
            color: U.Theme.secondaryBorder,
          ),
        ),
      ),
    );
  }
}

/// One-time fade + slide-in entrance animation.
class _EntranceAnimation extends StatefulWidget {
  final Widget child;

  const _EntranceAnimation({required this.child});

  @override
  State<_EntranceAnimation> createState() => _EntranceAnimationState();
}

class _EntranceAnimationState extends State<_EntranceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
