import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../config/scenario_config.dart';

/// V5.2 路线规划模块 — 纯数据管理，无出发入口
class RoutePlanPage extends StatefulWidget {
  const RoutePlanPage({super.key});

  static String _fmtDuration(int m) {
    if (m >= 1440) return '${(m / 1440).round()}天';
    if (m >= 60) return '${m ~/ 60}h${m % 60}min';
    return '${m}min';
  }

  @override
  State<RoutePlanPage> createState() => _RoutePlanPageState();
}

class _RoutePlanPageState extends State<RoutePlanPage> {
  String _search = '';
  OutdoorScenario? _filterScene;
  RouteDifficulty? _filterDifficulty;
  final List<_RouteEntry> _routes = _mockRoutes();

  static List<_RouteEntry> _mockRoutes() => [
    _RouteEntry('G318川藏线骑行', OutdoorScenario.cycle, RouteDifficulty.hard, 2100, 10800, 5200),
    _RouteEntry('川西小环线', OutdoorScenario.cycle, RouteDifficulty.medium, 320, 1440, 2400),
    _RouteEntry('青海甘肃大环线', OutdoorScenario.cycle, RouteDifficulty.hard, 1800, 7200, 6500),
    _RouteEntry('独库公路全程', OutdoorScenario.cycle, RouteDifficulty.hard, 561, 3600, 3800),
    _RouteEntry('桂林阳朔山水', OutdoorScenario.cycle, RouteDifficulty.easy, 85, 360, 400),
    _RouteEntry('皖南川藏线', OutdoorScenario.cycle, RouteDifficulty.medium, 120, 480, 2200),
    _RouteEntry('川西骑行大环线', OutdoorScenario.cycle, RouteDifficulty.hard, 680, 2880, 5200),
    _RouteEntry('太行天路', OutdoorScenario.cycle, RouteDifficulty.medium, 95, 360, 1800),
    _RouteEntry('秦岭分水岭', OutdoorScenario.cycle, RouteDifficulty.medium, 55, 180, 1500),
    _RouteEntry('洱海环湖骑行', OutdoorScenario.cycle, RouteDifficulty.easy, 42, 180, 320),
    _RouteEntry('独库公路骑行段', OutdoorScenario.cycle, RouteDifficulty.hard, 58, 360, 1200),
    _RouteEntry('千岛湖绿道全程', OutdoorScenario.cycle, RouteDifficulty.medium, 68, 360, 580),
    _RouteEntry('青海湖环湖', OutdoorScenario.cycle, RouteDifficulty.extreme, 360, 4320, 2800),
  ];

