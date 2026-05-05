import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../config/scenario_config.dart';
import '../models/route_model.dart';
import '../models/scenario.dart';
import 'route_library_page.dart';
import 'checklist_page.dart';
import 'departure_page.dart';

/// V5.1 首页 — 出发前决策面板（无地图，带动态视觉效果）
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  OutdoorScenario _scene = OutdoorScenario.cycle;
  bool _sceneDropdownOpen = false;
  OverlayEntry? _sceneOverlay;

  // 卡片入场动画控制
  bool _cardsVisible = false;
  bool _card1Visible = false;
  bool _card2Visible = false;
  bool _card3Visible = false;

  // Mock 天气
  String _weatherIcon = '☀️';
  int _temperature = 24;
  int _windLevel = 2;

  // Mock 热门路线
  late List<_HotRoute> _hotRoutes;

  @override
  void initState() {
    super.initState();
    _genHotRoutes();
    _startCardAnimations();
  }

  void _startCardAnimations() {
    // 品牌区淡入
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _cardsVisible = true);
    });
    // 三张卡片依次滑入，间隔 100ms
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _card1Visible = true);
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _card2Visible = true);
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _card3Visible = true);
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _sceneOverlay?.remove();
    _sceneOverlay = null;
    _sceneDropdownOpen = false;
  }

  // ===== 场景切换下拉 =====
  void _toggleScenePopup() {
    if (_sceneDropdownOpen) { _removeOverlay(); return; }
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
        onTap: _removeOverlay,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + renderBox.size.height + 4,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                shadowColor: Colors.black.withOpacity(0.1),
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: AppConfig.cardBg,
                    borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: items.map((it) {
                      final sel = _scene == it.$2;
                      return InkWell(
                        onTap: () {
                          _onSceneChanged(it.$2);
                        },
                        child: Container(
                          height: AppConfig.sceneDropItemH,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: sel ? it.$3 : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(it.$1, style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                                  color: sel ? it.$3 : AppConfig.textPrimary,
                                )),
                              ),
                              if (sel) Icon(Icons.check, size: 16, color: it.$3),
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

  void _onSceneChanged(OutdoorScenario newScene) {
    setState(() {
      _scene = newScene;
      _cardsVisible = false;
      _card1Visible = false;
      _card2Visible = false;
      _card3Visible = false;
    });
    _genHotRoutes();
    _removeOverlay();
    // 重新触发卡片动画（场景色过渡 0.3s）
    _startCardAnimations();
  }

  // ===== 热门路线 mock 生成 =====
  void _genHotRoutes() {
    final routes = <_HotRoute>[];
    switch (_scene) {
      case OutdoorScenario.cycle:
        routes.addAll([
          _HotRoute('洱海环湖骑行', 1243, 5832, 42.0, 320, 150, 1),
          _HotRoute('独库公路骑行段', 987, 4102, 58.0, 1200, 240, 3),
          _HotRoute('太湖东山半岛', 756, 3201, 28.0, 150, 90, 1),
          _HotRoute('千岛湖绿道全程', 1532, 7200, 68.0, 580, 210, 2),
          _HotRoute('青海湖环湖', 2100, 9800, 360.0, 2800, 180, 4),
        ]);
        break;
      case OutdoorScenario.moto:
        routes.addAll([
          _HotRoute('皖南川藏线', 1867, 8500, 120.0, 2200, 240, 3),
          _HotRoute('川西大环线', 3200, 15200, 680.0, 5200, 300, 4),
          _HotRoute('太行天路', 1543, 7100, 95.0, 1800, 180, 2),
          _HotRoute('G318川藏线', 5600, 28500, 2100.0, 12000, 720, 5),
          _HotRoute('秦岭分水岭', 892, 3900, 55.0, 1500, 120, 2),
        ]);
        break;
      case OutdoorScenario.drive:
        routes.addAll([
          _HotRoute('独库公路全程', 4500, 21000, 561.0, 3800, 120, 3),
          _HotRoute('G219新藏线', 3800, 18000, 2100.0, 8800, 600, 5),
          _HotRoute('川西小环线', 2800, 13500, 320.0, 2400, 120, 2),
          _HotRoute('青海甘肃大环线', 5200, 25000, 1800.0, 6500, 480, 4),
          _HotRoute('桂林阳朔山水', 1600, 7200, 85.0, 400, 180, 1),
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
        _buildTopBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: AppConfig.bottomNavHeight + bottomPadding + 24),
            child: Column(
              children: [
                // 4.2 品牌标识区
                _buildBrand(),
                const SizedBox(height: AppConfig.sectionGap),
                // 4.3 功能入口区（三卡片依次滑入）
                _buildFunctionArea(),
                const SizedBox(height: AppConfig.sectionGap),
                // 4.4 热门路线区
                _buildHotRoutes(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== 4.1 顶部操作栏 (48px, 毛玻璃) ====================
  Widget _buildTopBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppConfig.glassBlur, sigmaY: AppConfig.glassBlur),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppConfig.glassBg,
            border: const Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
            child: Row(
              children: [
                // 场景下拉
                GestureDetector(
                  onTap: _toggleScenePopup,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_sceneEmoji $_sceneLabel',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary),
                      ),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: _sceneDropdownOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppConfig.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // 全局搜索
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/search'),
                  child: const Icon(Icons.search, size: 20, color: AppConfig.textSecondary),
                ),
                const SizedBox(width: 16),
                // 天气快览 (可点击进入详情)
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
                        '${_windLevel}级风',
                        style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== 4.2 品牌标识区 ("去野" 金色渐变光泽, 无副标题) ====================
  Widget _buildBrand() {
    return AnimatedOpacity(
      opacity: _cardsVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [AppConfig.goldStart, AppConfig.goldEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: const Text(
            '去野',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppConfig.textPrimary,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== 4.3 功能入口区 (三卡片依次从下方淡入滑出, 间隔 100ms) ====================
  Widget _buildFunctionArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      child: Row(
        children: [
          _buildAnimatedFuncCard('路线规划', Icons.route_outlined, _card1Visible, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteLibraryPage()));
          }),
          const SizedBox(width: 8),
          _buildAnimatedFuncCard('轨迹记录', Icons.timeline_outlined, _card2Visible, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DeparturePage()));
          }),
          const SizedBox(width: 8),
          _buildAnimatedFuncCard('装备清单', Icons.checklist_outlined, _card3Visible, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChecklistPage()));
          }),
        ],
      ),
    );
  }

  Widget _buildAnimatedFuncCard(String label, IconData icon, bool visible, VoidCallback onTap) {
    return Expanded(
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.25),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          child: _buildFuncCard(label, icon, onTap),
        ),
      ),
    );
  }

  Widget _buildFuncCard(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTapDown: (_) => setState(() {}),
      onTapCancel: () => setState(() {}),
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, scale, _) {
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: AppConfig.cardBg,
                borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
                boxShadow: AppConfig.cardShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 图标 40px 位于 56px 浅色圆形背景
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: AppConfig.funcCircleSize,
                    height: AppConfig.funcCircleSize,
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: AppConfig.funcIconSize, color: _primaryColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppConfig.textPrimary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== 4.4 热门路线区 ====================
  Widget _buildHotRoutes() {
    return AnimatedOpacity(
      opacity: _card3Visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行 "── 热门路线 ──"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(width: 24, height: 1, color: AppConfig.textSecondary.withOpacity(0.25)),
                      const SizedBox(width: 10),
                      const Text('热门路线', style: TextStyle(fontSize: 14, color: AppConfig.textSecondary)),
                      const SizedBox(width: 10),
                      Expanded(child: Container(height: 1, color: AppConfig.textSecondary.withOpacity(0.15))),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteLibraryPage())),
                  child: const Text(
                    '查看全部 >',
                    style: TextStyle(fontSize: 12, color: AppConfig.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConfig.cardGap),
          // 路线卡片 (带入场动画: 底部上浮 30px)
          ...List.generate(_hotRoutes.length, (i) {
            return _buildRouteCard(_hotRoutes[i], index: i, total: _hotRoutes.length);
          }),
        ],
      ),
    );
  }

  Widget _buildRouteCard(_HotRoute route, {int index = 0, int total = 1}) {
    return FutureAnimatedEntry(
      delayMs: 300 + index * 80,
      offsetY: 30.0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppConfig.pageMargin, 0, AppConfig.pageMargin,
          index == total - 1 ? 0 : AppConfig.cardGap,
        ),
        child: Material(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppConfig.cardRadius),
            onTap: () {
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
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                boxShadow: AppConfig.cardShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary),
                        ),
                        const SizedBox(height: 6),
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
                        Text(
                          '${route.distanceKm.toStringAsFixed(1)}km · ↑${route.climb}m · ${_durStr(route.durationMinutes)}',
                          style: const TextStyle(fontSize: 14, color: AppConfig.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConfig.tagRadius),
                    ),
                    child: Text(
                      _difficultyLabel(route.difficulty),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _primaryColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star_outline_rounded, size: 18, color: AppConfig.textSecondary),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right, size: 18, color: AppConfig.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _durStr(int minutes) {
    if (minutes >= 24 * 60) return '${(minutes / (24 * 60)).round()}天';
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h${m}min' : '${h}h';
    }
    return '${minutes}min';
  }

  String _difficultyLabel(int d) {
    const map = {1: '新手', 2: '入门', 3: '进阶', 4: '困难', 5: '资深'};
    return map[d] ?? '未知';
  }
}

// ============================================================
// 通用入场动画 Widget（底部上浮淡入）
// ============================================================
class FutureAnimatedEntry extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final double offsetY;

  const FutureAnimatedEntry({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.offsetY = 30.0,
  });

  @override
  State<FutureAnimatedEntry> createState() => _FutureAnimatedEntryState();
}

class _FutureAnimatedEntryState extends State<FutureAnimatedEntry> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : Offset(0, widget.offsetY / 100),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ============================================================
// 热门路线数据
// ============================================================
class _HotRoute {
  final String name;
  final int likes;
  final int walkers;
  final double distanceKm;
  final int climb;
  final int durationMinutes;
  final int difficulty;

  const _HotRoute(this.name, this.likes, this.walkers, this.distanceKm, this.climb, this.durationMinutes, this.difficulty);
}

// ============================================================
// 天气详情页
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
          const SizedBox(height: AppConfig.cardGap),
          _weatherCard('明天', '⛅', 22, 14, '多云', 3),
          const SizedBox(height: AppConfig.cardGap),
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
                Text('$desc  ${wind}级风', style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 路线详情 Stub
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
