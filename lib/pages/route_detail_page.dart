import 'package:flutter/material.dart';

import '../config/scenario_config.dart';
import '../models/trip_model.dart';
import '../config/app_config.dart';

class RouteDetailPage extends StatelessWidget {
  final TripModel trip;
  const RouteDetailPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final cfg = ScenarioConfig.of(trip.scenario);
    final sceneColor = cfg.primaryColor;
    final emotionPoints = trip.trackPoints.where((p) => p.emotionTag != null).toList();

    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(title: Text(trip.name), backgroundColor: Colors.white),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 200,
            color: sceneColor.withOpacity(0.08),
            child: Center(child: Icon(Icons.route, size: 48, color: sceneColor.withOpacity(0.3))),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white, padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: sceneColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(cfg.label, style: TextStyle(fontSize: 12, color: sceneColor)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(12)),
                  child: Text(trip.status == TripStatus.completed ? '已完成' : '进行中',
                    style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                ),
              ]),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _dataChip('距离', trip.formatDistance),
                _dataChip('用时', trip.formatDuration),
                _dataChip('轨迹点', '${trip.trackPoints.length}'),
                _dataChip('情绪', '${emotionPoints.length}次'),
              ]),
            ]),
          ),
        ),
        SliverToBoxAdapter(child: _buildSceneSpecificData()),
        SliverToBoxAdapter(child: _buildRoadAnalysis()),
        if (trip.personalNote != null)
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white, padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.format_quote, size: 16, color: AppConfig.textSecondary),
                const SizedBox(width: 4),
                Expanded(child: Text(trip.personalNote!, style: const TextStyle(fontSize: 14, color: AppConfig.textPrimary, fontStyle: FontStyle.italic))),
              ]),
            ),
          ),
        SliverToBoxAdapter(child: _buildSupplyPoints()),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        if (emotionPoints.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white, padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('旅途情绪曲线', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppConfig.textPrimary)),
                const SizedBox(height: 4),
                const Text('每次标记的情绪记录在轨迹时间轴上', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                const SizedBox(height: 16),
                SizedBox(height: 80, child: _buildEmotionCurve(emotionPoints, trip.trackPoints.first.timestamp, trip.trackPoints.last.timestamp)),
              ]),
            ),
          ),
        if (emotionPoints.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white, padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 8),
                ...emotionPoints.map((pt) {
                  final meta = emotionMeta(pt.emotionTag!);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Text(meta.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(meta.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(meta.color))),
                      const Spacer(),
                      Text('${pt.timestamp.hour.toString().padLeft(2, '0')}:${pt.timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_on, size: 14, color: AppConfig.textSecondary),
                      const SizedBox(width: 2),
                      Text('${pt.latitude.toStringAsFixed(4)}, ${pt.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
                    ]),
                  );
                }),
              ]),
            ),
          ),
        if (trip.equipmentSnapshot.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white, margin: const EdgeInsets.only(top: 12), padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('装备清单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppConfig.textPrimary)),
                const SizedBox(height: 8),
                ...trip.equipmentSnapshot.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(width: 60, child: Text(e.key, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary))),
                    Expanded(child: Text(e.value.join('、'), style: const TextStyle(fontSize: 13, color: AppConfig.textPrimary))),
                  ]),
                )),
              ]),
            ),
          ),
        SliverToBoxAdapter(child: _buildReviews()),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ]),
    );
  }

  Widget _buildEmotionCurve(List<TrackPoint> emotionPoints, DateTime start, DateTime end) {
    final totalSec = end.difference(start).inSeconds;
    if (totalSec <= 0) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final usableW = constraints.maxWidth;
        return CustomPaint(size: Size(usableW, 80), painter: _EmotionCurvePainter(
          emotionPoints: emotionPoints, start: start, totalSec: totalSec, usableWidth: usableW));
      },
    );
  }

  Widget _buildSceneSpecificData() {
    final cfg = ScenarioConfig.of(trip.scenario);
    final sceneColor = cfg.primaryColor;
    switch (trip.scenario) {
      case OutdoorScenario.cycle: return _buildCycleData(sceneColor);
      case OutdoorScenario.moto: return _buildMotoData(sceneColor);
      case OutdoorScenario.drive: return _buildDriveData(sceneColor);
    }
  }

  Widget _buildCycleData(Color sceneColor) {
    return Container(
      color: Colors.white, margin: const EdgeInsets.only(top: 12), padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.directions_bike, size: 18, color: sceneColor), const SizedBox(width: 6),
          Text('骑行数据', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: sceneColor)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _sceneDataItem('坡度占比', '上坡42% 下坡58%', Icons.trending_up)),
          Expanded(child: _sceneDataItem('累计爬升', '1,280m', Icons.height)),
          Expanded(child: _sceneDataItem('卡路里估算', '~2,450kcal', Icons.local_fire_department)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _sceneDataItem('补水点', '沿线8处', Icons.water_drop)),
          Expanded(child: _sceneDataItem('骑行专用道', '占比65%', Icons.pedal_bike)),
          Expanded(child: _sceneDataItem('平均坡度', '3.2%', Icons.landscape)),
        ]),
      ]),
    );
  }

  Widget _buildMotoData(Color sceneColor) {
    return Container(
      color: Colors.white, margin: const EdgeInsets.only(top: 12), padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.motorcycle, size: 18, color: sceneColor), const SizedBox(width: 6),
          Text('摩旅数据', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: sceneColor)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _sceneDataItem('沿途加油站', '92#: 8处\n95#: 5处\n98#: 2处', Icons.local_gas_station)),
          Expanded(child: _sceneDataItem('最近维修站', '23km外\n祥云摩托车行', Icons.build)),
          Expanded(child: _sceneDataItem('禁摩区域', '无', Icons.block)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _sceneDataItem('摩旅驿站', '3处', Icons.coffee)),
          Expanded(child: _sceneDataItem('弯道预警', '12处', Icons.turn_sharp_left)),
          Expanded(child: _sceneDataItem('海拔变化', '+850m', Icons.terrain)),
        ]),
      ]),
    );
  }

  Widget _buildDriveData(Color sceneColor) {
    return Container(
      color: Colors.white, margin: const EdgeInsets.only(top: 12), padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.directions_car, size: 18, color: sceneColor), const SizedBox(width: 6),
          Text('自驾数据', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: sceneColor)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _sceneDataItem('前方服务区', '32km\n可加油/餐饮', Icons.local_gas_station)),
          Expanded(child: _sceneDataItem('观景台', '5处', Icons.photo_camera)),
          Expanded(child: _sceneDataItem('房车营地', '2处可停', Icons.rv_hookup)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _sceneDataItem('充电桩', '快充4个\n慢充8个', Icons.ev_station)),
          Expanded(child: _sceneDataItem('停车场', '6处', Icons.local_parking)),
          Expanded(child: _sceneDataItem('限高路段', '2处 <=2.5m', Icons.height)),
        ]),
      ]),
    );
  }

  Widget _buildRoadAnalysis() {
    final cfg = ScenarioConfig.of(trip.scenario);
    final sceneColor = cfg.primaryColor;
    final distKm = trip.totalDistanceKm;
    final uphillPct = (10 + (distKm * 2.5) % 35).toInt();
    final downhillPct = (10 + (distKm * 2.2) % 35).toInt();
    final flatPct = 100 - uphillPct - downhillPct;
    final climbTotal = (distKm * 28 + 120).toInt();

    return Container(
      color: Colors.white, margin: const EdgeInsets.only(top: 12), padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.landscape, size: 18, color: sceneColor), const SizedBox(width: 6),
          const Text('路段分析', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
        ]),
        const SizedBox(height: 16),
        const Text('坡度占比', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppConfig.textPrimary)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(height: 24, child: Row(children: [
            Expanded(flex: uphillPct, child: Container(color: const Color(0xFFE74C3C), alignment: Alignment.center,
              child: Text('上坡$uphillPct%', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)))),
            Expanded(flex: flatPct, child: Container(color: const Color(0xFF2ECC71), alignment: Alignment.center,
              child: flatPct >= 12 ? Text('平路$flatPct%', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)) : const SizedBox.shrink())),
            Expanded(flex: downhillPct, child: Container(color: const Color(0xFF3498DB), alignment: Alignment.center,
              child: Text('下坡$downhillPct%', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)))),
          ])),
        ),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _gradientLegend(const Color(0xFFE74C3C), '上坡'),
          _gradientLegend(const Color(0xFF2ECC71), '平路'),
          _gradientLegend(const Color(0xFF3498DB), '下坡'),
        ]),
        const SizedBox(height: 16),
        const Text('路面类型', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppConfig.textPrimary)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _roadSurfaceChip(Icons.add_road, '铺装路面', '68%')),
          Expanded(child: _roadSurfaceChip(Icons.terrain, '碎石路', '18%')),
          Expanded(child: _roadSurfaceChip(Icons.nature, '土路/林道', '10%')),
          Expanded(child: _roadSurfaceChip(Icons.landscape, '越野', '4%')),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _statCard(Icons.height, '累计爬升', '${climbTotal}m')),
          Expanded(child: _statCard(Icons.trending_up, '最大坡度', '${(7 + distKm % 8).toInt()}%')),
          Expanded(child: _statCard(Icons.terrain, '最高海拔', '${(climbTotal * 0.7 + 200).toInt()}m')),
        ]),
      ]),
    );
  }

  Widget _gradientLegend(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary)),
    ]);
  }

  Widget _roadSurfaceChip(IconData icon, String label, String pct) {
    return Container(padding: const EdgeInsets.symmetric(vertical: 6), child: Column(children: [
      Icon(icon, size: 18, color: AppConfig.textSecondary), const SizedBox(height: 4),
      Text(pct, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
      Text(label, style: const TextStyle(fontSize: 9, color: AppConfig.textSecondary)),
    ]));
  }

  Widget _statCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Icon(icon, size: 16, color: AppConfig.textSecondary), const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary)),
      ]),
    );
  }

  Widget _buildSupplyPoints() {
    final distKm = trip.totalDistanceKm;
    final supplyCount = (distKm / 15).ceil().clamp(2, 8);
    final icons = [Icons.water_drop, Icons.restaurant, Icons.local_gas_station, Icons.local_hospital, Icons.wc, Icons.coffee, Icons.build, Icons.local_convenience_store];
    final labels = ['补水点', '餐饮', '加油站', '医疗点', '卫生间', '补给站', '维修点', '便利店'];

    return Container(
      color: Colors.white, margin: const EdgeInsets.only(top: 12), padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.alt_route, size: 18, color: AppConfig.textPrimary), const SizedBox(width: 6),
          const Text('沿途补给', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
          const Spacer(),
          Text('共${supplyCount}处', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
        ]),
        const SizedBox(height: 12),
        ...List.generate(supplyCount, (i) {
          final km = ((distKm / (supplyCount + 1)) * (i + 1)).round();
          final idx = i % icons.length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(8)),
                child: Icon(icons[idx], size: 18, color: AppConfig.textSecondary)),
              const SizedBox(width: 10),
              Expanded(child: Text(labels[idx], style: const TextStyle(fontSize: 14, color: AppConfig.textPrimary))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(border: Border.all(color: AppConfig.textSecondary.withOpacity(0.3)), borderRadius: BorderRadius.circular(10)),
                child: Text('距起点 ${km}km', style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary))),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 16, color: AppConfig.textSecondary),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _buildReviews() {
    final reviews = const [
      _ReviewData('骑行老炮', '🚴', '5.0', '4月15日', '超级经典的一段路，沿途补给充足，下坡弯道很有骑行乐趣。9月中下旬来最合适，枫叶红了非常漂亮。'),
      _ReviewData('山野行者', '🏔️', '4.5', '4月10日', '全程风景不错，就是中间那段碎石路比较颠簸，公路车慎选。建议带备胎和补胎工具。'),
      _ReviewData('摩旅大叔', '🏍️', '4.8', '4月5日', '骑摩托走过两次了，弯道预警精准，沿途加油站标注清晰。推荐上午出发，下午回程逆光拍片更好看。'),
      _ReviewData('周末野游', '🥾', '4.2', '3月28日', '新手友好路线，坡度变化平缓。不过最后5km有一段修路，注意减速。整体体验不错。'),
      _ReviewData('露营爱好者', '⛺', '5.0', '3月20日', '路上的几个补给站可以买到冰镇饮料，夏天救命了。终点附近还有营地，适合两天一夜。'),
    ];

    return Container(
      color: Colors.white, margin: const EdgeInsets.only(top: 12), padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.rate_review_outlined, size: 18, color: AppConfig.textPrimary), const SizedBox(width: 6),
          const Text('用户点评', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.star, size: 14, color: Color(0xFFFF9800)), SizedBox(width: 4),
              Text('4.8', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFE65100))),
              SizedBox(width: 4),
              Text('(127条)', style: TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
            ])),
        ]),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Column(children: [
            Text('4.8', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppConfig.textPrimary)),
            Text('总分', style: TextStyle(fontSize: 10, color: AppConfig.textSecondary)),
          ]),
          const SizedBox(width: 16),
          Expanded(child: Column(children: [
            _ratingBar('5星', 72), const SizedBox(height: 3),
            _ratingBar('4星', 18), const SizedBox(height: 3),
            _ratingBar('3星', 6), const SizedBox(height: 3),
            _ratingBar('2星', 3), const SizedBox(height: 3),
            _ratingBar('1星', 1),
          ])),
        ]),
        const SizedBox(height: 16), const Divider(height: 1), const SizedBox(height: 12),
        ...reviews.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(r.avatar, style: const TextStyle(fontSize: 20)), const SizedBox(width: 8),
              Text(r.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppConfig.textPrimary)),
              const Spacer(),
              Icon(Icons.star, size: 14, color: const Color(0xFFFF9800)), const SizedBox(width: 2),
              Text(r.rating, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE65100))),
              const SizedBox(width: 8),
              Text(r.date, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
            ]),
            const SizedBox(height: 6),
            Text(r.text, style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary, height: 1.5)),
          ]),
        )),
        Center(child: TextButton(
          onPressed: () {},
          child: const Text('查看全部127条评价', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
        )),
      ]),
    );
  }

  Widget _ratingBar(String label, int pct) {
    return Row(children: [
      SizedBox(width: 24, child: Text(label, style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary))),
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(
        value: pct / 100.0, backgroundColor: AppConfig.bgMain, color: const Color(0xFFFF9800), minHeight: 6))),
      const SizedBox(width: 6),
      SizedBox(width: 24, child: Text('$pct%', style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary), textAlign: TextAlign.right)),
    ]);
  }

  Widget _sceneDataItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Icon(icon, size: 18, color: AppConfig.textSecondary), const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 12, color: AppConfig.textPrimary), textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary)),
      ]),
    );
  }

  Widget _dataChip(String label, String value) {
    return Column(children: [
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
      Text(label, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
    ]);
  }
}

