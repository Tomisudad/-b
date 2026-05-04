import 'dart:convert';
import '../models/trip_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripStorageService {
  static final TripStorageService instance = TripStorageService._();
  TripStorageService._();

  static const _key = 'quye_trips';

  Future<void> saveAll(List<TripModel> trips) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = trips.map((t) => t.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  Future<List<TripModel>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final List<dynamic> jsonList = jsonDecode(raw);
    return jsonList.map((j) => TripModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<void> addTrip(TripModel trip) async {
    final trips = await loadAll();
    trips.add(trip);
    await saveAll(trips);
  }

  Future<void> updateTrip(TripModel updated) async {
    final trips = await loadAll();
    final idx = trips.indexWhere((t) => t.id == updated.id);
    if (idx >= 0) {
      trips[idx] = updated;
      await saveAll(trips);
    }
  }

  Future<void> removeTrip(String id) async {
    final trips = await loadAll();
    trips.removeWhere((t) => t.id == id);
    await saveAll(trips);
  }

  Future<TripModel?> getActiveTrip() async {
    final trips = await loadAll();
    try {
      return trips.firstWhere((t) => t.status == TripStatus.active);
    } catch (_) {
      return null;
    }
  }
}
