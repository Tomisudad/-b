import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/scenario_config.dart';
import '../config/app_config.dart';
import '../providers/trip_provider.dart';
import '../services/tracking_service.dart';
import '../services/voice_service.dart';
import '../services/location_service.dart';
import '../models/reroute_model.dart';
import 'track_end_page.dart';

/// V6.5 导航页 — 全屏地图 + 轨迹记录 + 场景化面板 + 主动感知 + 安全应急
/// 包含：实时轨迹 / 场景化数据面板 / 海拔全景 / 天气预警 / 路况可视化
///      临时改道 / 顺路搜索 / SOS增强 / 停留超时预警 / 离线知识库
///      搭子偶遇 / 自动保存 / 省电模式 / 补录机制 / 实时分享
class NavigationPage extends StatefulWidget {
  final OutdoorScenario scenario;
  final String? routeName;
  final bool fromFreeRecord;
  final bool hasBackfill; // V6.5 1.11: 有无缓存可补录
  const NavigationPage({
    super.key,
    required this.scenario,
    this.routeName,
    this.fromFreeRecord = false,
    this.hasBackfill = false,
  });

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> with TickerProviderStateMixin {
  // ═══ 核心服务 ═══
  late final TrackingService _tracking;
  final _loc = LocationService.instance;
  final _voice = VoiceService.instance;

  // ═══ 导航状态 ═══
  bool _started = false;
  bool _paused = false;
  bool _showEmotionPicker = false;
  String? _lastEmotion;
  bool _avoidTolls = false;
  bool _preferHighway = true;
  bool _scenicRoute = false;

  // ═══ V6.5 1.2 场景化数据面板 ═══
  double _calories = 0;
  int _fuelRange = 180; // km, mock
  double _nextGasKm = 35.0; // mock
  double _nextServiceKm = 22.0; // mock
  double _gradePercent = 0; // mock grade %
  double _altitude = 450; // mock
  int _batteryLevel = 85; // mock %
  bool _panelExpanded = false;

  // ═══ V6.5 1.3 语音记录 ═══
  bool _recordingVoice = false;

  // ═══ V6.5 1.4 主动感知 ═══
  bool _showWeatherAlert = false;
  String _weatherAlertType = '';
  double _weatherDistKm = 0;
  String _weatherAdvice = '';
  bool _showElevationPanorama = false;

  // ═══ V6.5 1.4 路况覆盖 ═══
  bool _hasHazardZones = true; // mock: 有路况标记
  final List<_HazardZone> _hazards = [
    _HazardZone(left: 180, top: 60, w: 80, h: 50, color: Color(0x4DE74C3C), label: '施工'),
    _HazardZone(left: 260, top: 200, w: 60, h: 40, color: Color(0x4DF39C12), label: '湿滑'),
  ];

  // ═══ V6.5 1.5 改道（保留原有 + 增强） ═══
  bool _rerouted = false;
  double _newDistanceKm = 0;
  double _originalDistanceKm = 45.0;
  String? _rerouteMessage;
  Timer? _rerouteTipTimer;
  final List<RerouteAction> _rerouteLog = [];
  // 跳过/恢复的点
  final Set<int> _skippedWaypoints = {};

  // ═══ V6.5 1.5 顺路搜索 ═══
  bool _showAlongSearch = false;
  final _alongSearchCtrl = TextEditingController();
  List<_AlongResult> _alongResults = [];
  bool _alongSearching = false;

  // ═══ V6.5 1.6 快速标记 ═══
  final List<_QuickMark> _quickMarks = [];

  // ═══ V6.5 1.7 SOS 增强 ═══
  static const _hospitals = [
    _RescuePoint('杭州市第一人民医院', '3.2km', '0571-87065701'),
    _RescuePoint('浙江大学医学院附属第二医院', '5.8km', '0571-87783777'),
  ];
  static const _policeStations = [
    _RescuePoint('西湖区公安分局', '2.1km', '0571-110'),
  ];

  // ═══ V6.5 1.7 停留超时预警 ═══
  Timer? _inactivityTimer;
  bool _inactivityWarning = false;
  int _inactivityCountdown = 30;
  double _lastGpsLat = 0;
  double _lastGpsLng = 0;
  DateTime _lastGpsChange = DateTime.now();

  // ═══ V6.5 1.8 搭子偶遇 ═══
  Timer? _buddyCheckTimer;
  bool _showBuddyCard = false;
  String _buddyName = '';
  String _buddyTarget = '';
  String _buddyRoute = '';
  double _buddyDist = 0;

  // ═══ V6.5 1.9 自动保存 ═══
  Timer? _autoSaveTimer;

  // ═══ V6.5 1.10 省电模式 ═══
  bool _powerSaving = false;

  // ═══ V6.5 1.6 实时分享 ═══
  bool _sharingLocation = false;

  @override
  void initState() {
    super.initState();
    _tracking = TrackingService.instance;
    if (!_tracking.isTracking) {
      _tracking.startTracking(widget.scenario);
    }
    _started = true;
    _lastGpsLat = _loc.latitude;
    _lastGpsLng = _loc.longitude;

    // V6.5 1.9: 每30秒自动保存
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) => _autoSave());

    // V6.5 1.7: 停留超时检测
    _startInactivityMonitor();

    // V6.5 1.8: 搭子检测
    _buddyCheckTimer = Timer.periodic(const Duration(seconds: 60), (_) => _checkBuddy());

    // V6.5 1.10: 电量监测
    _checkBattery();

