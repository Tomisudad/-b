import 'dart:async';
import 'package:flutter/foundation.dart';

enum DownloadStatus { notDownloaded, downloading, paused, downloaded }

class MapRegion {
  final String id;
  final String name;
  final String province;
  final double sizeMB;
  final int tileCount;
  final double lat;
  final double lng;

  const MapRegion({
    required this.id,
    required this.name,
    required this.province,
    required this.sizeMB,
    required this.tileCount,
    this.lat = 0,
    this.lng = 0,
  });
}

class OfflineMapProvider extends ChangeNotifier {
  final Map<String, DownloadStatus> _statuses = {};
  final Map<String, double> _progress = {};
  final Map<String, Timer?> _timers = {};

  static const List<MapRegion> availableRegions = [
    MapRegion(id: 'beijing', name: '\u5317\u4eac\u5e02', province: '\u534e\u5317', sizeMB: 128, tileCount: 4200, lat: 39.9, lng: 116.4),
    MapRegion(id: 'shanghai', name: '\u4e0a\u6d77\u5e02', province: '\u534e\u4e1c', sizeMB: 96, tileCount: 3100, lat: 31.2, lng: 121.5),
    MapRegion(id: 'guangzhou', name: '\u5e7f\u5dde\u5e02', province: '\u534e\u5357', sizeMB: 112, tileCount: 3800, lat: 23.1, lng: 113.3),
    MapRegion(id: 'shenzhen', name: '\u6df1\u5733\u5e02', province: '\u534e\u5357', sizeMB: 88, tileCount: 2900, lat: 22.5, lng: 114.1),
    MapRegion(id: 'hangzhou', name: '\u676d\u5dde\u5e02', province: '\u534e\u4e1c', sizeMB: 104, tileCount: 3500, lat: 30.3, lng: 120.2),
    MapRegion(id: 'chengdu', name: '\u6210\u90fd\u5e02', province: '\u897f\u5357', sizeMB: 156, tileCount: 5200, lat: 30.6, lng: 104.1),
    MapRegion(id: 'chongqing', name: '\u91cd\u5e86\u5e02', province: '\u897f\u5357', sizeMB: 144, tileCount: 4800, lat: 29.5, lng: 106.6),
    MapRegion(id: 'kunming', name: '\u6606\u660e\u5e02', province: '\u897f\u5357', sizeMB: 132, tileCount: 4400, lat: 25.0, lng: 102.7),
    MapRegion(id: 'lijiang', name: '\u4e3d\u6c5f\u5e02', province: '\u897f\u5357', sizeMB: 78, tileCount: 2600, lat: 26.9, lng: 100.2),
    MapRegion(id: 'dali', name: '\u5927\u7406\u5dde', province: '\u897f\u5357', sizeMB: 68, tileCount: 2200, lat: 25.6, lng: 100.3),
    MapRegion(id: 'lhasa', name: '\u62c9\u8428\u5e02', province: '\u897f\u85cf', sizeMB: 198, tileCount: 6600, lat: 29.6, lng: 91.1),
    MapRegion(id: 'xining', name: '\u897f\u5b81\u5e02', province: '\u897f\u5317', sizeMB: 92, tileCount: 3000, lat: 36.6, lng: 101.8),
    MapRegion(id: 'xian', name: '\u897f\u5b89\u5e02', province: '\u897f\u5317', sizeMB: 118, tileCount: 3900, lat: 34.3, lng: 108.9),
    MapRegion(id: 'wuhan', name: '\u6b66\u6c49\u5e02', province: '\u534e\u4e2d', sizeMB: 108, tileCount: 3600, lat: 30.6, lng: 114.3),
    MapRegion(id: 'changsha', name: '\u957f\u6c99\u5e02', province: '\u534e\u4e2d', sizeMB: 96, tileCount: 3200, lat: 28.2, lng: 112.9),
    MapRegion(id: 'nanjing', name: '\u5357\u4eac\u5e02', province: '\u534e\u4e1c', sizeMB: 100, tileCount: 3300, lat: 32.0, lng: 118.8),
    MapRegion(id: 'suzhou', name: '\u82cf\u5dde\u5e02', province: '\u534e\u4e1c', sizeMB: 72, tileCount: 2400, lat: 31.3, lng: 120.6),
    MapRegion(id: 'qingdao', name: '\u9752\u5c9b\u5e02', province: '\u534e\u4e1c', sizeMB: 86, tileCount: 2800, lat: 36.1, lng: 120.4),
    MapRegion(id: 'dalian', name: '\u5927\u8fde\u5e02', province: '\u4e1c\u5317', sizeMB: 82, tileCount: 2700, lat: 38.9, lng: 121.6),
    MapRegion(id: 'guiyang', name: '\u8d35\u9633\u5e02', province: '\u897f\u5357', sizeMB: 94, tileCount: 3100, lat: 26.6, lng: 106.7),
    MapRegion(id: 'nanning', name: '\u5357\u5b81\u5e02', province: '\u534e\u5357', sizeMB: 106, tileCount: 3500, lat: 22.8, lng: 108.4),
    MapRegion(id: 'guilin', name: '\u6842\u6797\u5e02', province: '\u534e\u5357', sizeMB: 62, tileCount: 2000, lat: 25.3, lng: 110.3),
    MapRegion(id: 'haikou', name: '\u6d77\u53e3\u5e02', province: '\u534e\u5357', sizeMB: 56, tileCount: 1800, lat: 20.0, lng: 110.3),
    MapRegion(id: 'sanya', name: '\u4e09\u4e9a\u5e02', province: '\u534e\u5357', sizeMB: 48, tileCount: 1600, lat: 18.2, lng: 109.5),
    MapRegion(id: 'fuzhou', name: '\u798f\u5dde\u5e02', province: '\u534e\u4e1c', sizeMB: 84, tileCount: 2800, lat: 26.1, lng: 119.3),
    MapRegion(id: 'xiamen', name: '\u53a6\u95e8\u5e02', province: '\u534e\u4e1c', sizeMB: 52, tileCount: 1700, lat: 24.5, lng: 118.1),
    MapRegion(id: 'hefei', name: '\u5408\u80a5\u5e02', province: '\u534e\u4e1c', sizeMB: 90, tileCount: 3000, lat: 31.8, lng: 117.2),
    MapRegion(id: 'zhengzhou', name: '\u90d1\u5dde\u5e02', province: '\u534e\u4e2d', sizeMB: 102, tileCount: 3400, lat: 34.7, lng: 113.6),
    MapRegion(id: 'shijiazhuang', name: '\u77f3\u5bb6\u5e84\u5e02', province: '\u534e\u5317', sizeMB: 94, tileCount: 3100, lat: 38.0, lng: 114.5),
    MapRegion(id: 'taiyuan', name: '\u592a\u539f\u5e02', province: '\u534e\u5317', sizeMB: 86, tileCount: 2800, lat: 37.9, lng: 112.5),
    MapRegion(id: 'hohhot', name: '\u547c\u548c\u6d69\u7279\u5e02', province: '\u534e\u5317', sizeMB: 138, tileCount: 4600, lat: 40.8, lng: 111.7),
    MapRegion(id: 'shenyang', name: '\u6c88\u9633\u5e02', province: '\u4e1c\u5317', sizeMB: 110, tileCount: 3600, lat: 41.8, lng: 123.4),
    MapRegion(id: 'changchun', name: '\u957f\u6625\u5e02', province: '\u4e1c\u5317', sizeMB: 108, tileCount: 3500, lat: 43.9, lng: 125.3),
    MapRegion(id: 'harbin', name: '\u54c8\u5c14\u6ee8\u5e02', province: '\u4e1c\u5317', sizeMB: 152, tileCount: 5000, lat: 45.8, lng: 126.5),
    MapRegion(id: 'urumqi', name: '\u4e4c\u9c81\u6728\u9f50\u5e02', province: '\u897f\u5317', sizeMB: 176, tileCount: 5800, lat: 43.8, lng: 87.6),
    MapRegion(id: 'lanzhou', name: '\u5170\u5dde\u5e02', province: '\u897f\u5317', sizeMB: 98, tileCount: 3200, lat: 36.1, lng: 103.8),
    MapRegion(id: 'yinchuan', name: '\u94f6\u5ddd\u5e02', province: '\u897f\u5317', sizeMB: 76, tileCount: 2500, lat: 38.5, lng: 106.2),
    MapRegion(id: 'zhangjiajie', name: '\u5f20\u5bb6\u754c\u5e02', province: '\u534e\u4e2d', sizeMB: 58, tileCount: 1900, lat: 29.1, lng: 110.5),
    MapRegion(id: 'huangshan', name: '\u9ec4\u5c71\u5e02', province: '\u534e\u4e1c', sizeMB: 54, tileCount: 1800, lat: 29.7, lng: 118.3),
    MapRegion(id: 'yanbian', name: '\u5ef6\u8fb9\u5dde', province: '\u4e1c\u5317', sizeMB: 74, tileCount: 2400, lat: 42.9, lng: 129.5),
    MapRegion(id: 'ganzi', name: '\u7518\u5b5c\u5dde', province: '\u897f\u5357', sizeMB: 166, tileCount: 5500, lat: 30.0, lng: 101.9),
    MapRegion(id: 'linzhi', name: '\u6797\u829d\u5e02', province: '\u897f\u85cf', sizeMB: 128, tileCount: 4200, lat: 29.6, lng: 94.4),
    MapRegion(id: 'aba', name: '\u963f\u575d\u5dde', province: '\u897f\u5357', sizeMB: 144, tileCount: 4800, lat: 31.9, lng: 102.2),
    MapRegion(id: 'dunhuang', name: '\u6566\u714c\u5e02', province: '\u897f\u5317', sizeMB: 88, tileCount: 2900, lat: 40.1, lng: 94.7),
    MapRegion(id: 'kashgar', name: '\u5580\u4ec0\u5730\u533a', province: '\u897f\u5317', sizeMB: 212, tileCount: 7000, lat: 39.5, lng: 76.0),
    MapRegion(id: 'xishuangbanna', name: '\u897f\u53cc\u7248\u7eb3\u5dde', province: '\u897f\u5357', sizeMB: 64, tileCount: 2100, lat: 22.0, lng: 100.8),
    MapRegion(id: 'wuyishan', name: '\u6b66\u5937\u5c71\u5e02', province: '\u534e\u4e1c', sizeMB: 46, tileCount: 1500, lat: 27.7, lng: 118.0),
    MapRegion(id: 'emeishan', name: '\u5ce8\u7709\u5c71\u5e02', province: '\u897f\u5357', sizeMB: 52, tileCount: 1700, lat: 29.6, lng: 103.5),
    MapRegion(id: 'enshi', name: '\u6069\u65bd\u5dde', province: '\u534e\u4e2d', sizeMB: 66, tileCount: 2200, lat: 30.3, lng: 109.5),
    MapRegion(id: 'qianxinan', name: '\u9ed4\u897f\u5357\u5dde', province: '\u897f\u5357', sizeMB: 72, tileCount: 2400, lat: 25.1, lng: 104.9),
  ];

