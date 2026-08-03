import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:personal_ai_coach/modules/schedule/cubit/schedule_cubit.dart';
import 'package:personal_ai_coach/modules/schedule/task_creation_dlg.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class DailySchedule extends StatelessWidget {
  final List<DayTask> tasks;
  const DailySchedule({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 15),
        ...tasks.expand((e) => [TaskCard(task: e), SizedBox(height: 12)]),
        SizedBox(height: 21),
        // Expanded(
        //   child: ListView.separated(
        //     itemBuilder: (context, index) {
        //       return TaskCard(task: tasks[index]);
        //     },
        //     separatorBuilder: (context, index) => SizedBox(height: 8),
        //     itemCount: tasks.length,
        //   ),
        // ),
      ],
    );
  }
}

class TaskCard extends StatelessWidget {
  final DayTask task;
  const TaskCard({super.key, required this.task});

  bool isCurrent() {
    final currentHour = DateTime.now().hour;
    final part1 = task.primaryTask.scheduledStartTime.split(':')[0];
    return currentHour.toString() == part1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              flex: 10,
              child: Center(
                child: U.Text(
                  text: isCurrent()
                      ? 'NOW'
                      : task.primaryTask.scheduledStartTime,
                  color: U.Theme.tertiaryText,
                ),
              ),
            ),
            // const Spacer(flex: 10),
            Expanded(
              flex: 70,
              child: InkWell(
                onTap: () async {
                  TaskCreationDialolg.show(
                    
                    context,
                    scheduleCubit: context.read<ScheduleCubit>(),
                  );
                  // if (task.primaryTask.suggestedSearches.isEmpty) {
                  // TaskDetailDialog.show(context, task: task);
                  // } else {
                  // final temp = await GoRouter.of(context).pushNamed(
                  // TaskDetailPage.route,
                  // extra: {
                  // 'task': task,
                  // 'cubit': context.read<ScheduleCubit>(),
                  // },
                  // );
                  // if (temp == true) {
                  // context.read<ScheduleCubit>().onRefresh();
                  // }
                  // }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCurrent()
                        ? U.Theme.outlineHigh.withValues(alpha: 0.7)
                        : U.Theme.surfaceLight.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Row(
                          // mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: U.Text(
                                softWrap: false,
                                overFlow: TextOverflow.ellipsis,
                                text: task.primaryTask.title,
                                color: isCurrent()
                                    ? U.Theme.secondaryText
                                    : U.Theme.tertiaryText,
                                textWeight: U.TextWeight.semiBold,
                                textSize: U.TextSize.s16,
                              ),
                            ),
                            SizedBox(width: 22),
                            // Spacer(),
                            U.Text(
                              text: task.status.get,
                              textWeight: U.TextWeight.semiBold,
                              textSize: U.TextSize.s12,
                            ),
                            SizedBox(width: 8),
                            Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: U.Theme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      U.Text(
                        color: isCurrent()
                            ? U.Theme.secondaryText
                            : U.Theme.tertiaryText,
                        text: task.primaryTask.description,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DailyBanner extends StatelessWidget {
  final String day;
  final int done;

  const DailyBanner({super.key, required this.day, required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 333,
      // width: 422,
      decoration: BoxDecoration(
        color: U.Theme.outlineHigh.withValues(alpha: 0.7),

        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Spacer(flex: 10),
          SizedBox(height: 15),
          U.Text(text: day, textSize: U.TextSize.s18, color: U.Theme.white),
          SizedBox(height: 45),
          // const Spacer(flex: 20),
          TaskProgressCard(progress: done / 100),

          // const Spacer(flex: 20),
        ],
      ),
    );
  }
}

class TaskProgressCard extends StatefulWidget {
  final double progress; // 0.0 - 1.0
  final Color backgroundColor;
  final Color barColor;
  final Color trackColor;

  const TaskProgressCard({
    super.key,
    required this.progress,
    this.backgroundColor = const Color(0xFF1FBCA3),
    this.barColor = Colors.black,
    this.trackColor = const Color(0x33000000), // black @ 20% opacity
  });

  @override
  State<TaskProgressCard> createState() => _TaskProgressCardState();
}

class _TaskProgressCardState extends State<TaskProgressCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, _) => Flexible(
                child: Row(
                  children: [
                    U.Text(
                      textSize: U.TextSize.s14,
                      text: 'completed',
                      color: U.Theme.secondaryText,
                    ),
                    Spacer(),
                    Text(
                      '${(_animation.value * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _animation.value,
                minHeight: 8,
                backgroundColor: widget.trackColor,
                valueColor: AlwaysStoppedAnimation<Color>(widget.barColor),
              ),
            );
          },
        ),
      ],
    );
  }
}
