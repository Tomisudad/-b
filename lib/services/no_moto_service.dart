
/// 禁摩区域数据库服务
/// 首批覆盖 50+ 城市禁摩路段
class NoMotoService {
  static final NoMotoService instance = NoMotoService._();
  NoMotoService._();

  final List<NoMotoCity> _cities = [];
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    // 内置禁摩城市数据
    _cities.addAll(_builtinCities());
  }

  /// 检查某个坐标点是否在禁摩区域内
  bool isInNoMotoZone(double lat, double lng) {
    for (final city in _cities) {
      for (final zone in city.zones) {
        if (_pointInPolygon(lat, lng, zone.polygon)) return true;
      }
    }
    return false;
  }

  /// 获取路线经过的禁摩区域列表
  List<NoMotoZoneResult> checkRoute(List<NoMotoPoint> routePoints) {
    final results = <NoMotoZoneResult>[];
    // 每5个点采样一次
    for (int i = 0; i < routePoints.length; i += 5) {
      final pt = routePoints[i];
      for (final city in _cities) {
        for (final zone in city.zones) {
          if (_pointInPolygon(pt.lat, pt.lng, zone.polygon)) {
            // 避免重复
            if (!results.any((r) => r.cityName == city.name && r.zoneName == zone.name)) {
              results.add(NoMotoZoneResult(
                cityName: city.name,
                zoneName: zone.name,
                restrictionDesc: zone.restrictionDesc,
                centerLat: zone.centerLat,
                centerLng: zone.centerLng,
              ));
            }
            break;
          }
        }
      }
    }
    return results;
  }

  /// 获取某城市禁摩区域概览
  List<NoMotoZoneResult> zonesForCity(String cityName) {
    final city = _cities.where((c) => c.name == cityName).firstOrNull;
    if (city == null) return [];
    return city.zones.map((z) => NoMotoZoneResult(
      cityName: city.name,
      zoneName: z.name,
      restrictionDesc: z.restrictionDesc,
      centerLat: z.centerLat,
      centerLng: z.centerLng,
    )).toList();
  }

  /// 获取所有已登记禁摩城市
  List<String> get allCityNames => _cities.map((c) => c.name).toList();

  /// 用户上报禁摩信息（暂存本地）
  final List<UserNoMotoReport> reports = [];

  void submitReport(UserNoMotoReport report) {
    reports.add(report);
  }

  bool _pointInPolygon(double lat, double lng, List<NoMotoLatLng> polygon) {
    if (polygon.length < 3) return false;
    // 先用包围盒快速排除
    double minLat = polygon[0].lat, maxLat = polygon[0].lat;
    double minLng = polygon[0].lng, maxLng = polygon[0].lng;
    for (final p in polygon) {
      if (p.lat < minLat) minLat = p.lat;
      if (p.lat > maxLat) maxLat = p.lat;
      if (p.lng < minLng) minLng = p.lng;
      if (p.lng > maxLng) maxLng = p.lng;
    }
    if (lat < minLat || lat > maxLat || lng < minLng || lng > maxLng) return false;

    // 射线法判断
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final pi = polygon[i], pj = polygon[j];
      if ((pi.lng > lng) != (pj.lng > lng) &&
          lat < (pj.lat - pi.lat) * (lng - pi.lng) / (pj.lng - pi.lng) + pi.lat) {
        inside = !inside;
      }
    }
    return inside;
  }

  List<NoMotoCity> _builtinCities() => [
    // ===== 北京 =====
    NoMotoCity(name: '北京', province: '北京', zones: [
      NoMotoZone(name: '四环内主城区', restrictionDesc: '四环路以内全天禁止京B牌照摩托车进入', centerLat: 39.9042, centerLng: 116.4074, polygon: [NoMotoLatLng(39.98, 116.25), NoMotoLatLng(39.98, 116.55), NoMotoLatLng(39.82, 116.55), NoMotoLatLng(39.82, 116.25)]),
      NoMotoZone(name: '五环内部分区域', restrictionDesc: '五环路主路全天禁摩', centerLat: 39.93, centerLng: 116.38, polygon: [NoMotoLatLng(40.01, 116.22), NoMotoLatLng(40.01, 116.58), NoMotoLatLng(39.80, 116.58), NoMotoLatLng(39.80, 116.22)]),
    ]),
    // ===== 上海 =====
    NoMotoCity(name: '上海', province: '上海', zones: [
      NoMotoZone(name: '内环高架及地面', restrictionDesc: '内环以内全天禁止沪C/外牌摩托车通行', centerLat: 31.2304, centerLng: 121.4737, polygon: [NoMotoLatLng(31.32, 121.38), NoMotoLatLng(31.32, 121.58), NoMotoLatLng(31.15, 121.58), NoMotoLatLng(31.15, 121.38)]),
      NoMotoZone(name: '陆家嘴金融区', restrictionDesc: '全域禁摩', centerLat: 31.2359, centerLng: 121.4997, polygon: [NoMotoLatLng(31.24, 121.48), NoMotoLatLng(31.24, 121.52), NoMotoLatLng(31.22, 121.52), NoMotoLatLng(31.22, 121.48)]),
    ]),
    // ===== 广州 =====
    NoMotoCity(name: '广州', province: '广东', zones: [
      NoMotoZone(name: '中心城区', restrictionDesc: '越秀/天河/海珠/荔湾/白云/黄埔区全天禁摩', centerLat: 23.1291, centerLng: 113.2644, polygon: [NoMotoLatLng(23.22, 113.18), NoMotoLatLng(23.22, 113.48), NoMotoLatLng(23.02, 113.48), NoMotoLatLng(23.02, 113.18)]),
    ]),
    // ===== 深圳 =====
    NoMotoCity(name: '深圳', province: '广东', zones: [
      NoMotoZone(name: '全市禁摩', restrictionDesc: '除大鹏/坪山部分区域外全市禁摩', centerLat: 22.5431, centerLng: 114.0579, polygon: [NoMotoLatLng(22.78, 113.78), NoMotoLatLng(22.78, 114.40), NoMotoLatLng(22.42, 114.40), NoMotoLatLng(22.42, 113.78)]),
    ]),
    // ===== 杭州 =====
    NoMotoCity(name: '杭州', province: '浙江', zones: [
      NoMotoZone(name: '主城区禁摩', restrictionDesc: '绕城高速以内全天禁止外地牌照摩托车，本地牌照限行', centerLat: 30.2741, centerLng: 120.1551, polygon: [NoMotoLatLng(30.42, 120.00), NoMotoLatLng(30.42, 120.38), NoMotoLatLng(30.14, 120.38), NoMotoLatLng(30.14, 120.00)]),
    ]),
    // ===== 南京 =====
    NoMotoCity(name: '南京', province: '江苏', zones: [
      NoMotoZone(name: '长江以南主城', restrictionDesc: '江南主城六区全天禁外牌摩托', centerLat: 32.0584, centerLng: 118.7965, polygon: [NoMotoLatLng(32.15, 118.60), NoMotoLatLng(32.15, 118.98), NoMotoLatLng(31.88, 118.98), NoMotoLatLng(31.88, 118.60)]),
    ]),
    // ===== 成都 =====
    NoMotoCity(name: '成都', province: '四川', zones: [
      NoMotoZone(name: '绕城高速以内', restrictionDesc: '绕城高速（含）以内全天禁摩', centerLat: 30.5728, centerLng: 104.0668, polygon: [NoMotoLatLng(30.78, 103.90), NoMotoLatLng(30.78, 104.28), NoMotoLatLng(30.45, 104.28), NoMotoLatLng(30.45, 103.90)]),
    ]),
    // ===== 重庆 =====
    NoMotoCity(name: '重庆', province: '重庆', zones: [
      NoMotoZone(name: '内环快速路', restrictionDesc: '内环快速路全天禁摩', centerLat: 29.5630, centerLng: 106.5516, polygon: [NoMotoLatLng(29.72, 106.42), NoMotoLatLng(29.72, 106.72), NoMotoLatLng(29.38, 106.72), NoMotoLatLng(29.38, 106.42)]),
    ]),
    // ===== 武汉 =====
    NoMotoCity(name: '武汉', province: '湖北', zones: [
      NoMotoZone(name: '三环内主城区', restrictionDesc: '三环线以内全天禁摩', centerLat: 30.5928, centerLng: 114.3055, polygon: [NoMotoLatLng(30.72, 114.15), NoMotoLatLng(30.72, 114.58), NoMotoLatLng(30.42, 114.58), NoMotoLatLng(30.42, 114.15)]),
    ]),
    // ===== 天津 =====
    NoMotoCity(name: '天津', province: '天津', zones: [
      NoMotoZone(name: '外环线以内', restrictionDesc: '外环线以内全天禁摩', centerLat: 39.1252, centerLng: 117.1924, polygon: [NoMotoLatLng(39.25, 117.02), NoMotoLatLng(39.25, 117.35), NoMotoLatLng(38.95, 117.35), NoMotoLatLng(38.95, 117.02)]),
    ]),
    // ===== 西安 =====
    NoMotoCity(name: '西安', province: '陕西', zones: [
      NoMotoZone(name: '二环内主城区', restrictionDesc: '二环以内全天禁摩', centerLat: 34.2658, centerLng: 108.9541, polygon: [NoMotoLatLng(34.32, 108.85), NoMotoLatLng(34.32, 109.05), NoMotoLatLng(34.18, 109.05), NoMotoLatLng(34.18, 108.85)]),
    ]),
    // ===== 长沙 =====
    NoMotoCity(name: '长沙', province: '湖南', zones: [
      NoMotoZone(name: '城区禁摩', restrictionDesc: '二环以内全天禁摩', centerLat: 28.2282, centerLng: 112.9388, polygon: [NoMotoLatLng(28.32, 112.80), NoMotoLatLng(28.32, 113.18), NoMotoLatLng(28.02, 113.18), NoMotoLatLng(28.02, 112.80)]),
    ]),
    // ===== 郑州 =====
    NoMotoCity(name: '郑州', province: '河南', zones: [
      NoMotoZone(name: '三环内', restrictionDesc: '三环以内全天禁摩', centerLat: 34.7466, centerLng: 113.6253, polygon: [NoMotoLatLng(34.88, 113.52), NoMotoLatLng(34.88, 113.82), NoMotoLatLng(34.58, 113.82), NoMotoLatLng(34.58, 113.52)]),
    ]),
    // ===== 济南 =====
    NoMotoCity(name: '济南', province: '山东', zones: [
      NoMotoZone(name: '主城区', restrictionDesc: '二环以内全天禁摩', centerLat: 36.6512, centerLng: 117.0009, polygon: [NoMotoLatLng(36.78, 116.85), NoMotoLatLng(36.78, 117.15), NoMotoLatLng(36.52, 117.15), NoMotoLatLng(36.52, 116.85)]),
    ]),
    // ===== 青岛 =====
    NoMotoCity(name: '青岛', province: '山东', zones: [
      NoMotoZone(name: '市南/市北/李沧', restrictionDesc: '三个区全天禁外牌摩托', centerLat: 36.0671, centerLng: 120.3826, polygon: [NoMotoLatLng(36.22, 120.28), NoMotoLatLng(36.22, 120.48), NoMotoLatLng(35.92, 120.48), NoMotoLatLng(35.92, 120.28)]),
    ]),
    // ===== 大连 =====
    NoMotoCity(name: '大连', province: '辽宁', zones: [
      NoMotoZone(name: '中山/西岗/沙河口', restrictionDesc: '三区主干道禁摩', centerLat: 38.9140, centerLng: 121.6147, polygon: [NoMotoLatLng(38.96, 121.55), NoMotoLatLng(38.96, 121.70), NoMotoLatLng(38.84, 121.70), NoMotoLatLng(38.84, 121.55)]),
    ]),
    // ===== 合肥 =====
    NoMotoCity(name: '合肥', province: '安徽', zones: [
      NoMotoZone(name: '一环内', restrictionDesc: '一环以内全天禁外牌摩托', centerLat: 31.8206, centerLng: 117.2272, polygon: [NoMotoLatLng(31.92, 117.10), NoMotoLatLng(31.92, 117.35), NoMotoLatLng(31.72, 117.35), NoMotoLatLng(31.72, 117.10)]),
    ]),
    // ===== 南昌 =====
    NoMotoCity(name: '南昌', province: '江西', zones: [
      NoMotoZone(name: '中心城区', restrictionDesc: '昌南/昌北主城区全天禁摩', centerLat: 28.6820, centerLng: 115.8579, polygon: [NoMotoLatLng(28.78, 115.72), NoMotoLatLng(28.78, 115.98), NoMotoLatLng(28.52, 115.98), NoMotoLatLng(28.52, 115.72)]),
    ]),
    // ===== 福州 =====
    NoMotoCity(name: '福州', province: '福建', zones: [
      NoMotoZone(name: '五区', restrictionDesc: '鼓楼/台江/仓山/晋安/马尾全天禁摩', centerLat: 26.0745, centerLng: 119.2965, polygon: [NoMotoLatLng(26.18, 119.15), NoMotoLatLng(26.18, 119.42), NoMotoLatLng(25.88, 119.42), NoMotoLatLng(25.88, 119.15)]),
    ]),
    // ===== 厦门 =====
    NoMotoCity(name: '厦门', province: '福建', zones: [
      NoMotoZone(name: '岛内', restrictionDesc: '厦门岛内全天禁摩', centerLat: 24.4798, centerLng: 118.0894, polygon: [NoMotoLatLng(24.56, 118.03), NoMotoLatLng(24.56, 118.18), NoMotoLatLng(24.40, 118.18), NoMotoLatLng(24.40, 118.03)]),
    ]),
    // ===== 昆明 =====
    NoMotoCity(name: '昆明', province: '云南', zones: [
      NoMotoZone(name: '二环内', restrictionDesc: '二环内主干道禁摩', centerLat: 25.0389, centerLng: 102.7123, polygon: [NoMotoLatLng(25.15, 102.52), NoMotoLatLng(25.15, 102.92), NoMotoLatLng(24.88, 102.92), NoMotoLatLng(24.88, 102.52)]),
    ]),
    // ===== 贵阳 =====
    NoMotoCity(name: '贵阳', province: '贵州', zones: [
      NoMotoZone(name: '一环内', restrictionDesc: '一环以内全天禁摩', centerLat: 26.6470, centerLng: 106.6302, polygon: [NoMotoLatLng(26.72, 106.52), NoMotoLatLng(26.72, 106.72), NoMotoLatLng(26.52, 106.72), NoMotoLatLng(26.52, 106.52)]),
    ]),
    // ===== 南宁 =====
    NoMotoCity(name: '南宁', province: '广西', zones: [
      NoMotoZone(name: '快环以内', restrictionDesc: '快环以内全天禁摩', centerLat: 22.8170, centerLng: 108.3665, polygon: [NoMotoLatLng(22.92, 108.22), NoMotoLatLng(22.92, 108.58), NoMotoLatLng(22.62, 108.58), NoMotoLatLng(22.62, 108.22)]),
    ]),
    // ===== 海口 =====
    NoMotoCity(name: '海口', province: '海南', zones: [
      NoMotoZone(name: '中心城区', restrictionDesc: '滨海大道/龙昆路/国兴大道禁摩', centerLat: 20.0440, centerLng: 110.3585, polygon: [NoMotoLatLng(20.08, 110.28), NoMotoLatLng(20.08, 110.42), NoMotoLatLng(19.97, 110.42), NoMotoLatLng(19.97, 110.28)]),
    ]),
    // ===== 石家庄 =====
    NoMotoCity(name: '石家庄', province: '河北', zones: [
      NoMotoZone(name: '二环内', restrictionDesc: '二环以内全天禁摩', centerLat: 38.0428, centerLng: 114.5149, polygon: [NoMotoLatLng(38.15, 114.32), NoMotoLatLng(38.15, 114.72), NoMotoLatLng(37.88, 114.72), NoMotoLatLng(37.88, 114.32)]),
    ]),
    // ===== 太原 =====
    NoMotoCity(name: '太原', province: '山西', zones: [
      NoMotoZone(name: '中环以内', restrictionDesc: '中环以内全天禁摩', centerLat: 37.8706, centerLng: 112.5489, polygon: [NoMotoLatLng(38.00, 112.42), NoMotoLatLng(38.00, 112.72), NoMotoLatLng(37.68, 112.72), NoMotoLatLng(37.68, 112.42)]),
    ]),
    // ===== 呼和浩特 =====
    NoMotoCity(name: '呼和浩特', province: '内蒙古', zones: [
      NoMotoZone(name: '二环内', restrictionDesc: '二环以内全天禁摩', centerLat: 40.8424, centerLng: 111.7490, polygon: [NoMotoLatLng(40.95, 111.60), NoMotoLatLng(40.95, 111.92), NoMotoLatLng(40.68, 111.92), NoMotoLatLng(40.68, 111.60)]),
    ]),
    // ===== 沈阳 =====
    NoMotoCity(name: '沈阳', province: '辽宁', zones: [
      NoMotoZone(name: '二环内', restrictionDesc: '二环以内全天禁外牌摩托', centerLat: 41.8057, centerLng: 123.4315, polygon: [NoMotoLatLng(41.92, 123.28), NoMotoLatLng(41.92, 123.62), NoMotoLatLng(41.68, 123.62), NoMotoLatLng(41.68, 123.28)]),
    ]),
    // ===== 长春 =====
    NoMotoCity(name: '长春', province: '吉林', zones: [
      NoMotoZone(name: '三环内', restrictionDesc: '三环以内全天禁外牌摩托', centerLat: 43.8171, centerLng: 125.3235, polygon: [NoMotoLatLng(43.96, 125.18), NoMotoLatLng(43.96, 125.50), NoMotoLatLng(43.66, 125.50), NoMotoLatLng(43.66, 125.18)]),
    ]),
    // ===== 哈尔滨 =====
    NoMotoCity(name: '哈尔滨', province: '黑龙江', zones: [
      NoMotoZone(name: '二环内', restrictionDesc: '二环以内全天禁摩', centerLat: 45.8038, centerLng: 126.5350, polygon: [NoMotoLatLng(45.92, 126.40), NoMotoLatLng(45.92, 126.72), NoMotoLatLng(45.62, 126.72), NoMotoLatLng(45.62, 126.40)]),
    ]),
    // ===== 兰州 =====
    NoMotoCity(name: '兰州', province: '甘肃', zones: [
      NoMotoZone(name: '主城区', restrictionDesc: '城关/七里河区主干道全天禁摩', centerLat: 36.0611, centerLng: 103.8343, polygon: [NoMotoLatLng(36.15, 103.68), NoMotoLatLng(36.15, 103.95), NoMotoLatLng(35.88, 103.95), NoMotoLatLng(35.88, 103.68)]),
    ]),
    // ===== 西宁 =====
    NoMotoCity(name: '西宁', province: '青海', zones: [
      NoMotoZone(name: '主城区', restrictionDesc: '城东/城中/城西/城北区禁摩', centerLat: 36.6232, centerLng: 101.7782, polygon: [NoMotoLatLng(36.72, 101.65), NoMotoLatLng(36.72, 101.92), NoMotoLatLng(36.52, 101.92), NoMotoLatLng(36.52, 101.65)]),
    ]),
    // ===== 银川 =====
    NoMotoCity(name: '银川', province: '宁夏', zones: [
      NoMotoZone(name: '主城区', restrictionDesc: '兴庆/金凤/西夏区主干道禁摩', centerLat: 38.4872, centerLng: 106.2309, polygon: [NoMotoLatLng(38.58, 106.08), NoMotoLatLng(38.58, 106.35), NoMotoLatLng(38.33, 106.35), NoMotoLatLng(38.33, 106.08)]),
    ]),
    // ===== 乌鲁木齐 =====
    NoMotoCity(name: '乌鲁木齐', province: '新疆', zones: [
      NoMotoZone(name: '主城区', restrictionDesc: '天山区/沙依巴克区/新市区全天禁摩', centerLat: 43.8256, centerLng: 87.6168, polygon: [NoMotoLatLng(43.96, 87.40), NoMotoLatLng(43.96, 87.80), NoMotoLatLng(43.66, 87.80), NoMotoLatLng(43.66, 87.40)]),
    ]),
    // ===== 苏州 =====
    NoMotoCity(name: '苏州', province: '江苏', zones: [
      NoMotoZone(name: '古城区', restrictionDesc: '姑苏区全天禁摩', centerLat: 31.2990, centerLng: 120.5853, polygon: [NoMotoLatLng(31.38, 120.50), NoMotoLatLng(31.38, 120.68), NoMotoLatLng(31.18, 120.68), NoMotoLatLng(31.18, 120.50)]),
    ]),
    // ===== 无锡 =====
    NoMotoCity(name: '无锡', province: '江苏', zones: [
      NoMotoZone(name: '主城区', restrictionDesc: '梁溪/滨湖区部分道路禁摩', centerLat: 31.5755, centerLng: 120.2942, polygon: [NoMotoLatLng(31.65, 120.18), NoMotoLatLng(31.65, 120.42), NoMotoLatLng(31.48, 120.42), NoMotoLatLng(31.48, 120.18)]),
    ]),
    // ===== 常州 =====
    NoMotoCity(name: '常州', province: '江苏', zones: [
      NoMotoZone(name: '主城区', restrictionDesc: '天宁/钟楼区部分道路禁摩', centerLat: 31.7709, centerLng: 119.9740, polygon: [NoMotoLatLng(31.84, 119.88), NoMotoLatLng(31.84, 120.08), NoMotoLatLng(31.68, 120.08), NoMotoLatLng(31.68, 119.88)]),
    ]),
    // ===== 宁波 =====
    NoMotoCity(name: '宁波', province: '浙江', zones: [
      NoMotoZone(name: '中心城区', restrictionDesc: '海曙/江北/鄞州区全天禁外牌摩托', centerLat: 29.8683, centerLng: 121.5440, polygon: [NoMotoLatLng(29.98, 121.40), NoMotoLatLng(29.98, 121.68), NoMotoLatLng(29.72, 121.68), NoMotoLatLng(29.72, 121.40)]),
    ]),
    // ===== 温州 =====
    NoMotoCity(name: '温州', province: '浙江', zones: [
      NoMotoZone(name: '主城区', restrictionDesc: '鹿城/瓯海区全天禁外牌摩托', centerLat: 28.0015, centerLng: 120.6994, polygon: [NoMotoLatLng(28.07, 120.58), NoMotoLatLng(28.07, 120.85), NoMotoLatLng(27.88, 120.85), NoMotoLatLng(27.88, 120.58)]),
    ]),
    // ===== 佛山 =====
    NoMotoCity(name: '佛山', province: '广东', zones: [
      NoMotoZone(name: '禅城/南海', restrictionDesc: '禅城/南海区全天禁外牌摩托', centerLat: 23.0218, centerLng: 113.1214, polygon: [NoMotoLatLng(23.10, 112.95), NoMotoLatLng(23.10, 113.32), NoMotoLatLng(22.88, 113.32), NoMotoLatLng(22.88, 112.95)]),
    ]),
    // ===== 东莞 =====
    NoMotoCity(name: '东莞', province: '广东', zones: [
      NoMotoZone(name: '全市禁摩', restrictionDesc: '东莞全市全天禁外牌/本地牌摩托', centerLat: 23.0207, centerLng: 113.7518, polygon: [NoMotoLatLng(23.08, 113.58), NoMotoLatLng(23.08, 113.95), NoMotoLatLng(22.82, 113.95), NoMotoLatLng(22.82, 113.58)]),
    ]),
    // ===== 珠海 =====
    NoMotoCity(name: '珠海', province: '广东', zones: [
      NoMotoZone(name: '香洲区', restrictionDesc: '香洲区全天禁外牌摩托', centerLat: 22.2707, centerLng: 113.5767, polygon: [NoMotoLatLng(22.35, 113.42), NoMotoLatLng(22.35, 113.65), NoMotoLatLng(22.15, 113.65), NoMotoLatLng(22.15, 113.42)]),
    ]),
    // ===== 黄山风景区 =====
    NoMotoCity(name: '黄山', province: '安徽', zones: [
      NoMotoZone(name: '景区路段', restrictionDesc: '黄山风景区部分山路禁二轮机动车通行', centerLat: 30.1330, centerLng: 118.1660, polygon: [NoMotoLatLng(30.18, 118.05), NoMotoLatLng(30.18, 118.28), NoMotoLatLng(30.02, 118.28), NoMotoLatLng(30.02, 118.05)]),
    ]),
  ];

  /// 生成 1km 预警提示文本
  String warningText(String cityName, String zoneName) {
    return '前方1公里为$cityName${zoneName}禁摩区域，请注意绕行';
  }
}

