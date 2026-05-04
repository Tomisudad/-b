import '../models/scenario.dart';

class VoiceService {
  static final VoiceService instance = VoiceService._();
  VoiceService._();

  Map<OutdoorScenario, List<String>> tips = {
    OutdoorScenario.cycle: [
      '前方500米右转进入骑行专用道',
      '注意前方路口减速慢行',
      '已骑行10公里，推荐前方2公里补水点',
      '当前速度15km/h，心率区合理',
      '前方上坡路段，建议降档',
      '弯道提示：前方连续弯道，控制车速',
    ],
    OutdoorScenario.moto: [
      '前方路况良好，可保持巡航速度',
      '前方加油站距当前位置8公里',
      '弯道预警：前方急弯，建议减速至40km/h',
      '已连续驾驶1小时，建议在前方驿站休息',
      '海拔上升中，注意发动机动力变化',
      '前方隧道，请提前开启大灯',
    ],
    OutdoorScenario.drive: [
      '前方5公里处有服务区，可加油休息',
      '当前路段限速120km/h',
      '前方施工路段，限速60km/h',
      '导航提示：前方出口可前往观景台',
      '已连续驾驶2小时，建议休息一下',
      '前方ETC收费站，请减速慢行',
    ],
  };

  Map<OutdoorScenario, String> departureMsgs = {
    OutdoorScenario.cycle: '骑行出发！检查好头盔和刹车，享受风与自由吧。',
    OutdoorScenario.moto: '摩旅出发！油箱已满，前方一路畅通。',
    OutdoorScenario.drive: '自驾出发！系好安全带，一路平安。',
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
