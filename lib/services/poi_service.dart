/// POI 数据服务 —— 加油站 + 露营地/停车场
class PoiService {
  static final PoiService instance = PoiService._();
  PoiService._();

  // ── 加油站 ──

  List<GasStation> searchGasStations(double lat, double lng, {double radiusKm = 50}) {
    return _gasStations
        .where((g) => _dist(lat, lng, g.lat, g.lng) <= radiusKm)
        .toList()
      ..sort((a, b) => _dist(lat, lng, a.lat, a.lng).compareTo(_dist(lat, lng, b.lat, b.lng)));
  }

  // ── 露营地 / 停车场 ──

  List<Campsite> searchCampsites(double lat, double lng, {double radiusKm = 80}) {
    return _campsites
        .where((c) => _dist(lat, lng, c.lat, c.lng) <= radiusKm)
        .toList()
      ..sort((a, b) => _dist(lat, lng, a.lat, a.lng).compareTo(_dist(lat, lng, b.lat, b.lng)));
  }

  double _dist(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_rad(lat1)) * _cos(_rad(lat2)) * _sin(dLng / 2) * _sin(dLng / 2);
    return r * 2 * _atan2(_sqrt(a), _sqrt(1 - a));
  }
  double _rad(double deg) => deg * 0.0174533;
  double _sin(double x) {
    double r = x;
    double t = x;
    for (int i = 1; i < 6; i++) {
      t *= -x * x / ((2 * i) * (2 * i + 1));
      r += t;
    }
    return r;
  }
  double _cos(double x) {
    double r = 1.0;
    double t = 1.0;
    for (int i = 1; i < 6; i++) {
      t *= -x * x / ((2 * i - 1) * (2 * i));
      r += t;
    }
    return r;
  }
  double _sqrt(double x) {
    if (x <= 0) return 0;
    double r = x;
    for (int i = 0; i < 10; i++) {
      r = (r + x / r) / 2;
    }
    return r;
  }
  double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0) return _atan(y / x) + (y >= 0 ? 3.14159 : -3.14159);
    return y > 0 ? 1.5708 : (y < 0 ? -1.5708 : 0);
  }
  double _atan(double x) {
    double r = x;
    double t = x;
    double x2 = x * x;
    for (int i = 1; i < 12; i++) {
      t *= -x2;
      r += t / (2 * i + 1);
    }
    return r;
  }

  // ── 数据 ──

  static const List<GasStation> _gasStations = [
    // 川西
    GasStation('gs1', '中石油康定站', 30.05, 101.96, ['92','95','98'], false),
    GasStation('gs2', '中石化新都桥站', 30.04, 101.49, ['92','95'], false),
    GasStation('gs3', '理塘中石油', 29.99, 100.27, ['92','95'], false),
    GasStation('gs4', '稻城中石油', 29.04, 100.30, ['92','95'], false),
    GasStation('gs5', '丹巴加油站', 30.88, 101.88, ['92'], false),
    // 新疆
    GasStation('gs6', '独山子中石油', 44.33, 84.86, ['92','95','98'], false),
    GasStation('gs7', '那拉提加油站', 43.35, 84.05, ['92','95'], false),
    GasStation('gs8', '库车中石化', 41.72, 82.96, ['92','95','98'], false),
    GasStation('gs9', '喀纳斯加油站', 48.69, 87.03, ['92','95'], false),
    GasStation('gs10', '和田中石油', 37.12, 79.93, ['92','95'], false),
    // 西藏
    GasStation('gs11', '拉萨中石油', 29.65, 91.13, ['92','95','98'], false),
    GasStation('gs12', '林芝加油站', 29.58, 94.47, ['92','95'], false),
    GasStation('gs13', '日喀则中石油', 29.27, 88.88, ['92','95'], false),
    GasStation('gs14', '那曲加油站', 31.48, 92.06, ['92'], false),
    // 青海
    GasStation('gs15', '格尔木中石油', 36.41, 94.91, ['92','95','98'], false),
    GasStation('gs16', '西宁中石化', 36.62, 101.78, ['92','95','98'], false),
    GasStation('gs17', '德令哈加油站', 37.37, 97.37, ['92','95'], false),
    // 云南
    GasStation('gs18', '大理中石油', 25.61, 100.27, ['92','95','98'], false),
    GasStation('gs19', '丽江中石化', 26.87, 100.23, ['92','95'], false),
    GasStation('gs20', '香格里拉加油站', 27.83, 99.70, ['92','95'], false),
    // 内蒙古
    GasStation('gs21', '呼伦贝尔中石油', 49.21, 119.76, ['92','95'], false),
    GasStation('gs22', '满洲里加油站', 49.60, 117.45, ['92','95'], false),
    GasStation('gs23', '额济纳旗中石油', 41.96, 101.07, ['92','95'], false),
    // 甘肃
    GasStation('gs24', '敦煌中石油', 40.14, 94.67, ['92','95','98'], false),
    GasStation('gs25', '张掖中石化', 38.93, 100.45, ['92','95','98'], false),
    GasStation('gs26', '嘉峪关加油站', 39.77, 98.29, ['92','95'], false),
    // 华东区域
    GasStation('gs27', '黄山服务区加油站', 29.72, 118.34, ['92','95','98'], false),
    GasStation('gs28', '千岛湖中石化', 29.61, 119.04, ['92','95'], false),
    GasStation('gs29', '莫干山加油站', 30.63, 119.87, ['92','95'], false),
    GasStation('gs30', '婺源中石油', 29.25, 117.86, ['92','95'], false),

    // 禁摩加油站（motorbike_prohibited = true）
    GasStation('gs31', '北京三环内加油站', 39.93, 116.40, ['92','95','98'], true),
    GasStation('gs32', '上海内环加油站', 31.24, 121.47, ['92','95','98'], true),
    GasStation('gs33', '广州天河加油站', 23.13, 113.35, ['92','95','98'], true),
    GasStation('gs34', '深圳福田中石化', 22.54, 114.06, ['92','95','98'], true),
    GasStation('gs35', '杭州西湖中石油', 30.26, 120.15, ['92','95','98'], true),
    GasStation('gs36', '成都一环内加油站', 30.66, 104.07, ['92','95','98'], true),
    GasStation('gs37', '南京鼓楼加油站', 32.06, 118.79, ['92','95','98'], true),
    GasStation('gs38', '武汉武昌中石化', 30.59, 114.32, ['92','95','98'], true),
    GasStation('gs39', '郑州金水中石油', 34.77, 113.67, ['92','95','98'], true),
    GasStation('gs40', '西安城墙内加油站', 34.26, 108.95, ['92','95','98'], true),
  ];

  static const List<Campsite> _campsites = [
    // ⛺ 知名露营地
    Campsite('cp1', '牛背山星空营地', 29.77, 102.39, CampType.camp, '360°云海日出，海拔3666m', true, false, true, 20),
    Campsite('cp2', '四姑娘山长坪沟营地', 31.02, 102.84, CampType.camp, '雪山脚下的木屋营地', true, false, true, 80),
    Campsite('cp3', '稻城亚丁洛绒牛场', 28.42, 100.36, CampType.camp, '三神山环抱，海拔4180m', false, true, false, 0),
    Campsite('cp4', '喀纳斯湖畔营地', 48.71, 87.02, CampType.camp, '湖边白桦林环绕', true, true, false, 60),
    Campsite('cp5', '禾木村营地', 48.57, 87.44, CampType.camp, '图瓦人木屋民宿+帐篷区', true, true, false, 100),
    Campsite('cp6', '赛里木湖畔营地', 44.60, 81.16, CampType.camp, '大西洋最后一滴眼泪', true, false, true, 50),
    Campsite('cp7', '那拉提草原营地', 43.30, 84.00, CampType.camp, '空中草原毡房住宿', true, true, false, 120),
    Campsite('cp8', '乌兰布统草原营地', 42.52, 117.23, CampType.camp, '坝上草原最美营地', true, true, false, 80),
    Campsite('cp9', '若尔盖花湖营地', 33.92, 102.82, CampType.camp, '高原湿地生态营地', true, false, false, 40),
    Campsite('cp10', '洱海东岸营地', 25.76, 100.22, CampType.camp, '面朝洱海的房车营地', true, true, true, 150),
    Campsite('cp11', '泸沽湖里格半岛营地', 27.73, 100.77, CampType.camp, '摩梭风情湖景营地', true, true, false, 100),
    Campsite('cp12', '香格里拉纳帕海营地', 27.88, 99.64, CampType.camp, '藏式帐篷营地', true, false, true, 60),
    Campsite('cp13', '青海湖江西沟营地', 36.60, 100.23, CampType.camp, '环湖骑行补给站+帐篷', false, true, true, 30),
    Campsite('cp14', '祁连山草原营地', 38.18, 100.24, CampType.camp, '东方小瑞士', true, true, false, 50),
    Campsite('cp15', '张掖丹霞营地', 38.93, 100.10, CampType.camp, '七彩丹霞旁的露营区', true, true, false, 80),
    Campsite('cp16', '敦煌鸣沙山营地', 40.09, 94.67, CampType.camp, '沙漠星空露营', true, false, true, 120),
    Campsite('cp17', '呼伦贝尔金帐汗营地', 49.35, 119.72, CampType.camp, '莫日格勒河畔蒙古包', true, true, false, 150),
    Campsite('cp18', '阿尔山天池营地', 47.18, 119.96, CampType.camp, '火山天池森林营地', true, true, false, 60),
    Campsite('cp19', '长白山北坡营地', 42.02, 128.07, CampType.camp, '原始森林温泉营地', true, true, false, 120),
    Campsite('cp20', '漠河北极村营地', 53.48, 122.36, CampType.camp, '中国最北露营地', true, true, false, 80),

    // 🅿️ 停车场 / 驿站
    Campsite('cp21', '318国道通麦驿站', 30.10, 95.07, CampType.parking, '川藏线重要休整点', true, true, false, 0),
    Campsite('cp22', '318国道理塘驿站', 30.00, 100.27, CampType.parking, '世界高城补给站', true, true, false, 0),
    Campsite('cp23', '318国道八宿驿站', 30.05, 96.92, CampType.parking, '怒江72拐前休整点', true, true, false, 0),
    Campsite('cp24', '青藏线唐古拉山口驿站', 32.87, 91.92, CampType.parking, '海拔5231m 极限补给', false, true, false, 0),
    Campsite('cp25', '青藏线沱沱河驿站', 34.22, 92.44, CampType.parking, '长江源头补给站', true, true, false, 0),
    Campsite('cp26', '新藏线三十里营房', 36.37, 78.03, CampType.parking, 'G219重要兵站+补给', true, true, false, 0),
    Campsite('cp27', '独库公路乔尔玛服务区', 43.52, 84.37, CampType.parking, '独库北段核心服务区', true, true, false, 0),
    Campsite('cp28', '独库公路巴音布鲁克停车场', 43.02, 84.13, CampType.parking, '天鹅湖景区停车场', true, true, false, 20),
    Campsite('cp29', '独库公路库车大峡谷停车场', 41.99, 83.18, CampType.parking, '神秘大峡谷入口', true, true, false, 30),
    Campsite('cp30', '草原天路桦皮岭停车场', 41.06, 115.43, CampType.parking, '草原天路东入口', true, true, false, 0),
    Campsite('cp31', '张北草原停车场', 41.06, 114.72, CampType.parking, '草原天路中段', true, true, false, 0),
    Campsite('cp32', '皖南川藏线储家滩停车场', 30.32, 118.62, CampType.parking, '摄影天堂停车点', true, false, false, 0),
    Campsite('cp33', '黄山汤口换乘中心', 30.07, 118.18, CampType.parking, '黄山大巴接驳+停车场', true, true, false, 50),
    Campsite('cp34', '千岛湖中心湖区停车场', 29.60, 119.03, CampType.parking, '湖区游船码头停车场', true, true, false, 40),
    Campsite('cp35', '莫干山庾村停车场', 30.60, 119.87, CampType.parking, '莫干山旅游集散地', true, true, false, 30),
    Campsite('cp36', '桂林阳朔停车场', 24.78, 110.49, CampType.parking, '十里画廊入口', true, true, false, 20),
    Campsite('cp37', '漓江杨堤停车场', 24.98, 110.42, CampType.parking, '漓江竹筏起点', true, false, false, 10),
    Campsite('cp38', '张家界森林公园停车场', 29.32, 110.42, CampType.parking, '武陵源核心景区', true, true, false, 30),
    Campsite('cp39', '张家界天门山停车场', 29.06, 110.48, CampType.parking, '天门山索道站', true, true, false, 25),
    Campsite('cp40', '云南泸沽湖大落水停车场', 27.68, 100.79, CampType.parking, '泸沽湖核心区停车', true, true, false, 20),
    Campsite('cp41', '洱海才村停车场', 25.67, 100.17, CampType.parking, '骑行环湖起点', true, true, false, 0),
    Campsite('cp42', '青海湖二郎剑停车场', 36.59, 100.44, CampType.parking, '青海湖主景区', true, true, false, 30),
    Campsite('cp43', '茶卡盐湖停车场', 36.79, 99.08, CampType.parking, '天空之镜景区', true, true, false, 30),
    Campsite('cp44', '额济纳旗胡杨林停车场', 41.97, 101.08, CampType.parking, '胡杨林景区入口', true, true, false, 30),
    Campsite('cp45', '北疆喀纳斯贾登峪停车场', 48.13, 87.08, CampType.parking, '喀纳斯景区大门', true, true, false, 40),
    Campsite('cp46', '色达喇荣停车场', 32.30, 100.40, CampType.parking, '五明佛学院停车场', true, true, false, 10),
    Campsite('cp47', '若尔盖九曲黄河停车场', 33.48, 102.48, CampType.parking, '黄河第一湾观景', true, true, false, 20),
    Campsite('cp48', '稻城亚丁游客中心停车场', 28.57, 100.35, CampType.parking, '亚丁景区入口', true, true, false, 30),
    Campsite('cp49', '太行大峡谷停车场', 36.04, 113.77, CampType.parking, '挂壁公路起点', true, true, false, 20),
    Campsite('cp50', '林芝巴松措停车场', 30.29, 94.08, CampType.parking, '藏东明珠', true, true, false, 20),

    // 🏕️ 房车营地专用
    Campsite('cp51', '海南博鳌亚洲湾房车营地', 19.15, 110.58, CampType.rv, '滨海房车营地，水电桩齐全', true, true, false, 150),
    Campsite('cp52', '厦门环岛路房车营地', 24.44, 118.10, CampType.rv, '滨海大道房车停靠', true, true, false, 100),
    Campsite('cp53', '青岛崂山山海营地', 36.14, 120.67, CampType.rv, '山海之间房车停泊', true, true, false, 120),
    Campsite('cp54', '大连金石滩房车营地', 39.07, 121.99, CampType.rv, '黄金海岸房车站', true, true, false, 130),
    Campsite('cp55', '桂林漓江房车基地', 25.23, 110.22, CampType.rv, '山水间的移动之家', true, true, false, 100),
    Campsite('cp56', '大理洱海房车基地', 25.75, 100.20, CampType.rv, '苍山洱海间的停泊', true, true, false, 140),
    Campsite('cp57', '成都温江房车营地', 30.71, 103.86, CampType.rv, '川藏出发前的补给站', true, true, false, 120),
    Campsite('cp58', '西安临潼房车营地', 34.38, 109.21, CampType.rv, '兵马俑旁的房车之家', true, true, false, 110),
    Campsite('cp59', '杭州西湖房车营地', 30.24, 120.12, CampType.rv, '西湖西线房车泊位', true, true, false, 130),
    Campsite('cp60', '昆明滇池房车基地', 24.97, 102.67, CampType.rv, '滇池畔房车之家', true, true, false, 120),
  ];
}

// ── 模型 ──

class GasStation {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final List<String> fuelGrades;    // ['92','95','98']
  final bool motorbikeProhibited;   // 禁摩加油站
  const GasStation(this.id, this.name, this.lat, this.lng, this.fuelGrades, this.motorbikeProhibited);
}

enum CampType { camp, parking, rv }

class Campsite {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final CampType type;
  final String description;
  final bool hasWater;
  final bool hasToilet;
  final bool hasShower;
  final int feeEstimate; // 预估费用(元)

  const Campsite(this.id, this.name, this.lat, this.lng, this.type,
      this.description, this.hasWater, this.hasToilet, this.hasShower, this.feeEstimate);
}
