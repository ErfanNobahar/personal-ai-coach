import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/modules/chat/chat_page.dart';
import 'package:personal_ai_coach/modules/home/cubit/home_cubit.dart';
import 'package:personal_ai_coach/modules/roadmaps/cubit/roadmaps_cubit.dart';
import 'package:personal_ai_coach/modules/roadmaps/grid_item.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class RoadmapsPage extends StatelessWidget {
  const RoadmapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoadmapsCubit(context.read<BusinessRepository>()),
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: (previous, current) {
          return current.selectedIndex == 6;
        },
        listener: (context, state) {
          context.read<RoadmapsCubit>().onInit();
        },
        child: BlocBuilder<RoadmapsCubit, RoadmapsState>(
          builder: (context, state) {
            return state.loading
                ? Center(child: CircularProgressIndicator())
                : Scaffold(
                    body: switch (state.status) {
                      RoadmapsStateStatus.empty => Center(
                        child: Column(
                          children: [
                            U.Text(text: 'You havent created any roadmaps'),
                            SizedBox(height: 15),
                            U.OutlineButton(
                              title: 'craete now!',
                              onTap: () {
                                GoRouter.of(context).pushNamed(ChatPge.route);
                              },
                            ),
                          ],
                        ),
                      ),
                      RoadmapsStateStatus.filled => GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 20,
                          crossAxisCount:
                              MediaQuery.of(context).size.width ~/ 200,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return GridItem(roadmap: state.roadmaps[index]);
                        },
                      ),
                      RoadmapsStateStatus.error => Center(
                        child: U.Text(text: 'You havent created any roadmaps'),
                      ),
                    },
                  );
          },
        ),
      ),
    );
  }
}
