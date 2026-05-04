import 'scenario.dart';

enum TripStatus { pending, active, completed }

enum EmotionTag { calm, moved, tired, amazed, insight, happy }

class EmotionMeta {
  final String emoji;
  final String label;
  final int color;
  const EmotionMeta(this.emoji, this.label, this.color);
}

const _emotionMeta = <EmotionTag, EmotionMeta>{
  EmotionTag.calm: EmotionMeta('😌', '平静', 0xFF607D8B),
  EmotionTag.moved: EmotionMeta('🥹', '感动', 0xFFEC407A),
  EmotionTag.tired: EmotionMeta('😤', '疲惫', 0xFF78909C),
  EmotionTag.amazed: EmotionMeta('🤯', '震撼', 0xFFFF7043),
  EmotionTag.insight: EmotionMeta('🧘', '顿悟', 0xFFAB47BC),
  EmotionTag.happy: EmotionMeta('😊', '开心', 0xFFFFCA28),
};

const emotionTagList = EmotionTag.values;

EmotionMeta emotionMeta(EmotionTag tag) => _emotionMeta[tag]!;

class TripModel {
  final String id;
  final String name;
  final OutdoorScenario scenario;
  final TripStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? pausedAt;
  final DateTime? completedAt;
  final DateTime? lastActiveAt;
  final double totalDistanceKm;
  final int accumulatedSeconds;
  final List<TrackPoint> trackPoints;
  final Map<String, List<String>> equipmentSnapshot;
  final String? personalNote;
  final String? coverUrl;

  TripModel({
    required this.id,
    required this.name,
    required this.scenario,
    this.status = TripStatus.pending,
    DateTime? createdAt,
    this.startedAt,
    this.pausedAt,
    this.completedAt,
    this.lastActiveAt,
    this.totalDistanceKm = 0,
    this.accumulatedSeconds = 0,
    this.trackPoints = const [],
    this.equipmentSnapshot = const {},
    this.personalNote,
    this.coverUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TripModel.create({
    required String name,
    required OutdoorScenario scenario,
    Map<String, List<String>> equipmentSnapshot = const {},
    String? personalNote,
  }) {
    return TripModel(
      id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      scenario: scenario,
      status: TripStatus.pending,
      equipmentSnapshot: Map.from(equipmentSnapshot),
      personalNote: personalNote,
    );
  }

  TripModel start() {
    return TripModel(
      id: id, name: name, scenario: scenario, status: TripStatus.active,
      createdAt: createdAt, startedAt: DateTime.now(), lastActiveAt: DateTime.now(),
      totalDistanceKm: totalDistanceKm, accumulatedSeconds: accumulatedSeconds,
      trackPoints: trackPoints, equipmentSnapshot: Map.from(equipmentSnapshot),
      personalNote: personalNote, coverUrl: coverUrl,
    );
  }

  TripModel pause() {
    return TripModel(
      id: id, name: name, scenario: scenario, status: TripStatus.active,
      createdAt: createdAt, startedAt: startedAt, pausedAt: DateTime.now(),
      lastActiveAt: DateTime.now(), totalDistanceKm: totalDistanceKm,
      accumulatedSeconds: accumulatedSeconds, trackPoints: trackPoints,
      equipmentSnapshot: Map.from(equipmentSnapshot),
      personalNote: personalNote, coverUrl: coverUrl,
    );
  }

  TripModel resume() {
    return TripModel(
      id: id, name: name, scenario: scenario, status: TripStatus.active,
      createdAt: createdAt, startedAt: startedAt, pausedAt: null,
      lastActiveAt: DateTime.now(), totalDistanceKm: totalDistanceKm,
      accumulatedSeconds: accumulatedSeconds, trackPoints: trackPoints,
      equipmentSnapshot: Map.from(equipmentSnapshot),
      personalNote: personalNote, coverUrl: coverUrl,
    );
  }

  TripModel complete({required double finalDistanceKm, required int finalDurationSec}) {
    return TripModel(
      id: id, name: name, scenario: scenario, status: TripStatus.completed,
      createdAt: createdAt, startedAt: startedAt, completedAt: DateTime.now(),
      lastActiveAt: DateTime.now(), totalDistanceKm: finalDistanceKm,
      accumulatedSeconds: finalDurationSec, trackPoints: trackPoints,
      equipmentSnapshot: Map.from(equipmentSnapshot),
      personalNote: personalNote, coverUrl: coverUrl,
    );
  }

  TripModel appendTracks(List<TrackPoint> newPoints, double deltaKm, int deltaSec) {
    final merged = [...trackPoints, ...newPoints];
    return TripModel(
      id: id, name: name, scenario: scenario, status: status,
      createdAt: createdAt, startedAt: startedAt, pausedAt: pausedAt,
      lastActiveAt: DateTime.now(), totalDistanceKm: totalDistanceKm + deltaKm,
      accumulatedSeconds: accumulatedSeconds + deltaSec, trackPoints: merged,
      equipmentSnapshot: Map.from(equipmentSnapshot),
      personalNote: personalNote, coverUrl: coverUrl,
    );
  }

  String get formatDistance {
    if (totalDistanceKm < 1) return '${(totalDistanceKm * 1000).toInt()}m';
    return '${totalDistanceKm.toStringAsFixed(1)}km';
  }

  String get formatDuration {
    final sec = accumulatedSeconds;
    if (sec < 60) return '${sec}秒';
    final m = sec ~/ 60;
    if (m < 60) return '$m分钟';
    final h = m ~/ 60;
    final rm = m % 60;
    return rm > 0 ? '${h}小时${rm}分' : '${h}小时';
  }

  String get formatLastActive {
    if (lastActiveAt == null) return '';
    final diff = DateTime.now().difference(lastActiveAt!);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays == 1) return '昨天 ${_fmtTime(lastActiveAt!)}';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${lastActiveAt!.month}/${lastActiveAt!.day} ${_fmtTime(lastActiveAt!)}';
  }

  String _fmtTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'scenario': scenario.index, 'status': status.index,
    'createdAt': createdAt.toIso8601String(),
    'startedAt': startedAt?.toIso8601String(),
    'pausedAt': pausedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'lastActiveAt': lastActiveAt?.toIso8601String(),
    'totalDistanceKm': totalDistanceKm,
    'accumulatedSeconds': accumulatedSeconds,
    'trackPoints': trackPoints.map((p) => p.toJson()).toList(),
    'equipmentSnapshot': equipmentSnapshot,
    'personalNote': personalNote,
    'coverUrl': coverUrl,
  };

