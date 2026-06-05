class UserModel {
  final int id;
  final String username;
  final String email;
  final String avatar;
  final double totalDist;
  final int totalRides;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatar = '',
    this.totalDist = 0,
    this.totalRides = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'] ?? '',
      totalDist: (json['total_dist'] ?? 0).toDouble(),
      totalRides: json['total_rides'] ?? 0,
    );
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? avatar,
    double? totalDist,
    int? totalRides,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      totalDist: totalDist ?? this.totalDist,
      totalRides: totalRides ?? this.totalRides,
    );
  }
}
