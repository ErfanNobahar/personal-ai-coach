part of 'roadmaps_cubit.dart';

class RoadmapsState {
  final bool loading;

  RoadmapsState({required this.loading});

  RoadmapsState.init() : loading = false;

  RoadmapsState copyWith({bool? loading}) {
    return RoadmapsState(loading: loading ?? this.loading);
  }
}
