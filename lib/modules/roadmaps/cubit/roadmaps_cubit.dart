import 'package:bloc/bloc.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/domains/business_repository/models/roadmap.dart';

part 'roadmaps_state.dart';

class RoadmapsCubit extends Cubit<RoadmapsState> {
  BusinessRepository _repo;

  RoadmapsCubit(BusinessRepository repo)
    : _repo = repo,
      super(RoadmapsState.init());

  ////////////Functions
  Future<List<Roadmap>> getRoadmaps() async {
    final res = _repo.readRoadmaps();
    return res;
  }

  ////////////Events
  void onInit() async {
    emit(state.copyWith(loading: true));
    final res = await getRoadmaps();
    emit(
      state.copyWith(
        loading: false,
        roadmaps: res,
        status: res.isEmpty
            ? RoadmapsStateStatus.empty
            : RoadmapsStateStatus.filled,
      ),
    );
  }
}
