import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import 'route_plan_page.dart';
import 'track_list_page.dart';
import 'checklist_page.dart';
import 'my_todo_page.dart';
import 'weather_page.dart';
import 'nearby_poi_page.dart';
import 'cycling_knowledge_page.dart';

// ===== 可选模块枚举 =====
enum HomeModule {
  myTodo('📋', '我的待办', true),            // pinned, not deletable
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
}

// ===== 持久化 Key =====
const _prefKeyEnabledModules = 'v73_enabled_modules';
const _prefKeyShowHotRoutes = 'v73_show_hot_routes';
const _prefKeyTodoExpanded = 'v73_todo_expanded';

/// 默认模块（首次使用）
const List<HomeModule> _defaultModules = [
  HomeModule.myTodo,         // pinned, always first
  HomeModule.weatherAlert,
  HomeModule.nearbyPoi,
  HomeModule.cyclingStats,
  HomeModule.hotRoutes,
  HomeModule.maintenanceReminder,
  HomeModule.goldenHour,
];

/// Slogan 文案池
const _slogans = [
  '去野，去骑行',
  '下坡注意控制车速，安全第一',
  '出发前检查胎压和刹车',
  '每一次踩踏，都是对生活的热爱',
  '你走过的路，都在脚下发光',
  '找到你的踏频，找到你的节奏',
];

