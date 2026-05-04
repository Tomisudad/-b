import 'scenario.dart';

class RouteModel {
  final String id;
  final String name;
  final String? coverUrl;
  final OutdoorScenario scenario;
  final int difficulty; // 1-5
  final double distanceKm;
  final int durationMinutes;
  final int totalClimb;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> tags;
  final String? moodTag;
  final String? personalNote;
  final String? associatedMusic;
  final String? associatedBook;
  final List<String> photoUrls;

  RouteModel({
    required this.id,
    required this.name,
    this.coverUrl,
    required this.scenario,
    this.difficulty = 1,
    this.distanceKm = 0,
    this.durationMinutes = 0,
    this.totalClimb = 0,
    DateTime? startTime,
    this.endTime,
    this.tags = const [],
    this.moodTag,
    this.personalNote,
    this.associatedMusic,
    this.associatedBook,
    this.photoUrls = const [],
  }) : startTime = startTime ?? DateTime.now();

  String get difficultyLabel {
    switch (difficulty) {
      case 1: return '新手';
      case 2: return '入门';
      case 3: return '进阶';
      case 4: return '困难';
      case 5: return '资深';
      default: return '未知';
    }
  }

  String get formatDistance {
    if (distanceKm < 1) return '${(distanceKm * 1000).toInt()}m';
    return '${distanceKm.toStringAsFixed(1)}km';
  }

  String get formatDuration {
    if (durationMinutes < 60) return '$durationMinutes分钟';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m > 0 ? '${h}小时${m}分钟' : '${h}小时';
  }

  String get formatDate {
    return '${startTime.month}/${startTime.day}';
  }
}