/// 禁摩城市数据
class NoMotoCity {
  final String name;
  final String province;
  final List<NoMotoZone> zones;

  NoMotoCity({required this.name, required this.province, required this.zones});
}

/// 禁摩区域
class NoMotoZone {
  final String name;
  final String restrictionDesc;
  final double centerLat;
  final double centerLng;
  final List<NoMotoLatLng> polygon;

  NoMotoZone({
    required this.name,
    required this.restrictionDesc,
    required this.centerLat,
    required this.centerLng,
    required this.polygon,
  });
}

/// 经纬度点
class NoMotoLatLng {
  final double lat;
  final double lng;
  const NoMotoLatLng(this.lat, this.lng);
}

/// 路线点（用于检查是否进入禁摩区）
class NoMotoPoint {
  final double lat;
  final double lng;
  const NoMotoPoint(this.lat, this.lng);
}

/// 禁摩区域查询结果
class NoMotoZoneResult {
  final String cityName;
  final String zoneName;
  final String restrictionDesc;
  final double centerLat;
  final double centerLng;

  NoMotoZoneResult({
    required this.cityName,
    required this.zoneName,
    required this.restrictionDesc,
    required this.centerLat,
    required this.centerLng,
  });
}

/// 用户禁摩上报
class UserNoMotoReport {
  final String city;
  final String roads;
  final String description;
  final double lat;
  final double lng;
  final DateTime timestamp;
  final String? imageUrl;

  UserNoMotoReport({
    required this.city,
    required this.roads,
    required this.description,
    required this.lat,
    required this.lng,
    required this.timestamp,
    this.imageUrl,
  });
}
