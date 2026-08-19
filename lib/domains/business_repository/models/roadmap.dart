import 'dart:core';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:uuid/uuid.dart';

class Roadmap {
  final DateTime dateCreated;
  final String id;
  final String type;
  final String goal;
  final String summary;
  final int totalDurationWeeks;
  final String difficultyProgression;
  final List<Milestone> milestones;

  Roadmap({
    String? id,
    DateTime? dateCreated,
    required this.type,
    required this.goal,
    required this.summary,
    required this.totalDurationWeeks,
    required this.difficultyProgression,
    required this.milestones,
  }) : id = (id == null || id == '') ? Uuid().v4() : id,
       dateCreated = DateTime.now();

  Roadmap copyWith({
    String? id,
    DateTime? dateCreated,
    String? type,
    String? goal,
    String? summary,
    int? totalDurationWeeks,
    String? difficultyProgression,
    List<Milestone>? milestones,
  }) {
    return Roadmap(
      id: id ?? this.id,
      dateCreated: dateCreated ?? this.dateCreated,
      type: type ?? this.type,
      goal: goal ?? this.goal,
      summary: summary ?? this.summary,
      totalDurationWeeks: totalDurationWeeks ?? this.totalDurationWeeks,
      difficultyProgression:
          difficultyProgression ?? this.difficultyProgression,
      milestones: milestones ?? this.milestones,
    );
  }

  factory Roadmap.fromMap(Map<String, dynamic> map) {
    return Roadmap(
      id: map['id'],
      dateCreated: map['dateCreated'],
      type: map['type'] ?? '',
      goal: map['goal'] ?? '',
      summary: map['summary'] ?? '',
      totalDurationWeeks: map['totalDurationWeeks'] ?? 0,
      difficultyProgression: map['difficultyProgression'] ?? '',
      milestones: List.from(
        map['milestones'] ?? [],
      ).map((e) => Milestone.fromMap(asStringKeyedMap(e))).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateCreated': dateCreated,
      'type': type,
      'goal': goal,
      'summary': summary,
      'totalDurationWeeks': totalDurationWeeks,
      'difficultyProgression': difficultyProgression,
      'milestones': milestones.map((e) => e.toMap()).toList(),
    };
  }

  int getProgress(Roadmap roadmap) {
    final int completeds = roadmap.milestones.fold(
      0,
      (previousValue, e) =>
          previousValue +
          e.weeklyObjectives.fold(0, (previousValue, element) {
            // print('element.weeklyTasks.days.getDetails.completed');
            // print(element.weeklyTasks.days.getDetails.completed);
            return previousValue +
                element.weeklyTasks.days.getDetails.completed;
          }),
    );
    return ((completeds * 100) / (roadmap.totalDurationWeeks * 7)).ceil();
  }
}

class Milestone {
  final String id;
  final int order;
  final String title;
  final String description;
  final int startWeek;
  final int endWeek;
  final List<WeeklyObjective> weeklyObjectives;
  final Checkpoint checkpoint;

  Milestone({
    String? id,
    required this.order,
    required this.title,
    required this.description,
    required this.startWeek,
    required this.endWeek,
    required this.weeklyObjectives,
    required this.checkpoint,
  }) : id = (id == null || id == '') ? const Uuid().v4() : id;

  Milestone copyWith({
    int? order,
    String? title,
    String? description,
    int? startWeek,
    int? endWeek,
    List<WeeklyObjective>? weeklyObjectives,
    Checkpoint? checkpoint,
  }) {
    return Milestone(
      order: order ?? this.order,
      title: title ?? this.title,
      description: description ?? this.description,
      startWeek: startWeek ?? this.startWeek,
      endWeek: endWeek ?? this.endWeek,
      weeklyObjectives: weeklyObjectives ?? this.weeklyObjectives,
      checkpoint: checkpoint ?? this.checkpoint,
    );
  }

  factory Milestone.fromMap(Map<String, dynamic> map, {bool fromHive = false}) {
    return Milestone(
      id: fromHive ? map['id'] : null, // <-- only trust Hive for the id
      order: map['order'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startWeek: map['startWeek'] ?? 0,
      endWeek: map['endWeek'] ?? 0,
      weeklyObjectives: List.from(
        map['weeklyObjectives'] ?? [],
      ).map((e) => WeeklyObjective.fromMap(asStringKeyedMap(e))).toList(),
      checkpoint: Checkpoint.fromMap(asStringKeyedMap(map['checkpoint'])),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order': order,
      'title': title,
      'description': description,
      'startWeek': startWeek,
      'endWeek': endWeek,
      'weeklyObjectives': weeklyObjectives.map((e) => e.toMap()).toList(),
      'checkpoint': checkpoint.toMap(),
    };
  }
}

class WeeklyObjective {
  final int week;
  final String focus;
  final String outcome;
  final WeeklyTasks weeklyTasks;

  WeeklyObjective({
    required this.week,
    required this.focus,
    required this.outcome,
    required this.weeklyTasks,
  });

  WeeklyObjective copyWith({
    int? week,
    String? focus,
    String? outcome,
    WeeklyTasks? weeklyTasks,
  }) {
    return WeeklyObjective(
      week: week ?? this.week,
      focus: focus ?? this.focus,
      outcome: outcome ?? this.outcome,
      weeklyTasks: weeklyTasks ?? this.weeklyTasks,
    );
  }

  factory WeeklyObjective.fromMap(Map<String, dynamic> map) {
    return WeeklyObjective(
      week: map['week'] ?? 0,
      focus: map['focus'] ?? '',
      outcome: map['outcome'] ?? '',
      weeklyTasks: WeeklyTasks.fromMap(asStringKeyedMap(map['weeklyTasks'])),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'week': week,
      'focus': focus,
      'outcome': outcome,
      'weeklyTasks': weeklyTasks.toMap(),
    };
  }
}

class Checkpoint {
  final String id;
  final String title;
  final String criteria;

  Checkpoint({String? id, required this.title, required this.criteria})
    : id = (id == null || id == '') ? Uuid().v4() : id;

  Checkpoint copyWith({String? title, String? criteria}) {
    return Checkpoint(
      title: title ?? this.title,
      criteria: criteria ?? this.criteria,
    );
  }

  factory Checkpoint.fromMap(Map<String, dynamic> map) {
    return Checkpoint(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      criteria: map['criteria'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'criteria': criteria};
  }
}

Map<String, dynamic> asStringKeyedMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), v));
  }
  return <String, dynamic>{};
}
