import 'package:flutter/material.dart';

/// 位置服务（模拟）
class LocationService extends ChangeNotifier {
  static final LocationService instance = LocationService._();
  LocationService._();

  double _latitude = 30.2741;
  double _longitude = 120.1552;
  double _altitude = 45.0;
  double _heading = 0.0; // 方向角

  double get latitude => _latitude;
  double get longitude => _longitude;
  double get altitude => _altitude;
  double get heading => _heading;

  /// 请求定位权限（模拟）
  Future<bool> requestPermission() async {
    return true;
  }

  /// 是否有权限
  bool get hasPermission => true;
}
