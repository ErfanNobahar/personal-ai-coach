import 'package:flutter/material.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class NavigationBar extends StatefulWidget {
  final List<NavBarItem> navItems;
  final int selectedIndex;
  final Function(int index) onIndexChanged;
  const NavigationBar({
    super.key,
    required this.navItems,
    required this.onIndexChanged,
    required this.selectedIndex,
  });

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  final _sheetController = DraggableScrollableController();

  static const double _collapsedHeightPx = 114;
  static const double _maxChildSize = 0.8;

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Convert the fixed 144px target into a fraction of the
        // available height, since the sheet only works in fractions.
        final double totalHeight = constraints.maxHeight;
        final double minChildSize = (_collapsedHeightPx / totalHeight).clamp(
          0.0,
          1.0,
        );

        return DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: minChildSize,
          minChildSize: minChildSize,
          maxChildSize: _maxChildSize,
          snap: true,
          snapSizes: [minChildSize, _maxChildSize],
          builder: (context, scrollController) {
            final primaryList = widget.navItems
                .where((e) => e.isPrimary)
                .toList();
            final secondaryyList = widget.navItems
                .where((e) => !e.isPrimary)
                .toList();

            return Container(
              decoration: BoxDecoration(
                color: U.Theme.white.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CustomScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onVerticalDragUpdate: (details) {
                          final delta = details.primaryDelta! / totalHeight;
                          final newSize = (_sheetController.size - delta).clamp(
                            minChildSize,
                            _maxChildSize,
                          );
                          _sheetController.jumpTo(newSize);
                        },
                        onVerticalDragEnd: (details) {
                          final current = _sheetController.size;
                          final target =
                              (current - minChildSize).abs() <
                                  (current - _maxChildSize).abs()
                              ? minChildSize
                              : _maxChildSize;
                          _sheetController.animateTo(
                            target,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );

                          _sheetController.animateTo(
                            target,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Column(
                          children: [
                            const SizedBox(height: 14),
                            Container(
                              height: 5,
                              width: 40,
                              color: U.Theme.white,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 64,
                              decoration: BoxDecoration(
                                color: U.Theme.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 50),
                                  ...primaryList
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => PrimaryItem(
                                          isSelected:
                                              widget.selectedIndex == e.key,
                                          path: e.value.path,
                                          onTap: () =>
                                              widget.onIndexChanged(e.key),
                                        ),
                                      )
                                      .toList(),
                                  const SizedBox(width: 50),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    SliverList.separated(
                      itemBuilder: (context, i) {
                        final start = i * 2;
                        final end = (start + 2 > secondaryyList.length)
                            ? secondaryyList.length
                            : start + 2;
                        return ChunkItems(
                          list: secondaryyList.sublist(start, end),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemCount: (secondaryyList.length / 2).ceil(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class NavBarItem {
  final bool isPrimary;
  final String title;
  final String path;

  NavBarItem({
    required this.isPrimary,
    required this.title,
    required this.path,
  });
}

class PrimaryItem extends StatelessWidget {
  final String path;
  final Function() onTap;
  final bool isSelected;
  const PrimaryItem({
    super.key,
    required this.path,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? U.Theme.outlineHigh : null,
      child: GestureDetector(
        onTap: onTap,
        child: U.Image.icon(path: path, size: 36),
      ),
    );
  }
}

class SecondaryItem extends StatelessWidget {
  final String path;
  final String title;
  const SecondaryItem({super.key, required this.path, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF8FCFF),
      ),
      // margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 20),
        child: Column(
          children: [
            U.Image.icon(path: path, size: 64),
            const SizedBox(height: 18),
            U.Text(
              text: title,
              textSize: U.TextSize.s18,
              textWeight: U.TextWeight.bold,
            ),
          ],
        ),
      ),
    );
  }
}

class ChunkItems extends StatelessWidget {
  final List<NavBarItem> list;
  const ChunkItems({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: U.Theme.white,
        borderRadius: BorderRadius.circular(15),
      ),
      // margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...list.map((e) => SecondaryItem(path: e.path, title: e.title)),
          ],
        ),
      ),
    );
  }
}