    // V6.5 1.11: 补录弹窗
    if (widget.fromFreeRecord && widget.hasBackfill) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showBackfillDialog());
    }

    // V6.5 1.4: 天气主动预警（每5分钟）
    Timer.periodic(const Duration(minutes: 5), (_) => _checkWeatherAlert());
  }

  @override
  void dispose() {
    _rerouteTipTimer?.cancel();
    _inactivityTimer?.cancel();
    _buddyCheckTimer?.cancel();
    _autoSaveTimer?.cancel();
    _alongSearchCtrl.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════
  // ▼ V6.5 1.9 自动保存
  // ════════════════════════════════════════════════════════════
  void _autoSave() {
    if (!_tracking.isTracking || _paused) return;
    // mock: save to local storage
    debugPrint('[去野] 自动保存轨迹点: ${_tracking.points.length}');
  }

  // ════════════════════════════════════════════════════════════
  // ▼ V6.5 1.10 省电模式
  // ════════════════════════════════════════════════════════════
  void _checkBattery() {
    // mock: simulate battery at 25%
    if (_batteryLevel < 20 && !_powerSaving) {
      setState(() => _powerSaving = true);
    }
  }

  void _togglePowerSaving() {
    setState(() => _powerSaving = !_powerSaving);
  }

  // ════════════════════════════════════════════════════════════
  // ▼ V6.5 1.11 补录
  // ════════════════════════════════════════════════════════════
  void _showBackfillDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.dialogRadius)),
        title: const Text('检测到轨迹缓存', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('检测到您可能已在路上，是否补录\n之前30分钟的轨迹？（不计入成就统计）'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('放弃缓存', style: TextStyle(color: AppConfig.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ 已补录30分钟轨迹（自动补充）'), duration: Duration(seconds: 2)),
              );
            },
            child: const Text('确认补录', style: TextStyle(color: AppConfig.goldStart, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ▼ V6.5 1.7 停留超时预警
  // ════════════════════════════════════════════════════════════
  void _startInactivityMonitor() {
    _inactivityTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_paused || !mounted) return;
      final now = DateTime.now();
      final lat = _loc.latitude;
      final lng = _loc.longitude;
      final posChanged = (lat - _lastGpsLat).abs() > 0.0001 || (lng - _lastGpsLng).abs() > 0.0001;
      if (posChanged) {
        _lastGpsLat = lat;
        _lastGpsLng = lng;
        _lastGpsChange = now;
        return;
      }
      if (now.difference(_lastGpsChange).inMinutes >= 15 && !_inactivityWarning) {
        _triggerInactivityWarning();
      }
    });
  }

  void _triggerInactivityWarning() {
    setState(() {
      _inactivityWarning = true;
      _inactivityCountdown = 30;
    });
    // 倒计时
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_inactivityWarning) { timer.cancel(); return; }
      setState(() => _inactivityCountdown--);
      if (_inactivityCountdown <= 0) {
        timer.cancel();
        _sendInactivitySMS();
      }
    });
  }

  void _cancelInactivityWarning() {
    setState(() => _inactivityWarning = false);
  }

  void _sendInactivitySMS() {
    // mock: auto SMS via system
    if (mounted) {
      setState(() => _inactivityWarning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠ 已向紧急联系人发送提醒：位置(${_loc.latitude.toStringAsFixed(4)}, ${_loc.longitude.toStringAsFixed(4)})'), backgroundColor: AppConfig.sosRed),
      );
    }
  }

  // ════════════════════════════════════════════════════════════
  // ▼ V6.5 1.8 搭子偶遇
  // ════════════════════════════════════════════════════════════
  void _checkBuddy() {
    if (!_started || !mounted) return;
    // mock: 30% chance to detect nearby buddy
    if (Random().nextDouble() < 0.15 && !_showBuddyCard) {
      final names = ['山行者小李', '骑行老张', '🚴‍♀️追风女孩'];
      final routes = ['千岛湖绿道', '龙井爬坡段', '西湖环线'];
      setState(() {
        _showBuddyCard = true;
        _buddyName = names[Random().nextInt(names.length)];
        _buddyTarget = Random().nextBool() ? '风景组' : '挑战组';
        _buddyRoute = routes[Random().nextInt(routes.length)];
        _buddyDist = 1.5 + Random().nextDouble() * 3.5;
      });
    }
  }

  void _dismissBuddy() => setState(() => _showBuddyCard = false);

  void _sendBuddyPhrase(String phrase) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已发送："$phrase" → $_buddyName'), duration: const Duration(seconds: 2)),
    );
    _dismissBuddy();
  }

  // ════════════════════════════════════════════════════════════
  // ▼ V6.5 1.4 天气预警
  // ════════════════════════════════════════════════════════════
  void _checkWeatherAlert() {
    if (!mounted || _showWeatherAlert) return;
    if (Random().nextDouble() < 0.2) {
      final types = [
        ('强降雨', 15.0, '建议：前方15km处有避雨点「龙井茶室」'),
        ('大风', 8.0, '建议：减速慢行，注意横风路段'),
      ];
      final w = types[Random().nextInt(types.length)];
      setState(() {
        _showWeatherAlert = true;
        _weatherAlertType = w.$1;
        _weatherDistKm = w.$2;
        _weatherAdvice = w.$3;
      });
    }
  }

  void _dismissWeather() => setState(() => _showWeatherAlert = false);

  void _navigateToShelter() {
    _dismissWeather();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📍 已设置避雨点「龙井茶室」为临时途经点'), duration: Duration(seconds: 2)),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ▼ V6.5 1.5 顺路搜索
  // ════════════════════════════════════════════════════════════
  void _searchAlong() {
    final q = _alongSearchCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() => _alongSearching = true);
    // mock results
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _alongResults = [
          _AlongResult('加油站 · 中石化西湖站', '顺路', 0.8, '⛽', '92#/95#'),
          _AlongResult('餐馆 · 楼外楼', '绕路0.3km', 2.1, '🍜', '人均¥80'),
          _AlongResult('维修站 · 西湖修车', '顺路', 3.5, '🔧', '09:00-18:00'),
        ];
        _alongSearching = false;
      });
    });
  }

  void _addAlongPoint(_AlongResult r) {
    setState(() {
      _alongResults = [];
      _alongSearchCtrl.clear();
      _showAlongSearch = false;
    });
    _addWaypoint();
  }

  // ════════════════════════════════════════════════════════════
  // ▼ V6.5 1.3 快速标记
  // ════════════════════════════════════════════════════════════
  void _showQuickMark() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.pageMargin),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('快速标记', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
              const SizedBox(height: 16),
              _markOption('📸', '拍照打卡', AppConfig.goldEnd, () { Navigator.pop(context); _addMark('📸', '拍照打卡'); }),
              const SizedBox(height: 8),
              _markOption('⚠️', '路况上报', AppConfig.sosRed, () { Navigator.pop(context); _addMark('⚠️', '路况上报'); }),
              const SizedBox(height: 8),
              _markOption('💧', '发现补给', AppConfig.cyclePrimary, () { Navigator.pop(context); _addMark('💧', '发现补给'); }),
              const SizedBox(height: 8),
              _markOption('📝', '快速笔记', AppConfig.drivePrimary, () { Navigator.pop(context); _addMark('📝', '快速笔记'); }),
            ]),
          ),
        ),
      ),
    );
  }

  void _addMark(String icon, String type) {
    final lat = _loc.latitude;
    final lng = _loc.longitude;
    setState(() => _quickMarks.add(_QuickMark(icon, type, lat, lng, DateTime.now())));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$icon ${type}已标记@ (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})'), duration: const Duration(seconds: 2)),
    );
  }

  Widget _markOption(String emoji, String title, Color color, VoidCallback onTap) {
    return Material(
      color: AppConfig.bgMain, borderRadius: BorderRadius.circular(AppConfig.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color))),
            const Icon(Icons.chevron_right, size: 18, color: AppConfig.textSecondary),
          ]),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ▼ V6.5 1.7 SOS 增强
  // ════════════════════════════════════════════════════════════
  void _showSOS() {
    final lat = _loc.latitude.toStringAsFixed(5);
    final lng = _loc.longitude.toStringAsFixed(5);
    final timeStr = '${DateTime.now().hour.toString().padLeft(2, "0")}:${DateTime.now().minute.toString().padLeft(2, "0")}';
    final msg = '【去野SOS紧急求助】\n时间：$timeStr\n坐标：$lat, $lng\n请尽快联系我！';

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 12),
                Row(children: [
                  Icon(Icons.warning_amber_rounded, color: AppConfig.sosRed, size: 28),
                  const SizedBox(width: 8),
                  const Text('紧急求助', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(8)),
                  child: Text(msg, style: const TextStyle(fontSize: 13, height: 1.6)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: msg));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: const Text('已复制求援信息，可粘贴到微信/SMS发送'), backgroundColor: AppConfig.sosRed),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('复制求援信息'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.sosRed, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('附近救援点', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                const SizedBox(height: 8),
                const Text('🏥 医院', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.motoPrimary)),
                ..._hospitals.map((h) => _rescueRow(h)),
                const SizedBox(height: 8),
                const Text('👮 派出所', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.drivePrimary)),
                ..._policeStations.map((p) => _rescueRow(p)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showOfflineKnowledge();
                    },
                    icon: const Icon(Icons.menu_book_outlined, size: 16),
                    label: const Text('📖 应急知识库'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rescueRow(_RescuePoint p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Expanded(child: Text(p.name, style: const TextStyle(fontSize: 13, color: AppConfig.textPrimary))),
        Text(p.dist, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
        const SizedBox(width: 8),
        Text(p.phone, style: const TextStyle(fontSize: 12, color: AppConfig.cyclePrimary)),
        const SizedBox(width: 4),
        const Icon(Icons.navigation_outlined, size: 14, color: AppConfig.textSecondary),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ▼ V6.5 1.7 离线应急知识库
  // ════════════════════════════════════════════════════════════
  void _showOfflineKnowledge() {
    final items = switch (widget.scenario) {
      OutdoorScenario.cycle => _cyclingKnowledge(),
      OutdoorScenario.moto => _motoKnowledge(),
      OutdoorScenario.drive => _drivingKnowledge(),
    };
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75, maxChildSize: 0.95, minChildSize: 0.4,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius))),
          child: SafeArea(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(children: [
                  const Icon(Icons.menu_book, size: 24, color: AppConfig.goldEnd),
                  const SizedBox(width: 8),
                  const Text('应急知识库', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppConfig.cyclePrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: const Text('离线可用', style: TextStyle(fontSize: 10, color: AppConfig.cyclePrimary)),
                  ),
                ]),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (_, i) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(AppConfig.cardRadius), border: Border.all(color: AppConfig.divider)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(items[i].$1, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(items[i].$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary))),
                      ]),
                      const SizedBox(height: 6),
                      Text(items[i].$3, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary, height: 1.5)),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  List<(String, String, String)> _cyclingKnowledge() => const [
    ('🚴', '爆胎换胎（6步）', '1.卸轮 2.撬胎 3.取出内胎 4.检查外胎内壁 5.装入新内胎→充气 6.装轮→检查刹车'),
    ('🔗', '链条断裂应急', '使用魔术扣/快拆扣临时连接，或截链器截断后短接。注意：短接后避免大对大变速'),
    ('🔧', '刹车调整', '1.松开固定螺丝 2.调整刹车块位置 3.拉紧刹车线 4.测试→锁紧'),
    ('⚙️', '变速器失灵应急', '固定在最常用档位继续骑行，到达维修点后再处理'),
  ];

  List<(String, String, String)> _motoKnowledge() => const [
    ('🏍️', '常见故障灯对照', '🟡发动机灯→检查油门/进气/氧传感器 | 🔴机油灯→立即停车检查机油位 | 🔴水温灯→停车散热'),
    ('🔍', '无法启动排查', '1.检查电瓶→搭电 2.检查保险丝→更换 3.检查火花塞→清洁/更换 4.检查燃油→加油'),
    ('💧', '漏油应急处理', '停车→确认泄漏类型→关闭油箱开关→用胶带/肥皂临时封堵→低速骑行至维修点'),
    ('🔌', '火花塞更换', '1.拔高压包 2.用套筒拧下旧火花塞 3.手指旋入新火花塞→扳手加力1/4圈 4.插回高压包'),
  ];

  List<(String, String, String)> _drivingKnowledge() => const [
    ('🚙', '换备胎（5步）', '1.拉手刹→挂P档 2.松螺丝→千斤顶升起 3.卸旧胎→装备胎 4.对角拧紧螺丝 5.降下→复紧'),
    ('🔋', '电瓶搭电', '1.正极(红)接正→正接正 2.负极(黑)接救援车负极 3.另一端接被救车接地(远离电瓶) 4.启动救援车→启动被救车'),
    ('🌡️', '发动机过热', '1.靠边停车 2.怠速运转(不要熄火) 3.开暖风(最大)辅助散热 4.水温降后检查冷却液'),
    ('💧', '水箱漏水应急', '临时堵漏：鸡蛋清/碎肥皂塞入漏点→低速开至维修点。严重漏→叫拖车'),
  ];

  // ════════════════════════════════════════════════════════════
  // ▼ V6.5 1.6 实时分享
  // ════════════════════════════════════════════════════════════
  void _toggleLocationShare() {
    setState(() => _sharingLocation = !_sharingLocation);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_sharingLocation ? '✅ 实时位置分享已开启（链接有效期至行程结束+1小时）' : '已关闭实时位置分享')),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ▼ 导航控制（保留原有逻辑）
  // ════════════════════════════════════════════════════════════
  void _startNavigation() {
    if (!_started) {
      _tracking.startTracking(widget.scenario);
      final cfg = ScenarioConfig.of(widget.scenario);
      _voice.speak(cfg.label + _routePrefSummary());
      setState(() => _started = true);
    }
  }

  String _routePrefSummary() {
    final parts = <String>[];
    if (_avoidTolls) parts.add('避开收费');
    if (_scenicRoute) parts.add('风景优先');
    return parts.isEmpty ? '' : '，${parts.join('、')}路线已设置';
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    _voice.speak(_paused ? '已暂停' : '继续');
  }

  void _endNavigation() {
    final dist = _tracking.currentDistance;
    final startTime = _tracking.currentRoute?.startTime ?? DateTime.now();
    final durSec = DateTime.now().difference(startTime).inSeconds;
    _tracking.stopTracking();

    final prov = context.read<TripProvider>();
    if (prov.activeTrip != null) {
      prov.completeTrip(finalDistanceKm: dist, finalDurationSec: durSec);
    } else {
      prov.createTrip(widget.routeName ?? '自由记录', widget.scenario);
      prov.completeTrip(finalDistanceKm: dist, finalDurationSec: durSec);
    }

    final completed = prov.completedTrips.isNotEmpty ? prov.completedTrips.first : null;
    if (completed != null && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => TrackEndPage(trip: completed, rerouteLog: _rerouteLog)),
        (_) => false,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _tagEmotion(String emoji, String label) {
    setState(() { _lastEmotion = label; _showEmotionPicker = false; });
    _tracking.tagEmotion(emoji, label);
  }

  void _toggleVoiceRecord() {
    setState(() => _recordingVoice = !_recordingVoice);
    if (_recordingVoice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎤 开始录音（最长140字转文字）'), duration: Duration(seconds: 1)),
      );
      // mock recording
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _recordingVoice) {
          setState(() => _recordingVoice = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ 语音已保存："这段路太美了，值得再来"'), duration: Duration(seconds: 2)),
          );
          _addMark('📝', '快速笔记');
        }
      });
    }
  }

  // ════════════════════════════════════════════════════════════
  // ▼ V5.5 改道（保留原有 + 增强）
  // ════════════════════════════════════════════════════════════
  void _showMapLongPress() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius))),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.pageMargin),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('地图操作', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
              const SizedBox(height: 16),
              _rerouteOption('📍', '添加途经点', '插入到当前导航序列，重新规划路线', AppConfig.cyclePrimary, () { Navigator.pop(context); _addWaypoint(); }),
              const SizedBox(height: 8),
              _rerouteOption('🚩', '直接导航去这里', '变更终点，丢弃剩余途经点，原路线保留', AppConfig.motoPrimary, () { Navigator.pop(context); _changeDestination(); }),
              const SizedBox(height: 8),
              _rerouteOption('📝', '标记此处', '仅标记，不改路线', AppConfig.drivePrimary, () { Navigator.pop(context); _addMark('📍', '地图标记'); }),
              const SizedBox(height: 8),
              _rerouteOption('🔍', '顺路搜索', '搜索沿途补给点、加油站等', AppConfig.drivePrimary, () { Navigator.pop(context); setState(() => _showAlongSearch = true); }),
            ]),
          ),
        ),
      ),
    );
  }

  void _showWaypointActions(int index) {
    if (_skippedWaypoints.contains(index)) {
      // 恢复
      setState(() => _skippedWaypoints.remove(index));
      _applyReroute('恢复途经点 ${index + 1}', _originalDistanceKm);
      return;
    }
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius))),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.pageMargin),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('途经点 ${index + 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
              const SizedBox(height: 16),
              _rerouteOption('✏️', '编辑备注', '修改途经点名称', AppConfig.textPrimary, () => Navigator.pop(context)),
              const SizedBox(height: 8),
              _rerouteOption('🔇', '跳过此点', '本次导航绕开，可恢复', AppConfig.motoPrimary, () { Navigator.pop(context); _skipWaypoint(index); }),
              const SizedBox(height: 8),
              _rerouteOption('❌', '删除此点', '从本次导航移除', AppConfig.sosRed, () { Navigator.pop(context); _deleteWaypoint(index); }),
              const SizedBox(height: 8),
              _rerouteOption('📍', '设为终点', '提前结束，后续途经点移除', AppConfig.drivePrimary, () { Navigator.pop(context); _setAsDestination(index); }),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _rerouteOption(String emoji, String title, String desc, Color color, VoidCallback onTap) {
    return Material(
      color: AppConfig.bgMain, borderRadius: BorderRadius.circular(AppConfig.cardRadius),
      child: InkWell(borderRadius: BorderRadius.circular(AppConfig.cardRadius), onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 20)), const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
            Text(desc, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
          ])),
          const Icon(Icons.chevron_right, size: 18, color: AppConfig.textSecondary),
        ])),
      ),
    );
  }

  void _addWaypoint() { _applyReroute('添加途经点', _originalDistanceKm + 3.0 + Random().nextDouble() * 10); }
  void _changeDestination() {
    final diff = Random().nextDouble() * 15 + 2;
    if (diff > 10) {
      showDialog(context: context, builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.dialogRadius)),
        title: const Text('路线变更确认', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('新路线与原计划差异较大（${diff.toStringAsFixed(1)}km），确认更改？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(onPressed: () { Navigator.pop(ctx); _applyReroute('变更终点', _originalDistanceKm - 5 - Random().nextDouble() * 10); },
            child: const Text('确认更改', style: TextStyle(color: AppConfig.motoPrimary, fontWeight: FontWeight.w600))),
        ],
      ));
    } else { _applyReroute('变更终点', _originalDistanceKm - 5 - Random().nextDouble() * 10); }
  }
  void _skipWaypoint(int i) { setState(() => _skippedWaypoints.add(i)); _applyReroute('跳过途经点 ${i + 1}', _originalDistanceKm - 4); }
  void _deleteWaypoint(int i) { _applyReroute('删除途经点 ${i + 1}', _originalDistanceKm - 2); }
  void _setAsDestination(int i) { _applyReroute('提前设为终点(途经点${i + 1})', _originalDistanceKm * 0.5); }

  void _applyReroute(String action, double newDist) {
    setState(() {
      _rerouted = true; _newDistanceKm = newDist.abs();
      _rerouteMessage = '路线已调整：新距离 ${_newDistanceKm.toStringAsFixed(1)} km（原 ${_originalDistanceKm.toStringAsFixed(1)} km）';
      _rerouteLog.add(RerouteAction(action, _newDistanceKm, _originalDistanceKm));
    });
    _rerouteTipTimer?.cancel();
    _rerouteTipTimer = Timer(const Duration(seconds: 3), () { if (mounted) setState(() => _rerouteMessage = null); });
  }
  void _restoreOriginalRoute() {
    setState(() { _rerouted = false; _newDistanceKm = 0; _rerouteMessage = '已恢复原路线'; _rerouteLog.add(RerouteAction('恢复原路线', _originalDistanceKm, _newDistanceKm)); });
    _rerouteTipTimer?.cancel();
    _rerouteTipTimer = Timer(const Duration(seconds: 2), () { if (mounted) setState(() => _rerouteMessage = null); });
  }

  // ════════════════════════════════════════════════════════════
  // ▼ V6.5 驾驶态 UI（全屏地图 + 双层面板）
  // ════════════════════════════════════════════════════════════
  Widget _buildDrivingUI(Color sceneColor) {
    return ListenableBuilder(
      listenable: _tracking,
      builder: (context, _) {
        final speed = _tracking.avgSpeed;
        final dist = _tracking.currentDistance;
        final maxSpeed = _tracking.maxSpeed;
        if (dist > 0 && !_paused) _voice.cycleTip(widget.scenario, dist.toInt());

        // V6.5 1.2 mock data
        _calories = dist * 35; // ~35 kcal/km cycling
        _gradePercent = 2.5 + Random().nextDouble() * 5;
        _altitude = 450 + dist * 12;

        return Scaffold(
          backgroundColor: Colors.black87,
          body: SafeArea(
            child: Stack(children: [
              // ═══ 地图区域 ═══
              Positioned.fill(child: _buildMapArea(sceneColor, speed, dist)),
              // ═══ V6.5 1.4 路况预警覆盖 ═══
              if (_hasHazardZones) ..._hazards.map((hz) => Positioned(left: hz.left, top: hz.top, child: Container(width: hz.w, height: hz.h, decoration: BoxDecoration(color: hz.color, borderRadius: BorderRadius.circular(4), border: Border.all(color: hz.color.withOpacity(0.6))), child: Center(child: Text(hz.label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: hz.color.withOpacity(0.7))))))),
              // ═══ V6.5 1.10 省电模式横幅 ═══
              if (_powerSaving)
                Positioned(top: 0, left: 0, right: 0, child: GestureDetector(onTap: _togglePowerSaving, child: Container(color: const Color(0xFFE67E22), padding: const EdgeInsets.symmetric(vertical: 3), child: const Center(child: Text('🔋 已进入省电记录模式 · 点击退出', style: TextStyle(fontSize: 12, color: Colors.white)))))),
              // ═══ V6.5 1.4 天气预警 ═══
              if (_showWeatherAlert)
                Positioned(top: _powerSaving ? 28 : 0, left: 0, right: 0, child: Container(color: const Color(0xFFE67E22), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Row(children: [
                  const Text('⚠️', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${_weatherAlertType} · ${_weatherDistKm.toStringAsFixed(0)}km外', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(_weatherAdvice, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                  ])),
                  GestureDetector(onTap: _navigateToShelter, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(12)), child: const Text('导航避难', style: TextStyle(fontSize: 11, color: Colors.white)))),
                  const SizedBox(width: 6),
                  GestureDetector(onTap: _dismissWeather, child: const Icon(Icons.close, size: 16, color: Colors.white)),
                ]))),
              // ═══ 改道提示 ═══
              if (_rerouteMessage != null)
                Positioned(top: _showWeatherAlert ? 60 : (_powerSaving ? 28 : 8), left: 16, right: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow), child: Row(children: [Expanded(child: Text(_rerouteMessage!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)))]))),
              if (_rerouted)
                Positioned(top: _rerouteMessage != null ? 80 : (_showWeatherAlert ? 60 : 8), right: 16, child: GestureDetector(onTap: _restoreOriginalRoute, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(20), boxShadow: AppConfig.cardShadow), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.restore, size: 16, color: AppConfig.drivePrimary), SizedBox(width: 4), Text('恢复原路线', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConfig.drivePrimary))])))),
              // ═══ V6.5 1.1 速度面板（左上方） ═══
              Positioned(top: _rerouteMessage != null ? 80 : (_showWeatherAlert ? 60 : (_powerSaving ? 28 : 16)), left: 16, child: _buildSpeedPanel(sceneColor, speed, dist)),
              // ═══ V6.5 1.3 语音按钮（右侧悬浮） ═══
              Positioned(right: 16, top: MediaQuery.of(context).size.height * 0.3, child: GestureDetector(onTap: _toggleVoiceRecord, child: Container(width: 52, height: 52, decoration: BoxDecoration(shape: BoxShape.circle, color: _recordingVoice ? AppConfig.sosRed : Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)]), child: Icon(_recordingVoice ? Icons.mic : Icons.mic_none_outlined, size: 26, color: _recordingVoice ? Colors.white : AppConfig.sosRed)))),
              // ═══ V6.5 1.8 搭子偶遇卡片 ═══
              if (_showBuddyCard)
                Positioned(bottom: _showElevationPanorama ? 380 : 150, left: 16, right: 16, child: AnimatedContainer(duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppConfig.motoPrimary.withOpacity(0.3))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Text('👥', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text('附近有同路搭子 · $_buddyName', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                      const Spacer(),
                      GestureDetector(onTap: _dismissBuddy, child: const Icon(Icons.close, size: 16, color: AppConfig.textSecondary)),
                    ]),
                    const SizedBox(height: 4),
                    Text('${_buddyTarget} | ${_buddyRoute} | ~${_buddyDist.toStringAsFixed(1)}km', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                    const SizedBox(height: 8),
                    Row(children: [
                      _buddyQuickMsg('加油！'), const SizedBox(width: 6),
                      _buddyQuickMsg('一起骑一段？'), const SizedBox(width: 6),
                      _buddyQuickMsg('前方路况？'),
                    ]),
                  ]),
                )),
              // ═══ V6.5 1.5 顺路搜索 ═══
              if (_showAlongSearch)
                Positioned(top: 60, left: 16, right: 16, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(12), boxShadow: AppConfig.cardShadow), child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(children: [
                    Expanded(child: TextField(controller: _alongSearchCtrl, onSubmitted: (_) => _searchAlong(), decoration: InputDecoration(hintText: '搜顺路补给', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), isDense: true), style: const TextStyle(fontSize: 14))),
                    const SizedBox(width: 8),
                    GestureDetector(onTap: _searchAlong, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppConfig.goldStart, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.search, size: 18, color: Colors.white))),
                    const SizedBox(width: 4),
                    GestureDetector(onTap: () => setState(() { _showAlongSearch = false; _alongResults = []; _alongSearchCtrl.clear(); }), child: const Icon(Icons.close, size: 20, color: AppConfig.textSecondary)),
                  ]),
                  if (_alongSearching) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
                  ..._alongResults.map((r) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: () => _addAlongPoint(r),
                      child: Row(children: [
                        Text(r.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppConfig.textPrimary)),
                          Text(r.extra, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
                        ])),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: r.isOnRoute ? AppConfig.cyclePrimary.withOpacity(0.1) : AppConfig.motoPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(r.detail, style: TextStyle(fontSize: 10, color: r.isOnRoute ? AppConfig.cyclePrimary : AppConfig.motoPrimary))),
                      ]),
                    ),
                  )),
                ]))),
              // ═══ V6.5 1.6 实时分享指示 ═══
              if (_sharingLocation)
                Positioned(top: MediaQuery.of(context).size.height * 0.15, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppConfig.cyclePrimary.withOpacity(0.8), borderRadius: BorderRadius.circular(10)), child: const Text('📍 分享中', style: TextStyle(fontSize: 10, color: Colors.white)))),
              // ═══ V6.5 1.7 停留超时预警 ═══
              if (_inactivityWarning)
                Positioned.fill(child: Container(color: Colors.black.withOpacity(0.85), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.warning_amber_rounded, size: 64, color: AppConfig.sosRed),
                  const SizedBox(height: 16),
                  const Text('检测到您已停留15分钟', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text('是否安全？', style: TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 24),
                  Text('${_inactivityCountdown}s 后将自动通知紧急联系人', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: _inactivityCountdown <= 5 ? AppConfig.sosRed : Colors.white)),
                  const SizedBox(height: 32),
                  SizedBox(width: 200, child: ElevatedButton(onPressed: _cancelInactivityWarning, style: ElevatedButton.styleFrom(backgroundColor: AppConfig.cyclePrimary, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('我没事', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)))),
                ])))),
            ]),
          ),
          // ═══ V6.5 1.1 底部数据面板 ═══
          bottomNavigationBar: _buildBottomPanel(sceneColor, speed, dist, maxSpeed),
        );
      },
    );
  }

  // ── V6.5 1.1 地图区域 ──
  Widget _buildMapArea(Color sceneColor, double speed, double dist) {
    return GestureDetector(
      onLongPress: () { if (!_showAlongSearch) _showMapLongPress(); },
      child: Container(
        color: const Color(0xFF1A2A1E),
        child: Stack(children: [
          // 原路线虚线
          if (_rerouted) CustomPaint(size: Size.infinite, painter: _RouteLinePainter(AppConfig.textSecondary.withOpacity(0.3), true)),
          // 当前路线实线
          CustomPaint(size: Size.infinite, painter: _RouteLinePainter(_rerouted ? AppConfig.drivePrimary : sceneColor, false)),
          // 途经点（支持跳过标记）
          ...List.generate(4, (i) {
            final left = 20.0 + i * 80.0 + 20;
            final top = 50.0 + (i % 2 == 0 ? 60.0 : 120.0);
            final skipped = _skippedWaypoints.contains(i);
            return Positioned(left: left, top: top, child: GestureDetector(onTap: () => _showWaypointActions(i), child: Container(width: 24, height: 24, decoration: BoxDecoration(color: skipped ? AppConfig.textSecondary : (i < (_rerouted ? 2 : 4) ? sceneColor : AppConfig.textSecondary), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))))));
          }),
          // 当前位置
          Positioned(left: 160, top: 160, child: Container(width: 16, height: 16, decoration: BoxDecoration(color: AppConfig.goldStart, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppConfig.goldStart.withOpacity(0.4), blurRadius: 8)]))),
          // 快速标记预览
          ..._quickMarks.asMap().entries.map((e) {
            final i = e.key; final m = e.value;
            final left = 30.0 + (i % 5) * 60.0 + 40;
            final top = 180.0 + (i ~/ 5) * 40.0;
            return Positioned(left: left, top: top, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(8)), child: Text('${m.icon} ${m.type}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500))));
          }),
        ]),
      ),
    );
  }

  // ── V6.5 1.1 速度面板（场景化数据） ──
  Widget _buildSpeedPanel(Color sceneColor, double speed, double dist) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // 速度卡片
      Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: AppConfig.cardBg.withOpacity(_panelExpanded ? 1.0 : 0.9), borderRadius: BorderRadius.circular(12)), child: Column(children: [
        Text(_paused ? '⏸' : '${speed.toInt()}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: AppConfig.textPrimary, height: 0.9)),
        const Text('km/h', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
      ])),
      // V6.5 1.2 场景化数据
      ..._buildScenarioData(sceneColor, speed, dist),
      // 情绪标签
      if (_lastEmotion != null) ...[
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: sceneColor.withOpacity(0.85), borderRadius: BorderRadius.circular(16)), child: Text(_lastEmotion!, style: const TextStyle(fontSize: 13, color: Colors.white))),
      ],
    ]);
  }

  List<Widget> _buildScenarioData(Color sceneColor, double speed, double dist) {
    if (!_panelExpanded) return [];
    final items = <Widget>[const SizedBox(height: 6)];
    switch (widget.scenario) {
      case OutdoorScenario.cycle:
        items.addAll([
          _dataChip('爬升', '${(_altitude - 450).toInt()}m', sceneColor),
          const SizedBox(height: 4),
          _dataChip('坡度', '${_gradePercent.toStringAsFixed(1)}%', sceneColor),
          const SizedBox(height: 4),
          _dataChip('消耗', '${_calories.toInt()} kcal', AppConfig.goldEnd),
        ]);
      case OutdoorScenario.moto:
        items.addAll([
          _dataChip('油量续航', '${_fuelRange}km', AppConfig.motoPrimary),
          const SizedBox(height: 4),
          _dataChip('下个加油站', '${_nextGasKm.toStringAsFixed(1)}km', AppConfig.motoPrimary),
          const SizedBox(height: 4),
          _dataChip('海拔', '${_altitude.toInt()}m', AppConfig.drivePrimary),
        ]);
      case OutdoorScenario.drive:
        items.addAll([
          _dataChip('剩余距离', '${_originalDistanceKm.toStringAsFixed(1)}km', AppConfig.drivePrimary),
          const SizedBox(height: 4),
          _dataChip('下个服务区', '${_nextServiceKm.toStringAsFixed(1)}km', AppConfig.drivePrimary),
          const SizedBox(height: 4),
          _dataChip('海拔', '${_altitude.toInt()}m', AppConfig.drivePrimary),
        ]);
    }
    return items;
  }

  Widget _dataChip(String label, String value, Color color) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: TextStyle(fontSize: 11, color: color)),
      const SizedBox(width: 6),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
    ]));
  }

  // ── V6.5 1.1 + 1.4 底部数据面板（可上拉展开海拔全景） ──
  Widget _buildBottomPanel(Color sceneColor, double speed, double dist, double maxSpeed) {
    return GestureDetector(
      onVerticalDragUpdate: (d) {
        if (d.delta.dy < -30 && !_showElevationPanorama) setState(() => _showElevationPanorama = true);
        if (d.delta.dy > 30 && _showElevationPanorama) setState(() => _showElevationPanorama = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _showElevationPanorama ? 380 : (_showEmotionPicker ? 180 : 140),
        decoration: BoxDecoration(
          color: const Color(0xE01A1A1A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(children: [
          const SizedBox(height: 6),
          Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
          // ═══ V6.5 1.4 海拔全景图 ═══
          if (_showElevationPanorama)
            Expanded(child: Column(children: [
              const SizedBox(height: 8),
              const Text('海拔全景', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 8),
              Expanded(child: CustomPaint(size: Size.infinite, painter: _ElevationPainter(dist: dist, totalDist: _originalDistanceKm, alt: _altitude, totalClimb: (_altitude - 450).toInt(), peakAlt: 1850))),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _altStat('剩余爬升', '${((1850 - _altitude).toInt())}m', Colors.orangeAccent),
                _altStat('最高点', '1850m', Colors.redAccent),
                _altStat('前方坡度', '6%', Colors.yellowAccent),
              ])),
              const SizedBox(height: 8),
            ]))
          else ...[
            // ═══ 默认：方向 + 距离 ═══
            const SizedBox(height: 4),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: sceneColor.withOpacity(0.2), borderRadius: BorderRadius.circular(AppConfig.cardRadius)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.arrow_forward, size: 20, color: sceneColor),
                const SizedBox(width: 8),
                Text('继续前行 ${(2.5 + dist % 5).toStringAsFixed(1)}km', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: sceneColor)),
              ]),
            ),
            const SizedBox(height: 2),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                onTap: () => setState(() => _panelExpanded = !_panelExpanded),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('已行 ${dist.toStringAsFixed(1)}km${_rerouted ? " · 改道" : ""} · 均速 ${speed.toInt()}km/h · 极速 ${maxSpeed.toInt()}km/h', style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
                  const SizedBox(width: 4),
                  Icon(_panelExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 14, color: AppConfig.textSecondary),
                ]),
              ),
            ]),
            const SizedBox(height: 4),
            // ═══ V6.5 1.3 操作栏 ═══
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _driveCircleBtn(Icons.emoji_emotions, '心情', () => setState(() => _showEmotionPicker = !_showEmotionPicker), sceneColor),
              _driveCircleBtn(Icons.camera_alt, '标记', _showQuickMark, AppConfig.goldEnd),
              _driveCircleBtn(Icons.share_outlined, '分享', _toggleLocationShare, _sharingLocation ? AppConfig.cyclePrimary : AppConfig.textSecondary),
              _driveCircleBtn(_paused ? Icons.play_arrow : Icons.pause, _paused ? '继续' : '暂停', _togglePause, sceneColor),
              _driveCircleBtn(Icons.warning_amber_rounded, 'SOS', _showSOS, AppConfig.sosRed),
              _driveCircleBtn(Icons.stop_circle, '结束', _endNavigation, AppConfig.motoPrimary, primary: true),
            ]),
            // 长按提示
            Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), margin: const EdgeInsets.only(top: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(8)), child: Text('上拉查看海拔 · 长按地图改道', style: const TextStyle(fontSize: 9, color: Colors.white30)))),
          ],
        ]),
      ),
    );
  }

  Widget _altStat(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
    ]);
  }

  Widget _buddyQuickMsg(String msg) {
    return GestureDetector(
      onTap: () => _sendBuddyPhrase(msg),
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppConfig.motoPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(msg, style: const TextStyle(fontSize: 12, color: AppConfig.motoPrimary))),
    );
  }

  // ── 情绪选择网格 ──
  Widget _buildEmotionPicker() {
    const emotions = [('😌', '平静'), ('🥹', '感动'), ('😤', '疲惫'), ('🤯', '震撼'), ('🧘', '顿悟'), ('😊', '开心')];
    return Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x15000000), blurRadius: 12)]), child: Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: emotions.map((e) => GestureDetector(onTap: () => _tagEmotion(e.$1, e.$2), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: AppConfig.cyclePrimary.withOpacity(0.06), borderRadius: BorderRadius.circular(8)), child: Text('${e.$1} ${e.$2}', style: const TextStyle(fontSize: 13, color: AppConfig.cyclePrimary))))).toList()));
  }

  Widget _driveCircleBtn(IconData icon, String label, VoidCallback onTap, Color color, {bool primary = false}) {
    return GestureDetector(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: primary ? color : color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 20, color: primary ? Colors.white : color)),
      Text(label, style: TextStyle(fontSize: 9, color: color)),
    ]));
  }

  // ── V6.5 1.1 出发确认页 ──
  Widget _buildConfirmationPage(Color sceneColor, ScenarioConfig cfg) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      body: SafeArea(
        child: Column(children: [
          const Spacer(),
          Container(width: 80, height: 80, decoration: BoxDecoration(color: sceneColor.withOpacity(0.1), borderRadius: BorderRadius.circular(24)), child: Icon(Icons.navigation, size: 40, color: sceneColor)),
          const SizedBox(height: 16),
          Text(cfg.label, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: sceneColor)),
          const SizedBox(height: 8),
          const Text('准备出发', style: TextStyle(fontSize: 16, color: AppConfig.textSecondary)),
          const SizedBox(height: 32),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: Wrap(spacing: 10, runSpacing: 8, alignment: WrapAlignment.center, children: [
            FilterChip(selected: _avoidTolls, onSelected: (v) => setState(() => _avoidTolls = v), label: const Text('避开收费'), avatar: const Icon(Icons.money_off, size: 18), selectedColor: sceneColor.withOpacity(0.1), checkmarkColor: sceneColor),
            FilterChip(selected: _preferHighway, onSelected: (v) => setState(() => _preferHighway = v), label: const Text('优先高速'), avatar: const Icon(Icons.speed, size: 18), selectedColor: sceneColor.withOpacity(0.1), checkmarkColor: sceneColor),
            FilterChip(selected: _scenicRoute, onSelected: (v) => setState(() => _scenicRoute = v), label: const Text('风景路线'), avatar: const Icon(Icons.landscape, size: 18), selectedColor: sceneColor.withOpacity(0.1), checkmarkColor: sceneColor),
          ])),
          const Spacer(),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
            onPressed: _startNavigation,
            style: ElevatedButton.styleFrom(backgroundColor: sceneColor, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('开始导航', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ))),
          const SizedBox(height: 48),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cfg = ScenarioConfig.of(widget.scenario);
    final sceneColor = cfg.primaryColor;
    if (!_started) return _buildConfirmationPage(sceneColor, cfg);
    return Stack(children: [
      _buildDrivingUI(sceneColor),
      // V6.5 情绪选择器（Overlay）
      if (_showEmotionPicker && _started)
        Positioned(bottom: 150, left: 0, right: 0, child: _buildEmotionPicker()),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════
// ▼ V6.5 1.4 海拔全景 CustomPainter
// ═══════════════════════════════════════════════════════════════
class _ElevationPainter extends CustomPainter {
  final double dist, totalDist, alt;
  final int totalClimb, peakAlt;
  _ElevationPainter({required this.dist, required this.totalDist, required this.alt, required this.totalClimb, required this.peakAlt});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    final pad = const EdgeInsets.all(20);
    final chartW = w - pad.left - pad.right;
    final chartH = h - pad.top - pad.bottom - 20;

    // 填充渐变
    final path = Path();
    path.moveTo(pad.left, pad.top + chartH);
    // mock profile
    final pts = [0.45, 0.30, 0.15, 0.25, 0.10, 0.18, 0.35, 0.20, 0.08, 0.12];
    for (var i = 0; i < pts.length; i++) {
      final x = pad.left + chartW * i / (pts.length - 1);
      final y = pad.top + chartH * pts[i];
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.lineTo(pad.left + chartW, pad.top + chartH);
    path.lineTo(pad.left, pad.top + chartH);
    path.close();
    canvas.drawPath(path, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x40B2D8FF), Color(0x00B2D8FF)]).createShader(Rect.fromLTWH(pad.left, pad.top, chartW, chartH)));

    // 线
    final line = Path();
    for (var i = 0; i < pts.length; i++) {
      final x = pad.left + chartW * i / (pts.length - 1);
      final y = pad.top + chartH * pts[i];
      if (i == 0) line.moveTo(x, y); else line.lineTo(x, y);
    }
    canvas.drawPath(line, Paint()..color = const Color(0xCC4FC3F7)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round);

    // 当前位置箭头
    final idx = (dist / totalDist * pts.length).clamp(0, pts.length - 1).toInt();
    final cx = pad.left + chartW * idx / (pts.length - 1);
    final cy = pad.top + chartH * pts[idx];
    canvas.drawCircle(Offset(cx, cy), 6, Paint()..color = const Color(0xFF4FC3F7));
    canvas.drawCircle(Offset(cx, cy), 8, Paint()..color = const Color(0x604FC3F7)..style = PaintingStyle.stroke..strokeWidth = 2);

    // 标签
    final tp = TextPainter(text: TextSpan(text: '▲ 当前位置 ${alt.toInt()}m', style: const TextStyle(fontSize: 10, color: Color(0xFF4FC3F7), fontWeight: FontWeight.w600)), textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - 18));

    // 最高点
    final tp2 = TextPainter(text: TextSpan(text: '最高点 ${peakAlt}m 🏔️垭口', style: const TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.w500)), textDirection: TextDirection.ltr);
    tp2.layout();
    final peakX = pad.left + chartW * 0.82;
    tp2.paint(canvas, Offset(peakX - tp2.width / 2, pad.top + chartH * 0.08 - 14));
  }

  @override
  bool shouldRepaint(covariant _ElevationPainter old) => old.alt != alt || old.dist != dist;
}

