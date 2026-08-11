part of 'roadmaps_cubit.dart';

enum RoadmapsStateStatus { empty, filled, error }

class RoadmapsState {
  final bool loading;
  final List<Roadmap> roadmaps;
  final RoadmapsStateStatus status;
  RoadmapsState({
    required this.loading,
    required this.roadmaps,
    required this.status,
  });

  RoadmapsState.init()
    : status = RoadmapsStateStatus.empty,
      loading = false,
      roadmaps = [];

  RoadmapsState copyWith({
    bool? loading,
    List<Roadmap>? roadmaps,
    RoadmapsStateStatus? status,
  }) {
    return RoadmapsState(
      loading: loading ?? this.loading,
      roadmaps: roadmaps ?? this.roadmaps,
      status: status ?? this.status,
    );
  }
}
