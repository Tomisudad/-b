import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gowild_app/providers/app_state.dart';
import 'package:provider/provider.dart';
import 'package:gowild_app/painters/playback_track_painter.dart';
import 'package:gowild_app/painters/playback_chart_painter.dart';

class PlaybackPage extends StatefulWidget {
  final String routeName;
  final String totalDist;
  final String totalTime;
  final String totalClimb;

  const PlaybackPage({
    super.key,
    this.routeName = '成都→都江堰',
    this.totalDist = '68km',
    this.totalTime = '3h24m',
    this.totalClimb = '412m',
  });

  @override
  State<PlaybackPage> createState() => _PlaybackPageState();
}

class _PlaybackPageState extends State<PlaybackPage> {
  double _pos = 0.0; // 0.0 to 1.0
  bool _running = false;
  String _chartType = 'elev'; // 'elev' or 'speed'
  int _speed = 1;
  Timer? _timer;

  static const double _stepPerTick = 0.5 / 204.0; // normalized step per 30ms at 1x
  static const int _totalMinutes = 204; // 3h24m

  String get _formattedTime {
    final totalSec = (_pos * _totalMinutes * 60).round();
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')} / ${_formatShort(_totalMinutes)}';
  }

  String _formatShort(int totalMin) {
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return '$h:${m.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _running = !_running;
      if (_running) {
        _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
          if (!mounted) return;
          setState(() {
            _pos += _stepPerTick * _speed;
            if (_pos >= 1.0) {
              _pos = 1.0;
              _running = false;
              _timer?.cancel();
            }
          });
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _seekFromPosition(double ratio) {
    setState(() {
      _pos = ratio.clamp(0.0, 1.0);
    });
  }

  void _seekSeconds(int seconds) {
    final delta = seconds / (_totalMinutes * 60.0);
    setState(() {
      _pos = (_pos + delta).clamp(0.0, 1.0);
    });
  }

  void _toggleSpeed() {
    const speeds = [1, 2, 4, 8];
    final idx = speeds.indexOf(_speed);
    setState(() {
      _speed = speeds[(idx + 1) % speeds.length];
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('路书回放 · ${widget.routeName}',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('${widget.totalDist} · ${widget.totalTime} · ${widget.totalClimb}爬升',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _timer?.cancel();
                      Provider.of<AppState>(context, listen: false).goBack();
                    },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: const Color(0x1AFFFFFF), shape: BoxShape.circle),
                      child: const Center(child: Text('✕', style: TextStyle(color: Colors.white, fontSize: 16))),
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Column(
                children: [
                  // Track area (7/10)
                  Expanded(
                    flex: 7,
                    child: CustomPaint(
                      painter: PlaybackTrackPainter(playedFraction: _pos, routeName: widget.routeName),
                      child: Container(),
                    ),
                  ),

                  // Chart area (3/10)
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: PlaybackChartPainter(playedFraction: _pos, chartType: _chartType),
                            child: Container(),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 16,
                          child: Row(
                            children: [
                              _chartToggleBtn('高程', 'elev'),
                              const SizedBox(width: 8),
                              _chartToggleBtn('速度', 'speed'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom controls
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                border: const Border(top: BorderSide(color: Color(0x0DFFFFFF))),
              ),
              child: Column(
                children: [
                  // Progress bar
                  _ProgressBar(pos: _pos, onSeek: _seekFromPosition),
                  const SizedBox(height: 10),

                  // Controls row
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(_formattedTime,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
                      ),
                      const Spacer(),
                      _CircleBtn(icon: Icons.replay_10, onTap: () => _seekSeconds(-30)),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          width: 56, height: 56,
                          decoration: const BoxDecoration(color: Color(0xFFF57C00), shape: BoxShape.circle),
                          child: Center(
                            child: Icon(_running ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 32),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _CircleBtn(icon: Icons.forward_30, onTap: () => _seekSeconds(30)),
                      const Spacer(),
                      GestureDetector(
                        onTap: _toggleSpeed,
                        child: SizedBox(
                          width: 40,
                          child: Text('${_speed}x',
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartToggleBtn(String label, String type) {
    final active = _chartType == type;
    return GestureDetector(
      onTap: () => setState(() => _chartType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF57C00) : const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          )),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: const Color(0x1AFFFFFF), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double pos;
  final void Function(double) onSeek;

  const _ProgressBar({required this.pos, required this.onSeek});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (d) => onSeek(d.localPosition.dx / context.size!.width),
      onHorizontalDragUpdate: (d) => onSeek(d.localPosition.dx / context.size!.width),
      child: Container(
        height: 28,
        alignment: Alignment.center,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background track
            Container(
              height: 6,
              decoration: BoxDecoration(color: const Color(0x1AFFFFFF), borderRadius: BorderRadius.circular(3)),
            ),
            // Filled track
            FractionallySizedBox(
              widthFactor: pos,
              child: Container(
                height: 6,
                decoration: const BoxDecoration(color: Color(0xFFF57C00), borderRadius: BorderRadius.horizontal(left: Radius.circular(3))),
              ),
            ),
            // Thumb
            Positioned(
              left: pos * 1.0, // percentage
              top: 0,
              bottom: 0,
              child: Transform.translate(
                offset: const Offset(-8, 0),
                child: const Center(
                  child: SizedBox(
                    width: 16, height: 16,
                    child: Material(color: Colors.white, shape: CircleBorder(), elevation: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
