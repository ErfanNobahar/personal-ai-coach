import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_ai_coach/modules/chat/chat_page.dart';
import 'package:personal_ai_coach/modules/home/home.dart';
import 'package:personal_ai_coach/modules/roadmap/roadmap_page.dart';
import 'package:personal_ai_coach/modules/schedule/schedule_page.dart';
import 'package:personal_ai_coach/modules/task/task_page.dart';

final rootNavKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: SchedulePage.route,
  navigatorKey: rootNavKey,

  routes: [
    // GoRoute(
    //   path: Chat.route,
    //   name: Chat.route,
    //   builder: (context, state) => Chat(),
    // ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          HomeSell(child: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: ChatPge.route,
              name: ChatPge.route,
              builder: (context, state) => ChatPge(),
            ),
            GoRoute(
              path: RoadmapPage.route,
              name: RoadmapPage.route,
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                return RoadmapPage(
                  goal: extra['goal'] as String?,
                  roadMap: extra['roadMap'] as dynamic,
                  tasks: extra['tasks'] as dynamic,
                );
              },
            ),
            GoRoute(
              path: TaskDetailPage.route,
              name: TaskDetailPage.route,
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                return TaskDetailPage(
                  milestoneTitle: extra['milestone'] as String?,
                  initialTask: extra['task'] as dynamic,
                );
              },
            ),
            GoRoute(
              path: SchedulePage.route,
              name: SchedulePage.route,
              builder: (context, state) {
                return SchedulePage(initialTasks: state.extra as dynamic);
              },
            ),
          ],
        ),
      ],
    ),
    // ShellRoute(
    //   builder: (context, state, child) {
    //     return HomeSell(child: child);
    //   },
    //   routes: [GoRoute(path: Chat.route, name: Chat.route,
    //   builder: (context, state) => Chat(),
    //   )],
    // ),
  ],
);
