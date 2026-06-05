import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gowild_app/config/api_config.dart';
import 'package:gowild_app/models/route_model.dart';

class RouteService {
  static String? _token;

  Future<Map<String, String>> get _headers async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<List<RouteModel>> getRoutes() async {
    final res = await http.get(
      Uri.parse(ApiConfig.routes),
      headers: await _headers,
    );
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => RouteModel.fromJson(e)).toList();
  }

  Future<RouteModel> getRoute(int id) async {
    final res = await http.get(
      Uri.parse(ApiConfig.route(id)),
      headers: await _headers,
    );
    return RouteModel.fromJson(jsonDecode(res.body));
  }

  Future<RouteModel> createRoute(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse(ApiConfig.routes),
      headers: await _headers,
      body: jsonEncode(data),
    );
    return RouteModel.fromJson(jsonDecode(res.body));
  }

  Future<Map<String, dynamic>> importGPX(String filePath) async {
    final res = await http.post(
      Uri.parse(ApiConfig.gpxImport),
      headers: await _headers,
      body: jsonEncode({'file_path': filePath}),
    );
    return jsonDecode(res.body);
  }
}
