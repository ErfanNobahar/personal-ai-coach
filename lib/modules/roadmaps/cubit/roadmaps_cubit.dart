import 'package:bloc/bloc.dart';

part 'roadmaps_state.dart';

class RoadmapsCubit extends Cubit<RoadmapsState> {
  RoadmapsCubit() : super(RoadmapsState.init());
}
