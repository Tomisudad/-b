import '../config/scenario_config.dart';

class EquipmentItem {
  String name;
  bool checked;

  EquipmentItem({required this.name, this.checked = false});
}

class EquipmentCategory {
  final String name;
  final List<EquipmentItem> items;

  EquipmentCategory({required this.name, List<EquipmentItem>? items})
      : items = items ?? [];
}

/// 从模板生成装备分类列表
List<EquipmentCategory> createEquipmentFromTemplate(ScenarioConfig config) {
  return config.equipmentTemplates.map((tpl) {
    return EquipmentCategory(
      name: tpl.name,
      items: tpl.items.map((name) => EquipmentItem(name: name)).toList(),
    );
  }).toList();
}
