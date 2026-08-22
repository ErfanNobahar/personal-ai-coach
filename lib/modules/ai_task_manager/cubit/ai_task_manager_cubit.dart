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
      return T.DateFormater.dateFromString(e.day).day == DateTime.now().day;
    });
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
      findTasks(
        actions.entries.last.value.proposedAction!.taskIds,
        actions.entries.last.key,
      );
      emit(state.copyWith(chattingStatus: ChattingStatus.disabled));
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

  void onClarifytaped() {
    emit(state.copyWith(chattingStatus: ChattingStatus.clarifing));
  }

  Future<void> onClarified() async {
    emit(state.copyWith(chattingStatus: ChattingStatus.clarifing));
    final list = [...state.messages];
    final sentMessagesList = [...state.messages];
    final todaysTasks = state.tasks.firstWhere((e) {
      return T.DateFormater.dateFromString(e.day).day == DateTime.now().day;
    });
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
    sentMessagesList.add(
      Message.user(
        content:
            'your last proposal to the users request was ${actions.entries.last.value.toMap()}, and now he is making this clarificattion/change about your propsal',
      ),
    );

    sentMessagesList.add(Message.user(content: messageCtrl.text));
    list.add(Message.user(content: messageCtrl.text));

    final res = await _repo.createTaskResponse(sentMessagesList);
    final rawContent = res['message']['content'] as String;
    final Map<String, dynamic> taskJson = jsonDecode(_extractJson(rawContent));
    final temp = ChatResponse.fromMap(taskJson);
    list.add(Message.ai(content: temp.message));
    if (temp.proposedAction != null) {
      // actions.remove(actions.entries.last.key);
      actions.addEntries(<int, ChatResponse>{list.length - 1: temp}.entries);
      findTasks(
        actions.entries.last.value.proposedAction!.taskIds,
        actions.entries.last.key,
      );
    }
    print('-----------------------------------------------  ');
    print(actions);
    emit(
      state.copyWith(
        loading: false,
        messages: list,
        chattingStatus: ChattingStatus.disabled,
        actions: actions,
      ),
    );
  }

  Map<int, List<DayTask>> mapedTasks = {};
  Future<void> findTasks(List<String> ids, int key) async {
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
    mapedTasks.addEntries(<int, List<DayTask>>{key: nonNullList}.entries);
    emit(state.copyWith(modifiedTasks: mapedTasks, loading: false));
  }
}
