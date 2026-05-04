import 'dart:ui';
import 'app_config.dart';

// ===== 场景枚举 =====
enum OutdoorScenario { cycle, moto, drive }

extension OutdoorScenarioX on OutdoorScenario {
  String get label {
    switch (this) {
      case OutdoorScenario.cycle: return '骑行';
      case OutdoorScenario.moto:  return '摩旅';
      case OutdoorScenario.drive: return '自驾';
    }
  }

  String get emoji {
    switch (this) {
      case OutdoorScenario.cycle: return '🚴';
      case OutdoorScenario.moto:  return '🏍️';
      case OutdoorScenario.drive: return '🚙';
    }
  }

  Color get primaryColor {
    switch (this) {
      case OutdoorScenario.cycle: return AppConfig.cyclePrimary;
      case OutdoorScenario.moto:  return AppConfig.motoPrimary;
      case OutdoorScenario.drive: return AppConfig.drivePrimary;
    }
  }

  Color get color => primaryColor;
}

// ===== 路线难度 =====
enum RouteDifficulty { easy, medium, hard, extreme }

extension RouteDifficultyX on RouteDifficulty {
  String get label {
    switch (this) {
      case RouteDifficulty.easy:    return '休闲';
      case RouteDifficulty.medium:  return '中等';
      case RouteDifficulty.hard:    return '挑战';
      case RouteDifficulty.extreme: return '极限';
    }
  }
}

// ===== 场景配置（装备模板 + 补给类别 + 安全提示） =====
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

  // ==================== 自驾 ====================
  static const ScenarioConfig drive = ScenarioConfig(
    scenario: OutdoorScenario.drive,
    label: '自驾',
    primaryColor: AppConfig.drivePrimary,
    supplyCategories: ['加油站', '充电桩', '停车场', '房车营地', '服务区'],
    equipmentTemplates: [
      EquipmentCategoryTemplate(name: '车辆', items: ['备胎', '千斤顶', '三角警示牌', '灭火器', '拖车绳', '搭电线', '胎压表', '行车记录仪']),
      EquipmentCategoryTemplate(name: '安全', items: ['急救包', '反光背心', '破窗器', '安全带割刀', '防狼喷雾', '哨子']),
      EquipmentCategoryTemplate(name: '补给', items: ['饮用水(至少4L)', '压缩饼干', '能量棒', '功能性饮料']),
      EquipmentCategoryTemplate(name: '电子', items: ['手机支架', '车载充电器', '充电宝', '备用数据线']),
      EquipmentCategoryTemplate(name: '露营', items: ['帐篷', '睡袋', '防潮垫', '露营灯', '折叠桌椅']),
      EquipmentCategoryTemplate(name: '衣物', items: ['冲锋衣', '速干衣', '徒步鞋', '帽子', '墨镜', '防晒霜']),
    ],
    safetyTips: ['出发前检查胎压和刹车', '山区路段减速慢行', '不要疲劳驾驶', '提前下载离线地图'],
  );

  // ==================== 摩旅 ====================
  static const ScenarioConfig moto = ScenarioConfig(
    scenario: OutdoorScenario.moto,
    label: '摩旅',
    primaryColor: AppConfig.motoPrimary,
    supplyCategories: ['加油站(标号)', '摩托车维修站', '摩旅驿站'],
    equipmentTemplates: [
      EquipmentCategoryTemplate(name: '护具', items: ['头盔', '骑行手套', '护膝护肘', '骑行服', '骑行靴', '雨衣']),
      EquipmentCategoryTemplate(name: '车辆', items: ['补胎工具包', '链条油', '备用火花塞', '备用油', '简易套筒扳手']),
      EquipmentCategoryTemplate(name: '安全', items: ['急救包', '反光贴', 'GPS定位器', '哨子', '防身用具']),
      EquipmentCategoryTemplate(name: '补给', items: ['饮用水(至少2L)', '能量胶', '压缩饼干', '电解质冲剂']),
      EquipmentCategoryTemplate(name: '电子', items: ['手机支架', '蓝牙耳机', '运动相机', '充电宝']),
      EquipmentCategoryTemplate(name: '露营', items: ['轻量帐篷', '睡袋', '防潮垫', '头灯']),
      EquipmentCategoryTemplate(name: '衣物', items: ['速干内衣', '保暖中层', '防水外层', '头巾', '防晒霜']),
    ],
    safetyTips: ['始终佩戴全盔', '弯道减速，不压弯', '雨天路面湿滑加倍小心', '保持与汽车的安全距离'],
  );

  // ==================== 骑行 ====================
  static const ScenarioConfig cycle = ScenarioConfig(
    scenario: OutdoorScenario.cycle,
    label: '骑行',
    primaryColor: AppConfig.cyclePrimary,
    supplyCategories: ['补水点', '自行车维修店', '公共厕所'],
    equipmentTemplates: [
      EquipmentCategoryTemplate(name: '车辆', items: ['头盔', '骑行手套', '码表', '水壶架×2', '骑行眼镜', '备胎×2', '打气筒', '撬胎棒', '六角扳手套装', '链条油']),
      EquipmentCategoryTemplate(name: '安全', items: ['前灯', '尾灯', '反光背心', '急救包', '哨子']),
      EquipmentCategoryTemplate(name: '补给', items: ['能量胶×6', '盐丸', '能量棒', '电解质冲剂', '香蕉']),
      EquipmentCategoryTemplate(name: '电子', items: ['手机支架', '充电宝', '蓝牙耳机']),
      EquipmentCategoryTemplate(name: '衣物', items: ['骑行服', '骑行裤', '骑行袜', '骑行风衣', '防晒臂套', '防晒霜', '雨衣']),
      EquipmentCategoryTemplate(name: '工具', items: ['迷你打气筒', '多功能工具', '内胎补片', '扎带']),
    ],
    safetyTips: ['佩戴头盔！', '遵守交通规则，不闯红灯', '夜间一定要开前后灯', '注意补充水分和电解质'],
  );

  static const List<ScenarioConfig> all = [cycle, moto, drive];

  static ScenarioConfig of(OutdoorScenario s) {
    switch (s) {
      case OutdoorScenario.cycle: return cycle;
      case OutdoorScenario.moto:  return moto;
      case OutdoorScenario.drive: return drive;
    }
  }

  /// 按场景取默认装备列表（铺平所有分类）
  List<String> get flatEquipmentItems {
    final items = <String>[];
    for (final cat in equipmentTemplates) {
      items.addAll(cat.items);
    }
    return items;
  }
}

// ===== 装备模板 =====
class EquipmentCategoryTemplate {
  final String name;
  final List<String> items;
  const EquipmentCategoryTemplate({required this.name, required this.items});
}
