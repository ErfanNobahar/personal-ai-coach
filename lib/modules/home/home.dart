import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_ai_coach/modules/chat/chat_page.dart';
import 'package:personal_ai_coach/modules/schedule/task_creation_btms.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class HomeSell extends StatelessWidget {
  final Widget child;

  const HomeSell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Stack(
        children: [
          // Positioned.fill(child: child),
          Positioned(top: 0, left: 0, right: 0, bottom: 0, child: child),
          Positioned.fill(
            bottom: 0,
            left: 0,
            right: 0,
            child: U.NavigationBar(
              navItems: [
                U.NavBarItem(
                  isPrimary: true,
                  title: 'title',
                  path: U.Icons.menu,
                  onTap: () {
                    TaskCreationBtms.show(context);
                  },
                ),
                U.NavBarItem(
                  isPrimary: true,
                  title: 'title',
                  path: U.Icons.chat,
                  onTap: () {
                    GoRouter.of(context).pushNamed(ChatPge.route);
                  },
                ),
                U.NavBarItem(
                  isPrimary: false,
                  title: 'title',
                  path: U.Icons.create,
                  onTap: () {},
                ),
                U.NavBarItem(
                  isPrimary: false,
                  title: 'tasks',
                  path: U.Icons.progression,
                  onTap: () {},
                ),
                U.NavBarItem(
                  isPrimary: false,
                  title: 'journey',
                  path: U.Icons.journey,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
