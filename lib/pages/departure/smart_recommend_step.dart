import 'package:flutter/material.dart';
import '../../config/app_config.dart';

// ===== 智能推荐类型 =====
enum _SmartTarget {
  shortest, scenic, challenge, eco;
  String get label => switch (this) {
    _SmartTarget.shortest => '最短路径',
    _SmartTarget.scenic => '最美风景',
    _SmartTarget.challenge => '挑战爬坡',
    _SmartTarget.eco => '省力优先',
  };
  String get emoji => switch (this) {
    _SmartTarget.shortest => '⚡',
    _SmartTarget.scenic => '🏞️',
    _SmartTarget.challenge => '🏔️',
    _SmartTarget.eco => '🍃',
  };
}

enum _SmartScenery {
  lake, mountain, teaField, temple, ancientTown, coastline, forest, city;
  String get label => switch (this) {
    _SmartScenery.lake => '湖景',
    _SmartScenery.mountain => '山景',
    _SmartScenery.teaField => '茶园',
    _SmartScenery.temple => '寺庙',
    _SmartScenery.ancientTown => '古镇',
    _SmartScenery.coastline => '海岸线',
    _SmartScenery.forest => '森林',
    _SmartScenery.city => '城市',
  };
  String get emoji => switch (this) {
    _SmartScenery.lake => '🌊',
    _SmartScenery.mountain => '⛰️',
    _SmartScenery.teaField => '🍵',
    _SmartScenery.temple => '🛕',
    _SmartScenery.ancientTown => '🏘️',
    _SmartScenery.coastline => '🏖️',
    _SmartScenery.forest => '🌲',
    _SmartScenery.city => '🏙️',
  };
  Color get color => switch (this) {
    _SmartScenery.lake => const Color(0xFF3B82F6),
    _SmartScenery.mountain => const Color(0xFF6B7280),
    _SmartScenery.teaField => const Color(0xFF059669),
    _SmartScenery.temple => const Color(0xFFD97706),
    _SmartScenery.ancientTown => const Color(0xFF92400E),
    _SmartScenery.coastline => const Color(0xFF0EA5E9),
    _SmartScenery.forest => const Color(0xFF166534),
    _SmartScenery.city => const Color(0xFF6366F1),
  };
}

enum _SmartSurface {
  paved, mixed, trail;
  String get label => switch (this) {
    _SmartSurface.paved => '铺装路面',
    _SmartSurface.mixed => '混合路面',
    _SmartSurface.trail => '越野',
  };
  IconData get icon => switch (this) {
    _SmartSurface.paved => Icons.route,
    _SmartSurface.mixed => Icons.terrain,
    _SmartSurface.trail => Icons.landscape,
  };
}

class _SmartResult {
  final String name;
  final String desc;
  final double distanceKm;
  final int climb;
  final int durationMin;
  final List<String> pois;
  const _SmartResult({required this.name, required this.desc, required this.distanceKm, required this.climb, required this.durationMin, required this.pois});
}

/// 智能推荐步骤 — 独立 StatefulWidget
class SmartRecommendStep extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String name, double distKm, int climb, int durMin) onUseRoute;

  const SmartRecommendStep({super.key, required this.onBack, required this.onUseRoute});

  @override
  State<SmartRecommendStep> createState() => _SmartRecommendStepState();
}

class _SmartRecommendStepState extends State<SmartRecommendStep> {
  _SmartTarget _smartTarget = _SmartTarget.scenic;
  final Set<_SmartScenery> _smartScenery = {};
  _SmartSurface _smartSurface = _SmartSurface.paved;
  bool _smartNeedWater = true;
  bool _smartNeedViewpoint = true;
  int _smartMaxHour = 4;
  _SmartResult? _smartResult;

