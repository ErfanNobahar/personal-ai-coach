import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/domains/business_repository/models/ai_response.dart';
import 'package:personal_ai_coach/domains/business_repository/models/message.dart';
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:personal_ai_coach/tool_kit/tool_kit.dart' as T;

part 'ai_task_manager_state.dart';

class AiTaskManagerCubit extends Cubit<AiTaskManagerState> {
  final BusinessRepository _repo;

  AiTaskManagerCubit({required BusinessRepository repo})
    : _repo = repo,
      super(AiTaskManagerState.init()) {
    onInit();
  }
  final messageCtrl = TextEditingController();

  void onInit() async {
    emit(state.copyWith(loading: true));
    final res = await _repo.readSchedule();
    emit(state.copyWith(loading: false, tasks: res));
    // print('res.toString()');
    // print(res.toString());
  }

  String _extractJson(String raw) {
    var s = raw.trim();

    // Strip ```json ... ``` or ``` ... ``` fences if present
    if (s.startsWith('```')) {
      // Remove opening fence
      s = s.replaceFirst(RegExp(r'^```(json)?\s*', caseSensitive: false), '');
      // Remove closing fence - handle potential whitespace and trailing backticks
      s = s.replaceFirst(RegExp(r'\s*```\s*$'), '');
      s = s.trim();
    }

    // Fallback: grab the substring between the first { and the last }
    // in case there's any stray text around the JSON object.
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      s = s.substring(start, end + 1);
    }

    // Additional cleanup: remove any remaining backticks or stray characters
    s = s.replaceAll(RegExp(r'[`]'), '').trim();

    return s;
  }

  Map<int, ChatResponse> actions = {};

  Future<void> onMessageSent() async {
    final list = [...state.messages];
    final sentMessagesList = [...state.messages];
    final todaysTasks = state.tasks.firstWhere((e) {
      print('${T.DateFormater.dateFromString(e.day)} vsssss ${DateTime.now()}');
      return T.DateFormater.dateFromString(e.day).day == DateTime.now().day;
    });
    print('todaysTasks.day');
    print(todaysTasks.day);
    sentMessagesList.add(
      Message.user(
        content:
            'tasks of the user: ${todaysTasks.tasks.map((e) => e.toMap()).toList()}',
      ),
    );
    final today = DateTime.now();
    final formattedToday =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    sentMessagesList.add(
      Message.user(content: 'Todays date : $formattedToday'),
    );
    // sentMessagesList.add(
    //   Message.user(
    //     content:
    //         'these are the class models in my application and remember that some parameters of this class could be null also there is the specificstasks model class that has these as its parameters and the date of that days tasks are its first parameter class DayTask extends Equatable {final String date;final DayTaskStatus status;final String scheduledTimeSlot;final String scheduledTimeLabel;final PrimaryTask primaryTask;final List<SupportingTask> supportingTasks;const DayTask({required this.date,required this.status,required this.scheduledTimeSlot,required this.scheduledTimeLabel,required this.primaryTask,required this.supportingTasks,}); class PrimaryTask extends Equatable {final String id;final String title;final String description;final int estimatedMinutes;final String scheduledStartTime; // "HH:mm"final String scheduledEndTime; // "HH:mm"final String type;final String whyItMatters;final List<SuggestedSearch> suggestedSearches;const PrimaryTask({required this.id,required this.title,required this.description,required this.estimatedMinutes,required this.scheduledStartTime,required this.scheduledEndTime,required this.type,required this.whyItMatters,required this.suggestedSearches,});',
    //   ),
    // );
    sentMessagesList.add(Message.user(content: messageCtrl.text));
    list.add(Message.user(content: messageCtrl.text));

    emit(state.copyWith(loading: true, messages: list));
    final res = await _repo.createTaskResponse(sentMessagesList);
    final rawContent = res['message']['content'] as String;
    final Map<String, dynamic> taskJson = jsonDecode(_extractJson(rawContent));
    final temp = ChatResponse.fromMap(taskJson);
    list.add(Message.ai(content: temp.message));
    if (temp.proposedAction != null) {
      actions.addEntries(<int, ChatResponse>{list.length - 1: temp}.entries);
      findTasks(actions.entries.last.value.proposedAction!.taskIds);
    }
    print('temppppppppppppppppppp');
    print(temp.toMap());
    emit(state.copyWith(loading: false, messages: list, actions: actions));
    print('state.messages.length');
    print(
      state.messages.map((e) {
        print(e.content);
      }),
    );
  }

  Future<void> findTasks(List<String> ids) async {
    emit(state.copyWith(loading: true));
    final res = await _repo.readSchedule();
    // List<DayTask?> temp ;
    // for (var element in res) {
    // if(element.tasks.contains(element))
    // }
    List<DayTask> temp = res
        .expand(
          (e) => e.tasks.where((element) {
            return ids.contains(element.primaryTask.id);
          }),
        )
        .toList();
    List<DayTask> nonNullList = temp.whereType<DayTask>().toList();
    emit(state.copyWith(modifiedTasks: nonNullList, loading: false));
  }
}