class _EmotionCurvePainter extends CustomPainter {
  final List<TrackPoint> emotionPoints;
  final DateTime start;
  final int totalSec;
  final double usableWidth;

  _EmotionCurvePainter({required this.emotionPoints, required this.start, required this.totalSec, required this.usableWidth});

  @override
  void paint(Canvas canvas, Size size) {
    if (emotionPoints.isEmpty) return;
    final baseY = size.height - 10;
    final basePaint = Paint()..color = const Color(0xFFE5E5E5)..strokeWidth = 1;
    canvas.drawLine(Offset(0, baseY), Offset(usableWidth, baseY), basePaint);
    canvas.drawCircle(Offset(0, baseY), 4, Paint()..color = const Color(0xFFB2B2B2));
    double prevX = 0, prevY = baseY;
    for (int i = 0; i < emotionPoints.length; i++) {
      final pt = emotionPoints[i];
      final meta = emotionMeta(pt.emotionTag!);
      final color = Color(meta.color);
      final offsetSec = pt.timestamp.difference(start).inSeconds;
      final x = (offsetSec / totalSec) * usableWidth;
      final y = baseY - 20 - (i % 3) * 15.0;
      if (i > 0) {
        final linePaint = Paint()..color = color.withOpacity(0.3)..strokeWidth = 1.5..style = PaintingStyle.stroke;
        final path = Path()..moveTo(prevX, prevY)..quadraticBezierTo((prevX + x) / 2, prevY - 15, x, y);
        canvas.drawPath(path, linePaint);
      } else {
        canvas.drawLine(Offset(0, baseY), Offset(x, baseY), Paint()..color = color.withOpacity(0.15)..strokeWidth = 1);
      }
      canvas.drawCircle(Offset(x, y), 10, Paint()..color = color.withOpacity(0.2));
      canvas.drawCircle(Offset(x, y), 8, Paint()..color = color);
      final tp = TextPainter(text: TextSpan(text: meta.emoji, style: const TextStyle(fontSize: 10)), textDirection: TextDirection.ltr);
      tp.layout(); tp.paint(canvas, Offset(x - tp.width / 2, y - 28));
      final timeLabel = '${pt.timestamp.hour}:${pt.timestamp.minute.toString().padLeft(2, '0')}';
      final ttp = TextPainter(text: TextSpan(text: timeLabel, style: const TextStyle(fontSize: 9, color: AppConfig.textSecondary)), textDirection: TextDirection.ltr);
      ttp.layout(); ttp.paint(canvas, Offset(x - ttp.width / 2, baseY + 4));
      prevX = x; prevY = y;
    }
    canvas.drawCircle(Offset(usableWidth, baseY), 4, Paint()..color = const Color(0xFFB2B2B2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReviewData {
  final String name, avatar, rating, date, text;
  const _ReviewData(this.name, this.avatar, this.rating, this.date, this.text);
}
