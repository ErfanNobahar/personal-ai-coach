import 'package:equatable/equatable.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';

enum ChatIntent {
  rescheduleTask,
  deleteTask,
  addTask,
  query,
  disallowed,
  clarificationNeeded,
  retry;

  static ChatIntent fromString(String? value) {
    switch (value) {
      case 'reschedule_task':
        return ChatIntent.rescheduleTask;
      case 'delete_task':
        return ChatIntent.deleteTask;
      case 'add_task':
        return ChatIntent.addTask;
      case 'query':
        return ChatIntent.query;
      case 'disallowed':
        return ChatIntent.disallowed;
      case 'clarification_needed':
        return ChatIntent.clarificationNeeded;
      case 'retry':
      default:
        return ChatIntent.retry; // safest fallback: ask user to rephrase
    }
  }

  String get value {
    switch (this) {
      case ChatIntent.rescheduleTask:
        return 'reschedule_task';
      case ChatIntent.deleteTask:
        return 'delete_task';
      case ChatIntent.addTask:
        return 'add_task';
      case ChatIntent.query:
        return 'query';
      case ChatIntent.disallowed:
        return 'disallowed';
      case ChatIntent.clarificationNeeded:
        return 'clarification_needed';
      case ChatIntent.retry:
        return 'retry';
    }
  }
}

class ChatResponse extends Equatable {
  final String type;
  final ChatIntent intent;
  final String message;
  final ProposedAction? proposedAction;
  final Clarification? clarification;

  const ChatResponse({
    required this.type,
    required this.intent,
    required this.message,
    this.proposedAction,
    this.clarification,
  });

  factory ChatResponse.fromMap(Map<String, dynamic> map) {
    final proposedActionMap = map['proposedAction'];
    final clarificationMap = map['clarification'];
    print('map ssssssssssss');
    print(map['message'].runtimeType);
    print(map['type']);
    return ChatResponse(
      type: map['type'] ?? '',
      intent: ChatIntent.fromString(map['intent']),
      message: map['message'] ?? '',
      proposedAction: proposedActionMap != null
          ? ProposedAction.fromMap(asStringMap(proposedActionMap))
          : null,
      clarification: clarificationMap != null
          ? Clarification.fromMap(asStringMap(clarificationMap))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'intent': intent.value,
      'message': message,
      'proposedAction': proposedAction?.toMap(),
      'clarification': clarification?.toMap(),
    };
  }

  @override
  List<Object?> get props => [
    type,
    intent,
    message,
    proposedAction,
    clarification,
  ];
}

class ProposedAction extends Equatable {
  final String actionType; // "reschedule_task" | "delete_task" | "add_task"
  final String? taskId; // used for reschedule_task
  final List<String> taskIds; // used for delete_task (can target more than one)
  final bool isPrimaryTask;
  final String date;
  final String?
  newStartTime; // reschedule_task only; end time is always computed client-side
  final ProposedTaskPayload? task; // add_task only

  const ProposedAction({
    required this.actionType,
    this.taskId,
    this.taskIds = const [],
    this.isPrimaryTask = false,
    required this.date,
    this.newStartTime,
    this.task,
  });

factory ProposedAction.fromMap(Map<String, dynamic> map) {
    final taskMap = map['task'];
    return ProposedAction(
      actionType: map['actionType'] ?? '',
      taskId: map['taskId'],
      taskIds: List<String>.from(map['taskIds'] ?? []),
      isPrimaryTask: map['isPrimaryTask'] == true,
      date: map['date'] ?? '', // <-- FIX: Read date from map
      newStartTime: map['newStartTime'],
      task: taskMap != null
          ? ProposedTaskPayload.fromMap(asStringMap(taskMap))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'actionType': actionType,
      'taskId': taskId,
      'taskIds': taskIds,
      'isPrimaryTask': isPrimaryTask,
      'date': date,
      'newStartTime': newStartTime,
      'task': task?.toMap(),
    };
  }

  @override
  List<Object?> get props => [
    actionType,
    taskId,
    taskIds,
    isPrimaryTask,
    date,
    newStartTime,
    task,
  ];
}

/// Content-only payload for a newly proposed task. Deliberately has NO id
/// and NO scheduledEndTime — both must always be generated/computed
/// client-side via TaskFactory, never trusted from the AI response.
class ProposedTaskPayload extends Equatable {
  final String title;
  final String description;
  final int estimatedMinutes;
  final String scheduledStartTime;
  final String type;
  final String whyItMatters;
  final List<SuggestedSearch> suggestedSearches;
  final bool optional; // only meaningful when added as a supporting task

  const ProposedTaskPayload({
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    required this.scheduledStartTime,
    required this.type,
    required this.whyItMatters,
    required this.suggestedSearches,
    required this.optional,
  });

  factory ProposedTaskPayload.fromMap(Map<String, dynamic> map) {
    return ProposedTaskPayload(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      estimatedMinutes: map['estimatedMinutes'] ?? 0,
      scheduledStartTime: map['scheduledStartTime'] ?? '',
      type: map['type'] ?? '',
      whyItMatters: map['whyItMatters'] ?? '',
      suggestedSearches: asModelList(
        map['suggestedSearches'],
        SuggestedSearch.fromMap,
      ),
      optional: map['optional'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'estimatedMinutes': estimatedMinutes,
      'scheduledStartTime': scheduledStartTime,
      'type': type,
      'whyItMatters': whyItMatters,
      'suggestedSearches': suggestedSearches.map((e) => e.toMap()).toList(),
      'optional': optional,
    };
  }

  @override
  List<Object?> get props => [
    title,
    description,
    estimatedMinutes,
    scheduledStartTime,
    type,
    whyItMatters,
    suggestedSearches,
    optional,
  ];
}

class Clarification extends Equatable {
  final String question;
  final List<ClarificationOption> options;

  const Clarification({required this.question, required this.options});

  factory Clarification.fromMap(Map<String, dynamic> map) {
    return Clarification(
      question: map['question'] ?? '',
      options: List.from(
        map['options'],
      ).map((e) => ClarificationOption.fromMap(e)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options.map((e) => e.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [question, options];
}

class ClarificationOption extends Equatable {
  final String id;
  final String label;

  const ClarificationOption({required this.id, required this.label});

  factory ClarificationOption.fromMap(Map<String, dynamic> map) {
    return ClarificationOption(id: map['id'] ?? '', label: map['label'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'label': label};
  }

  @override
  List<Object?> get props => [id, label];
}

// map_utils.dart

/// Safely converts any Map (including Hive's untyped Map<dynamic, dynamic>)
/// into a proper Map<String, dynamic>. Returns {} if null.
Map<String, dynamic> asStringMap(dynamic value) {
  if (value == null) return {};
  return Map<String, dynamic>.from(value as Map);
}

/// Safely converts a dynamic list of maps into a typed list of models.
/// Works regardless of whether the source is JSON-decoded or Hive-decoded.
List<T> asModelList<T>(
  dynamic value,
  T Function(Map<String, dynamic>) fromMap,
) {
  if (value == null) return [];
  return List.from(value).map((e) => fromMap(asStringMap(e))).toList();
}
