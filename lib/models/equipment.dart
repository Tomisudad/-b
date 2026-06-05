/// 装备数据模型 — 严格对照 HTML state.equipment[]
/// HTML 结构: {n:名称, i:图标emoji, s:状态('ok'|'attention'|'missing')}
class Equipment {
  /// 装备名称 (n)
  String name;

  /// 图标 emoji (i)
  String icon;

  /// 状态 (s): 'ok' | 'attention' | 'missing'
  String status;

  Equipment({
    required this.name,
    required this.icon,
    this.status = 'ok',
  });

  /// 序列化 — 使用 HTML 原型的短键名
  Map<String, dynamic> toJson() => {
        'n': name,
        'i': icon,
        's': status,
      };

  /// 反序列化 — 兼容旧长键名和新短键名
  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
        name: (json['n'] ?? json['name'] ?? '') as String,
        icon: (json['i'] ?? json['icon'] ?? '🔧') as String,
        status: (json['s'] ?? json['status'] ?? 'ok') as String,
      );

  /// 状态切换循环: ok → attention → missing → ok
  static const List<String> statusCycle = ['ok', 'attention', 'missing'];

  void cycleStatus() {
    final idx = statusCycle.indexOf(status);
    status = statusCycle[(idx + 1) % 3];
  }
}
