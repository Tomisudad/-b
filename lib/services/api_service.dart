import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String baseUrl = 'http://10.0.2.2:8080/api';
  static String? _token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  static Future<Map<String, String>> get headers async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Auth
  static Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await headers,
      body: jsonEncode(
          {'username': username, 'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  // Users
  static Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/user/profile'),
      headers: await headers,
    );
    return jsonDecode(res.body);
  }

  // Routes
  static Future<List<dynamic>> getRoutes() async {
    final res = await http.get(
      Uri.parse('$baseUrl/routes'),
      headers: await headers,
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getRoute(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/routes/$id'),
      headers: await headers,
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createRoute(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/routes'),
      headers: await headers,
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  // Rides
  static Future<Map<String, dynamic>> startRide(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/rides'),
      headers: await headers,
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> endRide(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/rides/$id/end'),
      headers: await headers,
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getRides() async {
    final res = await http.get(
      Uri.parse('$baseUrl/rides'),
      headers: await headers,
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getRideStats() async {
    final res = await http.get(
      Uri.parse('$baseUrl/rides/stats'),
      headers: await headers,
    );
    return jsonDecode(res.body);
  }

  // Equipment
  static Future<List<dynamic>> getEquipment() async {
    final res = await http.get(
      Uri.parse('$baseUrl/equipment'),
      headers: await headers,
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createEquipment(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/equipment'),
      headers: await headers,
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getConsumables() async {
    final res = await http.get(
      Uri.parse('$baseUrl/equipment/consumables'),
      headers: await headers,
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getTodos() async {
    final res = await http.get(
      Uri.parse('$baseUrl/equipment/todos'),
      headers: await headers,
    );
    return jsonDecode(res.body);
  }

  // Weather
  static Future<Map<String, dynamic>> getWeather() async {
    final res = await http.get(
      Uri.parse('$baseUrl/routes/weather'),
      headers: await headers,
    );
    return jsonDecode(res.body);
  }

  // Team
  static Future<Map<String, dynamic>> createTeam(String name) async {
    final res = await http.post(
      Uri.parse('$baseUrl/team'),
      headers: await headers,
      body: jsonEncode({'name': name}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> joinTeam(String code) async {
    final res = await http.post(
      Uri.parse('$baseUrl/team/join'),
      headers: await headers,
      body: jsonEncode({'code': code}),
    );
    return jsonDecode(res.body);
  }
}
