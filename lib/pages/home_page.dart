import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../widgets/top_bar.dart';
import 'route_plan_page.dart';
import 'track_list_page.dart';
import 'checklist_page.dart';
import 'my_todo_page.dart';
import 'weather_page.dart';
import 'nearby_poi_page.dart';
import 'cycling_stats_page.dart';
import 'my_achievements_page.dart';
import 'trip_plan_page.dart';
import 'partner_activity_page.dart';
import 'favorite_routes_page.dart';
import 'cycling_video_page.dart';
import 'cycling_accounting_page.dart';
import 'maintenance_reminder_page.dart';
import 'golden_hour_page.dart';
import 'cycling_advice_page.dart';
import 'hot_routes_page.dart';

// ===== V7.5 optional module pool =====
enum HomeModule {
  myTodo('📋', '我的待办', true),
  weatherAlert('🌤️', '天气预警', false),
  nearbyPoi('📍', '附近点位', false),
  cyclingStats('📊', '骑行统计', false),
  myAchievements('🏅', '我的成就', false),
  tripPlan('📅', '出行计划', false),
  partnerActivity('👥', '搭子动态', false),
  hotRoutes('🔥', '热门路线', false),
  favoriteRoutes('📂', '常用路线', false),
  cyclingVideo('🎬', '骑行短片', false),
  cyclingAccounting('💰', '骑行记账', false),
  maintenanceReminder('🔧', '保养提醒', false),
  goldenHour('🌅', '黄金时刻', false),
  cyclingAdvice('💡', '骑行建议', false);

  final String emoji;
  final String label;
  final bool pinned;
  const HomeModule(this.emoji, this.label, this.pinned);

  Color get bgColor => switch (this) {
    HomeModule.myTodo => AppConfig.primary,
    HomeModule.weatherAlert => const Color(0xFFB0C4DE),
    HomeModule.nearbyPoi => AppConfig.sosRed,
    HomeModule.cyclingStats => AppConfig.primary,
    HomeModule.myAchievements => const Color(0xFFF1C40F),
    HomeModule.tripPlan => AppConfig.sosRed,
    HomeModule.partnerActivity => AppConfig.primary,
    HomeModule.hotRoutes => AppConfig.sosRed,
    HomeModule.favoriteRoutes => const Color(0xFFF39C12),
    HomeModule.cyclingVideo => const Color(0xFF9B59B6),
    HomeModule.cyclingAccounting => AppConfig.warmGold,
    HomeModule.maintenanceReminder => AppConfig.warningOrange,
    HomeModule.goldenHour => AppConfig.warningOrange,
    HomeModule.cyclingAdvice => AppConfig.drivePrimary,
  };
}

const _prefKeyModules = 'v75_enabled_modules';

const List<HomeModule> _defaultModules = [
  HomeModule.myTodo,
  HomeModule.weatherAlert,
  HomeModule.nearbyPoi,
  HomeModule.cyclingStats,
  HomeModule.myAchievements,
  HomeModule.tripPlan,
  HomeModule.partnerActivity,
  HomeModule.hotRoutes,
  HomeModule.favoriteRoutes,
  HomeModule.cyclingVideo,
  HomeModule.cyclingAccounting,
  HomeModule.maintenanceReminder,
  HomeModule.goldenHour,
  HomeModule.cyclingAdvice,
];

// ===== Hot route data =====
class _HotRoute {
  final String name;
  final int likes;
  final int walkers;
  final double stars;
  final double distanceKm;
  final int climb;
  final int durationMinutes;
  final String difficulty;
  const _HotRoute({
    required this.name,
    required this.likes,
    required this.walkers,
    required this.stars,
    required this.distanceKm,
    required this.climb,
    required this.durationMinutes,
    required this.difficulty,
  });
}

const _hotRoutes = [
  _HotRoute(name: '西湖环湖经典', likes: 2341, walkers: 146, stars: 4.8, distanceKm: 12.5, climb: 80, durationMinutes: 50, difficulty: '新手'),
  _HotRoute(name: '千岛湖绿道', likes: 1890, walkers: 118, stars: 4.9, distanceKm: 35.0, climb: 350, durationMinutes: 150, difficulty: '进阶'),
  _HotRoute(name: '龙井北坡', likes: 1560, walkers: 92, stars: 4.6, distanceKm: 2.5, climb: 220, durationMinutes: 25, difficulty: '资深'),
  _HotRoute(name: '赣北G318段', likes: 3200, walkers: 188, stars: 4.7, distanceKm: 180.0, climb: 3200, durationMinutes: 720, difficulty: '挑战'),
];