  DownloadStatus statusOf(String regionId) => _statuses[regionId] ?? DownloadStatus.notDownloaded;
  double progressOf(String regionId) => _progress[regionId] ?? 0;

  double get totalDownloadedMB {
    double total = 0;
    for (final r in availableRegions) {
      if (statusOf(r.id) == DownloadStatus.downloaded) total += r.sizeMB;
    }
    return total;
  }

  int get downloadedCount {
    return _statuses.values.where((s) => s == DownloadStatus.downloaded).length;
  }

  void download(String regionId) {
    final current = statusOf(regionId);
    if (current == DownloadStatus.downloaded || current == DownloadStatus.downloading) return;
    final region = availableRegions.firstWhere((r) => r.id == regionId);
    _statuses[regionId] = DownloadStatus.downloading;
    _progress[regionId] = 0;
    _startSimulateDownload(region);
    notifyListeners();
  }

  void pause(String regionId) {
    if (statusOf(regionId) != DownloadStatus.downloading) return;
    _timers[regionId]?.cancel();
    _timers[regionId] = null;
    _statuses[regionId] = DownloadStatus.paused;
    notifyListeners();
  }

  void resume(String regionId) {
    if (statusOf(regionId) != DownloadStatus.paused) return;
    final region = availableRegions.firstWhere((r) => r.id == regionId);
    _startSimulateDownload(region);
    notifyListeners();
  }

  void remove(String regionId) {
    _timers[regionId]?.cancel();
    _timers.remove(regionId);
    _progress.remove(regionId);
    _statuses.remove(regionId);
    notifyListeners();
  }

  void _startSimulateDownload(MapRegion region) {
    _statuses[region.id] = DownloadStatus.downloading;
    notifyListeners();
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      _timers[region.id] = timer;
      _progress[region.id] = (_progress[region.id] ?? 0) + 0.04;
      if (_progress[region.id]! >= 1.0) {
        _progress[region.id] = 1.0;
        _statuses[region.id] = DownloadStatus.downloaded;
        timer.cancel();
        _timers[region.id] = null;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    for (final t in _timers.values) {
      t?.cancel();
    }
    super.dispose();
  }
}
