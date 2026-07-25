import 'package:flutter/material.dart';

class ScrollableTabview extends StatefulWidget {
  final List<Widget> headers;
  final List<Widget> pages;
  final ScrollController tabController;
  final PageController pageController;

  /// Called ONLY when the active page settles on a whole integer.
  /// [progress] is a double between 0.0 (first page) and 1.0 (last page).
  final Function(double progress) onPageCountChanged;

  const ScrollableTabview({
    super.key,
    required this.headers,
    required this.pages,
    required this.tabController,
    required this.pageController,
    required this.onPageCountChanged,
  }) : assert(headers.length == pages.length);

  @override
  State<ScrollableTabview> createState() => _ScrollableTabviewState();
}

enum _SyncSource { tabs, pages }

class _ScrollableTabviewState extends State<ScrollableTabview> {
  static const double _pageChangeThreshold = 0.70;
  static const Duration _pageChangeDuration = Duration(milliseconds: 220);
  _SyncSource? _syncSource;
  int _activeIndex = 0;

  double _progress(ScrollMetrics metrics) {
    if (metrics.maxScrollExtent <= 0) return 0;
    return (metrics.pixels / metrics.maxScrollExtent).clamp(0.0, 1.0);
  }

  double _indexToProgress(int index) {
    final maxIndex = widget.pages.length - 1;
    if (maxIndex <= 0) return 0.0;
    return (index / maxIndex).clamp(0.0, 1.0);
  }

  void _jumpToIfNeeded(ScrollController controller, double target) {
    if (!controller.hasClients) return;
    final position = controller.position;
    final clampedTarget = target.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if ((position.pixels - clampedTarget).abs() > 0.5) {
      controller.jumpTo(clampedTarget);
    }
  }

  void _updatePageFromTabScroll() {
    if (!widget.tabController.hasClients || !widget.pageController.hasClients)
      return;
    if (widget.pages.length <= 1) return;

    final maxIndex = widget.pages.length - 1;
    final progress = _progress(widget.tabController.position);
    final onePageProgress = 1 / maxIndex;
    final activePageProgress = _activeIndex * onePageProgress;
    final difference = progress - activePageProgress;

    int targetIndex = _activeIndex;

    if (difference >= onePageProgress * _pageChangeThreshold) {
      final pagesToMove = (difference / onePageProgress).ceil();
      targetIndex = (_activeIndex + pagesToMove).clamp(0, maxIndex);
    } else if (difference <= -onePageProgress * _pageChangeThreshold) {
      final pagesToMove = (difference.abs() / onePageProgress).ceil();
      targetIndex = (_activeIndex - pagesToMove).clamp(0, maxIndex);
    }

    if (targetIndex == _activeIndex) return;

    setState(() => _activeIndex = targetIndex);

    widget.onPageCountChanged(_indexToProgress(targetIndex));

    widget.pageController.animateToPage(
      targetIndex,
      duration: _pageChangeDuration,
      curve: Curves.easeOutCubic,
    );
  }

  bool _onTabNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;

    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _syncSource = _SyncSource.tabs;
    }

    if (notification is ScrollUpdateNotification &&
        _syncSource == _SyncSource.tabs) {
      _updatePageFromTabScroll();
    }

    if (notification is ScrollEndNotification &&
        _syncSource == _SyncSource.tabs) {
      _syncSource = null;
    }

    return false;
  }

  bool _onPageNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;

    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _syncSource = _SyncSource.pages;
    }

    if (notification is ScrollUpdateNotification &&
        _syncSource == _SyncSource.pages &&
        widget.tabController.hasClients) {
      final progress = _progress(notification.metrics);
      final targetTabPixels =
          progress * widget.tabController.position.maxScrollExtent;
      _jumpToIfNeeded(widget.tabController, targetTabPixels);
    }

    // Only fire callback when the page settles on a whole integer
    if (notification is ScrollEndNotification &&
        _syncSource == _SyncSource.pages) {
      _syncSource = null;

      final page = widget.pageController.page?.round() ?? _activeIndex;
      if (page != _activeIndex) {
        setState(() => _activeIndex = page);
      }
      widget.onPageCountChanged(_indexToProgress(page));
    }

    return false;
  }

  Future<void> _onTabTap(int index) async {
    if (!widget.pageController.hasClients) return;

    setState(() => _activeIndex = index);
    _syncSource = _SyncSource.pages;

    widget.onPageCountChanged(_indexToProgress(index));

    await widget.pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    if (mounted && _syncSource == _SyncSource.pages) {
      _syncSource = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 19,
          child: NotificationListener<ScrollNotification>(
            onNotification: _onTabNotification,
            child: ListView.separated(
              controller: widget.tabController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              physics: const ClampingScrollPhysics(),
              itemCount: widget.headers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final isActive = index == _activeIndex;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _onTabTap(index),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: isActive ? 1 : 0.6,
                    child: widget.headers[index],
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 81,
          child: NotificationListener<ScrollNotification>(
            onNotification: _onPageNotification,
            child: PageView(
              controller: widget.pageController,
              children: widget.pages,
            ),
          ),
        ),
      ],
    );
  }
}
