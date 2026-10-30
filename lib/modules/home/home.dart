import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_ai_coach/modules/home/cubit/home_cubit.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class HomeSell extends StatelessWidget {
  final bool hideNavbar;
  final StatefulNavigationShell child;

  const HomeSell({super.key, required this.child, this.hideNavbar = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: Builder(
        builder: (context) {
          print('hideNavbar');
          print(hideNavbar);
          context.read<HomeCubit>().onIndexChanged(child.currentIndex);
          return Scaffold(
            backgroundColor: Colors.grey,
            body: Stack(
              children: [
                Positioned(top: 0, left: 0, right: 0, bottom: 0, child: child),
                AnimatedPositioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  top: 0,
                  duration: Duration(milliseconds: 300),
                  child: U.NavigationBar(
                    selectedIndex: child.currentIndex,
                    onIndexChanged: (index) {
                      child.goBranch(index);
                    },
                    navItems: [
                      U.NavBarItem(
                        isPrimary: true,
                        title: 'title',
                        path: U.Icons.menu,
                      ),
                      U.NavBarItem(
                        isPrimary: true,
                        title: 'title',
                        path: U.Icons.chat,
                      ),
                      U.NavBarItem(
                        isPrimary: false,
                        title: 'title',
                        path: U.Icons.create,
                      ),
                      U.NavBarItem(
                        isPrimary: false,
                        title: 'tasks',
                        path: U.Icons.progression,
                      ),
                      U.NavBarItem(
                        isPrimary: false,
                        title: 'journey',
                        path: U.Icons.journey,
                      ),
                      U.NavBarItem(
                        isPrimary: false,
                        title: 'Ai masnager',
                        path: U.Icons.journey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
