import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/scenario_config.dart';
import '../config/app_config.dart';
import '../providers/trip_provider.dart';
import '../services/tracking_service.dart';
import '../services/voice_service.dart';
import '../services/location_service.dart';
import 'track_end_page.dart';

class NavigationPage extends StatefulWidget {
  final OutdoorScenario scenario;
  const NavigationPage({super.key, required this.scenario});

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

  @override
  void initState() {
    super.initState();
    _tracking = TrackingService.instance;
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
    // Complete active trip if exists
    if (prov.activeTrip != null) {
      prov.completeTrip(finalDistanceKm: dist, finalDurationSec: durSec);
    } else {
      // Create & complete for free-recording mode
      prov.createTrip('自由记录', widget.scenario);
      prov.completeTrip(finalDistanceKm: dist, finalDurationSec: durSec);
    }

    final completed = prov.completedTrips.isNotEmpty ? prov.completedTrips.first : null;
    if (completed != null && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => TrackEndPage(trip: completed),
      ));
    } else {
      Navigator.pop(context);
    }
  }

  void _showSOS() {
    final lat = _loc.latitude.toStringAsFixed(5);
    final lng = _loc.longitude.toStringAsFixed(5);
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, "0")}:${now.minute.toString().padLeft(2, "0")}';
    final msg = '【去野SOS紧急求助】\n时间：$timeStr\n坐标：$lat, $lng\n请尽快联系我！';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // ── 出发确认页 ──

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

          // Route preferences
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Wrap(spacing: 10, runSpacing: 8, alignment: WrapAlignment.center, children: [
              FilterChip(
                selected: _avoidTolls,
                onSelected: (v) => setState(() => _avoidTolls = v),
                label: const Text('避开收费'),
                avatar: const Icon(Icons.money_off, size: 18),
                selectedColor: sceneColor.withOpacity(0.1),
                checkmarkColor: sceneColor,
              ),
              FilterChip(
                selected: _preferHighway,
                onSelected: (v) => setState(() => _preferHighway = v),
                label: const Text('优先高速'),
                avatar: const Icon(Icons.speed, size: 18),
                selectedColor: sceneColor.withOpacity(0.1),
                checkmarkColor: sceneColor,
              ),
              FilterChip(
                selected: _scenicRoute,
                onSelected: (v) => setState(() => _scenicRoute = v),
                label: const Text('风景路线'),
                avatar: const Icon(Icons.landscape, size: 18),
                selectedColor: sceneColor.withOpacity(0.1),
                checkmarkColor: sceneColor,
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Text(_routePrefSummary(), style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary)),

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

  // ── 驾驶态 ──

  Widget _buildDrivingUI(Color sceneColor) {
    return ListenableBuilder(
      listenable: _tracking,
      builder: (context, _) {
        final speed = _tracking.avgSpeed;
        final dist = _tracking.currentDistance;
        if (dist > 0) _voice.cycleTip(widget.scenario, dist.toInt());

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(children: [
              // Map background
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFEBF0E6),
                  child: Center(
                    child: Icon(Icons.map_outlined, size: 100,
                      color: const Color(0xFF2E7D32).withOpacity(0.12)),
                  ),
                ),
              ),

              // Top - speed + emotion
              Positioned(top: 16, left: 16, right: 16, child: Column(children: [
                Text('${speed.toInt()}', style: const TextStyle(
                  fontSize: 72, fontWeight: FontWeight.w300,
                  fontFamily: 'SF Pro Display', color: AppConfig.textPrimary, height: 0.9)),
                const Text('km/h', style: TextStyle(fontSize: 14, color: AppConfig.textSecondary)),
                if (_lastEmotion != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sceneColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('心情：$_lastEmotion',
                        style: TextStyle(fontSize: 13, color: sceneColor)),
                    ),
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: sceneColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.arrow_forward, size: 22, color: sceneColor),
                    const SizedBox(width: 8),
                    Text('继续前行 2.3km',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: sceneColor)),
                  ]),
                ),
                const SizedBox(height: 4),
                Text('已骑 ${dist.toStringAsFixed(1)}km',
                  style: const TextStyle(fontSize: 15, color: AppConfig.textSecondary)),
              ])),

              // Bottom button area
              Positioned(bottom: 20, left: 16, right: 16, child: Column(children: [
                if (_showEmotionPicker) _buildEmotionGrid(sceneColor),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _driveCircleBtn(Icons.emoji_emotions, '心情', () => setState(() => _showEmotionPicker = !_showEmotionPicker), sceneColor),
                  _driveCircleBtn(Icons.warning_amber_rounded, 'SOS', _showSOS, AppConfig.sosRed),
                  _driveCircleBtn(Icons.stop_circle, '结束', _endNavigation, sceneColor, primary: true),
                ]),
              ])),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x15000000), blurRadius: 12)],
      ),
      child: Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
        children: emotions.map((e) =>
          GestureDetector(
            onTap: () => _tagEmotion(e.$1, e.$2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: sceneColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${e.$1} ${e.$2}', style: TextStyle(fontSize: 14, color: sceneColor)),
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
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: primary ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 28, color: primary ? Colors.white : color),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cfg = ScenarioConfig.of(widget.scenario);
    final sceneColor = cfg.primaryColor;
    return _started ? _buildDrivingUI(sceneColor) : _buildConfirmationPage(sceneColor, cfg);
  }
}
