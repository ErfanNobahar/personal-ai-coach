import 'package:personal_ai_coach/data_providers/hive/hive_db.dart';
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';

enum keys { weeklyTasks }

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
      key: keys.weeklyTasks.index.toString(),
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
    return temp;
  }

  static Future<void> setWeeklyTasks(List<SpecificTasks> tasks) async {
    List<SpecificTasks> newTasks = List.from(tasks);
    final existingTasks = await getWeeklyTasks();

    List<SpecificTasks> rescheduledTasks = [];
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
    }  else
        {
      rescheduledTasks = [...newTasks];
    }
    print('boxxxxxxxxx');
    print(rescheduledTasks.length);
    HiveDB.set(
      boxName: boxName,
      key: keys.weeklyTasks.index.toString(),
      value: List.from(rescheduledTasks).map((e) => e.toMap()).toList(),
    );
  }
}
