import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;

import 'home_controller.dart';

class GridCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget content;

  GridCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  HomeController get c => Get.find();

  // style
  final rounded = 10.0;
  BoxShadow get shadow => BoxShadow(
        color: Colors.black12.withOpacity(opacity * 0.12),
        blurRadius: 10,
        spreadRadius: 10,
      );

  // config
  final headHeight = 34.0;
  final cardsGap = 40.0;
  final listPaddingTop = 30.0;

  // data
  final height = 0.0.obs;
  final positionInList = 0.0.obs;
  final boxKey = GlobalKey(debugLabel: 'gridCardBox');

  double get globalY {
    final renderObj = boxKey.currentContext?.findRenderObject();
    if (renderObj == null) return 0.0;
    return (renderObj as RenderBox?)?.localToGlobal(Offset.zero).dy ?? 0.0;
  }

  double get animationHeight => topOffset < 0.0
      ? max(min(height.value + topOffset, height.value), headHeight)
      : height.value;

  double get topOffset => positionInList.value - c.listOffset.value;

  bool get inTheAnimation {
    return height.value != 0.0
        ? topOffset < 0 && topOffset > -height.value + headHeight - cardsGap
        : false;
  }

  updateHeightData() {
    if (inTheAnimation) return;
    height.value = (boxKey.currentContext?.findRenderObject() as RenderBox?)
            ?.size
            .height ??
        0.0;
  }

  updatePositionInListData() {
    positionInList.value =
        globalY - c.listViewTop.value + c.listOffset.value - listPaddingTop;
  }

  double? get shellHeight => inTheAnimation ? height.value : null;
  double? get contentHeight => inTheAnimation ? animationHeight : null;

  double get translateY => inTheAnimation ? -topOffset : 0.0;
  double get opacity => topOffset < (-height.value + headHeight)
      ? min(
          max((1.0 - ((-topOffset - (height.value - headHeight)) / cardsGap)),
              0.0),
          1.0)
      : 1.0;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updatePositionInListData();
      ever(c.listViewTop, (value) {
        updatePositionInListData();
      });

      updateHeightData();
      ever(c.listOffset, (value) {
        updateHeightData();
      });
    });

    return SizedBox(
      key: boxKey,
      child: Obx(
        () => n.Box(
          n.Box(
            n.Wrap([
              n.Row([
                n.Icon(icon)
                  ..color = Colors.blue[50]!.withOpacity(0.7)
                  ..size = 14,
                n.Text(title)
                  ..color = Colors.blue[50]!.withOpacity(0.7)
                  ..fontSize = 14
                  ..fontWeight = FontWeight.w600
                  ..maxLines = 1
                  ..overflow = TextOverflow.ellipsis,
              ])
                ..pb = 4
                ..gap = 4,
              n.Box(content)
                ..rounded = 0
                ..wFull
                ..useChild(
                  (child) => ClipRect(child: child..translateY = -translateY),
                ),
            ])
              ..horizontal,
          )
            ..p = 8
            ..useChild(
              (child) => SizedBox(
                height: contentHeight,
                child: ClipRect(child: child),
              ),
            )
            ..bg = Colors.blueGrey[700]!.withOpacity(0.2)
            ..opacity = opacity
            ..bgBlur = opacity * 30
            ..rounded = rounded
            ..shadow = shadow
            ..translateY = translateY,
        )..useChild(
            (child) => Container(
              height: shellHeight,
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
      ),
    );
  }
}
