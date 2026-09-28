import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<T?> showPaperDialog<T>({
  required Widget child,
  bool barrierDismissible = true,
  Color barrierColor = Colors.black54,
}) {
  return Get.generalDialog<T>(
    barrierDismissible: barrierDismissible,
    barrierLabel: 'dialog',
    barrierColor: barrierColor,
    transitionDuration: const Duration(milliseconds: 420),
    transitionBuilder: (context, animation, secondaryAnimation, widget) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: AnimatedBuilder(
          animation: curved,
          builder: (context, _) {
            final t = curved.value;
            return Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.00115)
                ..rotateX((1 - t) * 1.22)
                ..scaleByDouble(
                  0.94 + (0.06 * t),
                  0.12 + (0.88 * t),
                  1.0,
                  1.0,
                ),
              child: widget,
            );
          },
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: Center(
          child: Material(
            type: MaterialType.transparency,
            child: child,
          ),
        ),
      );
    },
  );
}
