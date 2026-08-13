// ignore_for_file: prefer_initializing_formals
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/domains/business_repository/models/message.dart';
import 'package:personal_ai_coach/domains/business_repository/models/roadmap.dart';
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:personal_ai_coach/tool_kit/tool_kit.dart' as T;

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
  String? _extractJson(String raw) {
    var text = raw.trim();

    final fenceMatch = RegExp(
      r'```(?:json)?\s*([\s\S]*?)\s*```',
      caseSensitive: false,
    ).firstMatch(text);
    if (fenceMatch != null) {
      text = fenceMatch.group(1)!.trim();
    }

    if (!text.startsWith('{') && !text.startsWith('[')) {
      final start = text.indexOf(RegExp(r'[\{\[]'));
      if (start == -1) return null;
      final isObject = text[start] == '{';
      final end = text.lastIndexOf(isObject ? '}' : ']');
      if (end == -1 || end < start) return null;
      text = text.substring(start, end + 1);
    }

    return text;
  }

  Future<dynamic> onWeeklyTasksCreated(String message, int week) async {
    final List<WeeklyObjective> temp = [];
    for (var i = 0; i < state.roadmap!.milestones.length; i++) {
      temp.addAll(state.roadmap!.milestones[i].weeklyObjectives);
    }
    final test = temp.where(
      (e) {
        if (e.week == week && e.weeklyTasks.days.isEmpty) {
          return true;
        }
        return false;
      },
      //  e.week == week? e.weeklyTasks.days.isEmpty? return e: return  : return}
    ).firstOrNull;
    if (test != null) {
      emit(state.copyWith(loading: true));
      final res = await _repo.createWeeklyTasks(Message.user(content: message));

      final rawContent = res['message']['content'] as String;
      final cleaned = _extractJson(rawContent);

      if (cleaned == null) {
        emit(state.copyWith(loading: false));
        return;
      }

      Map<String, dynamic> weekJson;
      try {
        final decoded = jsonDecode(cleaned);
        if (decoded is! Map<String, dynamic>) {
          emit(state.copyWith(loading: false));
          return;
        }
        weekJson = decoded;
      } on FormatException catch (e) {
        print('JSON parse failed: $e\nRaw: $rawContent');
        emit(state.copyWith(loading: false));
        return;
      }

      final weeklyTasks = WeeklyTasks.fromMap(weekJson);
      final updatedTasks = weeklyTasks.copyWith(
        days: weeklyTasks.days.asMap().entries.map((e) {
          return e.value.copyWith(
            roadmapId: state.roadmap!.id,
            date: T.DateFormater.monthFormater(
              state.roadmap!.dateCreated.add(
                Duration(
                  days: e.key == 1
                      ? 7 * (week - 1)
                      : (7 * (week - 1)) + e.key - 1,
                ),
              ),
            ),
          );
        }).toList(),
      );
      await _repo.createSchedule(
        updatedTasks.days
            .map((e) => SpecificTasks(day: e.date, tasks: [e]))
            .toList(),
      );
      final updatedMilestones = state.roadmap!.milestones.map((m) {
        return m.copyWith(
          weeklyObjectives: m.weeklyObjectives
              .asMap()
              .entries
              .map(
                (wo) => wo.value.week == week
                    ? wo.value.copyWith(weeklyTasks: updatedTasks)
                    : wo.value,
              )
              .toList(),
        );
      }).toList();

      final updatedRoadmap = state.roadmap!.copyWith(
        milestones: updatedMilestones,
      );
      print('updatedRoadmapssssssssssss');
      print(updatedRoadmap.id);
      await _repo.updateroadmap(updatedRoadmap);
      emit(
        state.copyWith(
          loading: false,
          weeklyTasks: weeklyTasks,
          roadmap: updatedRoadmap,
        ),
      );
    }
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

  void onInit() async {
    emit(state.copyWith(roadmap: initialRoadmap, goal: initialGoal));
    print('++++++++++++++++++++++++++++++++++++++++++++++++');
    final res = await _repo.readRoadmapTasks(state.roadmap!);
    print('res.milestones[0].weeklyObjectives[0].weeklyTasks.toMap()');
    print(res.milestones[0].weeklyObjectives[0].weeklyTasks.toMap());
    emit(state.copyWith(roadmap: res));
  }
}