  void _genSmartRoute() {
    String name, desc;
    double dist; int cl, dur; List<String> ps;
    switch (_smartTarget) {
      case _SmartTarget.shortest:
        name = '龙井-梅家坞捷径'; desc = '最短路径，18.5km，避开拥堵路段'; dist = 18.5; cl = 280; dur = 55; ps = ['龙井村', '梅家坞', '云栖竹径']; break;
      case _SmartTarget.scenic:
        name = '西湖秘境环线'; desc = '途经3处观景台、2处茶园，风景评分 ⭐4.8'; dist = 26.8; cl = 420; dur = 90; ps = ['杨公堤', '茅家埠', '龙井茶园', '九溪烟树']; break;
      case _SmartTarget.challenge:
        name = '龙井北坡挑战线'; desc = '连续爬坡 6km，坡度最高 15%，适合进阶骑手'; dist = 22.3; cl = 680; dur = 85; ps = ['龙井北坡', '中天竺', '灵隐']; break;
      case _SmartTarget.eco:
        name = '龙井休闲缓坡线'; desc = '缓坡为主，全程坡度 < 5%，适合休闲骑行'; dist = 19.2; cl = 180; dur = 65; ps = ['虎跑路', '满觉陇', '六和塔']; break;
    }
    setState(() {
      _smartResult = _SmartResult(name: name, desc: desc, distanceKm: dist, climb: cl, durationMin: dur, pois: ps);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasResult = _smartResult != null;
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        title: Text(hasResult ? '推荐路线' : '智能推荐'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (hasResult) {
              setState(() => _smartResult = null);
            } else {
              widget.onBack();
            }
          },
        ),
      ),
      body: hasResult ? _buildSmartResult() : _buildSmartPreferences(),
    );
  }

  Widget _buildSmartPreferences() {
    return ListView(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      children: [
        // 目标类型
        const Text('路线目标', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        const SizedBox(height: 4),
        const Text('选择你最看重的路线特性', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: _SmartTarget.values.map((t) {
          final sel = _smartTarget == t;
          return GestureDetector(
            onTap: () => setState(() => _smartTarget = t),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppConfig.goldStart.withOpacity(0.1) : AppConfig.cardBg,
                borderRadius: BorderRadius.circular(AppConfig.tagRadius),
                border: Border.all(color: sel ? AppConfig.goldStart : AppConfig.divider),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [Text(t.emoji, style: const TextStyle(fontSize: 16)), const SizedBox(width: 6), Text(t.label, style: TextStyle(fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? AppConfig.goldStart : AppConfig.textPrimary))]),
            ),
          );
        }).toList()),

        const SizedBox(height: 16),
        // 风景偏好
        const Text('风景偏好（可多选）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _SmartScenery.values.map((s) {
          final sel = _smartScenery.contains(s);
          return GestureDetector(
            onTap: () => setState(() => sel ? _smartScenery.remove(s) : _smartScenery.add(s)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: sel ? s.color.withOpacity(0.1) : AppConfig.cardBg,
                borderRadius: BorderRadius.circular(AppConfig.tagRadius),
                border: Border.all(color: sel ? s.color : AppConfig.divider),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [Text(s.emoji, style: const TextStyle(fontSize: 14)), const SizedBox(width: 5), Text(s.label, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? s.color : AppConfig.textPrimary))]),
            ),
          );
        }).toList()),

        const SizedBox(height: 16),
        // 路面偏好
        const Text('路面偏好', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        const SizedBox(height: 8),
        Row(children: _SmartSurface.values.map((s) {
          final sel = _smartSurface == s;
          return Expanded(child: Padding(padding: EdgeInsets.only(right: s == _SmartSurface.values.last ? 0 : 8), child: GestureDetector(
            onTap: () => setState(() => _smartSurface = s),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? AppConfig.goldStart.withOpacity(0.1) : AppConfig.cardBg,
                borderRadius: BorderRadius.circular(AppConfig.tagRadius),
                border: Border.all(color: sel ? AppConfig.goldStart : AppConfig.divider),
              ),
              child: Column(children: [Icon(s.icon, size: 20, color: sel ? AppConfig.goldStart : AppConfig.textSecondary), const SizedBox(height: 4), Text(s.label, style: TextStyle(fontSize: 11, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? AppConfig.goldStart : AppConfig.textPrimary))]),
            ),
          )));
        }).toList()),

        const SizedBox(height: 16),
        // 途经需求
        const Text('途经需求', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        const SizedBox(height: 8),
        Row(children: [
          _toggleChip('💧 补给站', _smartNeedWater, (v) => setState(() => _smartNeedWater = v)),
          const SizedBox(width: 8),
          _toggleChip('📷 观景点', _smartNeedViewpoint, (v) => setState(() => _smartNeedViewpoint = v)),
        ]),

        const SizedBox(height: 16),
        // 体能参数
        const Text('体能参数', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), border: Border.all(color: AppConfig.divider)),
          child: Column(children: [
            Row(children: [
              const Text('最长骑行时间', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
              const Spacer(),
              Text('$_smartMaxHour 小时', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
            ]),
            Slider(
              value: _smartMaxHour.toDouble(),
              min: 1, max: 10, divisions: 9,
              activeColor: AppConfig.goldStart,
              label: '$_smartMaxHour 小时',
              onChanged: (v) => setState(() => _smartMaxHour = v.round()),
            ),
          ]),
        ),

        const SizedBox(height: 20),
        // 生成按钮
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _genSmartRoute,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
              backgroundColor: AppConfig.goldStart,
            ),
            child: const Text('生成推荐路线', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 8),
        const Text('基于你的偏好自动生成最优路线，< 500ms', style: TextStyle(fontSize: 11, color: AppConfig.textSecondary), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _toggleChip(String label, bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: value ? AppConfig.goldStart.withOpacity(0.08) : AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.tagRadius),
          border: Border.all(color: value ? AppConfig.goldStart.withOpacity(0.3) : AppConfig.divider),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 16, height: 16, child: Checkbox(value: value, onChanged: (v) => onChanged(v ?? false), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, activeColor: AppConfig.goldStart, side: const BorderSide(color: AppConfig.divider))),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: value ? AppConfig.goldStart : AppConfig.textSecondary)),
        ]),
      ),
    );
  }

  Widget _buildSmartResult() {
    final r = _smartResult!;
    return ListView(padding: const EdgeInsets.all(AppConfig.pageMargin), children: [
      // Route summary card
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
          boxShadow: AppConfig.cardShadow,
          border: Border.all(color: AppConfig.goldStart.withOpacity(0.2)),
        ),
        child: Column(children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: AppConfig.goldStart.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.route, size: 32, color: AppConfig.goldStart)),
          const SizedBox(height: 12),
          Text(r.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
          const SizedBox(height: 4),
          Text(r.desc, style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _dataCol('距离', '${r.distanceKm.toStringAsFixed(1)} km', AppConfig.textPrimary),
            _dataCol('爬升', '${r.climb} m', AppConfig.accentOrange),
            _dataCol('用时', '${(r.durationMin ~/ 60)}h${r.durationMin % 60}min', AppConfig.cyclePrimary),
          ]),
          const SizedBox(height: 14),
          // POI tags
          Wrap(spacing: 6, runSpacing: 6, children: r.pois.map((p) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppConfig.goldStart.withOpacity(0.08), borderRadius: BorderRadius.circular(AppConfig.tagRadius)), child: Text(p, style: const TextStyle(fontSize: 12, color: AppConfig.goldStart)))).toList()),
        ]),
      ),

      const SizedBox(height: 16),
      Text('偏好设置: ${_smartTarget.label} · ${_smartScenery.map((s) => s.label).join('、')} · ${_smartSurface.label}', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),

      const SizedBox(height: 16),
      Row(children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() => _smartResult = null),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)), side: const BorderSide(color: AppConfig.divider), foregroundColor: AppConfig.textPrimary),
            child: const Text('重新调整', style: TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => widget.onUseRoute(r.name, r.distanceKm, r.climb, r.durationMin),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)), backgroundColor: AppConfig.goldStart, foregroundColor: Colors.white),
            child: const Text('使用此路线', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    ]);
  }

  Widget _dataCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}
