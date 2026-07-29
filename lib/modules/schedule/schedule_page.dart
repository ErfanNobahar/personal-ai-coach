import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:personal_ai_coach/modules/schedule/cubit/schedule_cubit.dart';
import 'package:personal_ai_coach/modules/schedule/daily_schedule.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class SchedulePage extends StatefulWidget {
  static String route = '/schedule';
  final List<SpecificTasks>? initialTasks;
  const SchedulePage({super.key, this.initialTasks});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<GlobalKey> _pageKeys = [];
  double _maxPageHeight = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   // _pageKeys = List.generate(
  //   //   7,
  //   //   // widget.initialTasks[0].tasks.length,
  //   //   (_) => GlobalKey(),
  //   // );
  //   // Measure after first frame
  //   WidgetsBinding.instance.addPostFrameCallback((_) => _measurePages());
  // }

  void _measurePages() {
    double maxHeight = 0;
    for (final key in _pageKeys) {
      final context = key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          maxHeight = math.max(maxHeight, box.size.height);
        }
      }
    }
    if (maxHeight != _maxPageHeight && mounted) {
      setState(() => _maxPageHeight = maxHeight);
    }
  }

  int getPercent(List<DayTask> tasks) {
    var temp = tasks.where((e) {
      return e.status == DayTaskStatus.completed;
    }).toList();
    return (((temp.length / tasks.length) * 100).floor());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScheduleCubit(
        initialTasks: widget.initialTasks,
        repo: context.read<BusinessRepository>(),
      ),
      child: BlocConsumer<ScheduleCubit, ScheduleState>(
        listenWhen: (previous, current) {
          return ((previous.loading != current.loading) ||
              (previous.dailyTasks.length != current.dailyTasks.length));
        },
        listener: (BuildContext context, ScheduleState state) {
          final cubit = context.read<ScheduleCubit>();
          // print('state.dailyTasks.lengthhhhhhhhhhhhhhh');
          _pageKeys = List.generate(
            state.dailyTasks.length,
            // widget.initialTasks[0].tasks.length,
            (_) => GlobalKey(),
          );
          WidgetsBinding.instance.addPostFrameCallback((_) => _measurePages());
        },

        builder: (context, state) {
          final cubit = context.read<ScheduleCubit>();
          return state.loading
              ? CircularProgressIndicator()
              : Scaffold(
                  body: SafeArea(
                    child: ListView(
                      children: [
                        U.AppBar(title: 'todays tasks', blur: true),
                        const SizedBox(height: 22),
                        // Wrap ScrollableTabview in SizedBox with measured height
                        SizedBox(
                          height:
                              280 +
                              (_maxPageHeight > 0
                                  ? _maxPageHeight
                                  : MediaQuery.of(context).size.height * 0.7),
                          child: U.ScrollableTabview(
                            onPageCountChanged: cubit.onPageCountChanged,
                            tabController: cubit.tabCtril,
                            pageController: cubit.pageCtrl,
                            headers: [
                              ...state.dailyTasks.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 251,
                                    child: DailyBanner(
                                      day: e.day,
                                      done: getPercent(e.tasks),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            pages: [
                              ...state.dailyTasks.asMap().entries.map((entry) {
                                final index = entry.key;
                                final e = entry.value;
                                return Container(
                                  key: _pageKeys[index],
                                  child: DailySchedule(tasks: e.tasks),
                                );
                              }),
                            ],
                          ),
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
