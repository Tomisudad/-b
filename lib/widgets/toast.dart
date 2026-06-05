import 'package:flutter/material.dart';

/// Toast 组件 — 严格对照 HTML toast() 函数
/// 底部居中，深色半透明背景，白色文字，圆角 full
/// 2秒自动消失，从底部淡入动画
class Toast {
  static OverlayEntry? _entry;

  static void show(BuildContext context, String message) {
    _entry?.remove();
    _entry = OverlayEntry(
      builder: (ctx) => Positioned(
        bottom: 100,
        left: 0,
        right: 0,
        child: IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                builder: (ctx, opacity, child) {
                  return Opacity(
                    opacity: opacity,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - opacity)),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final overlay = Overlay.of(context);
    overlay.insert(_entry!);

    Future.delayed(const Duration(seconds: 2), () {
      _entry?.remove();
      _entry = null;
    });
  }
}
