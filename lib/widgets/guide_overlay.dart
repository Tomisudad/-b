import 'package:flutter/material.dart';

/// 新手引导遮罩 — 严格对照 HTML guideSteps
/// 4 步引导，首次打开显示，跳过或完成后不再显示
class GuideOverlay extends StatefulWidget {
  final VoidCallback onFinish;
  const GuideOverlay({Key? key, required this.onFinish}) : super(key: key);

  @override
  State<GuideOverlay> createState() => _GuideOverlayState();
}

class _GuideOverlayState extends State<GuideOverlay> {
  static const List<_GuideStep> _steps = [
    _GuideStep(
      icon: '\uD83C\uDFB4',
      title: '欢迎来到去野',
      desc: '专为骑行者打造的出行决策与记录工具。',
    ),
    _GuideStep(
      icon: '\uD83D\uDDF\uDF\uFE0F',
      title: '规划路线',
      desc: '在"我的路线"中创建或选择路线，查看途经点和分段详情。',
    ),
    _GuideStep(
      icon: '\uD83D\uDEE0\uFE0F',
      title: '检查装备',
      desc: '出发前确认装备状态，缺失项会在出发时提醒你。',
    ),
    _GuideStep(
      icon: '▶\uFE0F',
      title: '随时出发',
      desc: '滑动按钮，即刻开始骑行。',
    ),
  ];

  int _current = 0;

  void _next() {
    if (_current < _steps.length - 1) {
      setState(() => _current++);
    } else {
      widget.onFinish();
    }
  }

  void _skip() => widget.onFinish();

  @override
  Widget build(BuildContext context) {
    final step = _steps[_current];
    return Container(
      color: const Color(0x80000000), // overlay-mask 效果
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标
              Text(step.icon, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              // 标题
              Text(
                step.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              // 描述
              Text(
                step.desc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6A6A6F),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // 圆点指示器
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (i) {
                  final isActive = i == _current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF5A6F45)
                          : const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              // 按钮行
              Row(
                children: [
                  // 跳过
                  Expanded(
                    child: GestureDetector(
                      onTap: _skip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '跳过',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A4A5E),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 下一步 / 开始使用
                  Expanded(
                    child: GestureDetector(
                      onTap: _next,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF57C00),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _current == _steps.length - 1 ? '开始使用' : '下一步',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
      ),
    );
  }
}

class _GuideStep {
  final String icon;
  final String title;
  final String desc;
  const _GuideStep({
    required this.icon,
    required this.title,
    required this.desc,
  });
}
