import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../config/scenario_config.dart';
import '../models/trip_model.dart';
import '../models/reroute_model.dart';

/// V5.5 轨迹记录结束页 — 含路线调整记录 & 保存为新路线模板
class TrackEndPage extends StatefulWidget {
  final TripModel trip;
  final List<RerouteAction>? rerouteLog;

  const TrackEndPage({super.key, required this.trip, this.rerouteLog});

  @override
  State<TrackEndPage> createState() => _TrackEndPageState();
}

class _TrackEndPageState extends State<TrackEndPage> with TickerProviderStateMixin {
  late AnimationController _medalCtrl;
  late Animation<double> _medalScaleAnim;
  late Animation<double> _medalFadeAnim;
  bool _showMedal = false;
  bool _isPublic = false;
  late TripModel _trip;

  // 成就 mock
  final _unlocked = <_Achievement>[
    _Achievement('🚴', '首次出行', '完成第一次出行记录', _MedalTier.bronze),
  ];
  final _progress = <_Achievement>[
    _Achievement('🏔️', '爬升达人', '累计爬升达到10km', _MedalTier.silver, progress: 0.28),
    _Achievement('🗺️', '点亮10区县', '在10个不同区县留下轨迹', _MedalTier.gold, progress: 0.3),
  ];

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _medalCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _medalScaleAnim = Tween(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _medalCtrl, curve: Curves.elasticOut));
    _medalFadeAnim = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _medalCtrl, curve: const Interval(0.7, 1.0, curve: Curves.easeOut)));

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) { _showMedal = true; _medalCtrl.forward(); Future.delayed(const Duration(milliseconds: 2200), () { if (mounted) setState(() => _showMedal = false); }); }
    });
  }

  @override
  void dispose() { _medalCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final scenario = _trip.scenario;
    final cfg = ScenarioConfig.of(scenario);
    final distanceKm = _trip.totalDistanceKm;
    final durationMin = _trip.accumulatedSeconds ~/ 60;
    final avgSpeed = distanceKm > 0 ? distanceKm / (_trip.accumulatedSeconds / 3600) : 0;
    final calories = (distanceKm * 30).toInt();
    final totalClimb = (distanceKm * 0.022).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      body: Stack(children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            // 头部渐变
            Container(
              width: double.infinity, padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [cfg.primaryColor.withOpacity(0.15), AppConfig.bgMain])),
              child: Column(children: [
                Container(width: 80, height: 80, decoration: BoxDecoration(color: cfg.primaryColor.withOpacity(0.12), shape: BoxShape.circle), child: Icon(Icons.flag_outlined, size: 40, color: cfg.primaryColor)),
                const SizedBox(height: 16),
                Text(_trip.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
                const SizedBox(height: 4),
                Text('行程完成 🎉', style: TextStyle(fontSize: 14, color: cfg.primaryColor, fontWeight: FontWeight.w500)),
              ]),
            ),
            // 数据面板
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('行程总结', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                  const SizedBox(height: 16),
                  Row(children: [
                    _statBox('${distanceKm.toStringAsFixed(1)}', 'km', '里程', cfg.primaryColor),
                    _statBox('$durationMin', 'min', '用时', cfg.primaryColor),
                    _statBox(totalClimb, 'km', '爬升', cfg.primaryColor),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    _statBox(avgSpeed.toStringAsFixed(1), 'km/h', '均速', cfg.primaryColor),
                    _statBox('$calories', 'kcal', '卡路里', cfg.primaryColor),
                    _statBox('3', '个', '点亮区县', AppConfig.goldEnd),
                  ]),
                ]),
              ),
            ),
            // 轨迹预览
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                width: double.infinity, height: 160,
                decoration: BoxDecoration(color: cfg.primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(AppConfig.cardRadius)),
                child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.route_outlined, size: 40, color: cfg.primaryColor.withOpacity(0.35)),
                  const SizedBox(height: 6),
                  Text('轨迹地图预览', style: TextStyle(fontSize: 13, color: cfg.primaryColor.withOpacity(0.35))),
                ])),
              ),
            ),
            // V5.5 路线调整记录
            if (widget.rerouteLog != null && widget.rerouteLog!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Row(children: [
                      Icon(Icons.alt_route_outlined, size: 18, color: AppConfig.accentOrange),
                      SizedBox(width: 6),
                      Text('路线调整记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                    ]),
                    const SizedBox(height: 10),
                    ...widget.rerouteLog!.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: AppConfig.accentOrange, shape: BoxShape.circle)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(a.action, style: const TextStyle(fontSize: 13, color: AppConfig.textPrimary))),
                        Text('${a.newDistanceKm.toStringAsFixed(1)}km', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                      ]),
                    )),
                  ]),
                ),
              ),
            // V5.5 保存为新路线模板
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
                child: Row(children: [
                  const Icon(Icons.lightbulb_outline, size: 20, color: AppConfig.goldEnd),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('是否将实际路线保存为新路线模板？', style: TextStyle(fontSize: 13, color: AppConfig.textPrimary))),
                  TextButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存为新路线模板！'))); }, child: const Text('保存', style: TextStyle(color: AppConfig.goldStart, fontWeight: FontWeight.w600))),
                ]),
              ),
            ),
            // 感悟时间轴
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('途中感悟', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                  const SizedBox(height: 12),
                  _timelineItem('🥹', '感动', '14:22', '到达垭口那一刻，所有疲惫都值了'),
                  const SizedBox(height: 12),
                  _timelineItem('🤯', '震撼', '15:40', '云海翻涌，此生难忘的风景'),
                  const SizedBox(height: 12),
                  _timelineItem('😊', '开心', '17:15', '顺利到达终点，完成目标'),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('添加感悟'), style: OutlinedButton.styleFrom(foregroundColor: AppConfig.textSecondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
                ]),
              ),
            ),
            // 成就
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [const Text('成就检测', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)), const Spacer(), Text('点亮3区县', style: TextStyle(fontSize: 13, color: cfg.primaryColor, fontWeight: FontWeight.w500))]),
                  const SizedBox(height: 12),
                  if (_unlocked.isNotEmpty) ...[
                    const Text('🎖️ 新获得', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textSecondary)),
                    const SizedBox(height: 8),
                    ..._unlocked.map((a) => _medalRow(a, cfg.primaryColor, unlocked: true)),
                    const SizedBox(height: 12),
                  ],
                  if (_progress.isNotEmpty) ...[
                    const Text('📈 进行中', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textSecondary)),
                    const SizedBox(height: 8),
                    ..._progress.map((a) => _progressRow(a, cfg.primaryColor)),
                  ],
                ]),
              ),
            ),
            // 可见性
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('可见性', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                  const SizedBox(height: 4),
                  Text(_isPublic ? '公开后进入公开路线库' : '仅自己可见', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: GestureDetector(onTap: () => setState(() => _isPublic = false), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: _isPublic ? AppConfig.bgMain : cfg.primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: _isPublic ? AppConfig.divider : cfg.primaryColor.withOpacity(0.3))), child: const Center(child: Text('👤 仅自己', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppConfig.textPrimary)))))),
                    const SizedBox(width: 10),
                    Expanded(child: GestureDetector(onTap: () => setState(() => _isPublic = true), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: _isPublic ? cfg.primaryColor.withOpacity(0.08) : AppConfig.bgMain, borderRadius: BorderRadius.circular(8), border: Border.all(color: _isPublic ? cfg.primaryColor.withOpacity(0.3) : AppConfig.divider)), child: const Center(child: Text('🌍 公开', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppConfig.textPrimary)))))),
                  ]),
                ]),
              ),
            ),
            // 操作
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                SizedBox(width: double.infinity, height: AppConfig.secondaryBtnH, child: OutlinedButton.icon(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已转存为我的路线'))); }, icon: const Icon(Icons.save_outlined, size: 18), label: const Text('转存为我的路线'), style: OutlinedButton.styleFrom(foregroundColor: AppConfig.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)), side: const BorderSide(color: AppConfig.divider)))),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, height: AppConfig.secondaryBtnH, child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.share_outlined, size: 18), label: const Text('分享行程'), style: OutlinedButton.styleFrom(foregroundColor: AppConfig.textSecondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)), side: const BorderSide(color: AppConfig.divider)))),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, height: AppConfig.primaryBtnH, child: ElevatedButton(onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst), style: ElevatedButton.styleFrom(backgroundColor: cfg.primaryColor, foregroundColor: AppConfig.textInverse, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)), elevation: 0), child: const Text('完成', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
              ]),
            ),
          ]),
        ),
        Positioned(top: 44, left: 16, child: GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppConfig.cardBg, shape: BoxShape.circle, boxShadow: AppConfig.cardShadow), child: const Icon(Icons.arrow_back, size: 22, color: AppConfig.textPrimary)))),
        if (_showMedal)
          AnimatedBuilder(animation: _medalCtrl, builder: (context, child) => Container(width: double.infinity, height: double.infinity, color: AppConfig.textPrimary.withOpacity(0.55 * _medalFadeAnim.value), child: Center(child: Transform.scale(scale: _medalScaleAnim.value, child: Opacity(opacity: _medalFadeAnim.value.clamp(0.0, 1.0), child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 120, height: 120, decoration: BoxDecoration(gradient: goldGradient, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppConfig.goldStart.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 8))]), child: const Center(child: Text('🏅', style: TextStyle(fontSize: 56)))),
            const SizedBox(height: 20),
            const Text('获得勋章！', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppConfig.textInverse)),
            const SizedBox(height: 6),
            const Text('首次出行 · 铜', style: TextStyle(fontSize: 16, color: AppConfig.goldStart)),
          ])))))),
      ]),
    );
  }

  Widget _statBox(String value, String unit, String label, Color color) => Expanded(child: Column(children: [
    RichText(text: TextSpan(children: [TextSpan(text: value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color, fontFeatures: const [FontFeature.tabularFigures()])), TextSpan(text: ' $unit', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppConfig.textSecondary))])),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
  ]));

  Widget _timelineItem(String emoji, String tag, String time, String text) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Column(children: [Text(emoji, style: const TextStyle(fontSize: 18)), Container(width: 2, height: 36, color: AppConfig.divider)]),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(tag, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)), const SizedBox(width: 8), Text(time, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary))]), const SizedBox(height: 2), Text(text, style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis)])),
  ]);

  Widget _medalRow(_Achievement a, Color primaryColor, {required bool unlocked}) => Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: Row(children: [
    Text(a.emoji, style: const TextStyle(fontSize: 20)), const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)), Text(a.desc, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary))])),
    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: _tierColor(a.tier).withOpacity(0.12), borderRadius: BorderRadius.circular(4)), child: Text(unlocked ? _tierLabel(a.tier) : '新！', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: unlocked ? _tierColor(a.tier) : AppConfig.goldEnd))),
  ]));

  Widget _progressRow(_Achievement a, Color primaryColor) => Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Text(a.emoji, style: const TextStyle(fontSize: 18)), const SizedBox(width: 8), Expanded(child: Text(a.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppConfig.textPrimary))), Text('${(a.progress * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _tierColor(a.tier)))]),
    const SizedBox(height: 6),
    ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(value: a.progress, backgroundColor: const Color(0xFFEDEDED), valueColor: AlwaysStoppedAnimation<Color>(_tierColor(a.tier)), minHeight: 4)),
  ]));

  Color _tierColor(_MedalTier tier) => switch (tier) { _MedalTier.bronze => const Color(0xFFCD7F32), _MedalTier.silver => const Color(0xFFA8A8A8), _MedalTier.gold => AppConfig.goldEnd, _MedalTier.diamond => AppConfig.accentBlue };
  String _tierLabel(_MedalTier tier) => switch (tier) { _MedalTier.bronze => '🥉 铜', _MedalTier.silver => '🥈 银', _MedalTier.gold => '🥇 金', _MedalTier.diamond => '💎 钻' };
}

class _Achievement { final String emoji, name, desc; final _MedalTier tier; final double progress; const _Achievement(this.emoji, this.name, this.desc, this.tier, {this.progress = 1.0}); }
enum _MedalTier { bronze, silver, gold, diamond }

