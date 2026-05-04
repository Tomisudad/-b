import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../config/scenario_config.dart';
import '../models/route_model.dart';
import '../models/scenario.dart';
import 'route_library_page.dart';
import 'checklist_page.dart';
import 'departure_page.dart';

/// V4.0 首页 — 出发前决策与准备面板 + 热门路线发现
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  OutdoorScenario _scene = OutdoorScenario.cycle;
  bool _sceneDropdownOpen = false;
  final LayerLink _sceneLayer = LayerLink();
  OverlayEntry? _sceneOverlay;

  late AnimationController _btnAnimCtrl;

  // ===== Mock 天气 =====
  String _weatherIcon = '☀️';
  int _temperature = 24;
  int _windLevel = 2;

  // ===== Mock 热门路线 =====
  late List<_HotRoute> _hotRoutes;

  @override
  void initState() {
    super.initState();
    _btnAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _genHotRoutes();
  }

  @override
  void dispose() {
    _btnAnimCtrl.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _sceneOverlay?.remove();
    _sceneOverlay = null;
    _sceneDropdownOpen = false;
  }

  // ===== 场景切换 =====
  void _toggleScenePopup() {
    if (_sceneDropdownOpen) {
      _removeOverlay();
      return;
    }
    _showScenePopup();
  }

  void _showScenePopup() {
    _removeOverlay();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    const items = [
      ('🚴 骑行', OutdoorScenario.cycle, AppConfig.cyclePrimary),
      ('🏍️ 摩旅', OutdoorScenario.moto, AppConfig.motoPrimary),
      ('🚙 自驾', OutdoorScenario.drive, AppConfig.drivePrimary),
    ];

    _sceneOverlay = OverlayEntry(
      builder: (ctx) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _removeOverlay(),
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + renderBox.size.height + 4,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                shadowColor: Colors.black.withOpacity(0.08),
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: AppConfig.cardBg,
                    borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: items.map((item) {
                      final isSelected = _scene == item.$2;
                      return InkWell(
                        onTap: () {
                          setState(() => _scene = item.$2);
                          _genHotRoutes();
                          _removeOverlay();
                        },
                        child: Container(
                          height: AppConfig.sceneDropItemH,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: isSelected ? item.$3 : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.$1,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelected ? item.$3 : AppConfig.textPrimary,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check, size: 16, color: item.$3),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_sceneOverlay!);
    setState(() => _sceneDropdownOpen = true);
  }

  // ===== 热门路线数据 =====
  void _genHotRoutes() {
    final routes = <_HotRoute>[];
    switch (_scene) {
      case OutdoorScenario.cycle:
        routes.addAll([
          _HotRoute('洱海环湖骑行', 1243, 5832, 42.0, 320, '2h30min', 1),
          _HotRoute('独库公路骑行段', 987, 4102, 58.0, 1200, '4h', 3),
          _HotRoute('太湖东山半岛', 756, 3201, 28.0, 150, '1h30min', 1),
          _HotRoute('千岛湖绿道全程', 1532, 7200, 68.0, 580, '3h30min', 2),
          _HotRoute('青海湖环湖', 2100, 9800, 360.0, 2800, '3天', 4),
        ]);
        break;
      case OutdoorScenario.moto:
        routes.addAll([
          _HotRoute('皖南川藏线', 1867, 8500, 120.0, 2200, '4h', 3),
          _HotRoute('川西大环线', 3200, 15200, 680.0, 5200, '5天', 4),
          _HotRoute('太行天路', 1543, 7100, 95.0, 1800, '3h', 2),
          _HotRoute('G318川藏线', 5600, 28500, 2100.0, 12000, '12天', 5),
          _HotRoute('秦岭分水岭', 892, 3900, 55.0, 1500, '2h', 2),
        ]);
        break;
      case OutdoorScenario.drive:
        routes.addAll([
          _HotRoute('独库公路全程', 4500, 21000, 561.0, 3800, '2天', 3),
          _HotRoute('G219新藏线', 3800, 18000, 2100.0, 8800, '10天', 5),
          _HotRoute('川西小环线', 2800, 13500, 320.0, 2400, '2天', 2),
          _HotRoute('青海甘肃大环线', 5200, 25000, 1800.0, 6500, '8天', 4),
          _HotRoute('桂林阳朔山水', 1600, 7200, 85.0, 400, '3h', 1),
        ]);
        break;
    }
    _hotRoutes = routes;
  }

  Color get _primaryColor {
    switch (_scene) {
      case OutdoorScenario.cycle: return AppConfig.cyclePrimary;
      case OutdoorScenario.moto: return AppConfig.motoPrimary;
      case OutdoorScenario.drive: return AppConfig.drivePrimary;
    }
  }

  String get _sceneLabel {
    switch (_scene) {
      case OutdoorScenario.cycle: return '骑行';
      case OutdoorScenario.moto: return '摩旅';
      case OutdoorScenario.drive: return '自驾';
    }
  }

  String get _sceneEmoji {
    switch (_scene) {
      case OutdoorScenario.cycle: return '🚴';
      case OutdoorScenario.moto: return '🏍️';
      case OutdoorScenario.drive: return '🚙';
    }
  }

  // ============================================================
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Column(
      children: [
        // ===== 顶部栏：场景切换 + 天气 =====
        _buildTopBar(),
        // ===== 可滚动内容区 =====
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: AppConfig.bottomNavHeight + bottomPadding + 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                // ===== 品牌标识 =====
                _buildBrand(),
                const SizedBox(height: AppConfig.sectionGap),
                // ===== 功能入口 =====
                _buildFunctionArea(),
                const SizedBox(height: AppConfig.sectionGap),
                // ===== 热门路线 =====
                _buildHotRoutes(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== 顶部栏 ====================
  Widget _buildTopBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      decoration: const BoxDecoration(
        color: AppConfig.glassBg,
        border: Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          // 场景下拉
          CompositedTransformTarget(
            link: _sceneLayer,
            child: GestureDetector(
              onTap: _toggleScenePopup,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$_sceneEmoji $_sceneLabel', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _sceneDropdownOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppConfig.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // 天气快览
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _WeatherPage())),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_weatherIcon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  '${_temperature}°',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary),
                ),
                const SizedBox(width: 4),
                Text(
                  '$_windLevel级风',
                  style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 品牌标识 ====================
  Widget _buildBrand() {
    return Column(
      children: [
        Text(
          AppConfig.appName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppConfig.textPrimary, letterSpacing: 2),
        ),
        const SizedBox(height: 4),
        const Text('出行决策', style: TextStyle(fontSize: 14, color: AppConfig.textSecondary)),
      ],
    );
  }

  // ==================== 功能入口（三图标） ====================
  Widget _buildFunctionArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      child: Row(
        children: [
          _buildFuncIcon('路线规划', Icons.route_outlined, AppConfig.cyclePrimary, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteLibraryPage()));
          }),
          _buildFuncIcon('轨迹记录', Icons.timeline_outlined, AppConfig.drivePrimary, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DeparturePage()));
          }),
          _buildFuncIcon('装备清单', Icons.checklist_outlined, AppConfig.motoPrimary, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChecklistPage()));
          }),
        ],
      ),
    );
  }

  Widget _buildFuncIcon(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppConfig.cardIconSize, color: color),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
          ],
        ),
      ),
    );
  }

  // ==================== 热门路线 ====================
  Widget _buildHotRoutes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分隔符
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(width: 20, height: 1, color: AppConfig.textSecondary.withOpacity(0.3)),
                    const SizedBox(width: 8),
                    const Text('热门路线', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: 1, color: AppConfig.textSecondary.withOpacity(0.15))),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteLibraryPage())),
                child: Text(
                  '查看全部 >',
                  style: TextStyle(fontSize: 12, color: AppConfig.textSecondary.withOpacity(0.5)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 路线卡片列表
        ..._hotRoutes.asMap().entries.map((e) {
          final route = e.value;
          final isLast = e.key == _hotRoutes.length - 1;
          return _buildRouteCard(route, isLast: isLast);
        }),
      ],
    );
  }

  Widget _buildRouteCard(_HotRoute route, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppConfig.pageMargin, 0, AppConfig.pageMargin, isLast ? 0 : AppConfig.cardGap),
      child: Material(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          onTap: () {
            // 转为 RouteModel 并跳转详情
            final model = RouteModel(
              id: 'hot_${route.name.hashCode}',
              name: route.name,
              scenario: _scene,
              difficulty: route.difficulty,
              distanceKm: route.distanceKm,
              durationMinutes: route.durationMinutes,
              totalClimb: route.climb,
            );
            Navigator.push(context, MaterialPageRoute(builder: (_) => _RouteDetailStub(route: model)));
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 路线名称
                      Text(route.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
                      const SizedBox(height: 6),
                      // 点赞 + 走过人数
                      Row(
                        children: [
                          const Icon(Icons.thumb_up_outlined, size: 13, color: AppConfig.textSecondary),
                          const SizedBox(width: 3),
                          Text('${route.likes}', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                          const SizedBox(width: 12),
                          const Icon(Icons.directions_walk, size: 13, color: AppConfig.textSecondary),
                          const SizedBox(width: 3),
                          Text('${route.walkers}人走过', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // 距离·爬升·用时
                      Text(
                        '${route.distanceKm.toStringAsFixed(1)}km · ↑${route.climb}m · ${route.duration}',
                        style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 难度标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _difficultyLabel(route.difficulty),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 18, color: AppConfig.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _difficultyLabel(int d) {
    switch (d) {
      case 1: return '新手';
      case 2: return '入门';
      case 3: return '进阶';
      case 4: return '困难';
      case 5: return '资深';
      default: return '未知';
    }
  }
}

// ============================================================
// 热门路线数据类
// ============================================================
class _HotRoute {
  final String name;
  final int likes;
  final int walkers;
  final double distanceKm;
  final int climb;
  final String duration;
  final int difficulty;

  const _HotRoute(this.name, this.likes, this.walkers, this.distanceKm, this.climb, this.duration, this.difficulty);

  int get durationMinutes {
    if (duration.endsWith('天')) {
      final d = int.tryParse(duration.replaceAll('天', '')) ?? 1;
      return d * 24 * 60;
    }
    if (duration.endsWith('min')) {
      return int.tryParse(duration.replaceAll('min', '')) ?? 60;
    }
    // format: 'Xh' or 'XhYmin'
    final parts = duration.split('h');
    final h = int.tryParse(parts[0]) ?? 1;
    final m = parts.length > 1 ? (int.tryParse(parts[1].replaceAll('min', '')) ?? 0) : 0;
    return h * 60 + m;
  }
}

// ============================================================
// 天气详情页（Stub）
// ============================================================
class _WeatherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('天气详情')),
      body: ListView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        children: [
          _weatherCard('今天', '☀️', 24, 15, '晴', 2),
          const SizedBox(height: 12),
          _weatherCard('明天', '⛅', 22, 14, '多云', 3),
          const SizedBox(height: 12),
          _weatherCard('后天', '🌧️', 18, 12, '小雨', 4),
          const SizedBox(height: AppConfig.sectionGap),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConfig.sosRed.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppConfig.cardRadius),
              border: Border.all(color: AppConfig.sosRed.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppConfig.sosRed, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '后天有降雨预警，请注意出行安全，携带雨具。',
                    style: TextStyle(fontSize: 13, color: AppConfig.sosRed),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherCard(String day, String icon, int high, int low, String desc, int wind) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        boxShadow: AppConfig.cardShadow,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Column(
              children: [
                Text(icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 4),
                Text(day, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('$high°', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
                    const SizedBox(width: 8),
                    Text('$low°', style: const TextStyle(fontSize: 16, color: AppConfig.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('$desc  $wind级风', style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 路线详情 Stub（点击热门路线卡片跳转）
// ============================================================
class _RouteDetailStub extends StatelessWidget {
  final RouteModel route;
  const _RouteDetailStub({required this.route});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(route.name)),
      body: Padding(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(route.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            const SizedBox(height: 12),
            _infoRow('全程', '${route.distanceKm.toStringAsFixed(1)} km'),
            _infoRow('爬升', '${route.totalClimb} m'),
            _infoRow('难度', route.difficultyLabel),
            _infoRow('用时', route.formatDuration),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: AppConfig.primaryBtnH,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: goldGradient,
                  borderRadius: BorderRadius.all(Radius.circular(AppConfig.buttonRadius)),
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text('使用此路线出发', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textInverse)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 14, color: AppConfig.textSecondary))),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
        ],
      ),
    );
  }
}
