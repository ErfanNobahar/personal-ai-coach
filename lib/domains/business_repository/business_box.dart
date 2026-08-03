import 'package:personal_ai_coach/data_providers/hive/hive_db.dart';
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';

import 'models/task.dart';

enum Keys { weeklyTasks }

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
    for (var element in temp) {
      element.tasks.sortByHour();
    }
    print('temp.length');
    print(temp.length);
    return temp;
  }

  static Future<void> setWeeklyTasks(
    List<SpecificTasks> tasks, {
    bool conflictCheck = true,
  }) async {
    List<SpecificTasks> newTasks = [...tasks];
    final existingTasks = await getWeeklyTasks();

    List<SpecificTasks> rescheduledTasks = [];
    if (conflictCheck) {
      if (existingTasks.isNotEmpty) {
        final resByDay = {for (var r in existingTasks) r.day: r};

        newTasks = newTasks.map((taskGroup) {
          final matchedDay = resByDay[taskGroup.day];
          if (matchedDay == null) return taskGroup;
          final inComingDailySchedule = taskGroup.tasks
              .map((e) => e.primaryTask.scheduledStartTime)
              .toList();
          final existingDailySchedule = matchedDay.tasks
              .map((e) => e.primaryTask.scheduledStartTime)
              .toList();

          final finalTasks = taskGroup.tasks.map((element) {
            if (existingDailySchedule.contains(inComingDailySchedule[0])) {
              final temp = element.copyWith(
                primaryTask: element.primaryTask.reschedule(
                  occupiedTimes: existingDailySchedule,
                  scheduledStartTime: element.primaryTask.scheduledStartTime,
                ),
              );
              matchedDay.addToList(task: temp);
              rescheduledTasks.add(matchedDay);
              return temp;
            } else {
              matchedDay.addToList(task: element);
              rescheduledTasks.add(matchedDay);
              return element;
            }
          }).toList();

          return taskGroup.copyWith(tasks: finalTasks);
        }).toList();
      } else {
        rescheduledTasks = [...newTasks];
      }
    }
    final temp = List<SpecificTasks>.from(
      !conflictCheck ? rescheduledTasks : newTasks,
    ).map((e) => e.toMap()).toList();
    HiveDB.set(
      boxName: boxName,
      key: Keys.weeklyTasks.index.toString(),
      value: List<SpecificTasks>.from(
        conflictCheck ? rescheduledTasks : newTasks,
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
    final temp = res
        .where(
          (e) => e.tasks.any(
            (b) => b.primaryTask.description == task.primaryTask.description,
          ),
        )
        .first;
    // final temp = res.where((e) => e.tasks.contains(task)).toList().first;
    return temp;
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
