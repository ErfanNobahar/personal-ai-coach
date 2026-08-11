// ignore_for_file: prefer_initializing_formals
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/domains/business_repository/models/message.dart';
import 'package:personal_ai_coach/domains/business_repository/models/roadmap.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';

part 'roadmap_state.dart';

class RoadmapCubit extends Cubit<RoadmapState> {
  final BusinessRepository _repo;
  final Roadmap? initialRoadmap;
  final String? initialGoal;
  final WeeklyTasks? weeklyTasks;

  RoadmapCubit({
    this.initialGoal,
    this.initialRoadmap,
    this.weeklyTasks,
    required BusinessRepository repo,
  }) : _repo = repo,
       super(RoadmapState.init(weeklyTasks: weeklyTasks)) {
    onInit();
  }

  Future<dynamic> onWeeklyTasksCreated(String message) async {
    emit(state.copyWith(loading: true));
    final res = await _repo.createWeeklyTasks(Message.user(content: message));
    final Map<String, dynamic> weekJson = jsonDecode(res['message']['content']);
    WeeklyTasks weeklyTasks = WeeklyTasks.fromMap(weekJson);
    emit(state.copyWith(loading: false, weeklyTasks: weeklyTasks));
  }

  List<int> ids = [];
  void onExpandedCountChanged(int stepperId, bool shouldExpand) {
    if (!ids.contains(stepperId)) { 
      ids.add(stepperId);
      final index = ids.indexWhere((element) => element == stepperId) + 1;
      emit(state.copyWith(count: index));
    } else {
      if (shouldExpand) {
        final index = ids.indexWhere((element) => element == stepperId);
        emit(state.copyWith(count: index));
        ids.removeRange(index, ids.length);
      }
    }
  }

  Future<void> onRoadmapCreated() async {
    emit(state.copyWith(loading: true));
    await _repo.addRoadmap(state.roadmap!);
    emit(state.copyWith(loading: false));
  }



  void onInit() {
    emit(state.copyWith(roadmap: initialRoadmap, goal: initialGoal));
  }
}
