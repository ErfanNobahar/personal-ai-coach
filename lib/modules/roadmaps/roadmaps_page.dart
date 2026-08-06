import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_ai_coach/modules/roadmaps/cubit/roadmaps_cubit.dart';

class RoadmapsPage extends StatelessWidget {
  const RoadmapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoadmapsCubit(),
      child: Scaffold(body: ListView(children: [])),
    );
  }
}
