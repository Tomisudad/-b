/// 骑行记录数据模型 — 严格对照 HTML state.records[]
/// HTML 结构: {n:路线名, d:日期, s:距离, t:时间, c:爬升, v:均速}
class RideRecord {
  /// 路线名 (n)
  final String name;

  /// 日期 (d) — 如 '5/28' 或 '今天'
  final String date;

  /// 距离 (s) — 如 '68km'
  final String distance;

  /// 用时 (t) — 如 '3h24m'
  final String time;

  /// 爬升 (c) — 如 '412m'
  final String climb;

  /// 均速 (v) — 如 '20.0' (km/h)
  final String speed;

  RideRecord({
    required this.name,
    required this.date,
    required this.distance,
    required this.time,
    required this.climb,
    required this.speed,
  });

  /// 序列化 — 短键名
  Map<String, dynamic> toJson() => {
        'n': name,
        'd': date,
        's': distance,
        't': time,
        'c': climb,
        'v': speed,
      };

  /// 反序列化 — 兼容旧长键
  factory RideRecord.fromJson(Map<String, dynamic> json) => RideRecord(
        name: (json['n'] ?? json['name'] ?? '') as String,
        date: (json['d'] ?? json['date'] ?? '') as String,
        distance: (json['s'] ?? json['distance'] ?? '') as String,
        time: (json['t'] ?? json['time'] ?? '') as String,
        climb: (json['c'] ?? json['climb'] ?? '') as String,
        speed: (json['v'] ?? json['speed'] ?? '') as String,
      );
}
