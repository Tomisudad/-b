/// 路线数据模型 — 严格对照 HTML state.routes[]
/// HTML 结构: {n:路线名, d:距离, t:时间, e:爬升, diff:难度, waypoints:[{name}]}
class RouteModel {
  /// 路线名称 (n)
  final String name;

  /// 距离 (d) — 如 '68km'
  final String distance;

  /// 预估时间 (t) — 如 '3.5h'
  final String time;

  /// 爬升 (e) — 如 '412m'
  final String elevation;

  /// 难度 (diff) — '休闲' | '中级' | '挑战'
  final String difficulty;

  /// 途经点 — [{name: String}]
  final List<Waypoint> waypoints;

  RouteModel({
    required this.name,
    required this.distance,
    required this.time,
    required this.elevation,
    required this.difficulty,
    this.waypoints = const [],
  });

  Map<String, dynamic> toJson() => {
        'n': name,
        'd': distance,
        't': time,
        'e': elevation,
        'diff': difficulty,
        'waypoints': waypoints.map((w) => w.toJson()).toList(),
      };

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final wps = json['waypoints'];
    List<Waypoint> waypoints = [];
    if (wps is List) {
      waypoints = wps.map((w) => Waypoint.fromJson(w as Map<String, dynamic>)).toList();
    }
    return RouteModel(
      name: (json['n'] ?? json['name'] ?? '') as String,
      distance: (json['d'] ?? json['distance'] ?? '') as String,
      time: (json['t'] ?? json['time'] ?? '') as String,
      elevation: (json['e'] ?? json['elevation'] ?? '') as String,
      difficulty: (json['diff'] ?? json['difficulty'] ?? '休闲') as String,
      waypoints: waypoints,
    );
  }

  /// 途经点数量
  int get waypointCount => waypoints.length;
}

/// 途经点
class Waypoint {
  final String name;
  const Waypoint({required this.name});

  Map<String, dynamic> toJson() => {'name': name};
  factory Waypoint.fromJson(Map<String, dynamic> json) =>
      Waypoint(name: (json['name'] ?? '') as String);
}
