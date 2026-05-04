import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../config/scenario_config.dart';
import '../providers/scenario_provider.dart';
import '../providers/checklist_provider.dart';
import '../providers/trip_provider.dart';
import '../models/trip_model.dart';
import 'navigation_page.dart';
import 'route_library_page.dart';

// ============================================================
// 出发行程流程（4.1 主页面 → 4.2 确认页 → 导航）
// ============================================================

// ---- 步骤枚举 ----
enum _DepartStep { options, confirm }

// ---- 主页面 ----
class DeparturePage extends StatefulWidget {
  const DeparturePage({super.key});

  @override
  State<DeparturePage> createState() => _DeparturePageState();
}

class _DeparturePageState extends State<DeparturePage> {
  _DepartStep _step = _DepartStep.options;
  TripModel? _selectedTrip;

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _DepartStep.options:
        return _buildOptions();
      case _DepartStep.confirm:
        return _buildConfirm();
    }
  }

  // ==================== 4.1 出发选项 ====================
  Widget _buildOptions() {
    final scenario = context.watch<ScenarioProvider>().scenario;
    final cfg = ScenarioConfig.of(scenario);

    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        title: const Text('出发行程'),
        backgroundColor: AppConfig.glassBg,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: Column(
          children: [
            _optionCard(
              icon: Icons.map_outlined,
              title: '选择我的路线',
              subtitle: '从已创建的路线中选择一条',
              color: cfg.primaryColor,
              onTap: () async {
                final trip = await Navigator.push<TripModel>(
                  context,
                  MaterialPageRoute(builder: (_) => const RouteLibraryPage()),
                );
                if (trip != null && mounted) {
                  setState(() {
                    _selectedTrip = trip;
                    _step = _DepartStep.confirm;
                  });
                }
              },
            ),
            const SizedBox(height: AppConfig.cardGap),
            _optionCard(
              icon: Icons.edit_location_outlined,
              title: '新建路线规划',
              subtitle: '地图打点、导入GPX、从历史轨迹创建',
              color: AppConfig.motoPrimary,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('新建路线规划开发中')),
                );
              },
            ),
            const SizedBox(height: AppConfig.cardGap),
            _optionCard(
              icon: Icons.play_circle_outline,
              title: '自由记录开始',
              subtitle: '直接开始轨迹记录，无需预设路线',
              color: AppConfig.drivePrimary,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => NavigationPage(scenario: scenario),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                  )),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(
                    fontSize: 13, color: AppConfig.textSecondary,
                  )),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  // ==================== 4.2 行程确认页 ====================
  Widget _buildConfirm() {
    if (_selectedTrip == null) {
      return const Scaffold(body: Center(child: Text('未选择路线')));
    }

    final trip = _selectedTrip!;
    final scenario = context.watch<ScenarioProvider>().scenario;
    final cfg = ScenarioConfig.of(scenario);
    final chk = context.read<ChecklistProvider>();
    final unchecked = chk.totalItems - chk.checkedItems;

    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        title: const Text('行程确认'),
        backgroundColor: AppConfig.glassBg,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- 路线信息 ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConfig.cardBg,
                borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                boxShadow: AppConfig.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.name, style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary,
                  )),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _dataLabel('距离', '${trip.totalDistanceKm.toStringAsFixed(1)} km'),
                      const SizedBox(width: 24),
                      _dataLabel('预计', '${trip.accumulatedSeconds ~/ 3600}h${(trip.accumulatedSeconds % 3600) ~/ 60}min'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 地图缩略占位
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: cfg.primaryColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map_outlined, size: 36, color: cfg.primaryColor.withOpacity(0.4)),
                          const SizedBox(height: 4),
                          Text('路线预览', style: TextStyle(
                            fontSize: 13, color: cfg.primaryColor.withOpacity(0.4),
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConfig.cardGap),

            // ---- 天气快览 ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConfig.cardBg,
                borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                boxShadow: AppConfig.cardShadow,
              ),
              child: Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined, color: AppConfig.goldEnd),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('当前天气：晴 28°C 微风', style: TextStyle(
                      fontSize: 14, color: AppConfig.textPrimary,
                    )),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConfig.cardGap),

            // ---- 装备提醒 ----
            if (unchecked > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConfig.cardBg,
                  borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                  boxShadow: AppConfig.cardShadow,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 18, color: AppConfig.sosRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('尚有$unchecked项装备未检查，确认出发？', style: const TextStyle(
                        fontSize: 14, color: AppConfig.sosRed,
                      )),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppConfig.cardGap),

            // ---- 组队选项 ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConfig.cardBg,
                borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                boxShadow: AppConfig.cardShadow,
              ),
              child: Row(
                children: [
                  const Icon(Icons.group_add_outlined, color: AppConfig.motoPrimary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('组队选项：可跳过或创建/加入队伍', style: TextStyle(
                      fontSize: 14, color: AppConfig.textPrimary,
                    )),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('组队功能可在底部"组队"Tab 中使用')),
                      );
                    },
                    child: const Text('组队'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConfig.sectionGap),

            // ---- 开始导航大按钮 ----
            GestureDetector(
              onTap: () {
                final prov = context.read<TripProvider>();
                // 创建 + 开始行程
                prov.createTrip(trip.name, scenario);
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (_) => NavigationPage(scenario: scenario),
                ));
              },
              child: Container(
                width: double.infinity,
                height: AppConfig.primaryBtnH,
                decoration: BoxDecoration(
                  gradient: goldGradient,
                  borderRadius: BorderRadius.circular(AppConfig.buttonRadius),
                  boxShadow: [
                    BoxShadow(
                      color: AppConfig.goldStart.withOpacity(0.3),
                      blurRadius: 12, offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, size: 28, color: AppConfig.textInverse),
                    SizedBox(width: 6),
                    Text('开始导航', style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textInverse,
                    )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConfig.cardGap),

            // ---- 分享按钮 ----
            SizedBox(
              width: double.infinity,
              height: AppConfig.secondaryBtnH,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('分享功能开发中')),
                  );
                },
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('分享路线给好友'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppConfig.textSecondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
                  side: const BorderSide(color: AppConfig.divider),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _dataLabel(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
        )),
      ],
    );
  }
}
