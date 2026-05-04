import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../models/route_model.dart';
import '../config/scenario_config.dart';

/// 轨迹记录服务
class TrackingService extends ChangeNotifier {
  static final TrackingService instance = TrackingService._();

  TrackingService._();

  bool _isTracking = false;
  RouteModel? _currentRoute;
  double _currentDistance = 0;
  double _avgSpeed = 0;
  double _maxSpeed = 0;
  final List<TrackPoint> _points = [];
  Timer? _simTimer;

  bool get isTracking => _isTracking;

  RouteModel? get currentRoute => _currentRoute;

  double get currentDistance => _currentDistance;

  double get avgSpeed => _avgSpeed;

  double get maxSpeed => _maxSpeed;

  List<TrackPoint> get points => List.unmodifiable(_points);

  /// 开始模拟记录
  void startTracking(OutdoorScenario scenario) {
    _isTracking = true;
    _currentDistance = 0;
    _avgSpeed = 0;
    _maxSpeed = 0;
    _points.clear();
    _currentRoute = RouteModel(
      id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
      name: '新的${ScenarioConfig.of(scenario).label}之旅',
      scenario: scenario,
      startTime: DateTime.now(),
    );
    // 模拟每秒更新
    _simTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isTracking) return;
      final d = Random().nextDouble() * 0.02; // 每帧约 0.02km 增量
      _currentDistance += d;
      final s = 30 + Random().nextDouble() * 20;
      _avgSpeed = s;
      if (s > _maxSpeed) _maxSpeed = s;
      _points.add(TrackPoint(
        latitude: 30.27 + Random().nextDouble() * 0.01,
        longitude: 120.0 + Random().nextDouble() * 0.01,
        timestamp: DateTime.now(),
        speed: s,
      ));
      notifyListeners();
    });
    notifyListeners();
  }

  /// 停止记录
  void stopTracking() {
    _isTracking = false;
    _simTimer?.cancel();
    _simTimer = null;
    _currentRoute = _currentRoute != null
        ? RouteModel(
            id: _currentRoute!.id,
            name: _currentRoute!.name,
            scenario: _currentRoute!.scenario,
            distanceKm: _currentDistance,
            durationMinutes: (DateTime.now().difference(_currentRoute!.startTime).inSeconds / 60).round(),
            startTime: _currentRoute!.startTime,
            endTime: DateTime.now(),
          )
        : null;
    notifyListeners();
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    super.dispose();
  }
}

/// 轨迹点
class TrackPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double speed;

  const TrackPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.speed,
  });
}
