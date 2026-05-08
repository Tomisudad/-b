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

/// V5.5 导航页 — 全屏地图 + 轨迹记录 + 临时改道
class NavigationPage extends StatefulWidget {
  final OutdoorScenario scenario;
  final String? routeName;
  const NavigationPage({super.key, required this.scenario, this.routeName});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  late final TrackingService _tracking;
  final _loc = LocationService.instance;
  final _voice = VoiceService.instance;
  bool _started = false;
  bool _showEmotionPicker = false;
  String? _lastEmotion;
  bool _avoidTolls = false;
  bool _preferHighway = true;
  bool _scenicRoute = false;

  // V5.5 临时改道状态
  bool _rerouted = false;
  double _newDistanceKm = 0;
  double _originalDistanceKm = 45.0; // mock
  String? _rerouteMessage;
  Timer? _rerouteTipTimer;

  // 改道记录
  final List<RerouteAction> _rerouteLog = [];

  @override
  void initState() {
    super.initState();
    _tracking = TrackingService.instance;
    if (!_tracking.isTracking) {
      _tracking.startTracking(widget.scenario);
    }
    _started = true;
  }

  @override
  void dispose() {
    _rerouteTipTimer?.cancel();
    super.dispose();
  }

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

  // ============================================================
  // V5.5 SOS
  // ============================================================
  void _showSOS() {
    final lat = _loc.latitude.toStringAsFixed(5);
    final lng = _loc.longitude.toStringAsFixed(5);
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, "0")}:${now.minute.toString().padLeft(2, "0")}';
    final msg = '【去野SOS紧急求助】\n时间：$timeStr\n坐标：$lat, $lng\n请尽快联系我！';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.dialogRadius)),
        title: Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppConfig.sosRed),
          const SizedBox(width: 8),
          const Text('紧急求助', style: TextStyle(fontSize: 18)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConfig.bgMain,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(msg, style: const TextStyle(fontSize: 13, height: 1.6)),
          ),
        ]),
        actions: [
          OutlinedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: msg));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('已复制，可粘贴到微信/SMS发送'),
                  backgroundColor: AppConfig.sosRed),
              );
            },
            child: const Text('复制并分享'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _tagEmotion(String emoji, String label) {
    setState(() {
      _lastEmotion = label;
      _showEmotionPicker = false;
    });
    _tracking.tagEmotion(emoji, label);
  }

  // ============================================================
  // V5.5 临时改道入口
  // ============================================================
  void _showMapLongPress() {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                const Text('地图操作', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
                const SizedBox(height: 16),
                _rerouteOption('📍', '添加途经点', '插入到当前导航序列，重新规划路线', AppConfig.cyclePrimary, () {
                  Navigator.pop(context);
                  _addWaypoint();
                }),
                const SizedBox(height: 8),
                _rerouteOption('🚩', '直接导航去这里', '变更终点，丢弃剩余途经点，原路线保留', AppConfig.motoPrimary, () {
                  Navigator.pop(context);
                  _changeDestination();
                }),
                const SizedBox(height: 8),
                _rerouteOption('📝', '标记此处', '仅标记，不改路线', AppConfig.drivePrimary, () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📍 位置已标记'), duration: Duration(seconds: 1)),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWaypointActions(int index) {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text('途经点 ${index + 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
                const SizedBox(height: 16),
                _rerouteOption('✏️', '编辑备注', '修改途经点名称', AppConfig.textPrimary, () {
                  Navigator.pop(context);
                }),
                const SizedBox(height: 8),
                _rerouteOption('🔇', '跳过此点', '本次导航绕开，可恢复', AppConfig.motoPrimary, () {
                  Navigator.pop(context);
                  _skipWaypoint(index);
                }),
                const SizedBox(height: 8),
                _rerouteOption('❌', '删除此点', '从本次导航移除', AppConfig.sosRed, () {
                  Navigator.pop(context);
                  _deleteWaypoint(index);
                }),
                const SizedBox(height: 8),
                _rerouteOption('📍', '设为终点', '提前结束，后续途经点移除', AppConfig.drivePrimary, () {
                  Navigator.pop(context);
                  _setAsDestination(index);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rerouteOption(String emoji, String title, String desc, Color color, VoidCallback onTap) {
    return Material(
      color: AppConfig.bgMain,
      borderRadius: BorderRadius.circular(AppConfig.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
              Text(desc, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
            ])),
            const Icon(Icons.chevron_right, size: 18, color: AppConfig.textSecondary),
          ]),
        ),
      ),
    );
  }

  void _addWaypoint() {
    final rng = Random();
    final newDist = _originalDistanceKm + 3.0 + rng.nextDouble() * 10;
    _applyReroute('添加途经点', newDist);
  }

  void _changeDestination() {
    final diff = Random().nextDouble() * 15 + 2;
    if (diff > 10) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.dialogRadius)),
          title: const Text('路线变更确认', style: TextStyle(fontWeight: FontWeight.w700)),
          content: Text('新路线与原计划差异较大（${diff.toStringAsFixed(1)}km），确认更改？'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            TextButton(
              onPressed: () { Navigator.pop(ctx); _applyReroute('变更终点', _originalDistanceKm - 5 - Random().nextDouble() * 10); },
              child: const Text('确认更改', style: TextStyle(color: AppConfig.motoPrimary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    } else {
      _applyReroute('变更终点', _originalDistanceKm - 5 - Random().nextDouble() * 10);
    }
  }

  void _skipWaypoint(int i) {
    _applyReroute('跳过途经点 ${i + 1}', _originalDistanceKm - 4);
  }

  void _deleteWaypoint(int i) {
    _applyReroute('删除途经点 ${i + 1}', _originalDistanceKm - 2);
  }

  void _setAsDestination(int i) {
    _applyReroute('提前设为终点(途经点${i + 1})', _originalDistanceKm * 0.5);
  }

  void _applyReroute(String action, double newDist) {
    setState(() {
      _rerouted = true;
      _newDistanceKm = newDist.abs();
      _rerouteMessage = '路线已调整：新距离 ${_newDistanceKm.toStringAsFixed(1)} km（原 ${_originalDistanceKm.toStringAsFixed(1)} km）';
      _rerouteLog.add(RerouteAction(action, _newDistanceKm, _originalDistanceKm));
    });

    // 3秒后清除提示
    _rerouteTipTimer?.cancel();
    _rerouteTipTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _rerouteMessage = null);
    });
  }

  void _restoreOriginalRoute() {
    setState(() {
      _rerouted = false;
      _newDistanceKm = 0;
      _rerouteMessage = '已恢复原路线';
      _rerouteLog.add(RerouteAction('恢复原路线', _originalDistanceKm, _newDistanceKm));
    });
    _rerouteTipTimer?.cancel();
    _rerouteTipTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _rerouteMessage = null);
    });
  }

  // ============================================================
  // V5.5 驾驶态 UI
  // ============================================================
  Widget _buildDrivingUI(Color sceneColor) {
    return ListenableBuilder(
      listenable: _tracking,
      builder: (context, _) {
        final speed = _tracking.avgSpeed;
        final dist = _tracking.currentDistance;
        if (dist > 0) _voice.cycleTip(widget.scenario, dist.toInt());

        return Scaffold(
          backgroundColor: Colors.black87,
          body: SafeArea(
            child: Stack(children: [
              // 地图区域（可长按）
              Positioned.fill(
                child: GestureDetector(
                  onLongPress: _showMapLongPress,
                  child: Container(
                    color: const Color(0xFF1A2A1E),
                    child: Stack(
                      children: [
                        // 原路线灰色虚线（改道时）
                        if (_rerouted)
                          CustomPaint(
                            size: Size.infinite,
                            painter: _RouteLinePainter(AppConfig.textSecondary.withOpacity(0.3), true),
                          ),
                        // 当前路线实线
                        CustomPaint(
                          size: Size.infinite,
                          painter: _RouteLinePainter(
                            _rerouted ? AppConfig.drivePrimary : sceneColor,
                            false,
                          ),
                        ),
                        // 途经点标记
                        ...List.generate(4, (i) {
                          final left = 20.0 + i * 80.0 + 20;
                          final top = 50.0 + (i % 2 == 0 ? 60.0 : 120.0);
                          return Positioned(
                            left: left, top: top,
                            child: GestureDetector(
                              onTap: () => _showWaypointActions(i),
                              child: Container(
                                width: 24, height: 24,
                                decoration: BoxDecoration(
                                  color: i < (_rerouted ? 2 : 4) ? sceneColor : AppConfig.textSecondary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Center(
                                  child: Text('${i + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                                ),
                              ),
                            ),
                          );
                        }),
                        // 当前位置
                        Positioned(
                          left: 160, top: 160,
                          child: Container(
                            width: 16, height: 16,
                            decoration: BoxDecoration(
                              color: AppConfig.goldStart,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: AppConfig.goldStart.withOpacity(0.4), blurRadius: 8)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 改道提示条
              if (_rerouteMessage != null)
                Positioned(
                  top: 8, left: 16, right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppConfig.cardBg,
                      borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                      boxShadow: AppConfig.cardShadow,
                    ),
                    child: Row(children: [
                      Expanded(child: Text(_rerouteMessage!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textPrimary))),
                    ]),
                  ),
                ),

              // 恢复原路线按钮
              if (_rerouted)
                Positioned(
                  top: _rerouteMessage != null ? 70 : 8, right: 16,
                  child: GestureDetector(
                    onTap: _restoreOriginalRoute,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppConfig.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppConfig.cardShadow,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.restore, size: 16, color: AppConfig.drivePrimary),
                          SizedBox(width: 4),
                          Text('恢复原路线', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConfig.drivePrimary)),
                        ],
                      ),
                    ),
                  ),
                ),

              // 速度面板
              Positioned(
                top: 16, left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppConfig.cardBg.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text('${speed.toInt()}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: AppConfig.textPrimary, height: 0.9)),
                          const Text('km/h', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                        ],
                      ),
                    ),
                    if (_lastEmotion != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: sceneColor.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text('$_lastEmotion', style: const TextStyle(fontSize: 13, color: Colors.white)),
                      ),
                    ],
                  ],
                ),
              ),

              // 底部距离 & 转向
              Positioned(
                bottom: _rerouted ? 60 : 36, left: 0, right: 0,
                child: Column(children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sceneColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.arrow_forward, size: 22, color: sceneColor),
                      const SizedBox(width: 8),
                      Text(
                        '继续前行 ${(2.5 + dist % 5).toStringAsFixed(1)}km',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: sceneColor),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '已行 ${dist.toStringAsFixed(1)}km${_rerouted ? " · 改道中" : ""}',
                    style: const TextStyle(fontSize: 14, color: AppConfig.textSecondary),
                  ),
                ]),
              ),

              // 底部操作栏
              Positioned(
                bottom: 8, left: 12, right: 12,
                child: Column(children: [
                  if (_showEmotionPicker) _buildEmotionGrid(sceneColor),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    _driveCircleBtn(Icons.emoji_emotions, '心情', () => setState(() => _showEmotionPicker = !_showEmotionPicker), sceneColor),
                    _driveCircleBtn(Icons.warning_amber_rounded, 'SOS', _showSOS, AppConfig.sosRed),
                    _driveCircleBtn(Icons.stop_circle, '结束', _endNavigation, sceneColor, primary: true),
                  ]),
                ]),
              ),

              // 长按提示
              Positioned(
                bottom: _showEmotionPicker ? 140 : 76, left: 0, right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('长按地图 | 改道/标记', style: TextStyle(fontSize: 11, color: Colors.white70)),
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildEmotionGrid(Color sceneColor) {
    const emotions = [
      ('😌', '平静'), ('🥹', '感动'), ('😤', '疲惫'),
      ('🤯', '震撼'), ('🧘', '顿悟'), ('😊', '开心'),
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x15000000), blurRadius: 12)],
      ),
      child: Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center,
        children: emotions.map((e) =>
          GestureDetector(
            onTap: () => _tagEmotion(e.$1, e.$2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: sceneColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${e.$1} ${e.$2}', style: TextStyle(fontSize: 13, color: sceneColor)),
            ),
          ),
        ).toList()),
    );
  }

  Widget _driveCircleBtn(IconData icon, String label, VoidCallback onTap, Color color, {bool primary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: primary ? color : color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 24, color: primary ? Colors.white : color),
        ),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 10, color: color)),
      ]),
    );
  }

  // ── 出发确认页（首次进入）──
  Widget _buildConfirmationPage(Color sceneColor, ScenarioConfig cfg) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      body: SafeArea(
        child: Column(children: [
          const Spacer(),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: sceneColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.navigation, size: 40, color: sceneColor),
          ),
          const SizedBox(height: 16),
          Text(cfg.label, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: sceneColor)),
          const SizedBox(height: 8),
          const Text('准备出发', style: TextStyle(fontSize: 16, color: AppConfig.textSecondary)),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Wrap(spacing: 10, runSpacing: 8, alignment: WrapAlignment.center, children: [
              FilterChip(
                selected: _avoidTolls, onSelected: (v) => setState(() => _avoidTolls = v),
                label: const Text('避开收费'), avatar: const Icon(Icons.money_off, size: 18),
                selectedColor: sceneColor.withOpacity(0.1), checkmarkColor: sceneColor,
              ),
              FilterChip(
                selected: _preferHighway, onSelected: (v) => setState(() => _preferHighway = v),
                label: const Text('优先高速'), avatar: const Icon(Icons.speed, size: 18),
                selectedColor: sceneColor.withOpacity(0.1), checkmarkColor: sceneColor,
              ),
              FilterChip(
                selected: _scenicRoute, onSelected: (v) => setState(() => _scenicRoute = v),
                label: const Text('风景路线'), avatar: const Icon(Icons.landscape, size: 18),
                selectedColor: sceneColor.withOpacity(0.1), checkmarkColor: sceneColor,
              ),
            ]),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _startNavigation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: sceneColor, foregroundColor: Colors.white, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('开始导航', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(height: 48),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cfg = ScenarioConfig.of(widget.scenario);
    final sceneColor = cfg.primaryColor;
    return _started ? _buildDrivingUI(sceneColor) : _buildConfirmationPage(sceneColor, cfg);
  }
}

