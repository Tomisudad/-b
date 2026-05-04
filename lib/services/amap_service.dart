import 'dart:math';

/// 高德地图 API 服务（模拟数据层）
class AmapService {
  static final AmapService instance = AmapService._();
  AmapService._();

  // ---- 天气 ----
  Future<WeatherInfo> fetchWeather(double lat, double lng) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return WeatherInfo(
      temperature: 18 + Random().nextInt(10),
      weatherDesc: ['晴', '多云', '阴', '小雨'][Random().nextInt(4)],
      windSpeed: 2 + Random().nextInt(5),
      humidity: 40 + Random().nextInt(30),
      uvIndex: Random().nextInt(11),
      sunrise: '05:42',
      sunset: '18:56',
    );
  }

  // ---- 路况预警 ----
  Future<List<String>> fetchTrafficAlerts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ['当前路段畅通，放心出发'];
  }

  // ---- 补给站 ----
  Future<List<PoiItem>> fetchSupplyStations(String category, double lat, double lng) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.generate(3, (i) => PoiItem(
      name: '$category-${i + 1}',
      distance: 0.3 + Random().nextDouble() * 2.0,
      rating: 4.0 + Random().nextDouble(),
      address: '附近${(0.5 + i).toStringAsFixed(1)}km',
    ));
  }

  // ---- 摄影点 ----
  Future<List<PoiItem>> fetchPhotoSpots(double lat, double lng) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.generate(4, (i) => PoiItem(
      name: '西湖日落点${i + 1}',
      distance: 0.5 + i * 0.8,
      rating: 4.3 + i * 0.1,
      address: '距当前位置${(0.5 + i * 0.8).toStringAsFixed(1)}km',
    ));
  }
}

// ---- 数据模型 ----
class WeatherInfo {
  final int temperature;
  final String weatherDesc;
  final int windSpeed;
  final int humidity;
  final int uvIndex;
  final String sunrise;
  final String sunset;

  const WeatherInfo({
    required this.temperature,
    required this.weatherDesc,
    this.windSpeed = 0,
    this.humidity = 0,
    this.uvIndex = 0,
    this.sunrise = '',
    this.sunset = '',
  });

  String get weatherIcon {
    switch (weatherDesc) {
      case '晴': return '☀️';
      case '多云': return '⛅';
      case '阴': return '☁️';
      case '小雨': return '🌧️';
      default: return '🌤️';
    }
  }
}

class PoiItem {
  final String name;
  final double distance;
  final double rating;
  final String address;

  const PoiItem({
    required this.name,
    required this.distance,
    required this.rating,
    required this.address,
  });

  String get formatDistance => distance < 1 ? '${(distance * 1000).toInt()}m' : '${distance.toStringAsFixed(1)}km';
}