// ═══════════════════════════════════════════════════════════════
// ▼ V6.5 1.4 路况区
// ═══════════════════════════════════════════════════════════════
class _HazardZone {
  final double left, top, w, h;
  final Color color;
  final String label;
  const _HazardZone({required this.left, required this.top, required this.w, required this.h, required this.color, required this.label});
}

// ═══════════════════════════════════════════════════════════════
// ▼ V6.5 1.5 顺路搜索结果
// ═══════════════════════════════════════════════════════════════
class _AlongResult {
  final String name, detail;
  final double devKm;
  final String icon, extra;
  bool get isOnRoute => devKm < 1.0;
  const _AlongResult(this.name, this.detail, this.devKm, this.icon, this.extra);
}

// ═══════════════════════════════════════════════════════════════
// ▼ V6.5 1.3 快速标记
// ═══════════════════════════════════════════════════════════════
class _QuickMark {
  final String icon, type;
  final double lat, lng;
  final DateTime time;
  const _QuickMark(this.icon, this.type, this.lat, this.lng, this.time);
}

// ═══════════════════════════════════════════════════════════════
// ▼ V6.5 1.7 救援点
// ═══════════════════════════════════════════════════════════════
class _RescuePoint {
  final String name, dist, phone;
  const _RescuePoint(this.name, this.dist, this.phone);
}

