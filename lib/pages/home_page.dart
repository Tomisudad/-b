import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../config/scenario_config.dart';
import '../models/route_model.dart';
import '../models/scenario.dart';
import 'route_library_page.dart';
import 'route_plan_page.dart';
import 'track_list_page.dart';
import 'checklist_page.dart';

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

  // ===== V6.1 热门路线 mock 生成 (6条, 含图片URL和收藏) =====
  void _genHotRoutes() {
    final routes = <_HotRoute>[];
    switch (_scene) {
      case OutdoorScenario.cycle:
        routes.addAll([
          _HotRoute('洱海环湖骑行', 1243, 5832, 340, 42.0, 320, 150, 1, 'https://picsum.photos/seed/qy_cycle1/400/120', daysAgo: 1),
          _HotRoute('独库公路骑行段', 987, 4102, 280, 58.0, 1200, 240, 3, 'https://picsum.photos/seed/qy_cycle2/400/120', daysAgo: 2),
          _HotRoute('千岛湖绿道全程', 1532, 7200, 460, 68.0, 580, 210, 2, 'https://picsum.photos/seed/qy_cycle3/400/120', daysAgo: 0),
          _HotRoute('青海湖环湖', 2100, 9800, 520, 360.0, 2800, 180, 4, 'https://picsum.photos/seed/qy_cycle4/400/120', daysAgo: 3),
          _HotRoute('太湖东山半岛', 756, 3201, 190, 28.0, 150, 90, 1, 'https://picsum.photos/seed/qy_cycle5/400/120', daysAgo: 1),
          _HotRoute('海南东线骑行', 1890, 8600, 410, 220.0, 1800, 420, 2, 'https://picsum.photos/seed/qy_cycle6/400/120', daysAgo: 5),
        ]);
        break;
      case OutdoorScenario.moto:
        routes.addAll([
          _HotRoute('G318川藏线', 5600, 28500, 1200, 2100.0, 12000, 720, 5, 'https://picsum.photos/seed/qy_moto1/400/120', daysAgo: 2),
          _HotRoute('川西大环线', 3200, 15200, 680, 680.0, 5200, 300, 4, 'https://picsum.photos/seed/qy_moto2/400/120', daysAgo: 1),
          _HotRoute('皖南川藏线', 1867, 8500, 420, 120.0, 2200, 240, 3, 'https://picsum.photos/seed/qy_moto3/400/120', daysAgo: 0),
          _HotRoute('太行天路', 1543, 7100, 350, 95.0, 1800, 180, 2, 'https://picsum.photos/seed/qy_moto4/400/120', daysAgo: 4),
          _HotRoute('秦岭分水岭', 892, 3900, 210, 55.0, 1500, 120, 2, 'https://picsum.photos/seed/qy_moto5/400/120', daysAgo: 1),
          _HotRoute('独库公路摩旅段', 2300, 11000, 560, 280.0, 4500, 360, 4, 'https://picsum.photos/seed/qy_moto6/400/120', daysAgo: 7),
        ]);
        break;
      case OutdoorScenario.drive:
        routes.addAll([
          _HotRoute('独库公路全程', 4500, 21000, 980, 561.0, 3800, 120, 3, 'https://picsum.photos/seed/qy_drive1/400/120', daysAgo: 1),
          _HotRoute('青海甘肃大环线', 5200, 25000, 1100, 1800.0, 6500, 480, 4, 'https://picsum.photos/seed/qy_drive2/400/120', daysAgo: 3),
          _HotRoute('G219新藏线', 3800, 18000, 760, 2100.0, 8800, 600, 5, 'https://picsum.photos/seed/qy_drive3/400/120', daysAgo: 5),
          _HotRoute('川西小环线', 2800, 13500, 590, 320.0, 2400, 120, 2, 'https://picsum.photos/seed/qy_drive4/400/120', daysAgo: 0),
          _HotRoute('桂林阳朔山水', 1600, 7200, 380, 85.0, 400, 180, 1, 'https://picsum.photos/seed/qy_drive5/400/120', daysAgo: 2),
          _HotRoute('呼伦贝尔大草原', 3200, 14000, 640, 450.0, 1200, 300, 2, 'https://picsum.photos/seed/qy_drive6/400/120', daysAgo: 6),
        ]);
        break;
    }
    // V6.1: 按评分排序: likes×1 + walkers×2 + stars×0.5, 7天加权
    routes.sort((a, b) => b.score.compareTo(a.score));
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

  // ==================== 4.2 品牌标识区 (V6.1: 等高线纹理 + 字间距8) ====================
  Widget _buildBrand() {
    return AnimatedOpacity(
      opacity: _cardsVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: SizedBox(
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // V6.1: 等高线纹理背景 (3% opacity, 120px直径)
              CustomPaint(
                size: const Size(120, 120),
                painter: _ContourPainter(_primaryColor),
              ),
              // "去野" 金色渐变, 字间距 8
              ShaderMask(
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
                    letterSpacing: 8,
                  ),
                ),
              ),
            ],
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
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RoutePlanPage()));
          }),
          const SizedBox(width: 8),
          _buildAnimatedFuncCard('轨迹记录', Icons.timeline_outlined, _card2Visible, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackListPage()));
          }),
          const SizedBox(width: 8),
          _buildAnimatedFuncCard('装备清单', Icons.checklist_outlined, _card3Visible, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ChecklistPage(initialScene: _scene)));
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
    final iconFilled = _filledIcon(icon);
    return GestureDetector(
      onTap: onTap,
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
            // V6.1: 双色图标 (线条+填充), 渐变圆形背景
            Container(
              width: AppConfig.funcCircleSize,
              height: AppConfig.funcCircleSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor.withOpacity(0.12), _primaryColor.withOpacity(0.06)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (iconFilled != null)
                    Icon(iconFilled, size: AppConfig.funcIconSize, color: _primaryColor.withOpacity(0.30)),
                  Icon(icon, size: AppConfig.funcIconSize, color: _primaryColor),
                ],
              ),
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
  }

  IconData? _filledIcon(IconData outlined) {
    if (outlined == Icons.route_outlined) return Icons.route;
    if (outlined == Icons.timeline_outlined) return Icons.timeline;
    if (outlined == Icons.checklist_outlined) return Icons.checklist;
    return null;
  }

  // ==================== 4.4 热门路线区 ====================
  // ==================== V6.1 热门路线区 (沉浸式图片卡片 120px) ====================
  Widget _buildHotRoutes() {
    return AnimatedOpacity(
      opacity: _card3Visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
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
                  child: const Text('查看全部 >', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConfig.cardGap),
          // V6.1: 横向滚动沉浸式图片卡片 120px 高
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
              itemCount: _hotRoutes.length,
              itemExtent: 200,
              itemBuilder: (context, i) {
                return Padding(
                  padding: EdgeInsets.only(right: i == _hotRoutes.length - 1 ? 0 : 12),
                  child: _buildRouteCard(_hotRoutes[i], index: i),
                );
              },
            ),
          ),
          // V6.5 Fix 9: 安全免责声明
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
            child: Text(
              '⚠️ 户外活动具有一定危险性，出行前请充分准备并评估风险',
              style: TextStyle(fontSize: 11, color: AppConfig.textSecondary.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  // V6.1: 沉浸式图片卡片 (200×120, 图片+渐变遮罩+信息叠加)
  Widget _buildRouteCard(_HotRoute route, {int index = 0}) {
    return AnimatedOpacity(
      opacity: _card3Visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300 + index * 80),
      child: AnimatedSlide(
        offset: _card3Visible ? Offset.zero : const Offset(0, 0.3),
        duration: Duration(milliseconds: 400 + index * 80),
        curve: Curves.easeOut,
        child: GestureDetector(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
            child: SizedBox(
              width: 200, height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 封面图
                  Image.network(
                    route.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: _primaryColor.withOpacity(0.15)),
                  ),
                  // 渐变遮罩: 上浅 → 下深 (V6.5 Fix 3: rgba(0,0,0,0.65)→0.3)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0x4D000000), const Color(0x66000000), const Color(0xA6000000)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // 难度标签 (右上)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _difficultyLabel(route.difficulty),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                  // 底部信息
                  Positioned(
                    bottom: 10, left: 10, right: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.thumb_up, size: 11, color: Colors.white70),
                                const SizedBox(width: 2),
                                Text(_fmtNum(route.likes), style: const TextStyle(fontSize: 11, color: Colors.white70)),
                                const SizedBox(width: 8),
                                const Icon(Icons.directions_walk, size: 11, color: Colors.white70),
                                const SizedBox(width: 2),
                                Text('${_fmtNum(route.walkers)}人走过', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                              ],
                            ),
                            Text(
                              '${route.distanceKm.toStringAsFixed(0)}km ↑${route.climb}m ${_durStr(route.durationMinutes)}',
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // V6.5 Fix 14: 卡片底部细线分隔
                  const Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Divider(height: 1, thickness: 0.5, color: Colors.white24),
                  ),
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

  /// V6.5 Fix 4: 千位分隔符格式化
  String _fmtNum(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
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
// V6.1 品牌等高线纹理绘制
// 在品牌"去野"文字背后绘制淡色圆形等高线纹理
// ============================================================
class _ContourPainter extends CustomPainter {
  final Color baseColor;

  _ContourPainter(this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // 同心圆 (等高线)
    final circlePaint = Paint()
      ..color = baseColor.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < 6; i++) {
      final r = maxRadius * (0.3 + i * 0.12);
      canvas.drawCircle(center, r, circlePaint);
    }

    // 波浪等高线纹理
    final wavePaint = Paint()
      ..color = baseColor.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int w = 0; w < 4; w++) {
      final path = Path();
      final baseY = size.height * 0.2 + w * 16;
      path.moveTo(0, baseY);
      for (double x = 0; x < size.width; x += 4) {
        final relX = x / size.width;
        final y = baseY + sin(relX * 6.28 * 1.5 + w * 1.2) * 6;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// 热门路线数据 (V6.1: 增加图片URL和收藏数)
// 排序: likes×1 + walkers×2 + stars×0.5, 7天加权
// ============================================================
class _HotRoute {
  final String name;
  final int likes;
  final int walkers;
  final int stars;        // V6.1 新增
  final double distanceKm;
  final int climb;
  final int durationMinutes;
  final int difficulty;
  final String imageUrl;  // V6.1 新增: picsum 种子URL
  final int daysAgo;       // 用于7天加权排序

  const _HotRoute(
    this.name, this.likes, this.walkers, this.stars,
    this.distanceKm, this.climb, this.durationMinutes,
    this.difficulty, this.imageUrl, {this.daysAgo = 0}
  );

  double get score => (likes * 1.0 + walkers * 2.0 + stars * 0.5) * (1.0 / (1 + daysAgo));
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
