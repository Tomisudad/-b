import 'package:flutter/material.dart';
import 'package:gowild_app/models/ride_record_model.dart';
import 'package:gowild_app/services/ride_service.dart';

class RideProvider extends ChangeNotifier {
  final RideService _rideService = RideService();
  List<RideRecordModel> _records = [];
  RideRecordModel? _currentRide;
  bool _isLoading = false;
  String? _error;

  List<RideRecordModel> get records => _records;
  RideRecordModel? get currentRide => _currentRide;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRecords() async {
    _isLoading = true;
    notifyListeners();
    try {
      _records = await _rideService.getRides();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startRide(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentRide = await _rideService.startRide(data);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> endRide(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _rideService.endRide(id, data);
      _currentRide = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
