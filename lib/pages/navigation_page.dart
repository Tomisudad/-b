import 'package:flutter/material.dart';
import '../config/scenario_config.dart';
import '../theme/app_theme.dart';
import '../services/tracking_service.dart';

class NavigationPage extends StatefulWidget {
  final OutdoorScenario scenario;
  const NavigationPage({super.key, required this.scenario});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  late final TrackingService _tracking;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _tracking = TrackingService.instance;
  }

  void _startNavigation() {
    if (!_started) {
      _tracking.startTracking(widget.scenario);
      setState(() => _started = true);
    }
  }

  void _endNavigation() {
    _tracking.stopTracking();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = ScenarioConfig.of(widget.scenario);
    final sceneColor = cfg.primaryColor;

    if (!_started) {
      return Scaffold(
        backgroundColor: sceneColor.withOpacity(0.05),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.navigation, size: 64, color: sceneColor),
                const SizedBox(height: 16),
                Text(cfg.label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: sceneColor)),
                const SizedBox(height: 8),
                const Text('准备开始导航', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _startNavigation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sceneColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('开始导航', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ===== 驾驶态 =====
    return ListenableBuilder(
      listenable: _tracking,
      builder: (context, _) {
        final dist = _tracking.currentDistance;
        final speed = _tracking.avgSpeed;
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                // 地图区域
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFFEBF0E6),
                    child: Center(
                      child: Icon(Icons.map_outlined, size: 80, color: const Color(0xFF2E7D32).withOpacity(0.15)),
                    ),
                  ),
                ),

                // 顶部信息
                Positioned(
                  top: 16, left: 16, right: 16,
                  child: Column(
                    children: [
                      // 速度
                      Text(
                        '${speed.toInt()}',
                        style: const TextStyle(
                          fontSize: 72, fontWeight: FontWeight.w300,
                          fontFamily: 'SF Pro Display',
                          color: AppTheme.textPrimary,
                          height: 0.9,
                        ),
                      ),
                      const Text('km/h', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                      const SizedBox(height: 16),

                      // 转向指令
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: sceneColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_forward, size: 24, color: sceneColor),
                            const SizedBox(width: 8),
                            Text('继续前行 2.3km',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: sceneColor)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 剩余距离
                      Text(
                        '剩余 ${dist.toStringAsFixed(1)}km',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                ),

                // 底部按钮
                Positioned(
                  bottom: 32, left: 16, right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // SOS
                      _driveButton(
                        icon: Icons.warning_rounded,
                        label: 'SOS',
                        color: AppTheme.warning,
                        onTap: () {},
                      ),
                      // 结束
                      _driveButton(
                        icon: Icons.stop,
                        label: '结束',
                        color: sceneColor,
                        onTap: _endNavigation,
                        primary: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _driveButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? color : Colors.white,
          foregroundColor: primary ? Colors.white : color,
          elevation: primary ? 0 : 0,
          side: primary ? BorderSide.none : BorderSide(color: color, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
