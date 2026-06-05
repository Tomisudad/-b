import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/equipment.dart';
import '../models/route_model.dart';
import '../models/ride_record.dart';

// ── 子页面描述 ───────────────────────────────────────────────
class SubPage {
  final String title;
  final String key;
  const SubPage({required this.title, required this.key});
}

// ── 骑行实时数据 ─────────────────────────────────────────────
class RideData {
  double speed; // km/h
  double dist;   // km
  int time;      // 秒
  int elev;       // 米
  int hr;         // bpm

  RideData({
    this.speed = 28.5,
    this.dist = 12.4,
    this.time = 1560,
    this.elev = 320,
    this.hr = 142,
  });

  Map<String, dynamic> toJson() => {
        'speed': speed,
        'dist': dist,
        'time': time,
        'elev': elev,
        'hr': hr,
      };

  factory RideData.fromJson(Map<String, dynamic> json) => RideData(
        speed: (json['speed'] ?? 28.5).toDouble(),
        dist: (json['dist'] ?? 12.4).toDouble(),
        time: json['time'] ?? 1560,
        elev: json['elev'] ?? 320,
        hr: json['hr'] ?? 142,
      );
}

// ── 路书回放状态 ───────────────────────────────────────────
class PbState {
  double pos;        // 回放进度 0~204
  bool running;
  String chartType;  // 'elev' | 'speed'
  int speed;          // 1 | 2 | 4 | 8

  PbState({
    this.pos = 0,
    this.running = false,
    this.chartType = 'elev',
    this.speed = 1,
  });

  Map<String, dynamic> toJson() => {
        'pos': pos,
        'running': running,
        'chartType': chartType,
        'speed': speed,
      };

  factory PbState.fromJson(Map<String, dynamic> json) => PbState(
        pos: (json['pos'] ?? 0).toDouble(),
        running: json['running'] ?? false,
        chartType: json['chartType'] ?? 'elev',
        speed: json['speed'] ?? 1,
      );
}

// ── 全局状态管理 ─────────────────────────────────────────────
class AppState extends ChangeNotifier {
  // ── 导航 ───────────────────────────────────────────────────
  int _activeTab = 0;
  SubPage? _subPage;
  String? _selectedRoute;

  // ── 骑行中状态（不持久化）───────────────────────────────
  bool _rideActive = false;
  bool _ridePaused = false;
  bool _rideEnding = false;
  RideData _rideData = RideData();

  // ── 路书回放状态（不持久化）────────────────────────────
  PbState _pbState = PbState();

  // ── 列表数据 ──────────────────────────────────────────────
  List<Equipment> _equipment = [];
  List<RouteModel> _routes = [];
  List<RideRecord> _records = [];

  // ── 统计数据 ──────────────────────────────────────────────
  int _totalKm = 1240;
  int _totalRides = 48;

  // ── 引导 ──────────────────────────────────────────────────
  bool _guideShown = false;

  // ── Getters ───────────────────────────────────────────────
  int get activeTab => _activeTab;
  SubPage? get subPage => _subPage;
  String? get selectedRoute => _selectedRoute;

  bool get rideActive => _rideActive;
  bool get ridePaused => _ridePaused;
  bool get rideEnding => _rideEnding;
  RideData get rideData => _rideData;

  PbState get pbState => _pbState;

  List<Equipment> get equipment => _equipment;
  List<RouteModel> get routes => _routes;
  List<RideRecord> get records => _records;

  int get totalKm => _totalKm;
  int get totalRides => _totalRides;

  bool get guideShown => _guideShown;
  int get equipmentIssues =>
      _equipment.where((e) => e.status != 'ok').length;

  bool get isLoading => false; // 初始化完成后始终 false

  // ── 构造 & 初始化 ───────────────────────────────────────
  AppState() {
    _loadFromStorage();
  }

  /// 切换底部 Tab（同时清空子页面、重置滑块）
  void switchTab(int tab) {
    _activeTab = tab;
    _subPage = null;
    notifyListeners();
  }

  /// 进入子页面
  void openSub(String title, String key) {
    _subPage = SubPage(title: title, key: key);
    notifyListeners();
  }

  /// 返回首页/列表
  void goBack() {
    _subPage = null;
    notifyListeners();
  }

  // ── 路线 ──────────────────────────────────────────────────
  void setSelectedRoute(String? route) {
    _selectedRoute = route;
    _saveToStorage();
    notifyListeners();
  }

  void addRoute(RouteModel route) {
    _routes.add(route);
    _saveToStorage();
    notifyListeners();
  }

  // ── 装备 ──────────────────────────────────────────────────
  void cycleEquipStatus(int index) {
    if (index < 0 || index >= _equipment.length) return;
    _equipment[index].cycleStatus();
    _saveToStorage();
    notifyListeners();
  }

  /// 别名 — 供 EquipmentPage 使用
  void cycleEquipmentStatus(int index) => cycleEquipStatus(index);

  void addEquipment(Equipment equip) {
    _equipment.add(equip);
    _saveToStorage();
    notifyListeners();
  }

  /// 便捷添加方法 — 供 EquipmentPage 底部面板使用
  void addEquip({required String name, required String icon, String status = 'ok'}) {
    _equipment.add(Equipment(name: name, icon: icon, status: status));
    _saveToStorage();
    notifyListeners();
  }

  /// 刷新出发面板（装备状态变更后调用）
  void refreshDepartPanel() {
    notifyListeners();
  }

