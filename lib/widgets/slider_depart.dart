import 'package:flutter/material.dart';
import 'dart:math';
import '../config/theme.dart';

/// 滑动出发按钮 — 严格对照 HTML initSlider() / startDrag() / endDrag()
/// 深色背景 + 自行车图标可向右拖动 + 滑动到85%触发出发流程
class SliderDepart extends StatefulWidget {
  final VoidCallback? onTrigger;
  const SliderDepart({Key? key, this.onTrigger}) : super(key: key);

  @override
  State<SliderDepart> createState() => SliderDepartState();
}

class SliderDepartState extends State<SliderDepart> {
  double _currentX = 0;
  double _maxX = 200; // 初始估算，LayoutBuilder 会更新
  bool _isDragging = false;
  bool _triggered = false;

  static const double _btnWidth = 64;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        _maxX = containerWidth - 16 - _btnWidth; // padding(8*2) - btnWidth

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.rCard24),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.darkNav,
              borderRadius: BorderRadius.circular(AppTheme.rCard24),
              boxShadow: AppTheme.cardShadowList,
            ),
            padding: const EdgeInsets.all(8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 进度条背景 — 活力橙，宽度随拖动增加
                AnimatedContainer(
                  duration: _isDragging
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  width: _btnWidth + _currentX,
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                // 内容行
                Row(
                  children: [
                    // 自行车按钮（可拖动）
                    GestureDetector(
                      onHorizontalDragStart: _onDragStart,
                      onHorizontalDragUpdate: _onDragUpdate,
                      onHorizontalDragEnd: _onDragEnd,
                      child: Transform.translate(
                        offset: Offset(_currentX, 0),
                        child: _buildBikeButton(),
                      ),
                    ),
                    // 文字（随拖动透明度降低）
                    Expanded(
                      child: Center(
                        child: Opacity(
                          opacity: max(
                              0.0,
                              1.0 -
                                  (_currentX / max(_maxX, 1)).clamp(0.0, 1.0)),
                          child: const Text(
                            '准备好出发了吗？',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: AppTheme.wBold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBikeButton() => Container(
        width: _btnWidth,
        height: _btnWidth,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.directions_bike,
            color: Colors.white, size: 32),
      );

  void _onDragStart(DragStartDetails d) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      _currentX = (_currentX + d.delta.dx).clamp(0.0, _maxX);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    setState(() {
      _isDragging = false;
    });

    // 85% 阈值触发
    if (_currentX >= _maxX * 0.85 && !_triggered) {
      _triggered = true;
      _onTriggered();
    } else {
      _resetToStart();
    }
  }

  void _onTriggered() {
    // 按钮滑到最右 + 文字消失
    setState(() {
      _currentX = _maxX;
    });
    // 显示 toast 提示
    if (widget.onTrigger != null) {
      widget.onTrigger!();
    }
    // 2秒后重置
    Future.delayed(const Duration(seconds: 2), _resetToStart);
  }

  void _resetToStart() {
    if (!mounted) return;
    setState(() {
      _currentX = 0;
      _triggered = false;
    });
  }

  /// 外部调用：重置滑块（退出子页面时）
  void reset() => _resetToStart();
}
