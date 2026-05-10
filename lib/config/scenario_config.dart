import 'package:flutter/painting.dart';
import 'app_config.dart';

/// 场景枚举 V7.3 - 骑行深度定制版
enum OutdoorScenario { cycle, moto, drive }

extension OutdoorScenarioX on OutdoorScenario {
  String get label {
    switch (this) {
      case OutdoorScenario.cycle:
        return '骑行';
      case OutdoorScenario.moto:
        return '摩旅';
      case OutdoorScenario.drive:
        return '自驾';
    }
  }

  String get emoji {
    switch (this) {
      case OutdoorScenario.cycle:
        return '🚴';
      case OutdoorScenario.moto:
        return '🏍️';
      case OutdoorScenario.drive:
        return '🚙';
    }
  }

  Color get primaryColor {
    switch (this) {
      case OutdoorScenario.cycle:
        return AppConfig.primary;
      case OutdoorScenario.moto:
        return AppConfig.warningOrange;
      case OutdoorScenario.drive:
        return const Color(0xFF3498DB);
    }
  }

  Color get color => primaryColor;
}

/// 路线难度
enum RouteDifficulty { easy, medium, hard, extreme }

extension RouteDifficultyX on RouteDifficulty {
  String get label {
    switch (this) {
      case RouteDifficulty.easy:
        return '休闲';
      case RouteDifficulty.medium:
        return '中等';
      case RouteDifficulty.hard:
        return '挑战';
      case RouteDifficulty.extreme:
        return '极限';
    }
  }
}

/// 骑行者目标标签
enum CyclingGoal {
  challenge('🏆', '挑战', const Color(0xFFFFD700), const Color(0xFFCD7F32)),
  scenery('🏞️', '风景', const Color(0xFF2ECC71), const Color(0xFF3498DB)),
  social('🎉', '社交', const Color(0xFFE67E22), const Color(0xFFE74C3C)),
  longRide('🗺️', '长途', const Color(0xFF3498DB), const Color(0xFF1A1A2E)),
  exploration('🧭', '探索', const Color(0xFF9B59B6), const Color(0xFF3498DB));

  final String emoji;
  final String label;
  final Color colorStart;
  final Color colorEnd;

  const CyclingGoal(this.emoji, this.label, this.colorStart, this.colorEnd);

  LinearGradient get gradient => LinearGradient(
        colors: [colorStart, colorEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

/// 场景配置 V7.3 - 聚焦骑行
class ScenarioConfig {
  final OutdoorScenario scenario;
  final String label;
  final Color primaryColor;
  final List<String> supplyCategories;
  final List<EquipmentCategoryTemplate> equipmentTemplates;
  final List<String> safetyTips;

  const ScenarioConfig({
    required this.scenario,
    required this.label,
    required this.primaryColor,
    required this.supplyCategories,
    required this.equipmentTemplates,
    required this.safetyTips,
  });

  // ========== 骑行配置 V7.3 ==========
  static const ScenarioConfig cycle = ScenarioConfig(
    scenario: OutdoorScenario.cycle,
    label: '骑行',
    primaryColor: AppConfig.primary,
    supplyCategories: ['补水点', '自行车维修店', '公共厕所', '便利店', '餐饮店'],
    equipmentTemplates: [
      EquipmentCategoryTemplate(
        name: '🛡️ 核心装备',
        items: ['头盔', '骑行手套', '前灯', '尾灯', '备胎×2', '打气筒', '能量胶×3', '水壶×2'],
      ),
      EquipmentCategoryTemplate(
        name: '🔧 车辆状态',
        items: ['刹车检查', '胎压检查', '链条润油', '变速检查'],
      ),
      EquipmentCategoryTemplate(
        name: '👕 衣物',
        items: ['骑行服', '骑行裤', '骑行袜', '骑行风衣', '防晒臂套', '雨衣'],
      ),
      EquipmentCategoryTemplate(
        name: '🔌 电子',
        items: ['码表', '手机支架', '充电宝', '蓝牙耳机'],
      ),
      EquipmentCategoryTemplate(
        name: '🏥 应急',
        items: ['急救包', '哨子', '扎带', '六角扳手套装'],
      ),
    ],
    safetyTips: [
      '佩戴头盔！安全第一',
      '遵守交通规则，不闯红灯',
      '夜间一定要开前后灯',
      '注意补充水分，每15公里补一次',
      '横风4级以上注意减速',
      '连续下坡注意控制车速',
    ],
  );

  static const List<ScenarioConfig> all = [cycle];

  static ScenarioConfig of(OutdoorScenario s) {
    return cycle; // V7.3 只用骑行
  }

  List<String> get flatEquipmentItems {
    final items = <String>[];
    for (final cat in equipmentTemplates) {
      items.addAll(cat.items);
    }
    return items;
  }
}

/// 装备分类模板
class EquipmentCategoryTemplate {
  final String name;
  final List<String> items;

  const EquipmentCategoryTemplate({required this.name, required this.items});
}