  void removeEquipment(int index) {
    if (index < 0 || index >= _equipment.length) return;
    _equipment.removeAt(index);
    _saveToStorage();
    notifyListeners();
  }

  /// 选择已有路线出发（快速出发）
  void quickDepart(String routeName) {
    _selectedRoute = routeName;
    notifyListeners();
  }

  // ── 骑行控制 ──────────────────────────────────────────────
  void startRide() {
    _rideActive = true;
    _ridePaused = false;
    _rideEnding = false;
    _rideData = RideData();
    notifyListeners();
  }

  void setRideActive(bool v) {
    _rideActive = v;
    if (!v) _rideEnding = false; // 退出时重置 ending 状态
    notifyListeners();
  }

  void setRidePaused(bool v) {
    _ridePaused = v;
    notifyListeners();
  }

  void setRideEnding(bool v) {
    _rideEnding = v;
    notifyListeners();
  }

  void updateRideData(RideData data) {
    _rideData = data;
    notifyListeners();
  }

  // ── 路书回放 ─────────────────────────────────────────────
  void setPbState(PbState s) {
    _pbState = s;
    notifyListeners();
  }

  // ── 记录 ──────────────────────────────────────────────────
  void addRecord(RideRecord record) {
    _records.insert(0, record);
    final km = double.tryParse(
            record.distance.replaceAll(RegExp(r'[^0-9.]'), '')) ??
        0;
    _totalKm += km.round();
    _totalRides++;
    _saveToStorage();
    notifyListeners();
  }

  // ── 引导 ──────────────────────────────────────────────────
  Future<void> setGuideShown(bool v) async {
    _guideShown = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('guide_shown', v);
    notifyListeners();
  }

  // ── 持久化 ────────────────────────────────────────────────
  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // 装备
    final equipData = prefs.getString('equipment');
    if (equipData != null) {
      final list = jsonDecode(equipData) as List;
      _equipment = list.map((e) => Equipment.fromJson(e)).toList();
    } else {
      _equipment = _defaultEquipment();
    }

    // 路线
    final routeData = prefs.getString('routes');
    if (routeData != null) {
      final list = jsonDecode(routeData) as List;
      _routes = list.map((r) => RouteModel.fromJson(r)).toList();
    } else {
      _routes = _defaultRoutes();
    }

    // 记录
    final recordData = prefs.getString('records');
    if (recordData != null) {
      final list = jsonDecode(recordData) as List;
      _records = list.map((r) => RideRecord.fromJson(r)).toList();
    } else {
      _records = _defaultRecords();
    }

    _totalKm = prefs.getInt('totalKm') ?? _totalKm;
    _totalRides = prefs.getInt('totalRides') ?? _totalRides;
    _guideShown = prefs.getBool('guide_shown') ?? false;

    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'equipment', jsonEncode(_equipment.map((e) => e.toJson()).toList()));
    prefs.setString(
        'routes',
        jsonEncode(_routes
            .map((r) => r.toJson())
            .toList()));
    prefs.setString(
        'records',
        jsonEncode(_records.map((r) => r.toJson()).toList()));
    prefs.setInt('totalKm', _totalKm);
    prefs.setInt('totalRides', _totalRides);
  }

  // ── HTML 原型默认数据 ─────────────────────────────────────
  List<Equipment> _defaultEquipment() => [
        Equipment(name: '头盔', icon: '\u26D1\uFE0F', status: 'ok'),
        Equipment(name: '手套', icon: '\uD83E\uDDE4', status: 'ok'),
        Equipment(name: '水壶', icon: '\uD83E\uDED7', status: 'missing'),
        Equipment(name: '内胎×2', icon: '\uD83E\uDEDE', status: 'ok'),
        Equipment(name: '打气筒', icon: '\uD83D\uDD27', status: 'ok'),
        Equipment(name: '能量胶', icon: '\uD83C\uDF6C', status: 'attention'),
      ];

  List<RouteModel> _defaultRoutes() => [
        RouteModel(
          name: '成都→都江堰',
          distance: '68km',
          time: '3.5h',
          elevation: '412m',
          difficulty: '中级',
          waypoints: [
            Waypoint(name: '成都'),
            Waypoint(name: '郫都'),
            Waypoint(name: '安德'),
            Waypoint(name: '都江堰'),
          ],
        ),
        RouteModel(
          name: '蒲虹路爬坡',
          distance: '26km',
          time: '2h',
          elevation: '800m',
          difficulty: '挑战',
          waypoints: [
            Waypoint(name: '山脚'),
            Waypoint(name: '发夹弯'),
            Waypoint(name: '山顶'),
          ],
        ),
        RouteModel(
          name: '锦城绿道',
          distance: '42km',
          time: '2h',
          elevation: '120m',
          difficulty: '休闲',
          waypoints: [
            Waypoint(name: '起点'),
            Waypoint(name: '彩虹桥'),
            Waypoint(name: '终点'),
          ],
        ),
      ];

  List<RideRecord> _defaultRecords() => [
        RideRecord(
            name: '成都→都江堰',
            date: '5/28',
            distance: '68km',
            time: '3h24m',
            climb: '412m',
            speed: '20.0'),
        RideRecord(
            name: '蒲虹路爬坡',
            date: '5/25',
            distance: '26km',
            time: '1h52m',
            climb: '800m',
            speed: '13.9'),
        RideRecord(
            name: '锦城绿道',
            date: '5/22',
            distance: '42km',
            time: '2h08m',
            climb: '120m',
            speed: '19.7'),
      ];
}
