class UserModel {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final String? phone;
  final String? bio;
  final bool verified;
  final List<String> badges;
  final List<String> vehicleIds;
  final int tripCount;
  final int totalDistanceKm;
  final DateTime joinDate;
  final bool isLoggedIn;

  UserModel({
    this.id = '',
    this.nickname = '',
    this.avatarUrl,
    this.phone,
    this.bio,
    this.verified = false,
    this.badges = const [],
    this.vehicleIds = const [],
    this.tripCount = 0,
    this.totalDistanceKm = 0,
    DateTime? joinDate,
    this.isLoggedIn = false,
  }) : joinDate = joinDate ?? DateTime.now();

  UserModel copyWith({
    String? id,
    String? nickname,
    String? avatarUrl,
    String? phone,
    String? bio,
    bool? verified,
    List<String>? badges,
    List<String>? vehicleIds,
    int? tripCount,
    int? totalDistanceKm,
    DateTime? joinDate,
    bool? isLoggedIn,
  }) {
    return UserModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      verified: verified ?? this.verified,
      badges: badges ?? this.badges,
      vehicleIds: vehicleIds ?? this.vehicleIds,
      tripCount: tripCount ?? this.tripCount,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      joinDate: joinDate ?? this.joinDate,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  static final UserModel guest = UserModel();
}