Color _diffColor(String d) {
  switch (d) {
    case '新手': return AppConfig.primary;
    case '进阶': return AppConfig.warmGold;
    case '资深': return AppConfig.warningOrange;
    case '挑战': return AppConfig.sosRed;
    default: return AppConfig.textSecondary;
  }
}

String _fmtCount(int n) {
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return n.toString();
}

// ===== Fixed entry cards =====
class _FixedEntry {
  final String emoji;
  final String label;
  final Widget Function(BuildContext) builder;
  const _FixedEntry(this.emoji, this.label, this.builder);
}

final _fixedEntries = [
  _FixedEntry('🗺️', '路线规划', (_) => const RoutePlanPage()),
  _FixedEntry('📝', '骑行记录', (_) => const TrackListPage()),
  _FixedEntry('🛠️', '骑行装备', (_) => const ChecklistPage()),
];

// ===== Module → page route =====
Widget? _modulePage(HomeModule m) {
  switch (m) {
    case HomeModule.myTodo: return const MyTodoPage();
    case HomeModule.weatherAlert: return const WeatherPage();
    case HomeModule.nearbyPoi: return const NearbyPoiPage();
    case HomeModule.cyclingStats: return const CyclingStatsPage();
    case HomeModule.myAchievements: return const MyAchievementsPage();
    case HomeModule.tripPlan: return const TripPlanPage();
    case HomeModule.partnerActivity: return const PartnerActivityPage();
    case HomeModule.hotRoutes: return const HotRoutesPage();
    case HomeModule.favoriteRoutes: return const FavoriteRoutesPage();
    case HomeModule.cyclingVideo: return const CyclingVideoPage();
    case HomeModule.cyclingAccounting: return const CyclingAccountingPage();
    case HomeModule.maintenanceReminder: return const MaintenanceReminderPage();
    case HomeModule.goldenHour: return const GoldenHourPage();
    case HomeModule.cyclingAdvice: return const CyclingAdvicePage();
    default: return null;
  }
}

