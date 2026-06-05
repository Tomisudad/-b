class MapConfig {
  // 高德地图配置
  static const String androidApiKey = '你的高德Key';
  static const String iosApiKey = '你的高德Key';

  // 默认地图中心 (成都)
  static const double defaultLat = 30.5728;
  static const double defaultLng = 104.0668;
  static const double defaultZoom = 13.0;

  // 离线地图配置
  static const String offlineMapDir = 'gowild_offline_maps';
  static const double maxOfflineCacheMB = 200;
}