// ============================================================
// 路线线绘制
// ============================================================
class _RouteLinePainter extends CustomPainter {
  final Color color;
  final bool dashed;
  _RouteLinePainter(this.color, this.dashed);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (dashed) {
      final w = size.width;
      final h = size.height;
      double x = 20;
      double y = h * 0.55;
      const dashLen = 12.0;
      const gapLen = 8.0;
      double drawn = 0;

      final path = Path();
      path.moveTo(x, y);
      // simulates a zigzag road
      final points = [
        Offset(x + w * 0.12, y - 40),
        Offset(x + w * 0.25, y - 80),
        Offset(x + w * 0.38, y - 50),
        Offset(x + w * 0.50, y - 30),
        Offset(x + w * 0.62, y - 20),
        Offset(x + w * 0.75, y + 10),
        Offset(x + w * 0.85, y + 20),
      ];
      for (final pt in points) {
        path.lineTo(pt.dx, pt.dy);
      }
      var pathMetrics = path.computeMetrics();
      for (final metric in pathMetrics) {
        while (drawn < metric.length) {
          final end = drawn + dashLen;
          canvas.drawPath(
            metric.extractPath(drawn, end.clamp(0.0, metric.length)),
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5
              ..strokeCap = StrokeCap.round,
          );
          drawn = end + gapLen;
        }
      }
    } else {
      final w = size.width;
      final h = size.height;
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

// ============================================================
// 改道记录
// ============================================================

