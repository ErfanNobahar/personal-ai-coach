part of 'ai_insight_cubit.dart';

class AiInsightState extends Equatable {
  final bool loading;
  final List<SpecificTasks> weeklyTasks;

  const AiInsightState({required this.loading, required this.weeklyTasks});

  const AiInsightState.init() : loading = true, weeklyTasks = const [];

  AiInsightState copyWith({bool? loading, List<SpecificTasks>? weeklyTasks}) {
    return AiInsightState(
      loading: loading ?? this.loading,
      weeklyTasks: weeklyTasks ?? this.weeklyTasks,
    );
  }

  @override
  List<Object> get props => [loading, weeklyTasks];
}