// =====================================================================
// HomePage
// =====================================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<HomeModule> _modules = [..._defaultModules];
  bool _isEditing = false;
  bool _entry = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefKeyModules);
    if (raw != null && raw.isNotEmpty) {
      final parsed = <HomeModule>[];
      for (final r in raw) {
        final m = HomeModule.values.cast<HomeModule?>().firstWhere(
          (e) => e?.name == r,
          orElse: () => null,
        );
        if (m != null) parsed.add(m);
      }
      if (parsed.isNotEmpty) _modules = parsed;
    }
    setState(() => _entry = true);
  }

  Future<void> _saveModules(List<HomeModule> m) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKeyModules, m.map((e) => e.name).toList());
  }

  void _addModule(HomeModule mod) {
    if (_modules.contains(mod)) return;
    final afterPinned = _modules.where((x) => x.pinned).length;
    setState(() {
      _modules = [..._modules.sublist(0, afterPinned), mod, ..._modules.sublist(afterPinned)];
    });
    _saveModules(_modules);
  }

  void _removeModule(HomeModule mod) {
    if (mod.pinned) return;
    setState(() => _modules.remove(mod));
    _saveModules(_modules);
  }

  // ===== Build =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(AppConfig.topBarHeight),
        child: QuYeTopBar(),
      ),
      body: _entry
          ? RefreshIndicator(
              onRefresh: () async => _loadPrefs(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBrandArea(),
                    const SizedBox(height: 16),
                    _buildFixedEntries(),
                    const SizedBox(height: 24),
                    _buildModuleSection(),
                    const SizedBox(height: 24),
                    _buildHotRoutesSection(),
                    const SizedBox(height: 24),
                    _buildSafetyNotice(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator(color: AppConfig.primary)),
    );
  }

  // ===== Brand area =====
  Widget _buildBrandArea() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _ChainTexturePainter()),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppConfig.deepGreen, AppConfig.primary],
                  ).createShader(bounds),
                  child: const Text(
                    '去野',
                    style: TextStyle(fontSize: AppConfig.brandSize, fontWeight: AppConfig.w700, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(AppConfig.tagline, style: TextStyle(fontSize: AppConfig.captionSize, color: AppConfig.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== Fixed entries =====
  Widget _buildFixedEntries() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_fixedEntries.length, (i) {
          final e = _fixedEntries[i];
          final List<Color> gradColors = [
            [const Color(0x0D2ECC71), const Color(0x052ECC71)], // green
            [const Color(0x0D3498DB), const Color(0x053498DB)], // blue
            [const Color(0x0DE67E22), const Color(0x05E67E22)], // orange
          ][i];
          return Container(
            width: AppConfig.fixedCardW,
            height: AppConfig.fixedCardH,
            decoration: BoxDecoration(
              color: AppConfig.cardBg,
              borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
              boxShadow: AppConfig.cardShadow,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: e.builder)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: AppConfig.fixedEntrySize,
                      height: AppConfig.fixedEntrySize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: gradColors),
                      ),
                      child: Center(child: Text(e.emoji, style: const TextStyle(fontSize: AppConfig.fixedIconSize))),
                    ),
                    const SizedBox(height: 6),
                    Text(e.label, style: const TextStyle(fontSize: AppConfig.captionSize, color: AppConfig.textPrimary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ===== Module section =====
  Widget _buildModuleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('常用功能', style: TextStyle(fontSize: AppConfig.pageTitleSize, fontWeight: AppConfig.w700, color: AppConfig.textPrimary)),
              GestureDetector(
                onTap: () => setState(() => _isEditing = !_isEditing),
                child: Text(_isEditing ? '完成' : '编辑',
                  style: const TextStyle(fontSize: AppConfig.captionSize, color: AppConfig.primary, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
          child: _isEditing ? _buildEditList() : _buildModuleGrid(),
        ),
      ],
    );
  }

  Widget _buildModuleGrid() {
    if (_modules.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('暂无模块，点击"编辑"添加', style: TextStyle(color: AppConfig.textSecondary)),
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 12,
      children: _modules.map((m) => GestureDetector(
        onTap: () => _onModuleTap(m),
        onLongPress: () => setState(() => _isEditing = true),
        child: SizedBox(
          width: AppConfig.funcIconSize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppConfig.funcIconSize,
                height: AppConfig.funcIconSize,
                decoration: BoxDecoration(
                  color: m.bgColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppConfig.funcIconRadius),
                ),
                child: Center(child: Text(m.emoji, style: const TextStyle(fontSize: AppConfig.funcInnerIconSize))),
              ),
              const SizedBox(height: 4),
              Text(m.label, style: const TextStyle(fontSize: AppConfig.funcLabelSize, color: AppConfig.textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildEditList() {
    final available = HomeModule.values.where((m) => !_modules.contains(m)).toList();
    return Column(
      children: [
        ..._modules.asMap().entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppConfig.cardBg,
            borderRadius: BorderRadius.circular(AppConfig.cardRadius),
            border: Border.all(color: AppConfig.divider),
          ),
          child: Row(
            children: [
              if (!e.value.pinned)
                const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.drag_handle, color: AppConfig.textSecondary, size: 20)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Row(
                    children: [
                      Text(e.value.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Text(e.value.label, style: const TextStyle(fontSize: AppConfig.bodySize, color: AppConfig.textPrimary)),
                      if (e.value.pinned) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppConfig.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('固定', style: TextStyle(fontSize: 10, color: AppConfig.primary)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (!e.value.pinned)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: AppConfig.sosRed, size: 20),
                  onPressed: () => _removeModule(e.value),
                ),
            ],
          ),
        )),
        if (available.isNotEmpty) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showAddModuleSheet(available),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppConfig.cardBg,
                borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                border: Border.all(color: AppConfig.primary, width: 1),
              ),
              child: const Center(
                child: Text('+ 添加模块', style: TextStyle(fontSize: AppConfig.bodySize, color: AppConfig.primary, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showAddModuleSheet(List<HomeModule> available) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConfig.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('添加模块', style: TextStyle(fontSize: AppConfig.pageTitleSize, fontWeight: AppConfig.w700)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: available.map((m) => GestureDetector(
                onTap: () {
                  _addModule(m);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppConfig.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppConfig.tagRadius),
                  ),
                  child: Text('${m.emoji} ${m.label}',
                    style: const TextStyle(fontSize: AppConfig.bodySize, color: AppConfig.textPrimary)),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _onModuleTap(HomeModule m) {
    if (_isEditing) return;
    final page = _modulePage(m);
    if (page != null) Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // ===== Hot routes =====
  Widget _buildHotRoutesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
          child: Text('🔥 热门路线', style: TextStyle(fontSize: AppConfig.pageTitleSize, fontWeight: AppConfig.w700, color: AppConfig.textPrimary)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
            scrollDirection: Axis.horizontal,
            itemCount: _hotRoutes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _buildHotRouteCard(_hotRoutes[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildHotRouteCard(_HotRoute r) {
    return GestureDetector(
      onTap: () => _showRoutePreview(r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 240,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
          boxShadow: AppConfig.cardShadow,
          border: const Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppConfig.deepGreen, AppConfig.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              const Positioned(
                bottom: 0, left: 0, right: 0, height: 80,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black54],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _statChip('👍 ${_fmtCount(r.likes)}'),
                        const SizedBox(width: 4),
                        _statChip('👣 ${_fmtCount(r.walkers)}人走过'),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.name, style: const TextStyle(fontSize: 16, fontWeight: AppConfig.w700, color: Colors.white)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: _diffColor(r.difficulty).withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
                              child: Text(r.difficulty, style: TextStyle(fontSize: 11, color: _diffColor(r.difficulty), fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 8),
                            Text('${r.distanceKm.toStringAsFixed(1)}km · ${r.durationMinutes}min',
                              style: const TextStyle(fontSize: AppConfig.captionSize, color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(fontSize: 11, color: Colors.white)),
    );
  }

  void _showRoutePreview(_HotRoute r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppConfig.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
      ),
      builder: (_) => _RoutePreview(route: r),
    );
  }

  // ===== Safety notice =====
  Widget _buildSafetyNotice() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      child: Text(
        '户外骑行存在一定风险，请根据自身体能选择合适路线，量力而行。\n遵守交通规则，佩戴头盔，安全第一。',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: AppConfig.captionSize, color: AppConfig.textSecondary, height: 1.6),
      ),
    );
  }
}

// ===== Chain texture painter =====
class _ChainTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppConfig.primary.withOpacity(AppConfig.brandChainTexPct)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const linkW = 8.0, linkH = 14.0;
    const gap = 40.0;
    final rng = Random(42);
    for (double x = -linkW; x < size.width + linkW; x += gap) {
      for (double y = -linkH; y < size.height + linkH; y += gap) {
        final ox = x + (rng.nextDouble() - 0.5) * 10;
        final oy = y + (rng.nextDouble() - 0.5) * 10;
        canvas.drawOval(Rect.fromCenter(center: Offset(ox, oy), width: linkW, height: linkH), paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ===== Route preview =====
class _RoutePreview extends StatelessWidget {
  final _HotRoute route;
  const _RoutePreview({required this.route});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Text(route.name, style: const TextStyle(fontSize: 20, fontWeight: AppConfig.w700, color: AppConfig.textPrimary))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _diffColor(route.difficulty).withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
              child: Text(route.difficulty, style: TextStyle(fontSize: 12, color: _diffColor(route.difficulty), fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(AppConfig.cardRadius)),
            child: const Center(child: Icon(Icons.map_outlined, size: 48, color: AppConfig.textSecondary)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoCol('距离', '${route.distanceKm.toStringAsFixed(1)} km'),
              _infoCol('爬升', '${route.climb} m'),
              _infoCol('用时', '${route.durationMinutes} min'),
              _infoCol('评分', '★ ${route.stars.toStringAsFixed(1)}'),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.favorite_border, size: 16, color: AppConfig.textSecondary),
            const SizedBox(width: 4),
            Text(_fmtCount(route.likes), style: const TextStyle(color: AppConfig.textSecondary)),
            const SizedBox(width: 16),
            const Icon(Icons.directions_bike, size: 16, color: AppConfig.textSecondary),
            const SizedBox(width: 4),
            Text('${_fmtCount(route.walkers)} 人走过', style: const TextStyle(color: AppConfig.textSecondary)),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: AppConfig.primaryBtnH,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('开始导航', style: TextStyle(fontSize: AppConfig.bodySize, fontWeight: AppConfig.w700)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _infoCol(String label, String val) => Column(children: [
    Text(val, style: const TextStyle(fontSize: 16, fontWeight: AppConfig.w700, color: AppConfig.textPrimary)),
    Text(label, style: const TextStyle(fontSize: AppConfig.captionSize, color: AppConfig.textSecondary)),
  ]);
}