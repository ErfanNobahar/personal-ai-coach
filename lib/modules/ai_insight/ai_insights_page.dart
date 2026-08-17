import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/modules/ai_insight/cubit/ai_insight_cubit.dart';
import 'package:personal_ai_coach/modules/ai_insight/overview.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class AiInsightsPage extends StatelessWidget {
  static String route = '/ai-insights';
  const AiInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AiInsightCubit(repo: context.read<BusinessRepository>()),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: U.Theme.afternoonPallet.getColors,
              begin: AlignmentGeometry.topCenter,
              end: AlignmentGeometry.bottomCenter,
            ),
          ),
          child: U.ScrollableTabview(
            headers: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(10),
                  height: 40,
                  width: 99,
                  color: U.Theme.outlineHigh,
                  child: U.Text(text: '1111'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(10),
                  height: 40,
                  width: 99,
                  color: U.Theme.outlineHigh,
                  child: U.Text(text: '1111'),
                ),
              ),
            ],
            pages: [
              Overview(),
              Overview(),
            ],
            tabController: ScrollController(),
            pageController: PageController(),
            onPageCountChanged: (s) {},
          ),
        ),
      ),
    );
  }
}