  List<_RouteEntry> get _filtered {
    return _routes.where((r) {
      if (_search.isNotEmpty && !r.name.contains(_search)) return false;
      if (_filterScene != null && r.scene != _filterScene) return false;
      if (_filterDifficulty != null && r.difficulty != _filterDifficulty) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        title: const Text('我的路线', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () => _showCreateOptions(context),
            child: const Text('+', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: AppConfig.textSecondary)),
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 0, AppConfig.pageMargin, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索路线...',
                prefixIcon: const Icon(Icons.search, size: 20, color: AppConfig.textSecondary),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          // 筛选标签
          Padding(
            padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 0, AppConfig.pageMargin, 12),
            child: Row(
              children: [
                _buildSceneFilter(),
                const SizedBox(width: 8),
                _buildDifficultyFilter(),
              ],
            ),
          ),
          // 路线列表
          Expanded(
            child: filtered.isEmpty
                ? _emptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppConfig.cardGap),
                    itemBuilder: (_, i) => _buildRouteCard(filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneFilter() {
    return GestureDetector(
      onTap: () => _showPicker('场景', OutdoorScenario.values, _filterScene, (v) => setState(() => _filterScene = v)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _filterScene != null ? _filterScene!.primaryColor.withOpacity(0.1) : AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.tagRadius),
          border: Border.all(color: _filterScene != null ? _filterScene!.primaryColor : AppConfig.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _filterScene?.label ?? '全部场景',
              style: TextStyle(fontSize: 12, color: _filterScene?.primaryColor ?? AppConfig.textSecondary),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: _filterScene?.primaryColor ?? AppConfig.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyFilter() {
    return GestureDetector(
      onTap: () => _showPicker('难度', RouteDifficulty.values, _filterDifficulty, (v) => setState(() => _filterDifficulty = v)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _filterDifficulty != null ? AppConfig.cyclePrimary.withOpacity(0.1) : AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.tagRadius),
          border: Border.all(color: _filterDifficulty != null ? AppConfig.cyclePrimary : AppConfig.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _filterDifficulty?.label ?? '全部难度',
              style: TextStyle(fontSize: 12, color: _filterDifficulty != null ? AppConfig.cyclePrimary : AppConfig.textSecondary),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: _filterDifficulty != null ? AppConfig.cyclePrimary : AppConfig.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showPicker<T>(String title, List<T> values, T? current, void Function(T?) onPick) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textSecondary)),
              const SizedBox(height: 8),
              ...values.map((v) {
                final label = v is OutdoorScenario ? v.label : (v as RouteDifficulty).label;
                final selected = v == current;
                return ListTile(
                  dense: true,
                  title: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: AppConfig.textPrimary)),
                  trailing: selected ? const Icon(Icons.check, size: 18, color: AppConfig.cyclePrimary) : null,
                  onTap: () { onPick(v); Navigator.pop(context); },
                );
              }),
              ListTile(
                dense: true,
                title: const Text('不限', style: TextStyle(color: AppConfig.textSecondary)),
                onTap: () { onPick(null); Navigator.pop(context); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteCard(_RouteEntry r) {
    final color = r.scene.primaryColor;
    return Dismissible(
      key: Key('route_${r.name}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppConfig.sosRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        ),
        child: const Icon(Icons.delete_outline, color: AppConfig.sosRed),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('删除路线'),
            content: Text('确定删除"${r.name}"吗？'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: AppConfig.sosRed))),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => setState(() => _routes.remove(r)),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _RouteDetailPage(route: r))),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppConfig.cardBg,
            borderRadius: BorderRadius.circular(AppConfig.cardRadius),
            boxShadow: AppConfig.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text(r.scene.emoji, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                    const SizedBox(height: 4),
                    Text(
                      '${r.distanceKm.toStringAsFixed(0)}km · ${r.difficulty.label} · ${RoutePlanPage._fmtDuration(r.durationMinutes)}',
                      style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.edit_outlined, size: 18), color: AppConfig.textSecondary, onPressed: () {}),
              IconButton(icon: const Icon(Icons.share_outlined, size: 18), color: AppConfig.textSecondary, onPressed: () {}),
              const Icon(Icons.chevron_right, size: 18, color: AppConfig.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppConfig.cyclePrimary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.route_outlined, size: 36, color: AppConfig.cyclePrimary),
        ),
        const SizedBox(height: 16),
        const Text('还没有路线', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
        const SizedBox(height: 6),
        const Text('点击右上角 + 开始规划', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
      ],
    ),
  );

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.pageMargin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('创建路线', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
                const SizedBox(height: 16),
                _createOption('🗺️', '地图打点', '在图上标记关键节点', () { Navigator.pop(context); }),
                const SizedBox(height: 8),
                _createOption('📂', '导入GPX', '从文件导入GPX轨迹', () { Navigator.pop(context); }),
                const SizedBox(height: 8),
                _createOption('📋', '从历史轨迹创建', '基于已有轨迹生成路线', () { Navigator.pop(context); }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createOption(String emoji, String title, String desc, VoidCallback onTap) {
    return Material(
      color: AppConfig.bgMain,
      borderRadius: BorderRadius.circular(AppConfig.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                    Text(desc, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppConfig.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteEntry {
  final String name;
  final OutdoorScenario scene;
  final RouteDifficulty difficulty;
  final int distanceKm;
  final int durationMinutes;
  final int climb;

  const _RouteEntry(this.name, this.scene, this.difficulty, this.distanceKm, this.durationMinutes, this.climb);
}

/// 路线详情（纯管理，无出发按钮）
class _RouteDetailPage extends StatelessWidget {
  final _RouteEntry route;
  const _RouteDetailPage({required this.route});

  @override
  Widget build(BuildContext context) {
    final color = route.scene.primaryColor;
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(title: Text(route.name)),
      body: ListView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        children: [
          // 地图占位
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppConfig.cardRadius),
              border: Border.all(color: color.withOpacity(0.15)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, size: 40, color: color.withOpacity(0.4)),
                  const SizedBox(height: 8),
                  Text('路线地图预览', style: TextStyle(fontSize: 13, color: color.withOpacity(0.5))),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConfig.cardGap),
          // 数据卡片
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
            child: Column(
              children: [
                _dataRow('场景', route.scene.label, color),
                _dataRow('难度', route.difficulty.label, color),
                _dataRow('距离', '${route.distanceKm} km', color),
                _dataRow('爬升', '${route.climb} m', color),
                _dataRow('预计用时', RoutePlanPage._fmtDuration(route.durationMinutes), color),
              ],
            ),
          ),
          const SizedBox(height: AppConfig.cardGap),
          // 分段列表（mock）
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('分段', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                const SizedBox(height: 8),
                ...['起点 → 第一补给站 (18km)', '补给站 → 垭口 (22km)', '垭口 → 观景台 (15km)', '观景台 → 终点 (25km)'].map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Text(s, style: const TextStyle(fontSize: 13, color: AppConfig.textPrimary)),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: AppConfig.sectionGap),
          // 操作按钮（无出发）
          Row(
            children: [
              Expanded(child: _actionBtn(context, Icons.edit_outlined, '编辑', () {})),
              const SizedBox(width: 8),
              Expanded(child: _actionBtn(context, Icons.cloud_download_outlined, '离线下载', () {})),
              const SizedBox(width: 8),
              Expanded(child: _actionBtn(context, Icons.share_outlined, '分享', () {})),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dataRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 64, child: Text(label, style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color))),
        ],
      ),
    );
  }

  Widget _actionBtn(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
