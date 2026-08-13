import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class Stepper extends StatefulWidget {
  final int id;
  final List<StepperItem> items;
  final bool primary;
  final Color? backgroundColor;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool isMoveable;
  final bool useDashedLine;
  final int count;
  final Function(int count, bool shouldExpand)? onExapndedCountChanged;

  const Stepper({
    super.key,
    required this.items,
    required this.id,
    this.primary = true,
    this.backgroundColor,
    this.shrinkWrap = true,
    this.physics,
    this.onExapndedCountChanged,
    this.isMoveable = false,
    this.useDashedLine = false,
    this.count = 0,
  });

  @override
  State<Stepper> createState() => _StepperState();
}

class _StepperState extends State<Stepper> {
  int? expandedIndex;

  bool get hasExpandedItem => expandedIndex != null;

  Color get _secondaryBackgroundColor =>
      widget.backgroundColor ?? U.Theme.onBackground;

  @override
  void didUpdateWidget(covariant Stepper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.count != widget.count) {
      setState(() {});
    }
  }

  void _toggleItem(int index, bool isExpanded) {
    widget.onExapndedCountChanged?.call(widget.id, isExpanded);

    setState(() {
      expandedIndex = isExpanded ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shouldMove = hasExpandedItem && widget.isMoveable;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      tween: Tween<double>(end: shouldMove ? widget.count.toDouble() : 0.0),
      builder: (context, value, child) {
        return FractionallySizedBox(
          alignment: Alignment.topRight,
          widthFactor: 1 + (0.08 * value),
          child: child,
        );
      },
      child: ListView.builder(
        padding: widget.primary ? const EdgeInsets.all(8) : EdgeInsets.zero,
        itemCount: widget.items.length,
        shrinkWrap: widget.shrinkWrap,
        primary: false,
        physics:
            widget.physics ??
            (widget.shrinkWrap
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics()),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final isExpanded = expandedIndex == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (index != widget.items.length - 1)
                  Positioned(
                    left: 5,
                    top: widget.useDashedLine ? 20 : 25,
                    bottom: widget.useDashedLine ? -26 : -32,
                    child: widget.useDashedLine
                        ? SizedBox(
                            width: 3,
                            child: VerticalDashedLine(
                              color: U.Theme.divider,
                              width: 3,
                              dashHeight: 6,
                              dashSpacing: 4,
                              radius: 12,
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            width: 3,
                            decoration: BoxDecoration(
                              color: U.Theme.divider,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIndicator(item),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.subTitle != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Column(
                                children: [
                                  U.Text(
                                    text: item.subTitle!,
                                    color: U.Theme.primary,
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ),
                            ),
                          widget.primary
                              ? _buildPrimaryItem(item, index, isExpanded)
                              : _buildSecondaryItem(item, index, isExpanded),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIndicator(StepperItem item) {
    return Column(
      children: [
        const SizedBox(height: 13),
        item.isDone != null
            ? Container(
                height: 13,
                width: 13,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isDone! ? Colors.green : Color(0xFFE49B9B),
                ),
              )
            : Container(
                height: 14,
                width: 14,
                decoration: BoxDecoration(
                  border: Border.all(color: U.Theme.primary),
                  shape: BoxShape.circle,
                  color: item.inProgress ? U.Theme.primary : U.Theme.white,
                ),
                child: Center(
                  child: Container(
                    height: 6,
                    width: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.inProgress ? U.Theme.white : U.Theme.primary,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildHeader(
    StepperItem item,
    int index,
    bool isExpanded, {
    required Color color,
    required BorderRadius borderRadius,
  }) {
    return InkWell(
      borderRadius: borderRadius,
      onTap: item.isDisabled ? null : () => _toggleItem(index, isExpanded),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: item.isDisabled
              ? color.withValues(alpha: 0.3)
              : color.withValues(alpha: 0.6),
          borderRadius: borderRadius,
        ),
        child: Row(
          children: [
            Expanded(
              child: U.Text(
                text: item.title,
                color: item.isDisabled
                    ? U.Theme.primaryText.withValues(alpha: 0.4)
                    : U.Theme.primaryText,
                textSize: U.TextSize.s16,
                textWeight: U.TextWeight.semiBold,
              ),
            ),
            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: isExpanded ? 0.5 : 0,
              child: Icon(
                Icons.keyboard_arrow_down,
                color: item.isDisabled
                    ? U.Theme.secondaryButton.withValues(alpha: 0.4)
                    : U.Theme.secondaryButton,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Original / primary visual style.
  Widget _buildPrimaryItem(StepperItem item, int index, bool isExpanded) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(
          item,
          index,
          isExpanded,
          color: U.Theme.onBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        ClipRect(
          child: Padding(
            padding: item.padding,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: U.Theme.outlineHigh,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Align(
                                alignment: AlignmentGeometry.xy(1.0, 0),

                                child: Column(
                                  children: [
                                    item.child,
                                    if (isExpanded && item.loading)
                                      // _buildLoader(),
                                      SizedBox(height: 3),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (item.onTap != null)
                            GestureDetector(
                              onTap: item.onTap,
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: U.Theme.divider.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.arrow_right_sharp,
                                  size: 21,
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  // Bordered / non-primary visual style.
  Widget _buildSecondaryItem(StepperItem item, int index, bool isExpanded) {
    final headerRadius = isExpanded
        ? const BorderRadius.only(
            topLeft: Radius.circular(7),
            topRight: Radius.circular(7),
          )
        : BorderRadius.circular(7);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: U.Theme.divider.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(
            item,
            index,
            isExpanded,
            color: _secondaryBackgroundColor,
            borderRadius: headerRadius,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Column(
                    children: [
                      Container(
                        color: _secondaryBackgroundColor.withValues(alpha: 0.6),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: item.itemBackground,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 2,
                                offset: const Offset(0, -2),
                                color: U.Theme.primary.withValues(alpha: 0.2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    item.child,
                                    if (item.loading) _buildLoader(),
                                  ],
                                ),
                              ),
                              if (item.onTap != null)
                                GestureDetector(
                                  onTap: item.onTap,
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: U.Theme.divider.withValues(
                                        alpha: 0.6,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_right_sharp,
                                      size: 21,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return Align(
      alignment: AlignmentGeometry.xy(0.14, 0),
      child: Column(
        children: [
          const SizedBox(height: 7),
          LoadingAnimationWidget.fourRotatingDots(
            color: U.Theme.primary,
            size: 20,
          ),
          SizedBox(height: 6),
        ],
      ),
    );
  }
}

class StepperItem {
  final bool isDisabled;
  final bool? isDone;
  final bool inProgress;
  final bool loading;
  final EdgeInsetsGeometry padding;
  final String title;
  final String? subTitle;
  final Widget child;
  final Color? itemBackground;
  final Function()? onTap;

  StepperItem({
    this.isDisabled = false,
    this.inProgress = false,
    this.loading = false,
    this.padding = const EdgeInsets.only(left: 16.0),
    this.isDone,
    required this.title,
    this.subTitle,
    this.itemBackground = U.Theme.background,
    required this.child,
    this.onTap,
  });
}

class VerticalDashedLine extends StatelessWidget {
  final double width;
  final Color color;
  final double dashHeight;
  final double dashSpacing;
  final double radius;

  const VerticalDashedLine({
    super.key,
    this.width = 3,
    required this.color,
    this.dashHeight = 6,
    this.dashSpacing = 4,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxHeight / (dashHeight + dashSpacing))
            .floor();

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return Container(
              width: width,
              height: dashHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(radius),
              ),
            );
          }),
        );
      },
    );
  }
}
