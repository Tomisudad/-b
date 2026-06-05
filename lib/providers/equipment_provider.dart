import 'package:flutter/material.dart';
import 'package:gowild_app/models/equipment_model.dart';
import 'package:gowild_app/services/equipment_service.dart';

class EquipmentProvider extends ChangeNotifier {
  final EquipmentService _equipmentService = EquipmentService();
  List<Equipment> _equipment = [];
  List<Consumable> _consumables = [];
  List<TodoItem> _todos = [];
  bool _isLoading = false;
  String? _error;

  List<Equipment> get equipment => _equipment;
  List<Consumable> get consumables => _consumables;
  List<TodoItem> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      _equipment = await _equipmentService.getEquipment();
      _consumables = await _equipmentService.getConsumables();
      _todos = await _equipmentService.getTodos();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
