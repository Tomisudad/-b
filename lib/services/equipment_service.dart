import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gowild_app/config/api_config.dart';
import 'package:gowild_app/models/equipment_model.dart';

class EquipmentService {
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

  Future<List<Equipment>> getEquipment() async {
    final res = await http.get(
      Uri.parse(ApiConfig.equipment),
      headers: await _headers,
    );
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => Equipment.fromJson(e)).toList();
  }

  Future<Equipment> createEquipment(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse(ApiConfig.equipment),
      headers: await _headers,
      body: jsonEncode(data),
    );
    return Equipment.fromJson(jsonDecode(res.body));
  }

  Future<List<Consumable>> getConsumables() async {
    final res = await http.get(
      Uri.parse(ApiConfig.consumables),
      headers: await _headers,
    );
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => Consumable.fromJson(e)).toList();
  }

  Future<List<TodoItem>> getTodos() async {
    final res = await http.get(
      Uri.parse(ApiConfig.todos),
      headers: await _headers,
    );
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => TodoItem.fromJson(e)).toList();
  }
}
