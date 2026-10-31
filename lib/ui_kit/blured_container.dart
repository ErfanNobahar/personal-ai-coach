import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredContainer extends StatefulWidget {
  //
  final bool enable;

  final double radius;
  final ScrollController? scrollCtrl;

  final Widget child;

  const BlurredContainer({
    super.key,
    required this.enable,
    required this.radius,
    required this.child,
    required this.scrollCtrl,
  });

  @override
  State<BlurredContainer> createState() => BlurredContainerState();
}

class BlurredContainerState extends State<BlurredContainer> {
  bool applyColor = false;
  @override
  void didUpdateWidget(oldWidget) {
    if (oldWidget.scrollCtrl != widget.scrollCtrl) {
      oldWidget.scrollCtrl?.removeListener(changeColor);
      changeColor();
      widget.scrollCtrl?.addListener(changeColor);
    }
    super.didUpdateWidget(oldWidget);
  }

  void changeColor() {
    var temp = applyColor;
    if (widget.scrollCtrl == null) {
      temp = true;
    } else {
      temp = widget.scrollCtrl!.hasClients
          ? widget.scrollCtrl!.offset > 4
          : false;
    }
    if (temp != applyColor) {
      setState(() {
        applyColor = temp;
      });
    }
  }

  @override
  void initState() {
    changeColor();
    widget.scrollCtrl?.addListener(changeColor);
    super.initState();
  }

  @override
  void dispose() {
    if (widget.scrollCtrl != null) {
      widget.scrollCtrl!.removeListener(changeColor);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: Radius.circular( widget.radius),topRight: Radius.circular( widget.radius),),
      // Important: clips the blur to bounds
child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.enable ? 10.0 : 0.0,
          sigmaY: widget.enable ? 10.0 : 0.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: applyColor
                ? Colors.white.withValues(
                    alpha: 0.34,
                  ) // Semi-transparent so blur shows
                : Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadiusDirectional.vertical(
              top: Radius.circular(widget.radius),
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
