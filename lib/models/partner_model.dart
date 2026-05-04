import 'scenario.dart';

class PartnerModel {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final OutdoorScenario scenario;
  final String destination;
  final DateTime departTime;
  final int capacity;
  final int joined;
  final String? description;
  final List<String> tags;
  final bool verified;

  PartnerModel({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    required this.scenario,
    required this.destination,
    required this.departTime,
    this.capacity = 4,
    this.joined = 1,
    this.description,
    this.tags = const [],
    this.verified = false,
  });

  bool get isFull => joined >= capacity;
  int get remaining => capacity - joined;

  String get formatDate {
    final diff = departTime.difference(DateTime.now());
    if (diff.inDays == 0) return '今天出发';
    if (diff.inDays == 1) return '明天出发';
    if (diff.inDays <= 7) return '${diff.inDays}天后出发';
    return '${departTime.month}/${departTime.day}出发';
  }
}

// ===== 社区动态 =====
class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final List<String> imageUrls;
  final String? videoUrl;
  final OutdoorScenario scenario;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final String? moodTag;
  final String? locationName;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.imageUrls = const [],
    this.videoUrl,
    required this.scenario,
    this.likeCount = 0,
    this.commentCount = 0,
    DateTime? createdAt,
    this.moodTag,
    this.locationName,
  }) : createdAt = createdAt ?? DateTime.now();

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${createdAt.month}/${createdAt.day}';
  }
}

// ===== 篝火匿名消息 =====
class BonfireMessage {
  final String id;
  final String content;
  final String? moodTag;
  final DateTime createdAt;
  final int warmthCount; // 暖心数

  BonfireMessage({
    required this.id,
    required this.content,
    this.moodTag,
    DateTime? createdAt,
    this.warmthCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    return '${diff.inHours}小时前';
  }
}
