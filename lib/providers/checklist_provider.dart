import 'package:flutter/material.dart';

import '../config/scenario_config.dart';
import '../models/equipment_model.dart';

class ChecklistProvider extends ChangeNotifier {
  List<EquipmentCategory> _categories = [];

  List<EquipmentCategory> get categories => _categories;

  int get totalItems => _categories.fold(0, (sum, c) => sum + c.items.length);
  int get checkedItems => _categories.fold(0, (sum, c) => sum + c.items.where((i) => i.checked).length);
  double get progress => totalItems == 0 ? 0 : checkedItems / totalItems;
  List<String> get missingItems => _categories
    .expand((c) => c.items.where((i) => !i.checked).map((i) => '${c.name} · ${i.name}'))
    .toList();

  /// 按场景加载装备模板
  void loadForScenario(OutdoorScenario scenario) {
    _categories = createEquipmentFromTemplate(ScenarioConfig.of(scenario));
    notifyListeners();
  }

  /// 切换单项
  void toggleItem(int catIndex, int itemIndex) {
    _categories[catIndex].items[itemIndex].checked =
        !_categories[catIndex].items[itemIndex].checked;
    notifyListeners();
  }

  /// 全选/取消某个分类
  void toggleCategory(int catIndex, bool value) {
    for (final item in _categories[catIndex].items) {
      item.checked = value;
    }
    notifyListeners();
  }
}
