import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../providers/scenario_provider.dart';
import '../providers/trip_provider.dart';
import '../config/scenario_config.dart';
import '../services/amap_service.dart';
import '../services/location_service.dart';
import '../services/tracking_service.dart';
import '../services/poi_service.dart';
import '../models/trip_model.dart';
import '../theme/app_theme.dart';
import 'search_page.dart';
import 'navigation_page.dart';
import 'route_library_page.dart';
import 'route_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WeatherInfo? _weather;
  List<String> _trafficAlerts = [];
  List<String> _supplyCategories = [];
  List<PoiItem> _supplies = [];
  List<PoiItem> _photoSpots = [];
  bool _loadingWeather = true;
  bool _loadingSupplies = false;
  String _currentSupplyCategory = '';
  bool _showSOSPanel = false;

  List<GasStation> _gasStations = [];
  List<Campsite> _campsites = [];
  bool _loadingPoi = false;

  final _amap = AmapService.instance;
  final _loc = LocationService.instance;

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _loadTrafficAlerts();
    _loadPoi();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = context.read<ScenarioProvider>().scenario;
    final cfg = ScenarioConfig.of(s);
    if (_supplyCategories.isEmpty || _supplyCategories.first != cfg.supplyCategories.first) {
      _supplyCategories = List.from(cfg.supplyCategories);
      if (_supplyCategories.isNotEmpty) {
        _loadSupplies(_supplyCategories.first);
      }
    }
  }

  Future<void> _loadWeather() async {
    setState(() => _loadingWeather = true);
    final w = await _amap.fetchWeather(_loc.latitude, _loc.longitude);
    if (mounted) setState(() { _weather = w; _loadingWeather = false; });
  }

  Future<void> _loadTrafficAlerts() async {
    final a = await _amap.fetchTrafficAlerts();
    if (mounted) setState(() => _trafficAlerts = a);
  }

  Future<void> _loadSupplies(String category) async {
    setState(() { _loadingSupplies = true; _currentSupplyCategory = category; });
    final s = await _amap.fetchSupplyStations(category, _loc.latitude, _loc.longitude);
    if (mounted) setState(() { _supplies = s; _loadingSupplies = false; });
  }

  Future<void> _loadPhotoSpots() async {
    final s = await _amap.fetchPhotoSpots(_loc.latitude, _loc.longitude);
    if (mounted) setState(() => _photoSpots = s);
  }

  void _loadPoi() {
    if (_loadingPoi) return;
    setState(() => _loadingPoi = true);
    final poi = PoiService.instance;
    final gs = poi.searchGasStations(_loc.latitude, _loc.longitude);
    final cs = poi.searchCampsites(_loc.latitude, _loc.longitude);
    if (mounted) setState(() {
      _gasStations = gs;
      _campsites = cs;
      _loadingPoi = false;
    });
  }

  void _startTrip() {
    final scenario = context.read<ScenarioProvider>().scenario;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NavigationPage(scenario: scenario)),
    );
  }

  void _openRouteLibrary() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RouteLibraryPage()),
    );
  }

  void _continueTrip(TripModel trip) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NavigationPage(
          scenario: trip.scenario,

        ),
      ),
    );
  }

  void _showEndTripSheet(TripModel trip) {
    final tracking = TrackingService.instance;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('要结束今天的行程吗？',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  final provider = context.read<TripProvider>();
                  provider.pauseTrip();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '暂停，明天继续',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  final provider = context.read<TripProvider>();
                  if (tracking.isTracking) {
                    tracking.stopTracking();
                    provider.completeTrip(
                      finalDistanceKm: tracking.currentDistance,
                      finalDurationSec: (trip.accumulatedSeconds),
                    );
                  } else {
                    provider.completeTrip(
                      finalDistanceKm: trip.totalDistanceKm,
                      finalDurationSec: trip.accumulatedSeconds,
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '结束整个行程',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('取消', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// SOS 紧急求助面板
  void _toggleSOSPanel() {
    setState(() => _showSOSPanel = !_showSOSPanel);
  }

  Widget _buildSOSPanel(Color warningColor) {
    final lat = _loc.latitude.toStringAsFixed(5);
    final lng = _loc.longitude.toStringAsFixed(5);
    final timeStr = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    final amapLink = 'https://uri.amap.com/marker?position=$lng,$lat&name=SOS&src=quye';
    final sosMsg = '【去野SOS紧急求助】\n'
        '时间：$timeStr\n'
        '坐标：$lat, $lng\n'
        '高德导航：$amapLink\n'
        '（此消息由去野App自动生成，请尽快与我联系）';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: warningColor.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: warningColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.warning_amber_rounded, color: warningColor, size: 22),
              ),
              const SizedBox(width: 12),
              const Text('紧急求助', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showSOSPanel = false),
                child: Container(width: 32, height: 32,
                  decoration: BoxDecoration(color: AppTheme.secondaryBg, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.close, size: 18, color: AppTheme.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location + Amap deep link card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: warningColor.withOpacity(0.15)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.location_on, size: 16, color: warningColor),
                const SizedBox(width: 6),
                Text('$lat, $lng', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: warningColor, fontFamily: 'SF Mono')),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.link, size: 14, color: AppTheme.textAux),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(amapLink, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontFamily: 'SF Mono'),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 14),

          // Auto-generated SOS message preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(sosMsg, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, height: 1.6)),
          ),
          const SizedBox(height: 14),

          // Copy SOS message (main action)
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: sosMsg));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('求助消息已复制！可粘贴到微信/SMS发送'),
                    backgroundColor: AppTheme.warning, behavior: SnackBarBehavior.floating),
                );
              },
              icon: const Icon(Icons.content_copy, size: 20),
              label: const Text('复制求助消息（微信/SMS发送）', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: warningColor, foregroundColor: Colors.white,
                elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Copy Amap navigation link
          SizedBox(
            width: double.infinity, height: 56,
            child: OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: amapLink));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('高德导航链接已复制！粘贴到浏览器可一键导航'),
                    backgroundColor: const Color(0xFF1565C0), behavior: SnackBarBehavior.floating),
                );
              },
              icon: const Icon(Icons.navigation, size: 20),
              label: const Text('复制高德导航链接', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1565C0),
                side: BorderSide(color: const Color(0xFF1565C0).withOpacity(0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Share buttons row
          Row(children: [
            Expanded(
              child: SizedBox(height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: sosMsg));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已复制消息，请打开微信粘贴发送'),
                        backgroundColor: const Color(0xFF07C160), behavior: SnackBarBehavior.floating),
                    );
                    setState(() => _showSOSPanel = false);
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('分享微信', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: BorderSide(color: AppTheme.divider),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: sosMsg));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已复制消息，请打开短信粘贴发送'),
                        backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating),
                    );
                    setState(() => _showSOSPanel = false);
                  },
                  icon: const Icon(Icons.sms, size: 18),
                  label: const Text('发送短信', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: BorderSide(color: AppTheme.divider),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 10),

          // Hospital + Police row
          Row(children: [
            Expanded(
              child: SizedBox(height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('正在导航至最近医院...'), behavior: SnackBarBehavior.floating),
                    );
                    setState(() => _showSOSPanel = false);
                  },
                  icon: const Icon(Icons.local_hospital, size: 18),
                  label: const Text('附近医院', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: warningColor,
                    side: BorderSide(color: warningColor.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('正在导航至最近派出所...'), behavior: SnackBarBehavior.floating),
                    );
                    setState(() => _showSOSPanel = false);
                  },
                  icon: const Icon(Icons.local_police, size: 18),
                  label: const Text('附近派出所', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: BorderSide(color: AppTheme.divider),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildTripStatusCard(TripProvider tripProv, OutdoorScenario scenario) {
    final active = tripProv.activeTrip;
    final sceneColor = ScenarioConfig.of(scenario).primaryColor;

    if (active != null) return _buildActiveTripCard(active, sceneColor);
    final latestCompleted = tripProv.completedTrips.isNotEmpty ? tripProv.completedTrips.first : null;
    if (latestCompleted != null) return _buildCompletedReviewCard(latestCompleted, scenario);
    return _buildEmptyState(scenario);
  }

  Widget _buildActiveTripCard(TripModel trip, Color sceneColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8,
                decoration: BoxDecoration(color: sceneColor, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('行程进行中', style: TextStyle(fontSize: 12, color: sceneColor, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Text(trip.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          Text(ScenarioConfig.of(trip.scenario).label,
            style: TextStyle(fontSize: 12, color: sceneColor.withOpacity(0.7))),
          const SizedBox(height: 8),
          Text('已${ScenarioConfig.of(trip.scenario).label} ${trip.formatDuration} · ${trip.formatDistance}',
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          Text('最后活跃：${trip.formatLastActive}', style: const TextStyle(fontSize: 12, color: AppTheme.textAux)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => _continueTrip(trip),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sceneColor, foregroundColor: Colors.white, elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(0, 44),
                    ),
                    child: const Text('继续行程', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _showEndTripSheet(trip),
                child: Text('结束行程', style: TextStyle(fontSize: 16, color: sceneColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedReviewCard(TripModel trip, OutdoorScenario scenario) {
    final sceneColor = ScenarioConfig.of(scenario).primaryColor;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: _cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120, width: double.infinity, color: AppTheme.secondaryBg,
            child: Center(
              child: Icon(Icons.route, size: 40, color: sceneColor.withOpacity(0.3)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text('${trip.completedAt?.month ?? trip.createdAt.month}/${trip.completedAt?.day ?? trip.createdAt.day} · ${trip.formatDistance} · ${trip.formatDuration}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => RouteDetailPage(trip: trip)),
                      ),
                      child: Text('查看回顾', style: TextStyle(fontSize: 14, color: sceneColor)),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => RouteDetailPage(trip: trip)),
                      ),
                      child: Text('写心得', style: TextStyle(fontSize: 14, color: sceneColor)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(OutdoorScenario scenario) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: _cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppTheme.secondaryBg, borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(Icons.explore_outlined, size: 32, color: AppTheme.textAux),
          ),
          const SizedBox(height: 12),
          const Text('开始记录你的第一次出行',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          const Text('每一次出发都值得被记住',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          SizedBox(
            width: 160, height: 40,
            child: ElevatedButton(
              onPressed: _startTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: ScenarioConfig.of(scenario).primaryColor,
                foregroundColor: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('开始行程', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    if (_loadingWeather) {
      return _cardShell(const Center(child: SizedBox(height: 80, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))));
    }
    final w = _weather!;
    return _cardShell(
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(w.weatherIcon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${w.temperature}°  ${w.weatherDesc}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    Text('风速${w.windSpeed}级 · 湿度${w.humidity}% · UV ${w.uvIndex}',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _weatherTag('UV指数', '${w.uvIndex}', w.uvIndex > 6 ? AppTheme.warning : const Color(0xFF2E7D32)),
                const SizedBox(width: 16),
                _weatherTag('日出', w.sunrise, AppTheme.textSecondary),
                const SizedBox(width: 16),
                _weatherTag('日落', w.sunset, AppTheme.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherTag(String label, String value, Color color) {
    return Row(
      children: [
        Text('$label ', style: const TextStyle(fontSize: 12, color: AppTheme.textAux)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _buildTrafficCard() {
    return _cardShell(
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFA726).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFA726), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('路况预警', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  ..._trafficAlerts.map((a) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(children: [
                      Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.textAux, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(a, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
                    ]),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplyCard(OutdoorScenario scenario) {
    final sceneColor = ScenarioConfig.of(scenario).primaryColor;
    return _cardShell(
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('附近补给站', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _supplyCategories.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c, style: TextStyle(
                      fontSize: 13, color: _currentSupplyCategory == c ? sceneColor : AppTheme.textSecondary,
                    )),
                    selected: _currentSupplyCategory == c,
                    selectedColor: sceneColor.withOpacity(0.1),
                    backgroundColor: AppTheme.secondaryBg,
                    side: BorderSide.none,
                    onSelected: (_) => _loadSupplies(c),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 8),
            if (_loadingSupplies)
              const Padding(padding: EdgeInsets.all(24), child: Center(child: LinearProgressIndicator(minHeight: 2)))
            else ..._supplies.map((s) => _supplyRow(s, sceneColor)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _supplyRow(PoiItem item, Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                Text(item.address, style: const TextStyle(fontSize: 12, color: AppTheme.textAux)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(item.formatDistance, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(width: 12),
          SizedBox(
            height: 36,
            child: TextButton(
              onPressed: () => _startTrip(),
              style: TextButton.styleFrom(
                foregroundColor: primary, padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: primary.withOpacity(0.3)),
                ),
              ),
              child: const Text('导航', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassCard() {
    return _cardShell(
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 80, height: 80,
              child: CustomPaint(painter: _CompassPainter(heading: _loc.heading)),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('方向', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                Text('${_loc.heading.toInt()}°',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: AppTheme.textPrimary, fontFamily: 'SF Pro Display')),
                const SizedBox(height: 12),
                const Text('海拔', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                Text('${_loc.altitude.toInt()}m',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: AppTheme.textPrimary, fontFamily: 'SF Pro Display')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunPhotoCard() {
    if (_photoSpots.isEmpty) _loadPhotoSpots();
    return _cardShell(
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('日出日落', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Row(
              children: [
                _sunBlock('日出', _weather?.sunrise ?? '--'),
                const SizedBox(width: 32),
                _sunBlock('日落', _weather?.sunset ?? '--'),
                const SizedBox(width: 32),
                _sunBlock('白天', _weather != null ? '13h' : '--'),
              ],
            ),
            const Divider(height: 32, color: AppTheme.divider),
            const Text('附近最佳摄影点', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: _photoSpots.isEmpty
                  ? const Center(child: Text('加载中...', style: TextStyle(fontSize: 12, color: AppTheme.textAux)))
                  : ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photoSpots.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final p = _photoSpots[i];
                  return SizedBox(
                    width: 130,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 130, height: 70,
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(child: Icon(Icons.photo_camera_outlined, size: 24, color: AppTheme.textAux)),
                        ),
                        const SizedBox(height: 6),
                        Text(p.name, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(p.formatDistance, style: const TextStyle(fontSize: 11, color: AppTheme.textAux)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sunBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _buildMapTrackCard() {
    return _cardShell(
      InkWell(
        onTap: () => _startTrip(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200, width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFEBF0E6),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_outlined, size: 48, color: const Color(0xFF2E7D32).withOpacity(0.25)),
                        const SizedBox(height: 8),
                        const Text('高德地图', style: TextStyle(fontSize: 12, color: AppTheme.textAux)),
                      ],
                    ),
                  ),
                  Positioned(
                    left: MediaQuery.of(context).size.width / 2 - 8, top: 90,
                    child: Container(width: 16, height: 16,
                      decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle)),
                  ),
                  const Positioned(
                    top: 12, left: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('· 轨迹：最近3条', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                        Text('· 兴趣点：休息点/拍照点', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(14),
              child: Text('点击查看全屏地图 →', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  double _poiDist(double lat2, double lng2) {
    const r = 6371.0;
    final dLat = (lat2 - _loc.latitude) * 0.0174533;
    final dLng = (lng2 - _loc.longitude) * 0.0174533;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_loc.latitude * 0.0174533) * cos(lat2 * 0.0174533) * sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(max(0, 1 - a)));
  }

  Widget _buildGasStationCard(OutdoorScenario scenario) {
    if (_loadingPoi) return _cardShell(const Center(child: Padding(
      padding: EdgeInsets.all(24),
      child: LinearProgressIndicator(minHeight: 2))));
    final sceneColor = ScenarioConfig.of(scenario).primaryColor;
    final isMoto = scenario == OutdoorScenario.moto;
    final top = _gasStations.where((g) => !g.motorbikeProhibited || isMoto).take(4).toList();
    if (top.isEmpty) return const SizedBox.shrink();
    return _cardShell(
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.local_gas_station, size: 20, color: sceneColor),
              const SizedBox(width: 8),
              const Text('附近加油站', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            ]),
            const SizedBox(height: 12),
            ...top.map((g) {
              final dist = _poiDist(g.lat, g.lng);
              final distStr = dist < 1 ? '${(dist * 1000).toInt()}m' : '${dist.toStringAsFixed(1)}km';
              final grades = g.fuelGrades.join('/');
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: g.motorbikeProhibited ? const Color(0xFFEF5350).withOpacity(0.08) : sceneColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(g.motorbikeProhibited ? Icons.block : Icons.local_gas_station,
                        size: 16, color: g.motorbikeProhibited ? const Color(0xFFEF5350) : sceneColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Flexible(child: Text(g.name, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary), overflow: TextOverflow.ellipsis)),
                          if (g.motorbikeProhibited && isMoto)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF5350).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Text('禁摩', style: TextStyle(fontSize: 9, color: Color(0xFFEF5350))),
                            ),
                        ]),
                        Text('$grades    $distStr', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ]),
                    ),
                    SizedBox(
                      height: 30,
                      child: TextButton(
                        onPressed: () => _startTrip(),
                        style: TextButton.styleFrom(
                          foregroundColor: sceneColor, padding: const EdgeInsets.symmetric(horizontal: 10),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(color: sceneColor.withOpacity(0.3)),
                          ),
                        ),
                        child: const Text('导航', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCampsiteCard(OutdoorScenario scenario) {
    if (_loadingPoi) return _cardShell(const Center(child: Padding(
      padding: EdgeInsets.all(24),
      child: LinearProgressIndicator(minHeight: 2))));
    final sceneColor = ScenarioConfig.of(scenario).primaryColor;
    final top5 = _campsites.take(5).toList();
    if (top5.isEmpty) return const SizedBox.shrink();
    return _cardShell(
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.cabin, size: 20, color: Color(0xFF5D4037)),
              const SizedBox(width: 8),
              const Text('附近营地/停车', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            ]),
            const SizedBox(height: 12),
            ...top5.map((c) {
              final dist = _poiDist(c.lat, c.lng);
              final distStr = dist < 1 ? '${(dist * 1000).toInt()}m' : '${dist.toStringAsFixed(1)}km';
              final typeIcon = c.type == CampType.camp ? '⛺' : (c.type == CampType.rv ? '🚐' : '🅿️');
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: AppTheme.secondaryBg, borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text(typeIcon, style: const TextStyle(fontSize: 16))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c.name, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                      Text(c.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      const SizedBox(height: 2),
                      Row(children: [
                        if (c.hasWater) ...[const Icon(Icons.water_drop, size: 12, color: AppTheme.textAux), const SizedBox(width: 3)],
                        if (c.hasToilet) ...[const Icon(Icons.wc, size: 12, color: AppTheme.textAux), const SizedBox(width: 3)],
                        if (c.hasShower) ...[const Icon(Icons.shower, size: 12, color: AppTheme.textAux), const SizedBox(width: 4)],
                        if (c.feeEstimate > 0) Text('¥${c.feeEstimate}  ', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                        Text(distStr, style: TextStyle(fontSize: 11, color: sceneColor)),
                      ]),
                    ]),
                  ),
                ]),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _cardShell(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: _cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  static const _cardShadow = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  @override
  Widget build(BuildContext context) {
    final scenario = context.watch<ScenarioProvider>().scenario;
    final sceneColor = ScenarioConfig.of(scenario).primaryColor;
    final tripProv = context.watch<TripProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text('去野 · ${ScenarioConfig.of(scenario).label}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 24, color: AppTheme.textPrimary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined, size: 24, color: AppTheme.textPrimary),
            tooltip: '路线库',
            onPressed: _openRouteLibrary,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: _buildTripStatusCard(tripProv, scenario),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _startTrip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: sceneColor, foregroundColor: Colors.white, elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('＋ 开始新的行程', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  if (_weather != null) _buildWeatherCard(),
                  _buildTrafficCard(),
                  _buildSupplyCard(scenario),
                  _buildCompassCard(),
                  _buildSunPhotoCard(),
                  _buildMapTrackCard(),
                  _buildGasStationCard(scenario),
                  _buildCampsiteCard(scenario),
                  const SizedBox(height: 80),
                ]),
              ),
            ],
          ),

          // SOS 悬浮按钮
          Positioned(
            right: 20, bottom: 24,
            child: GestureDetector(
              onTap: _toggleSOSPanel,
              child: Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFE53935).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
              ),
            ),
          ),

          // SOS 面板
          if (_showSOSPanel)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Material(
                color: Colors.transparent,
                child: _buildSOSPanel(const Color(0xFFE53935)),
              ),
            ),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double heading;
  _CompassPainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy) - 4;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFE5E5E5);
    canvas.drawCircle(Offset(cx, cy), r, paint);
    final ang = heading * pi / 180;
    final arrow = Paint()..style = PaintingStyle.fill..color = const Color(0xFFD32F2F);
    final tip = Offset(cx + sin(ang) * (r - 4), cy - cos(ang) * (r - 4));
    canvas.drawCircle(tip, 4, arrow);
    canvas.drawCircle(Offset(cx, cy), 2, Paint()..style=PaintingStyle.fill..color=AppTheme.textPrimary);
    final tp = TextPainter(
      text: const TextSpan(text: 'N', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
      textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - r + tp.height / 2));
  }

  @override
  bool shouldRepaint(_CompassPainter old) => old.heading != heading;
}
