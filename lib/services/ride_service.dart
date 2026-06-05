import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gowild_app/config/api_config.dart';
import 'package:gowild_app/models/ride_record_model.dart';

class RideService {
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

  Future<List<RideRecordModel>> getRides() async {
    final res = await http.get(
      Uri.parse(ApiConfig.rides),
      headers: await _headers,
    );
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => RideRecordModel.fromJson(e)).toList();
  }

  Future<RideRecordModel> startRide(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse(ApiConfig.rideStart),
      headers: await _headers,
      body: jsonEncode(data),
    );
    return RideRecordModel.fromJson(jsonDecode(res.body));
  }

  Future<Map<String, dynamic>> endRide(int id, Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse(ApiConfig.rideEnd(id)),
      headers: await _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getStats() async {
    final res = await http.get(
      Uri.parse(ApiConfig.rideStats),
      headers: await _headers,
    );
    return jsonDecode(res.body);
  }
}
