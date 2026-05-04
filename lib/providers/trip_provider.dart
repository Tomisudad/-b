import 'package:flutter/foundation.dart';
import '../models/trip_model.dart';
import '../services/trip_storage_service.dart';
import '../config/scenario_config.dart';

class TripProvider extends ChangeNotifier {
  final _storage = TripStorageService.instance;
  TripModel? _activeTrip;
  List<TripModel> _completedTrips = [];
  bool _loaded = false;

  TripModel? get activeTrip => _activeTrip;
  List<TripModel> get completedTrips => _completedTrips;
  bool get loaded => _loaded;

  Future<void> loadFromStorage() async {
    if (_loaded) return;
    final trips = await _storage.loadAll();
    _activeTrip = trips.where((t) => t.status == TripStatus.active).firstOrNull;
    _completedTrips = trips.where((t) => t.status == TripStatus.completed).toList()
      ..sort((a, b) => (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt));
    _loaded = true;
    notifyListeners();
  }

  void createTrip(String name, OutdoorScenario scenario, {Map<String, List<String>> equipment = const {}, String? note}) {
    if (_activeTrip != null) return;
    _activeTrip = TripModel.create(name: name, scenario: scenario, equipmentSnapshot: equipment, personalNote: note);
    notifyListeners();
  }

  void startTrip() {
    if (_activeTrip == null) return;
    _activeTrip = _activeTrip!.start();
    notifyListeners();
  }

  void pauseTrip() {
    if (_activeTrip == null) return;
    _activeTrip = _activeTrip!.pause();
    notifyListeners();
  }

  void resumeTrip() {
    if (_activeTrip == null) return;
    _activeTrip = _activeTrip!.resume();
    notifyListeners();
  }

  void completeTrip({required double finalDistanceKm, required int finalDurationSec}) {
    if (_activeTrip == null) return;
    final completed = _activeTrip!.complete(finalDistanceKm: finalDistanceKm, finalDurationSec: finalDurationSec);
    _completedTrips.insert(0, completed);
    _storage.addTrip(completed);
    _activeTrip = null;
    notifyListeners();
  }

  void appendTracks(List<TrackPoint> points, double deltaKm, int deltaSec) {
    if (_activeTrip == null) return;
    _activeTrip = _activeTrip!.appendTracks(points, deltaKm, deltaSec);
    notifyListeners();
  }

  void tagEmotion(EmotionTag tag) {
    if (_activeTrip == null) return;
    // Emotion tagging is handled by TrackingService
  }

  TripModel? getTripById(String id) {
    if (_activeTrip?.id == id) return _activeTrip;
    try {
      return _completedTrips.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
