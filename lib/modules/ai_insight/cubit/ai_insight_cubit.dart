import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/domains/business_repository/models/goal.dart';
import 'package:personal_ai_coach/tool_kit/tool_kit.dart' as T;
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';

part 'ai_insight_state.dart';

class AiInsightCubit extends Cubit<AiInsightState> {
  final BusinessRepository _repo;
  AiInsightCubit({required BusinessRepository repo})
    : _repo = repo,
      super(AiInsightState.init()) {
    onInit();
  }
  //////////////////// Functions
  Future<List<SpecificTasks>> getTasks() async {
    final res = await _repo.readSchedule();
    if (res.isEmpty) return [];

    DateTime parse(String d) => T.DateFormater.dateFromString(d);
    DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
    DateTime mondayOf(DateTime d) =>
        dateOnly(d).subtract(Duration(days: d.weekday - DateTime.monday));

    final today = dateOnly(DateTime.now());

    // Pair each task with its parsed date once.
    final parsed = res
        .map((t) => (task: t, date: dateOnly(parse(t.day))))
        .toList();

    // 1. The single task whose date is closest to today.
    final nearest = parsed.reduce((a, b) {
      final da = a.date.difference(today).inHours.abs();
      final db = b.date.difference(today).inHours.abs();
      if (da != db) return da < db ? a : b;
      return a.date.isBefore(b.date) ? a : b; // tie → prefer the past one
    });

    // 2. The week that task belongs to (Monday 00:00 … Sunday 23:59).
    final chosenMonday = mondayOf(nearest.date);

    // 3. Keep only tasks in that week, ordered by date.
    final finalList =
        parsed
            .where((p) => mondayOf(p.date) == chosenMonday)
            .map((p) => p.task)
            .toList()
          ..sort((a, b) => parse(a.day).compareTo(parse(b.day)));

    return finalList;
  }

  List<Goal> get getGoals {
    // final roadmaps = _repo.readRoadmaps();
    final List<Goal> goals = _repo.getGoals();
    return goals;
  }

  ///////////////////// Events
  void onInit() async {
    emit(state.copyWith(loading: true));
    final tasks = await getTasks();
    final goals = getGoals;
    emit(state.copyWith(weeklyTasks: tasks, loading: false, goals: goals));
  }
}
