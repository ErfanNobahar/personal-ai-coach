import 'package:personal_ai_coach/domains/business_repository/models/roadmap.dart';

class Goal {
  final String roadmapId;
  final Roadmap? roadmap;
  Goal({this.roadmap, required this.roadmapId});
}
