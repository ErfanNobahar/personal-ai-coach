import 'package:personal_ai_coach/data_providers/hive/hive_db.dart';
import 'package:personal_ai_coach/domains/business_repository/models/roadmap.dart';
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';
import 'package:personal_ai_coach/ui_kit/duration_picker_dlg.dart';

import 'models/task.dart';

enum Keys { weeklyTasks, roadMap }

abstract class BusinessBox {
  static String boxName = 'business';
  static bool isOpen = false;

  static Future<void> open() async {
    if (!isOpen) {
      await HiveDB.openBox(boxName: boxName);
      isOpen = true;
    }
  }

  static Future<List<SpecificTasks>> getWeeklyTasks() async {
    final res = await HiveDB.get(
      boxName: boxName,
      key: Keys.weeklyTasks.index.toString(),
    );
    List<SpecificTasks> temp = [];
    if (res != null) {
      temp = List.from(res).map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        return SpecificTasks.fromMap(map);
      }).toList();
    }
    // for (var element in temp) {
    //   print(element.toMap());
    // }
    for (var element in temp) {
      element.tasks.sortByHour();
    }

    return temp;
  }

  static Future<bool> checkIfTaskExists(DayTask task) async {
    final res = await getWeeklyTasks();
    final temp = res
        .where(
          (e) => e.tasks.any((b) {
            print('b.primaryTask: ${b.primaryTask}');
            print('task.primaryTask: ${task.primaryTask}\n');
            return b.primaryTask == task.primaryTask;
          }),
        )
        .toList()
        .firstOrNull;
    if (temp != null) {
      return true;
    }
    return false;
  }

  static Future<void> setWeeklyTasks(
    List<SpecificTasks> tasks, {
    bool conflictCheck = true,
  }) async {
    List<SpecificTasks> newTasks = [...tasks];
    final existingTasks = await getWeeklyTasks();
    List<SpecificTasks> test1 = [];
    test1.addAll([...existingTasks, ...newTasks]);
    // print('tesssssssssssssssssss1111111111111111111111111111');
    // print(test1.length);
    Map<int, List<SpecificTasks>> mapedTasks = {};
    for (var i = 0; i < test1.length; i++) {
      mapedTasks.addAll({
        i: test1.where((e) {
          if (e.day == test1[i].day) {
            // print('${e.day} vs ${test1[i].day} vs $i');
          }
          return e.day == test1[i].day;
        }).toList(),
      });
    }
    List<SpecificTasks> filteredTasks = [];
    mapedTasks.removeWhere((key, value) {
      // print('value.lengthssssssssssssssss');
      // print(value.length);
      return value.length == 1;
    });
    // List<SpecificTasks> newMaped =
    // filteredTasks.addAll();
    List<SpecificTasks> rescheduledTasks = [];

    // print(mapedTasks);

    List<SpecificTasks> shouldntCheck = [];
    for (var i = 0; i < test1.length; i++) {
      if (conflictCheck) {
        // print('mapedTasks.keys');
        // print(' mapedTasks:${mapedTasks} mapedTasks.keys${mapedTasks.keys}');
        if (mapedTasks.keys.toList().contains(i)) {
          print('111111111111');
          print('shouldntCheck');
          print(!shouldntCheck.contains(test1[i]));
          if (!shouldntCheck.contains(test1[i])) {
            List<String> existingTimes = [];
            // print('!shouldntCheck.contains(test1[i])');
            // print(!shouldntCheck.contains(test1[i]));
            List<TimeSlot> incomingTimes = [];
            existingTimes = [
              ...test1[i].tasks.map((e) => e.primaryTask.scheduledStartTime),
            ];
            incomingTimes = [
              ...mapedTasks[i]!.first.tasks.map(
                (e) => TimeSlot(
                  startMinutes:
                      int.parse(
                        e.primaryTask.scheduledStartTime.split(':')[0],
                      ) *
                      60,
                  endMinutes:
                      ((int.parse(
                            e.primaryTask.scheduledStartTime.split(':')[0],
                          ) *
                          60) +
                      e.primaryTask.estimatedMinutes),
                ),
              ),
            ];
            List<String> icomingTimes2 = incomingTimes.convertToInt
                .map((e) => '${e.toString().padLeft(2, '0')}:00')
                .toList();
            final tasks = [...test1[i].tasks];

            final incomingTasks = mapedTasks[i]!.last.tasks
                .map(
                  (e) => e.copyWith(
                    primaryTask: e.primaryTask.reschedule(
                      occupiedTimes: icomingTimes2,
                      scheduledStartTime: e.primaryTask.scheduledStartTime,
                    ),
                  ),
                )
                .toList();
            tasks.addAll([...incomingTasks]);
            // final tempTask =

            filteredTasks.add(test1[i].copyWith(tasks: tasks));
            shouldntCheck.add(mapedTasks[i]!.last);
          }
        } else {
          print('2222222222222222222');
          filteredTasks.add(test1[i]);
        }
        print('iiiiiiiiiiiiiiiiiiiii');
        print(i);
      } else {
        filteredTasks = [...newTasks];
      }
    }

    // if (conflictCheck) {
    //   if (existingTasks.isNotEmpty) {
    //     final resByDay = {for (var r in existingTasks) r.day: r};
    //     newTasks = newTasks.map((taskGroup) {
    //       final matchedDay = resByDay[taskGroup.day];
    //       if (matchedDay == null) return taskGroup;
    //       final inComingDailySchedule = taskGroup.tasks
    //           .map((e) => e.primaryTask.scheduledStartTime)
    //           .toList();
    //       final existingDailySchedule = matchedDay.tasks
    //           .map((e) => e.primaryTask.scheduledStartTime)
    //           .toList();

    //       final finalTasks = taskGroup.tasks.map((element) {
    //         if (existingDailySchedule.contains(inComingDailySchedule[0])) {
    //           final temp = element.copyWith(
    //             primaryTask: element.primaryTask.reschedule(
    //               occupiedTimes: existingDailySchedule,
    //               scheduledStartTime: element.primaryTask.scheduledStartTime,
    //             ),
    //           );
    //           matchedDay.addToList(task: temp);
    //           rescheduledTasks.add(matchedDay);
    //           return temp;
    //         } else {
    //           matchedDay.addToList(task: element);
    //           rescheduledTasks.add(matchedDay);
    //           return element;
    //         }
    //       }).toList();

    //       return taskGroup.copyWith(tasks: finalTasks);
    //     }).toList();
    //   } else {
    //     rescheduledTasks = [...newTasks];
    //   }
    // }
    // final temp = List<SpecificTasks>.from(
    //   !conflictCheck ? rescheduledTasks : newTasks,
    // ).map((e) => e.toMap()).toList();
    HiveDB.set(
      boxName: boxName,
      key: Keys.weeklyTasks.index.toString(),
      value: List<SpecificTasks>.from(
        filteredTasks,
      ).map((e) => e.toMap()).toList(),
    );
  }

  static Future<SpecificTasks?> readByDay(String day) async {
    final res = await getWeeklyTasks();
    final temp = res.where((e) => e.day == day).firstOrNull;
    return temp;
  }

  static Future<SpecificTasks> readSpecificTask(DayTask task) async {
    final res = await getWeeklyTasks();
    // print('boooooooooooxtask');
    // print(task);
    final temp = res
        .where(
          (e) => e.tasks.any((elements) {
            return elements.primaryTask == task.primaryTask;
          }),
        )
        .toList()
        .first;
    // final temp = res.where((e) => e.tasks.contains(task)).toList().first;
    return temp;
  }

  static Future<void> deleteTask(DayTask task) async {
    final weeklyTasks = await getWeeklyTasks();

    final updated = weeklyTasks.map((day) {
      if (day.day != task.date) return day;

      final filtered = day.tasks
          .where(
            (t) => t.primaryTask.description != task.primaryTask.description,
          )
          .toList();
      return day.copyWith(tasks: filtered);
    }).toList();

    await HiveDB.set(
      boxName: boxName,
      key: Keys.weeklyTasks.index.toString(),
      value: updated.map((e) => e.toMap()).toList(),
    );
  }

  static Future<Roadmap> readRoadmapTasks(Roadmap roadmap) async {
    final res = readRoadmap();
    final temp = res.firstWhere((e) => e.id == roadmap.id);
    final tasks = await getWeeklyTasks();
    final weeklyTasks = tasks
        .map(
          (e) =>
              e.tasks.firstWhere((element) => element.roadmapId == roadmap.id),
        )
        .toList();
    final updated = temp.copyWith(
      milestones: temp.milestones
          .map(
            (e) => e.copyWith(
              weeklyObjectives: e.weeklyObjectives
                  .map(
                    (element) => element.weeklyTasks.isCurrent
                        ? element.copyWith(
                            weeklyTasks: element.weeklyTasks.copyWith(
                              days: weeklyTasks,
                            ),
                          )
                        : element,
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
    return updated;
  }

  static Future<void> createRoadmap(Roadmap roadmap) async {
    final res = readRoadmap();
    final temp = [...res];
    temp.add(roadmap);
    await HiveDB.set(
      boxName: boxName,
      key: Keys.roadMap.index.toString(),
      value: temp.map((e) => e.toMap()).toList(),
    );
  }

  static List<Roadmap> readRoadmap() {
    final res = HiveDB.get(
      boxName: boxName,
      key: Keys.roadMap.index.toString(),
    );
    if (res != null) {
      final list = List.from(
        res,
      ).map((e) => Roadmap.fromMap(asStringKeyedMap(e))).toList();
      return list;
    }
    return [];
  }

  static Future<void> updateRoadmap(Roadmap roadmap) async {
    final res = readRoadmap();
    final index = res.indexWhere((e) {
      print('${e.id} vsssssss ${roadmap.id}');
      return e.id == roadmap.id;
    });
    res.removeAt(index);
    res.insert(index, roadmap);
    await HiveDB.set(
      boxName: boxName,
      key: Keys.roadMap.index.toString(),
      value: res.map((e) => e.toMap()).toList(),
    );
  }

  static Future<void> updateRoadmapTasks(DayTask task) async {
    final roadmap = readRoadmap();
    final temp = roadmap.firstWhere((e) => e.id == task.roadmapId);
    final List<Milestone> list = [];
    // for (var element in temp.milestones) {
    //   for (var pelement in element.weeklyObjectives) {
    //     for (var bb in pelement.weeklyTasks.days) {
    //       if (bb.date == task.date) {}
    //     }
    //   }
    // }
    for (var element in temp.milestones) {
      list.add(
        element.copyWith(
          weeklyObjectives: element.weeklyObjectives
              .map(
                (e) => e.copyWith(
                  weeklyTasks: e.weeklyTasks.copyWith(
                    days: e.weeklyTasks.days.map((b) {
                      if (b.date == task.date) {
                        return task;
                      } else {
                        return b;
                      }
                    }).toList(),
                  ),
                ),
              )
              .toList(),
        ),
      );
    }
    temp.copyWith(milestones: list);
    final index = roadmap.indexWhere((e) => e.id == task.roadmapId);
    roadmap.removeAt(index);
    roadmap.insert(index, temp);
    HiveDB.set(
      boxName: boxName,
      key: Keys.roadMap.index.toString(),
      value: roadmap.map((e) => e.toMap()).toList(),
    );
  }

  static Future<void> updateTasks(DayTask task, {bool isNew = false}) async {
    final res = await getWeeklyTasks();
    List<SpecificTasks> temp;
    if (isNew) {
      temp = res.map((e) {
        if (e.day == task.date) {
          e.tasks.add(task);
          final temp = e.tasks;
          return e.copyWith(tasks: temp);
        } else {
          return e;
        }
      }).toList();
    } else {
      temp = res
          .map(
            (weekEntry) => weekEntry.copyWith(
              tasks: weekEntry.tasks.map((b) {
                if (b.primaryTask.description == task.primaryTask.description) {
                  return b.copyWith(
                    status: task.status,
                    primaryTask: b.primaryTask.copyWith(
                      scheduledStartTime: task.primaryTask.scheduledStartTime,
                    ),
                  );
                } else {
                  return b;
                }
              }).toList(),
            ),
          )
          .toList();
    }
    await setWeeklyTasks(temp, conflictCheck: false);
  }
}
