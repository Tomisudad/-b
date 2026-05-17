import 'package:flutter/material.dart';

import '../config/scenario_config.dart';

class ScenarioProvider extends ChangeNotifier {
  OutdoorScenario _scenario = OutdoorScenario.cycle;

  OutdoorScenario get scenario => _scenario;

  set scenario(OutdoorScenario s) {
    if (_scenario == s) return;
    _scenario = s;
    notifyListeners();
  }

  ScenarioConfig get config => ScenarioConfig.of(_scenario);
}
