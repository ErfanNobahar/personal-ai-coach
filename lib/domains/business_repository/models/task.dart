import 'package:personal_ai_coach/tool_kit/tool_kit.dart' as T;
import 'dart:core';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class WeeklyTasks {
  final String type;
  final int weekNumber;
  final String weekStartDate;
  final String weekEndDate;
  final MilestoneContext milestoneContext;
  final List<DayTask> days;
  final ProgressSnapshot progressSnapshot;
  final String insight;

  WeeklyTasks({
    required this.type,
    required this.weekNumber,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.milestoneContext,
    required this.days,
    required this.progressSnapshot,
    required this.insight,
  });
  factory WeeklyTasks.fromMap(Map<String, dynamic> map) {
    return WeeklyTasks(
      type: map['type'] ?? '',
      weekNumber: map['weekNumber'] ?? 0,
      weekStartDate: map['weekStartDate'] ?? '',
      weekEndDate: map['weekEndDate'] ?? '',
      milestoneContext: MilestoneContext.fromMap(
        map['milestoneContext'] != null
            ? Map<String, dynamic>.from(map['milestoneContext'] as Map)
            : {},
      ),
      days: List.from(map['days'] ?? [])
          .map((e) => DayTask.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      progressSnapshot: ProgressSnapshot.fromMap(
        map['progressSnapshot'] != null
            ? Map<String, dynamic>.from(map['progressSnapshot'] as Map)
            : {},
      ),
      insight: map['insight'] ?? '',
    );
  }

  bool get isCurrent {
    final now = DateTime.now();
    if (days.isNotEmpty) {
      final startDate = T.DateFormater.dateFromString(days.first.date);
      final endDate = T.DateFormater.dateFromString(days.last.date);
      return now.isAfter(startDate) && now.isBefore(endDate);
    } else {
      return false;
    }
  }

  String? get weeklyStatus {
    final res = days
        .where(
          (e) =>
              e.status == DayTaskStatus.completed ||
              e.status == DayTaskStatus.skipped,
        )
        .toList();
    if (res.isNotEmpty) {
      return res.length == days.length ? 'completed' : 'pending';
    } else {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'weekNumber': weekNumber,
      'weekStartDate': weekStartDate,
      'weekEndDate': weekEndDate,
      'milestoneContext': milestoneContext.toMap(),
      'days': days.map((e) => e.toMap()).toList(),
      'progressSnapshot': progressSnapshot.toMap(),
      'insight': insight,
    };
  }

  WeeklyTasks copyWith({
    String? type,
    int? weekNumber,
    String? weekStartDate,
    String? weekEndDate,
    MilestoneContext? milestoneContext,
    List<DayTask>? days,
    ProgressSnapshot? progressSnapshot,
    String? insight,
  }) {
    return WeeklyTasks(
      type: type ?? this.type,
      weekNumber: weekNumber ?? this.weekNumber,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      weekEndDate: weekEndDate ?? this.weekEndDate,
      milestoneContext: milestoneContext ?? this.milestoneContext,
      days: days ?? this.days,
      progressSnapshot: progressSnapshot ?? this.progressSnapshot,
      insight: insight ?? this.insight,
    );
  }
}

class MilestoneContext {
  final String milestoneId;
  final String milestoneTitle;

  MilestoneContext({required this.milestoneId, required this.milestoneTitle});

  factory MilestoneContext.fromMap(Map<String, dynamic> map) {
    return MilestoneContext(
      milestoneId: map['milestoneId'] ?? '',
      milestoneTitle: map['milestoneTitle'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'milestoneId': milestoneId, 'milestoneTitle': milestoneTitle};
  }
}

enum DayTaskStatus { skipped, completed, pending }

extension Status on DayTaskStatus {
  String get get {
    switch (this) {
      case DayTaskStatus.skipped:
        return 'skipped';
      case DayTaskStatus.completed:
        return 'completed';
      case DayTaskStatus.pending:
        return 'pending';
    }
  }
}

class DayTask extends Equatable {
  final String roadmapId;
  final String date;
  final DayTaskStatus status;
  final String scheduledTimeSlot;
  final String scheduledTimeLabel;
  final PrimaryTask primaryTask;
  final List<SupportingTask> supportingTasks;

  const DayTask({
    required this.roadmapId,
    required this.date,
    required this.status,
    required this.scheduledTimeSlot,
    required this.scheduledTimeLabel,
    required this.primaryTask,
    required this.supportingTasks,
  });

  static DayTaskStatus fromString(String? value) {
    switch (value) {
      case 'skipped':
        return DayTaskStatus.skipped;
      case 'completed':
        return DayTaskStatus.completed;
      case 'pending':
        return DayTaskStatus.pending;
      default:
        return DayTaskStatus.pending; // fallback for unknown/null values
    }
  }

  factory DayTask.fromMap(Map<String, dynamic> map) {
    return DayTask(
      roadmapId: map['roadmapId'] ?? '',
      date: map['date'],
      status: fromString(map['status'] ?? 'pending'),
      scheduledTimeSlot: map['scheduledTimeSlot'] ?? '',
      scheduledTimeLabel: map['scheduledTimeLabel'] ?? '',
      primaryTask: PrimaryTask.fromMap(
        map['primaryTask'] != null
            ? Map<String, dynamic>.from(map['primaryTask'] as Map)
            : {},
      ),
      supportingTasks: List.from(map['supportingTasks'] ?? [])
          .map(
            (e) => SupportingTask.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
    );
  }
  DayTask copyWith({
    String? roadmapId,
    String? date,
    DayTaskStatus? status,
    String? scheduledTimeSlot,
    String? scheduledTimeLabel,
    PrimaryTask? primaryTask,
    List<SupportingTask>? supportingTasks,
  }) {
    return DayTask(
      roadmapId: roadmapId ?? this.roadmapId,
      date: date ?? this.date,
      status: status ?? this.status,
      scheduledTimeSlot: scheduledTimeSlot ?? this.scheduledTimeSlot,
      scheduledTimeLabel: scheduledTimeLabel ?? this.scheduledTimeLabel,
      primaryTask: primaryTask ?? this.primaryTask,
      supportingTasks: supportingTasks ?? this.supportingTasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'roadmapId': roadmapId,
      'status': status.get,
      'scheduledTimeSlot': scheduledTimeSlot,
      'scheduledTimeLabel': scheduledTimeLabel,
      'primaryTask': primaryTask.toMap(),
      'supportingTasks': List.from(
        supportingTasks.map((e) => e.toMap()).toList(),
      ),
    };
  }

  @override
  List<Object?> get props => [
    date,
    scheduledTimeLabel,
    scheduledTimeSlot,
    primaryTask,
  ];
}

class PrimaryTask extends Equatable {
  final String id;
  final String title;
  final String description;
  final int estimatedMinutes;
  final String scheduledStartTime; // "HH:mm"
  final String scheduledEndTime; // "HH:mm"
  final String type;
  final String whyItMatters;
  final List<SuggestedSearch> suggestedSearches;

  const PrimaryTask({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.type,
    required this.whyItMatters,
    required this.suggestedSearches,
  });

  static List<String> dayTimes = [
    '01:00',
    '02:00',
    '03:00',
    '04:00',
    '05:00',
    '06:00',
    '07:00',
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
    '23:00',
    '00:00',
  ];
  String findSlot({
    required List<String> occupiedTimes,
    required String conflictingTime,
  }) {
    print('$conflictingTime vs $occupiedTimes');
    final currentTime = dayTimes.indexWhere((e) => e == conflictingTime);
    if (occupiedTimes.contains(conflictingTime)) {
      return findSlot(
        occupiedTimes: occupiedTimes,
        conflictingTime:
            dayTimes[currentTime == dayTimes.length - 1 ? 0 : currentTime + 1],
      );
    } else {
      return conflictingTime;
    }
  }

  PrimaryTask reschedule({
    required List<String> occupiedTimes,
    String? scheduledStartTime,
    String? scheduledEndTime,
  }) {
    final newTimeLine = findSlot(
      occupiedTimes: occupiedTimes,
      conflictingTime: scheduledStartTime!,
    );
    final parts = newTimeLine.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final startTotalMinutes = hour * 60 + minute;
    final endTotalMinutes = startTotalMinutes + estimatedMinutes;

    final endHour = (endTotalMinutes ~/ 60) % 24;
    final endMinute = endTotalMinutes % 60;
    final newEndTime =
        '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

    return PrimaryTask(
      id: id,
      title: title,
      description: description,
      estimatedMinutes: estimatedMinutes,
      scheduledStartTime: newTimeLine,
      scheduledEndTime: newEndTime,
      type: type,
      whyItMatters: whyItMatters,
      suggestedSearches: suggestedSearches,
    );
  }

  PrimaryTask copyWith({
    String? id,
    String? title,
    String? description,
    int? estimatedMinutes,
    String? scheduledStartTime,
    String? scheduledEndTime,
    String? type,
    String? whyItMatters,
    List<SuggestedSearch>? suggestedSearches,
  }) {
    return PrimaryTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      scheduledEndTime: scheduledEndTime ?? this.scheduledEndTime,
      type: type ?? this.type,
      whyItMatters: whyItMatters ?? this.whyItMatters,
      suggestedSearches: suggestedSearches ?? this.suggestedSearches,
    );
  }

  factory PrimaryTask.fromMap(Map<String, dynamic> map) {
    return PrimaryTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      estimatedMinutes: map['estimatedMinutes'] ?? 0,
      scheduledStartTime: map['scheduledStartTime'] ?? '',
      scheduledEndTime: map['scheduledEndTime'] ?? '',
      type: map['type'] ?? '',
      whyItMatters: map['whyItMatters'] ?? '',
      suggestedSearches: List.from(map['suggestedSearches'] ?? [])
          .map(
            (e) => SuggestedSearch.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'estimatedMinutes': estimatedMinutes,
      'scheduledStartTime': scheduledStartTime,
      'scheduledEndTime': scheduledEndTime,
      'type': type,
      'whyItMatters': whyItMatters,
      'suggestedSearches': List.from(suggestedSearches.map((e) => e.toMap())),
    };
  }

  /// Convenience for schedule-page rendering
  TimeOfDay get startTimeOfDay {
    final parts = scheduledStartTime.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  List<Object?> get props => [
    id,
    type,
    whyItMatters,
    title,
    description, // add this
    scheduledStartTime,
    scheduledEndTime, // recommend adding
    estimatedMinutes, // recommend adding
    suggestedSearches, // recommend adding
  ];
}

extension Primary on List<DayTask> {
  void sortByHour() {
    sort(
      (a, b) => _toMinutes(
        a.primaryTask.scheduledStartTime,
      ).compareTo(_toMinutes(b.primaryTask.scheduledStartTime)),
    );
  }

  static int _toMinutes(String time) {
    final p = time.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }
}

class SupportingTask {
  final String id;
  final String title;
  final int estimatedMinutes;
  final String scheduledStartTime;
  final String scheduledEndTime;
  final String type;
  final bool optional;

  SupportingTask({
    required this.id,
    required this.title,
    required this.estimatedMinutes,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.type,
    required this.optional,
  });
  SupportingTask copyWith({
    String? id,
    String? title,
    int? estimatedMinutes,
    String? scheduledStartTime,
    String? scheduledEndTime,
    String? type,
    bool? optional,
  }) {
    return SupportingTask(
      id: id ?? this.id,
      title: title ?? this.title,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      scheduledEndTime: scheduledEndTime ?? this.scheduledEndTime,
      type: type ?? this.type,
      optional: optional ?? this.optional,
    );
  }

  factory SupportingTask.fromMap(Map<String, dynamic> map) {
    return SupportingTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      estimatedMinutes: map['estimatedMinutes'] ?? 0,
      scheduledStartTime: map['scheduledStartTime'] ?? '',
      scheduledEndTime: map['scheduledEndTime'] ?? '',
      type: map['type'] ?? '',
      optional: map['optional'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'estimatedMinutes': estimatedMinutes,
      'scheduledStartTime': scheduledStartTime,
      'scheduledEndTime': scheduledEndTime,
      'type': type,
      'optional': optional,
    };
  }
}

class SuggestedSearch {
  final String query;

  SuggestedSearch({required this.query});

  factory SuggestedSearch.fromMap(Map<String, dynamic> map) {
    return SuggestedSearch(query: map['query'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'query': query};
  }
}

class ProgressSnapshot {
  final String currentMilestone;
  final int milestonesCompleted;
  final int totalMilestones;
  final int weeksAheadOrBehind;
  final String momentumStatus;

  ProgressSnapshot({
    required this.currentMilestone,
    required this.milestonesCompleted,
    required this.totalMilestones,
    required this.weeksAheadOrBehind,
    required this.momentumStatus,
  });

  factory ProgressSnapshot.fromMap(Map<String, dynamic> map) {
    return ProgressSnapshot(
      currentMilestone: map['currentMilestone'] ?? '',
      milestonesCompleted: map['milestonesCompleted'] ?? 0,
      totalMilestones: map['totalMilestones'] ?? 0,
      weeksAheadOrBehind: map['weeksAheadOrBehind'] ?? 0,
      momentumStatus: map['momentumStatus'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentMilestone': currentMilestone,
      'milestonesCompleted': milestonesCompleted,
      'totalMilestones': totalMilestones,
      'weeksAheadOrBehind': weeksAheadOrBehind,
      'momentumStatus': momentumStatus,
    };
  }
}