  factory TripModel.fromJson(Map<String, dynamic> json) => TripModel(
    id: json['id'], name: json['name'],
    scenario: OutdoorScenario.values[json['scenario']],
    status: TripStatus.values[json['status']],
    createdAt: DateTime.parse(json['createdAt']),
    startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
    pausedAt: json['pausedAt'] != null ? DateTime.parse(json['pausedAt']) : null,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    lastActiveAt: json['lastActiveAt'] != null ? DateTime.parse(json['lastActiveAt']) : null,
    totalDistanceKm: (json['totalDistanceKm'] as num).toDouble(),
    accumulatedSeconds: json['accumulatedSeconds'],
    trackPoints: (json['trackPoints'] as List).map((p) => TrackPoint.fromJson(p)).toList(),
    equipmentSnapshot: (json['equipmentSnapshot'] as Map).map((k, v) => MapEntry(k as String, List<String>.from(v))),
    personalNote: json['personalNote'],
    coverUrl: json['coverUrl'],
  );
}

class TrackPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double speed;
  final double? altitude;
  final EmotionTag? emotionTag;

  const TrackPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.speed,
    this.altitude,
    this.emotionTag,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude, 'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
    'speed': speed, 'altitude': altitude,
    if (emotionTag != null) 'emotionTag': emotionTag!.index,
  };

  factory TrackPoint.fromJson(Map<String, dynamic> json) => TrackPoint(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    timestamp: DateTime.parse(json['timestamp']),
    speed: (json['speed'] as num).toDouble(),
    altitude: json['altitude'] != null ? (json['altitude'] as num).toDouble() : null,
    emotionTag: json['emotionTag'] != null ? EmotionTag.values[json['emotionTag']] : null,
  );
}
