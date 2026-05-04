import 'package:flutter/material.dart';

import '../config/scenario_config.dart';

/// 场景主题扩展
extension ScenarioTheme on ThemeData {
  Color get scenePrimary => colorScheme.primary;
  Color get sceneSecondary => colorScheme.secondary;
  Color get sceneSurface => colorScheme.surface;
  Color get sceneOnPrimary => colorScheme.onPrimary;

  /// 为指定场景创建原生色板副本
  ThemeData forScenario(OutdoorScenario scenario) {
    final c = ScenarioConfig.of(scenario);
    return copyWith(
      colorScheme: colorScheme.copyWith(primary: c.primaryColor),
    );
  }
}

/// 场景颜色常量访问
class SceneColor {
  final OutdoorScenario scenario;

  const SceneColor(this.scenario);

  Color get primary => ScenarioConfig.of(scenario).primaryColor;
}
