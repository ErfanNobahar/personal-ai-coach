import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/domains/business_repository/models/followup_question.dart';
import 'package:personal_ai_coach/domains/business_repository/models/message.dart';
import 'package:personal_ai_coach/domains/business_repository/models/roadmap.dart';
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:uuid/uuid.dart';
import 'package:personal_ai_coach/tool_kit/tool_kit.dart' as T;
part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final BusinessRepository _repo;
  final goalCtrl = TextEditingController();

  ChatCubit({required BusinessRepository repository})
    : _repo = repository,
      super(ChatState.init());

  Future<void> onInit() async {}

  Future<void> onGoalCreated({required Message message}) async {
    emit(state.copyWith(loading: true));
    final messagesList = [...state.messages];
    messagesList.add(message);
    final res = await _repo.createCredentials(messages: messagesList);
    final Map<String, dynamic> questionJson = jsonDecode(
      res['message']['content'],
    );
    final lastMessage = Message.fromMap(res['message']);
    final lastQuestion = FollowupQuestion.fromMap(questionJson);
    messagesList.add(lastMessage);
    final questionsList = [...state.questions, lastQuestion];
    emit(
      state.copyWith(
        loading: false,
        questions: questionsList,
        goal: goalCtrl.text,
        messages: messagesList,
      ),
    );
  }

  void onAnswerSelected(Question question) {
    List<Question> list = [...state.selectedQuestions];
    list.add(question);
    emit(state.copyWith(selectedQuestions: list));
  }

  Future<({Roadmap roadmap, WeeklyTasks tasks})> onRoadmapGenrated() async {
    emit(state.copyWith(loading: true));
    Map<String, String> roadmapMap = {};
    roadmapMap = {'user goal': '${state.goal}'};
    for (var e = 0; e <= state.selectedQuestions.length - 1; e++) {
      roadmapMap.addEntries(
        <String, String>{
          state.selectedQuestions[e].questionLabel:
              state.selectedQuestions[e].label,
        }.entries,
      );
    }
    final res = await _repo.createRoadmap(
      message: Message.user(
        // content: roadmapMap.toString(),
        content:
            '{user goal: i want to become a python developer, experience_level: Intermediate (Comfortable with another language), time_commitment: Medium (6-15 hours per week), preferred_time_of_day: Afternoon (12-5 PM), desired_timeline: Steady (6 months), lifestyle_constraints: Family or caregiving responsibilities}',
      ),
    );
    final Map<String, dynamic> roadmapJson = jsonDecode(
      res['message']['content'],
    );
    print('===========================================');
    print(roadmapJson.toString());
    final roadmap = Roadmap.fromMap(roadmapJson);
    print('++++++++++++++++++++++++++++++++++++++++++++++++++');
    print(roadmap);
    final tasksRes = await _repo.createWeeklyTasks(
      Message.user(
        content:
            'user goal and state: ${state.goal} currentMilestone: ${roadmap.milestones[0].toMap().toString()} currentWeek: ${roadmap.milestones[0].weeklyObjectives[0].toString()} ',
      ),
    );
    final Map<String, dynamic> weekJson = jsonDecode(
      tasksRes['message']['content'],
    );
    WeeklyTasks weeklyTasks = WeeklyTasks.fromMap(weekJson);
    weeklyTasks = weeklyTasks.copyWith(
      days: weeklyTasks.days
          .asMap()
          .entries
          .map(
            (day) => day.value.copyWith(
              roadmapId: roadmap.id,
              date: day.key == 1
                  ? T.DateFormater.monthFormater(DateTime.now())
                  : T.DateFormater.monthFormater(
                      DateTime.now().add(Duration(days: day.key - 1)),
                    ),
            ),
          )
          .toList(),
    );
    final updated = roadmap.milestones
        .map(
          (e) => e.startWeek == 1
              ? e.copyWith(
                  weeklyObjectives: e.weeklyObjectives
                      .map(
                        (element) => element.week == 1
                            ? element.copyWith(
                                weeklyTasks: weeklyTasks,
                                // weeklyTasks.copyWith(
                                //   days: weeklyTasks.days
                                //       .asMap()
                                //       .entries
                                //       .map(
                                //         (day) => day.value.copyWith(
                                //           roadmapId: roadmap.id,
                                //           date: day.key == 1
                                //               ? T.DateFormater.monthFormater(
                                //                   DateTime.now(),
                                //                 )
                                //               : T.DateFormater.monthFormater(
                                //                   DateTime.now().add(
                                //                     Duration(days: day.key - 1),
                                //                   ),
                                //                 ),
                                //         ),
                                //       )
                                //       .toList(),
                                // ),
                              )
                            : element,
                      )
                      .toList(),
                )
              : e,
        )
        .toList();
    print('roadmap.iddddddddddd+++++++++++++++');
    print(roadmap.id);
    final updatedRoadMap = roadmap.copyWith(milestones: updated);

    final specificTasks = weeklyTasks.days
        .asMap()
        .entries
        .map(
          ((e) => SpecificTasks(
            day: T.DateFormater.monthFormater(
              e.key == 1
                  ? DateTime.now()
                  : DateTime.now().add(Duration(days: e.key - 1)),
            ),
            tasks: [e.value],
          )),
        )
        .toList();
    await _repo.createSchedule(specificTasks);
    await _repo.addRoadmap(updatedRoadMap);
    print('roadmap.toMap()ppppppppppppppp');
    print(roadmap.toMap());

    emit(state.copyWith(loading: false));

    return (roadmap: updatedRoadMap, tasks: weeklyTasks);
  }

  // void printing() {
  //   print(state.);
  // }
}