/// V7.3 首页 — 骑行深度定制版
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // ===== 模块 =====
  List<HomeModule> _modules = List.from(_defaultModules);
  bool _editMode = false;
  bool _showHotRoutes = true;
  bool _todoExpanded = false;

  // ===== Slogan =====
  int _sloganIdx = 0;
  late AnimationController _sloganFadeCtrl;
  late Animation<double> _sloganFade;
  Timer? _sloganTimer;

  // ===== 入场动画 =====
  bool _entry = false;

  @override
  void initState() {
    super.initState();
    _sloganFadeCtrl = AnimationController(vsync: this, duration: Duration(milliseconds: AppConfig.sloganFadeMs));
    _sloganFade = Tween(begin: 0.0, end: 1.0).animate(_sloganFadeCtrl);

    _loadPrefs();
    _startSloganLoop();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _entry = true);
    });
  }

  @override
  void dispose() {
    _sloganTimer?.cancel();
    _sloganFadeCtrl.dispose();
    super.dispose();
  }

  // ===== 持久化 =====
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefKeyEnabledModules);
    if (raw != null && raw.isNotEmpty) {
      _modules = raw.map((s) {
        final idx = HomeModule.values.indexWhere((m) => m.name == s);
        return idx != -1 ? HomeModule.values[idx] : null;
      }).whereType<HomeModule>().toList();
      if (!_modules.contains(HomeModule.myTodo)) _modules.insert(0, HomeModule.myTodo);
    }
    _showHotRoutes = prefs.getBool(_prefKeyShowHotRoutes) ?? true;
    _todoExpanded = prefs.getBool(_prefKeyTodoExpanded) ?? false;
    if (mounted) setState(() => _entry = true);
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKeyEnabledModules, _modules.map((m) => m.name).toList());
    await prefs.setBool(_prefKeyShowHotRoutes, _showHotRoutes);
    await prefs.setBool(_prefKeyTodoExpanded, _todoExpanded);
  }

  // ===== Slogan 循环 =====
  void _startSloganLoop() {
    _sloganFadeCtrl.forward();
    _sloganTimer = Timer.periodic(Duration(milliseconds: AppConfig.sloganIntervalMs), (_) {
      _sloganFadeCtrl.reverse().then((_) {
        if (!mounted) return;
        setState(() => _sloganIdx = (_sloganIdx + 1) % _slogans.length);
        _sloganFadeCtrl.forward();
      });
    });
  }

  // ===== 编辑模式 =====
  void _toggleEditMode() {
    setState(() => _editMode = !_editMode);
    if (!_editMode) _savePrefs();
  }

  void _showModulePicker() {
    final available = HomeModule.values.where((m) => !_modules.contains(m) && !m.pinned).toList();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: AppConfig.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(AppConfig.pageMargin),
                child: Text('添加模块', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
              ),
              if (available.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
                  child: Text('所有模块已添加', style: TextStyle(color: AppConfig.textSecondary)),
                ),
              ...available.map((m) => ListTile(
                    leading: Text(m.emoji, style: const TextStyle(fontSize: 24)),
                    title: Text(m.label, style: const TextStyle(fontSize: 15, color: AppConfig.textPrimary)),
                    onTap: () {
                      setState(() => _modules.add(m));
                      _savePrefs();
                      Navigator.pop(context);
                    },
                  )),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Build =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 32),
              _buildBrandArea(),
              const SizedBox(height: 28),
              _buildFixedCards(),
              const SizedBox(height: AppConfig.sectionGap),
              _buildModuleSection(),
              if (_showHotRoutes || _editMode) ...[
                const SizedBox(height: AppConfig.sectionGap),
                _buildHotRoutesSection(),
              ],
              _buildSafetyDisclaimer(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 顶部栏 ====================
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          // Logo → Profile
          GestureDetector(
            onTap: () => _navigateToProfile(),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: greenGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: AppConfig.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: const Center(
                child: Text('🚴', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Slogan 流动
          Expanded(
            child: AnimatedBuilder(
              animation: _sloganFade,
              builder: (_, child) => Opacity(
                opacity: _sloganFade.value,
                child: Text(
                  _slogans[_sloganIdx],
                  style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary, height: 1.3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 天气胶囊
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherPage())),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppConfig.glassBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppConfig.divider.withOpacity(0.5)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('☀️', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    const Text('25°', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 品牌区 ====================
  Widget _buildBrandArea() {
    return Center(
      child: AnimatedOpacity(
        opacity: _entry ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 600),
        child: ShaderMask(
          shaderCallback: (bounds) => greenGradient.createShader(bounds),
          blendMode: BlendMode.srcATop,
          child: const Text(
            '去野',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 8),
          ),
        ),
      ),
    );
  }

  // ==================== 三个固定卡片 ====================
  Widget _buildFixedCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      child: Row(
        children: [
          _fixedCard('🗺️', '路线规划', AppConfig.primary.withOpacity(0.1), () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RoutePlanPage()));
          }),
          const SizedBox(width: 12),
          _fixedCard('📝', '骑行记录', AppConfig.primary.withOpacity(0.1), () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackListPage()));
          }),
          const SizedBox(width: 12),
          _fixedCard('🛠️', '骑行装备', AppConfig.primary.withOpacity(0.1), () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChecklistPage()));
          }),
        ],
      ),
    );
  }

  Widget _fixedCard(String emoji, String label, Color bgColor, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppConfig.cardBg,
            borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
            boxShadow: AppConfig.cardShadow,
          ),
          child: Column(
            children: [
              Container(
                width: AppConfig.moduleCircleSize,
                height: AppConfig.moduleCircleSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppConfig.primary.withOpacity(0.08), AppConfig.primary.withOpacity(0.2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 可选模块区 ====================
  Widget _buildModuleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
          child: Row(
            children: [
              const Text('常用功能', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
              const Spacer(),
              if (_modules.isNotEmpty)
                GestureDetector(
                  onTap: _toggleEditMode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _editMode ? AppConfig.primary.withOpacity(0.1) : AppConfig.bgMain,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _editMode ? '完成' : '编辑',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _editMode ? AppConfig.primary : AppConfig.textSecondary),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 模块网格
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _modules.asMap().entries.map((e) => _buildModuleTile(e.key, e.value)).toList(),
          ),
        ),
        // 编辑模式：添加按钮
        if (_editMode && _modules.length < HomeModule.values.length) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
            child: GestureDetector(
              onTap: _showModulePicker,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppConfig.cardBg,
                  borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                  border: Border.all(color: AppConfig.divider, style: BorderStyle.solid),
                ),
                child: const Center(
                  child: Text('＋ 添加模块', style: TextStyle(fontSize: 14, color: AppConfig.textSecondary)),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildModuleTile(int idx, HomeModule module) {
    final isTodo = module == HomeModule.myTodo;
    final tileWidth = (MediaQuery.of(context).size.width - AppConfig.pageMargin * 2 - 12 * 3) / 4;

    Widget tile = GestureDetector(
      onTap: _editMode ? null : () => _onModuleTap(module),
      onLongPress: () {
        if (!_editMode) setState(() => _editMode = true);
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey('${module.name}_${_editMode}'),
          width: tileWidth,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: AppConfig.cardBg,
            borderRadius: BorderRadius.circular(AppConfig.cardRadius),
            boxShadow: _editMode ? AppConfig.cardShadowPressed : AppConfig.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 模块图标
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: isTodo ? AppConfig.warmGold.withOpacity(0.1) : AppConfig.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(module.emoji, style: const TextStyle(fontSize: 22))),
                  ),
                  if (_editMode && !module.pinned)
                    Positioned(
                      top: -4, right: -4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _modules.removeAt(idx));
                          _savePrefs();
                        },
                        child: Container(
                          width: 18, height: 18,
                          decoration: const BoxDecoration(color: AppConfig.editDeleteBg, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                module.label,
                style: const TextStyle(fontSize: 11, color: AppConfig.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );

    // My Todo: 可折叠面板
    if (isTodo) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tile,
          if (_todoExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
              child: _buildTodoInline(),
            ),
        ],
      );
    }

    return tile;
  }

  void _onModuleTap(HomeModule module) {
    switch (module) {
      case HomeModule.myTodo:
        setState(() {
          _todoExpanded = !_todoExpanded;
          _savePrefs();
        });
      case HomeModule.weatherAlert:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherPage()));
      case HomeModule.nearbyPoi:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyPoiPage()));
      case HomeModule.cyclingStats:
        Navigator.push(context, MaterialPageRoute(builder: (_) => _CyclingStatsStub()));
      case HomeModule.myAchievements:
        Navigator.push(context, MaterialPageRoute(builder: (_) => _AchievementsStub()));
      case HomeModule.tripPlan:
        Navigator.push(context, MaterialPageRoute(builder: (_) => _TripPlanStub()));
      case HomeModule.partnerActivity:
        _switchToTab(1);
      case HomeModule.favoriteRoutes:
        Navigator.push(context, MaterialPageRoute(builder: (_) => _FavoriteRoutesStub()));
      case HomeModule.cyclingVideo:
        Navigator.push(context, MaterialPageRoute(builder: (_) => _CyclingVideoStub()));
      case HomeModule.cyclingAccounting:
        Navigator.push(context, MaterialPageRoute(builder: (_) => _CyclingAccountingStub()));
      case HomeModule.maintenanceReminder:
        Navigator.push(context, MaterialPageRoute(builder: (_) => _MaintenanceReminderStub()));
      case HomeModule.goldenHour:
        Navigator.push(context, MaterialPageRoute(builder: (_) => _GoldenHourStub()));
      case HomeModule.cyclingAdvice:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CyclingKnowledgePage()));
      case HomeModule.hotRoutes:
        setState(() {
          _showHotRoutes = !_showHotRoutes;
          _savePrefs();
        });
    }
  }

  void _switchToTab(int index) {
    // Navigate to tab via MainShell's state (simplified: just navigate to partner page directly)
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('搭子动态'), backgroundColor: AppConfig.cardBg),
        body: const Center(child: Text('搭子动态 — 建设中', style: TextStyle(color: AppConfig.textSecondary))),
      ),
    ));
  }

  void _navigateToProfile() {
    _switchToTab(4);
  }

  // ===== My Todo 内联面板 =====
  Widget _buildTodoInline() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        boxShadow: AppConfig.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🛡️ 核心装备', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyTodoPage())),
              child: Text('详情→', style: TextStyle(fontSize: 12, color: AppConfig.primary)),
            ),
          ]),
          const SizedBox(height: 8),
          ..._todoItems().map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  Text(item.icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(item.label, style: TextStyle(fontSize: 12, color: item.done ? AppConfig.textSecondary : AppConfig.textPrimary)),
                  if (!item.done) ...[
                    const Spacer(),
                    Text(item.hint, style: const TextStyle(fontSize: 11, color: AppConfig.warningOrange)),
                  ],
                ]),
              )),
        ],
      ),
    );
  }

  List<_TodoItem> _todoItems() {
    return [
      _TodoItem('✅', '头盔', true, ''),
      _TodoItem('✅', '水壶×2', true, ''),
      _TodoItem('✅', '手套', true, ''),
      _TodoItem('⚠️', '能量胶', false, '需补充'),
      _TodoItem('⚠️', '备用内胎', false, '需补充×1'),
      _TodoItem('⬜', '骑行眼镜', false, ''),
    ];
  }

  // ==================== 热门路线 ====================
  Widget _buildHotRoutesSection() {
    if (_editMode) {
      // Edit mode: show on/off toggle
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
        child: Row(
          children: [
            const Text('🔥 热门路线', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            const Spacer(),
            GestureDetector(
              onTap: () {
                setState(() => _showHotRoutes = !_showHotRoutes);
                _savePrefs();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _showHotRoutes ? AppConfig.primary.withOpacity(0.1) : AppConfig.bgMain,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _showHotRoutes ? '已显示' : '已隐藏',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                    color: _showHotRoutes ? AppConfig.primary : AppConfig.textSecondary),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() => _modules.remove(HomeModule.hotRoutes));
                _showHotRoutes = false;
                _savePrefs();
              },
              child: const Icon(Icons.delete_outline, size: 18, color: AppConfig.textSecondary),
            ),
          ],
        ),
      );
    }
    if (!_showHotRoutes) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
          child: const Text('🔥 热门路线', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        ),
        const SizedBox(height: 12),
        _buildHotRoutesList(),
      ],
    );
  }


  void _showRoutePreview(BuildContext context, _HotRoute route) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _RoutePreviewPage(route: route)));
  }
  Widget _buildHotRoutesList() {
    final routes = [
      _HotRoute('环西湖骑行', 5832, 28500, 42, 22.0, 80, 75, 1, 'https://picsum.photos/seed/qh1/400/240'),
      _HotRoute('龙井爬坡线', 3210, 18900, 35, 8.5, 320, 40, 3, 'https://picsum.photos/seed/lj2/400/240'),
      _HotRoute('千岛湖环湖', 4200, 24100, 48, 140.0, 1200, 420, 2, 'https://picsum.photos/seed/qdh3/400/240'),
      _HotRoute('梅家坞线', 1850, 12000, 22, 15.0, 250, 60, 1, 'https://picsum.photos/seed/mjw4/400/240'),
    ];

    return SizedBox(
      height: 136,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
        itemCount: routes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _buildHotRouteCard(routes[i], i),
      ),
    );
  }

  Widget _buildHotRouteCard(_HotRoute route, int index) {
    return FutureAnimatedEntry(
      delayMs: 120 * index,
      child: GestureDetector(
        onTap: () {
          _showRoutePreview(context, route);
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
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppConfig.primary, AppConfig.primary.withOpacity(0.25)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppConfig.primary.withOpacity(0.5), AppConfig.primary.withOpacity(0.15)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(route.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
                // 渐变遮罩
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0x4D000000), const Color(0x66000000), const Color(0xA6000000)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // 难度标签
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppConfig.primary.withOpacity(0.85),
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
                      Text(route.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            const Icon(Icons.thumb_up, size: 11, color: Colors.white70),
                            const SizedBox(width: 2),
                            Text(_fmtNum(route.likes), style: const TextStyle(fontSize: 11, color: Colors.white70)),
                            const SizedBox(width: 8),
                            const Icon(Icons.directions_walk, size: 11, color: Colors.white70),
                            const SizedBox(width: 2),
                            Text('${_fmtNum(route.walkers)}人走过', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                          ]),
                          Text(
                            '${route.distanceKm.toStringAsFixed(0)}km ↑${route.climb}m ${_durStr(route.durationMinutes)}',
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 卡片底部分隔
                Positioned(
                  bottom: 0, left: 10, right: 10,
                  child: Divider(height: 1, thickness: 0.5, color: Colors.white24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _difficultyLabel(int d) {
    switch (d) {
      case 1: return '休闲';
      case 2: return '中等';
      case 3: return '挑战';
      default: return '极限';
    }
  }

  String _fmtNum(int n) {
    if (n < 1000) return n.toString();
    if (n < 10000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '${(n / 10000).toStringAsFixed(1)}W';
  }

  String _durStr(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    return h > 0 ? '${h}h${m}min' : '${m}min';
  }

  // ==================== 安全免责 ====================
  Widget _buildSafetyDisclaimer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppConfig.warmGold.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                '户外骑行存在一定风险，请根据自身体能选择合适路线，量力而行。遵守交通规则，佩戴头盔，安全第一。',
                style: TextStyle(fontSize: 11, color: AppConfig.textSecondary, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== 热门路线数据 =====


// ===== 热门路线预览页 =====
class _RoutePreviewPage extends StatelessWidget {
  final dynamic route;
  const _RoutePreviewPage({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: Text(route.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
              child: Image.network(route.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 200, decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2ECC71), Color(0xFF27AE60)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
                ), child: const Center(child: Icon(Icons.landscape, size: 64, color: Colors.white))),
              ),
            ),
            const SizedBox(height: AppConfig.sectionGap),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConfig.pageMargin),
              decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('路线数据', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
                const SizedBox(height: 14),
                Row(children: [
                  _buildStat('📏', '距离', '${route.distanceKm.toStringAsFixed(1)} km'),
                  _buildStat('🏔️', '爬升', '${route.climb} m'),
                  _buildStat('⏱️', '预计', _fmtMins(route.durationMinutes)),
                  _buildStat('⭐', '难度', _diffLabel(route.difficulty as int)),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  const Icon(Icons.thumb_up, size: 14, color: AppConfig.textSecondary),
                  const SizedBox(width: 4),
                  Text('${_fmtStatic(route.likes as int)} 点赞', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                  const SizedBox(width: 16),
                  const Icon(Icons.directions_walk, size: 14, color: AppConfig.textSecondary),
                  const SizedBox(width: 4),
                  Text('${_fmtStatic(route.walkers as int)} 人走过', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                  const SizedBox(width: 16),
                  const Icon(Icons.star, size: 14, color: AppConfig.textSecondary),
                  const SizedBox(width: 4),
                  Text('${route.stars} 收藏', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStat(String icon, String label, String value) {
    return Expanded(
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
      ]),
    );
  }

  static String _fmtMins(int mins) {
    if (mins < 60) return '${mins}min';
    return '${mins ~/ 60}h${mins % 60}min';
  }

  static String _fmtStatic(int n) {
    if (n < 1000) return '$n';
    if (n < 10000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '${(n / 10000).toStringAsFixed(1)}W';
  }

  static String _diffLabel(int d) {
    return ['', '★', '★★', '★★★'][d];
  }
}
class _HotRoute {
  final String name;
  final int likes;
  final int walkers;
  final int stars;
  final double distanceKm;
  final int climb;
  final int durationMinutes;
  final int difficulty;
  final String imageUrl;

  const _HotRoute(this.name, this.likes, this.walkers, this.stars, this.distanceKm, this.climb, this.durationMinutes, this.difficulty, this.imageUrl);

  double get score => (likes * 1.0 + walkers * 2.0 + stars * 0.5) * (1.0 / (1 + 0));
}

// ===== Todo 内联数据 =====
class _TodoItem {
  final String icon;
  final String label;
  final bool done;
  final String hint;
  const _TodoItem(this.icon, this.label, this.done, this.hint);
}

// ===== 通用入场动画 =====
class FutureAnimatedEntry extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final double offsetY;

  const FutureAnimatedEntry({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.offsetY = 20,
  });

  @override
  State<FutureAnimatedEntry> createState() => _FutureAnimatedEntryState();
}

class _FutureAnimatedEntryState extends State<FutureAnimatedEntry> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _fade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween(begin: Offset(0, widget.offsetY / 100), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: widget.child));
  }
}

// ===== 占位页面 =====
class _CyclingStatsStub extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _stubPage(context, '骑行统计', '总里程/爬升/时间/速度\n本周/月度/年度统计\n骑行日历热力图');
}
class _AchievementsStub extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _stubPage(context, '我的成就', '等级勋章/里程碑\n连续骑行天数\n挑战完成记录');
}
class _TripPlanStub extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _stubPage(context, '出行计划', '创建骑行计划\n设置日期/路线/队友\n计划提醒');
}
class _FavoriteRoutesStub extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _stubPage(context, '常用路线', '收藏的路线列表\n快速出发\n路线分组');
}
class _CyclingVideoStub extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _stubPage(context, '骑行短片', '自动生成30秒骑行视频\n轨迹动画+照片+数据\n分享到社区');
}
class _CyclingAccountingStub extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _stubPage(context, '骑行记账', '快速记账：补给/餐饮/住宿\n行程结束后自动汇总\n分类占比饼图');
}
class _MaintenanceReminderStub extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _stubPage(context, '保养提醒', '按里程/时间设保养周期\n链条/刹车/轮胎/变速\n超期角标提醒');
}
class _GoldenHourStub extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _stubPage(context, '黄金时刻', '今日日出日落时间\n黄金拍摄时段提醒\n最佳光线预测');
}

Widget _stubPage(BuildContext context, String title, String desc) {
  return Scaffold(
    backgroundColor: AppConfig.bgMain,
    appBar: AppBar(title: Text(title), backgroundColor: AppConfig.cardBg),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppConfig.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.construction_rounded, size: 36, color: AppConfig.primary),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(fontSize: 14, color: AppConfig.textSecondary, height: 1.6), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppConfig.warmGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('🏗️ 功能开发中', style: TextStyle(fontSize: 13, color: AppConfig.warningOrange)),
            ),
          ],
        ),
      ),
    ),
  );
}