// ═══════════════════════════════════════════════════════════════
// ▼ 路线线绘制（保留原有）
// ═══════════════════════════════════════════════════════════════
class _RouteLinePainter extends CustomPainter {
  final Color color;
  final bool dashed;
  _RouteLinePainter(this.color, this.dashed);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

    if (dashed) {
      final w = size.width; final h = size.height;
      double x = 20; double y = h * 0.55;
      const dashLen = 12.0; const gapLen = 8.0; double drawn = 0;
      final path = Path(); path.moveTo(x, y);
      final points = [Offset(x + w * 0.12, y - 40), Offset(x + w * 0.25, y - 80), Offset(x + w * 0.38, y - 50), Offset(x + w * 0.50, y - 30), Offset(x + w * 0.62, y - 20), Offset(x + w * 0.75, y + 10), Offset(x + w * 0.85, y + 20)];
      for (final pt in points) { path.lineTo(pt.dx, pt.dy); }
      var pathMetrics = path.computeMetrics();
      for (final metric in pathMetrics) {
        while (drawn < metric.length) {
          final end = drawn + dashLen;
          canvas.drawPath(metric.extractPath(drawn, end.clamp(0.0, metric.length)), Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round);
          drawn = end + gapLen;
        }
      }
    } else {
      final w = size.width; final h = size.height;
      final path = Path();
      path.moveTo(20, h * 0.55);
      path.cubicTo(20 + w * 0.15, h * 0.45, 20 + w * 0.3, h * 0.25, 20 + w * 0.5, h * 0.35);
      path.cubicTo(20 + w * 0.7, h * 0.45, 20 + w * 0.8, h * 0.55, 20 + w * 0.9, h * 0.65);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}