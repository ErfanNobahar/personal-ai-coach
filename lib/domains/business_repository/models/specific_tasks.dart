import 'package:equatable/equatable.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:personal_ai_coach/tool_kit/tool_kit.dart' as T;

class SpecificTasks extends Equatable {
  final String day;
  final List<DayTask> tasks;
  const SpecificTasks({required this.day, required this.tasks});

  SpecificTasks addToList({required DayTask task}) {
    tasks.add(task);
    List<DayTask> newtasks = [...tasks];
    return SpecificTasks(day: day, tasks: newtasks);
  }

  SpecificTasks copyWith({String? day, List<DayTask>? tasks}) {
    return SpecificTasks(day: day ?? this.day, tasks: tasks ?? this.tasks);
  }

  factory SpecificTasks.fromMap(Map<String, dynamic> map) {
    return SpecificTasks(
      day: map['day'],
      tasks: List.from(map['tasks'] ?? [])
          .map((e) => DayTask.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'day': day, 'tasks': List.from(tasks.map((e) => e.toMap()))};
  }

  @override
  List<Object?> get props => [day, tasks];
}

extension Specific on List<SpecificTasks> {
  List<SpecificTasks> get sortByDay {
    final res = List<SpecificTasks>.from(this)
      ..sort(
        (a, b) => T.DateFormater.dateFromString(
          a.day,
        ).compareTo(T.DateFormater.dateFromString(b.day)),
      );
    return res;
  }

  ({int completed, int skipped, int pending, int taskCount}) get getDetails {
    int completed = 0;
    int skipped = 0;
    int pending = 0;
    int tasksCount = 0;
    for (var i = 0; i < length; i++) {
      for (var element = 0; element < this[i].tasks.length; element++) {
        tasksCount++;
        if (this[i].tasks[element].status == DayTaskStatus.completed) {
          completed++;
        } else if (this[i].tasks[element].status == DayTaskStatus.skipped) {
          skipped++;
        } else {
          pending++;
        }
      }
    }
    return (
      completed: completed,
      skipped: skipped,
      pending: pending,
      taskCount: tasksCount,
    );
  }
}
