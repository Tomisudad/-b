import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gowild_app/painters/nav_map_painter.dart';
import 'package:gowild_app/providers/app_state.dart';
import 'package:gowild_app/screens/ride_summary.dart';
import 'package:provider/provider.dart';

class RideNavPage extends StatefulWidget {
  const RideNavPage({super.key});

  @override
  State<RideNavPage> createState() => _RideNavPageState();
}

class _RideNavPageState extends State<RideNavPage> {
  Timer? _timer;
  Timer? _clockTimer;
  String _clock = '';

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 10), (_) => _updateClock());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      state.setRideActive(true);
      state.setRidePaused(false);
      state.updateRideData(RideData());
      _startTimer();
    });
  }

  void _updateClock() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    setState(() => _clock = '$h:$m');
  }

  void _startTimer() {
    _timer?.cancel();
    final rng = Random();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final state = Provider.of<AppState>(context, listen: false);
      if (!state.ridePaused) {
        state.rideData.time += 2;
        state.rideData.dist += 0.015;
        state.rideData.speed = 25 + sin(state.rideData.time / 60) * 5 + (rng.nextDouble() - 0.5) * 3;
        state.rideData.elev += (rng.nextDouble() - 0.3 * 8).round();
        state.rideData.hr = 135 + (sin(state.rideData.time / 30) * 15).round() + (rng.nextDouble() - 0.5 * 10).round();
        if (mounted) setState(() {});
      }
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _togglePause() {
    final state = Provider.of<AppState>(context, listen: false);
    state.setRidePaused(!state.ridePaused);
    setState(() {});
  }

  void _endRide() {
    final state = Provider.of<AppState>(context, listen: false);
    if (state.rideEnding) return;
    state.setRideEnding(true);
    _timer?.cancel();

    final d = state.rideData;
    final totalSec = d.time;
    final h = totalSec ~/ 3600;
    final m = (totalSec % 3600) ~/ 60;
    final s = totalSec % 60;
    final timeStr = h > 0 ? '${h}h${m}m' : '$m分${s}秒';

    // 使用 addRecord 统一处理记录插入和统计更新
    state.addRecord(RideRecord(
      name: state.selectedRoute ?? '自由骑行',
      date: '今天',
      distance: '${d.dist.toStringAsFixed(1)}km',
      time: timeStr,
      climb: '${d.elev}m',
      speed: d.speed.toStringAsFixed(1),
    ));
    state.setSelectedRoute(null);
    state.setRideActive(false);

    if (mounted) {
      showRideSummaryModal(context, record: state.records.first);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final d = state.rideData;
        final routeName = state.selectedRoute ?? '自由骑行';

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: SafeArea(
            child: Column(
              children: [
                // Top bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  color: Colors.black.withValues(alpha: 0.4),
                  child: Row(
                    children: [
                      const Icon(Icons.pedal_bike, color: Color(0xFFF57C00), size: 20),
                      const SizedBox(width: 10),
                      Text(routeName, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text(_clock, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _endRide,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.2), shape: BoxShape.circle),
                          child: const Center(child: Text('✕', style: TextStyle(color: Color(0xFFF87171), fontSize: 18))),
                        ),
                      ),
                    ],
                  ),
                ),

                // Map area
                Expanded(
                  child: Stack(
                    children: [
                      // Canvas map
                      Positioned.fill(
                        child: CustomPaint(
                          painter: NavMapPainter(),
                          child: Container(),
                        ),
                      ),
                      // Pulse dot
                      const Center(
                        child: _PulseDot(),
                      ),
                      // Right floating buttons
                      Positioned(
                        right: 16,
                        top: 0,
                        bottom: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _FloatingBtn(icon: Icons.camera_alt, onTap: () => _toast('标记已保存')),
                            const SizedBox(height: 16),
                            _FloatingBtn(icon: Icons.location_on, onTap: () => _toast('途经点已添加')),
                            const SizedBox(height: 16),
                            _FloatingBtn(icon: Icons.warning_amber, color: Colors.red.withValues(alpha: 0.4), iconColor: const Color(0xFFFCA5A5), onTap: () => _toast('求救信号已发送')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom data panel
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    border: const Border(top: BorderSide(color: Color(0x0DFFFFFF))),
                  ),
                  child: Column(
                    children: [
                      // Speed
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(d.speed.toStringAsFixed(1), style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w100, color: Color(0xFFF57C00))),
                            const SizedBox(width: 8),
                            Text('km/h', style: TextStyle(fontSize: 18, color: Colors.white.withValues(alpha: 0.5))),
                          ],
                        ),
                      ),

                      // 4-grid data
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _DataCell(value: d.dist.toStringAsFixed(1), label: 'km'),
                            _DataCell(value: _formatTime(d.time), label: '时间'),
                            _DataCell(value: d.elev.toString(), label: '爬升m'),
                            _DataCell(value: d.hr.toString(), label: '心率'),
                          ],
                        ),
                      ),

                      // Control bar
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _CtrlBtn(icon: Icons.build, onTap: () => _toast('维修手册')),
                            const SizedBox(width: 24),
                            GestureDetector(
                              onTap: _togglePause,
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(color: Color(0xFFF57C00), shape: BoxShape.circle),
                                child: Center(
                                  child: Icon(state.ridePaused ? Icons.play_arrow : Icons.pause, color: Colors.white, size: 32),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            _CtrlBtn(icon: Icons.mic, onTap: () => _toast('语音记录')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center),
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.only(bottom: 120, left: 60, right: 60),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..repeat(reverse: false);
    _scale = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = (1.0 - (_controller.value < 0.5 ? _controller.value * 2 : 2.0 - _controller.value * 2)).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFF57C00),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFFF57C00).withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 2)],
            ),
          ),
        );
      },
    );
  }
}

class _FloatingBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _FloatingBtn({required this.icon, this.color = const Color(0x1AFFFFFF), this.iconColor = const Color(0xCCFFFFFF), required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String value;
  final String label;

  const _DataCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.5))),
      ],
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CtrlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: const Color(0x1AFFFFFF), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}