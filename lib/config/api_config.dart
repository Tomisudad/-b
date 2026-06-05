class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';

  // Auth
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';

  // User
  static const String userProfile = '$baseUrl/user/me';

  // Routes
  static const String routes = '$baseUrl/routes';
  static String route(int id) => '$baseUrl/routes/$id';
  static const String gpxImport = '$baseUrl/routes/import/gpx';

  // Rides
  static const String rides = '$baseUrl/rides';
  static const String rideStart = '$baseUrl/rides/start';
  static String rideEnd(int id) => '$baseUrl/rides/$id/end';
  static String ridePause(int id) => '$baseUrl/rides/$id/pause';
  static String rideResume(int id) => '$baseUrl/rides/$id/resume';
  static String rideSOS(int id) => '$baseUrl/rides/$id/sos';
  static const String rideStats = '$baseUrl/rides/stats';

  // Equipment
  static const String equipment = '$baseUrl/equipment';
  static String equipmentItem(int id) => '$baseUrl/equipment/$id';
  static String equipmentStatus(int id) => '$baseUrl/equipment/$id/status';
  static const String consumables = '$baseUrl/equipment/consumables';

  // Team
  static const String team = '$baseUrl/team';
  static const String teamCreate = '$baseUrl/team/create';
  static const String teamJoin = '$baseUrl/team/join';
  static const String teamLeave = '$baseUrl/team/leave';
  static const String teamMessage = '$baseUrl/team/message';
  static const String teamLocation = '$baseUrl/team/location';

  // Todos
  static const String todos = '$baseUrl/todos';

  // Weather
  static const String weather = '$baseUrl/weather';
}
