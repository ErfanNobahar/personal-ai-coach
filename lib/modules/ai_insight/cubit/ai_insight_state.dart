part of 'ai_insight_cubit.dart';

class AiInsightState extends Equatable {
  final bool loading;
  final List<SpecificTasks> weeklyTasks;
  final List<Goal> goals;
  const AiInsightState({
    required this.loading,
    required this.weeklyTasks,
    required this.goals,
  });

  const AiInsightState.init()
    : loading = true,
      weeklyTasks = const [],
      goals = const [];

  AiInsightState copyWith({
    bool? loading,
    List<SpecificTasks>? weeklyTasks,
    List<Goal>? goals,
  }) {
    return AiInsightState(
      loading: loading ?? this.loading,
      weeklyTasks: weeklyTasks ?? this.weeklyTasks,
      goals: goals ?? this.goals,
    );
  }

  @override
  List<Object> get props => [loading, weeklyTasks];
}
