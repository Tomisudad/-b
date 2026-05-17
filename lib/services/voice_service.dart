import 'package:flutter/foundation.dart';
import '../models/scenario.dart';

class VoiceService {
  static final VoiceService instance = VoiceService._();
  VoiceService._();

  String _lastTip = '';
  int _lastKm = 0;

  /// 播报语音（Web端模拟）
  void speak(String msg) {
    // Flutter Web TTS placeholder
    debugPrint('[Voice] $msg');
  }

  /// 每骑行1km轮播一次提示
  void cycleTip(OutdoorScenario scenario, int km) {
    if (km > _lastKm) {
      _lastKm = km;
      final tip = getRandomTip(scenario);
      if (tip.isNotEmpty && tip != _lastTip) {
        _lastTip = tip;
        speak(tip);
      }
    }
  }

  Map<OutdoorScenario, List<String>> tips = {
    OutdoorScenario.cycle: [
      '前方500米右转进入骑行专用道',
      '注意前方路口减速慢行',
      '已骑行10公里，推荐前方2公里补水点',
      '当前速度15km/h，心率区合理',
      '前方上坡路段，建议降档',
      '弯道提示：前方连续弯道，控制车速',
      '前方路况良好，可保持巡航速度',
      '弯道预警：前方急弯，建议减速至40km/h',
      '已连续骑行1小时，建议在前方休息点休息',
      '海拔上升中，注意体能分配',
      '前方隧道，请提前开启车灯',
      '前方5公里处有服务点，可补水休息',
      '前方施工路段，注意避让',
      '导航提示：前方出口可前往观景点',
      '已连续骑行2小时，建议休息一下',
      '注意前方路况，减速慢行',
    ],
  };

  Map<OutdoorScenario, String> departureMsgs = {
    OutdoorScenario.cycle: '骑行出发！检查好头盔和刹车，享受风与自由吧。',
  };

  String getDepartureMsg(OutdoorScenario scenario) {
    return departureMsgs[scenario] ?? '出发！旅途愉快。';
  }

  String getRandomTip(OutdoorScenario scenario) {
    final list = tips[scenario] ?? [];
    if (list.isEmpty) return '';
    return list[DateTime.now().millisecond % list.length];
  }
}
