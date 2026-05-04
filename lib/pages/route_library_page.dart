import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../config/scenario_config.dart';
import '../models/route_model.dart';
import '../providers/scenario_provider.dart';

/// 路线库 —— 按场景展示路线列表
class RouteLibraryPage extends StatelessWidget {
  const RouteLibraryPage({super.key});

  String _scenarioEmoji(OutdoorScenario s) {
    switch (s) {
      case OutdoorScenario.drive: return '🚗';
      case OutdoorScenario.moto: return '🏍️';
      case OutdoorScenario.cycle: return '🚴';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenario = context.watch<ScenarioProvider>().scenario;
    final sceneColor = scenario.color;
    final routes = _routesFor(scenario);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('${_scenarioEmoji(scenario)} 路线库',
          style: const TextStyle(color: AppConfig.textPrimary)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppConfig.textPrimary), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: routes.length,
        itemBuilder: (context, index) {
          return _buildRouteCard(context, routes[index], sceneColor);
        },
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, RouteModel route, Color sceneColor) {
    final isOfficial = route.tags.contains('official');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: sceneColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.route, color: sceneColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(route.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary),
                          ),
                        ),
                        if (isOfficial)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: sceneColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('官方',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(route.difficultyLabel,
                      style: const TextStyle(color: AppConfig.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildStat(Icons.route, route.formatDistance),
                        const SizedBox(width: 14),
                        _buildStat(Icons.timer, route.formatDuration),
                        const SizedBox(width: 14),
                        _buildStat(Icons.trending_up, '${route.totalClimb}m'),
                        const Spacer(),
                        ...List.generate(route.difficulty, (_) {
                          return Icon(Icons.star, size: 12, color: sceneColor);
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppConfig.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFFB2B2B2)),
        const SizedBox(width: 3),
        Text(text, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
      ],
    );
  }

  List<RouteModel> _routesFor(OutdoorScenario s) {
    return _presetRoutes.where((r) => r.scenario == s).toList();
  }

  static final _presetRoutes = <RouteModel>[
    RouteModel(id: "r1", name: "川西大环线", scenario: OutdoorScenario.drive, difficulty: 4, distanceKm: 1800, durationMinutes: 4320, totalClimb: 8500, tags: ["official"]),
    RouteModel(id: "r2", name: "独库公路", scenario: OutdoorScenario.drive, difficulty: 3, distanceKm: 560, durationMinutes: 1440, totalClimb: 3200, tags: []),
    RouteModel(id: "r3", name: "青甘大环线", scenario: OutdoorScenario.drive, difficulty: 3, distanceKm: 2700, durationMinutes: 5760, totalClimb: 6200, tags: ["official"]),
    RouteModel(id: "r10", name: "G318川藏南线", scenario: OutdoorScenario.drive, difficulty: 5, distanceKm: 2150, durationMinutes: 7200, totalClimb: 12000, tags: ["official"]),
    RouteModel(id: "r11", name: "滇藏线", scenario: OutdoorScenario.drive, difficulty: 4, distanceKm: 1950, durationMinutes: 6000, totalClimb: 9800, tags: []),
    RouteModel(id: "r12", name: "青藏线", scenario: OutdoorScenario.drive, difficulty: 4, distanceKm: 1956, durationMinutes: 6480, totalClimb: 7500, tags: ["official"]),
    RouteModel(id: "r13", name: "新藏线G219", scenario: OutdoorScenario.drive, difficulty: 5, distanceKm: 2800, durationMinutes: 8640, totalClimb: 15000, tags: []),
    RouteModel(id: "r14", name: "北疆环线", scenario: OutdoorScenario.drive, difficulty: 3, distanceKm: 2200, durationMinutes: 5760, totalClimb: 5500, tags: ["official"]),
    RouteModel(id: "r15", name: "南北疆大环线", scenario: OutdoorScenario.drive, difficulty: 4, distanceKm: 4500, durationMinutes: 11520, totalClimb: 9000, tags: []),
    RouteModel(id: "r16", name: "喀纳斯-禾木", scenario: OutdoorScenario.drive, difficulty: 2, distanceKm: 480, durationMinutes: 960, totalClimb: 1800, tags: ["official"]),
    RouteModel(id: "r17", name: "甘南小环线", scenario: OutdoorScenario.drive, difficulty: 3, distanceKm: 850, durationMinutes: 2880, totalClimb: 4200, tags: []),
    RouteModel(id: "r18", name: "色达-稻城亚丁", scenario: OutdoorScenario.drive, difficulty: 4, distanceKm: 1100, durationMinutes: 3600, totalClimb: 7200, tags: ["official"]),
    RouteModel(id: "r19", name: "呼伦贝尔草原线", scenario: OutdoorScenario.drive, difficulty: 2, distanceKm: 1200, durationMinutes: 2880, totalClimb: 2400, tags: []),
    RouteModel(id: "r20", name: "大兴安岭穿越", scenario: OutdoorScenario.drive, difficulty: 4, distanceKm: 1600, durationMinutes: 4320, totalClimb: 5200, tags: ["official"]),
    RouteModel(id: "r21", name: "漠河极光之旅", scenario: OutdoorScenario.drive, difficulty: 3, distanceKm: 2200, durationMinutes: 5760, totalClimb: 4800, tags: []),
    RouteModel(id: "r22", name: "太行挂壁公路", scenario: OutdoorScenario.drive, difficulty: 3, distanceKm: 280, durationMinutes: 720, totalClimb: 3200, tags: ["official"]),
    RouteModel(id: "r23", name: "桂林-阳朔自驾", scenario: OutdoorScenario.drive, difficulty: 2, distanceKm: 180, durationMinutes: 480, totalClimb: 800, tags: []),
    RouteModel(id: "r24", name: "海南环岛高速", scenario: OutdoorScenario.drive, difficulty: 2, distanceKm: 900, durationMinutes: 2160, totalClimb: 1500, tags: ["official"]),
    RouteModel(id: "r25", name: "厦门-永定土楼", scenario: OutdoorScenario.drive, difficulty: 2, distanceKm: 380, durationMinutes: 720, totalClimb: 1200, tags: []),
    RouteModel(id: "r26", name: "皖南古村落环线", scenario: OutdoorScenario.drive, difficulty: 2, distanceKm: 350, durationMinutes: 960, totalClimb: 2100, tags: ["official"]),
    RouteModel(id: "r27", name: "秦岭穿越线", scenario: OutdoorScenario.drive, difficulty: 3, distanceKm: 520, durationMinutes: 1440, totalClimb: 4500, tags: []),
    RouteModel(id: "r28", name: "恩施大峡谷环线", scenario: OutdoorScenario.drive, difficulty: 3, distanceKm: 420, durationMinutes: 1200, totalClimb: 3800, tags: ["official"]),
    RouteModel(id: "r29", name: "长白山环山公路", scenario: OutdoorScenario.drive, difficulty: 2, distanceKm: 360, durationMinutes: 960, totalClimb: 2200, tags: []),
    RouteModel(id: "r30", name: "张掖-嘉峪关", scenario: OutdoorScenario.drive, difficulty: 3, distanceKm: 280, durationMinutes: 720, totalClimb: 1600, tags: ["official"]),
    RouteModel(id: "r31", name: "丽江-香格里拉", scenario: OutdoorScenario.drive, difficulty: 3, distanceKm: 350, durationMinutes: 960, totalClimb: 3600, tags: []),
    RouteModel(id: "r32", name: "泸沽湖环湖自驾", scenario: OutdoorScenario.drive, difficulty: 2, distanceKm: 76, durationMinutes: 180, totalClimb: 600, tags: ["official"]),
    RouteModel(id: "r33", name: "黄山-宏村-呈坎", scenario: OutdoorScenario.drive, difficulty: 2, distanceKm: 220, durationMinutes: 600, totalClimb: 1800, tags: []),
    RouteModel(id: "r34", name: "张家界-凤凰古城", scenario: OutdoorScenario.drive, difficulty: 3, distanceKm: 380, durationMinutes: 960, totalClimb: 3200, tags: ["official"]),
    RouteModel(id: "r35", name: "阿尔山-柴河", scenario: OutdoorScenario.drive, difficulty: 3, distanceKm: 680, durationMinutes: 1800, totalClimb: 2800, tags: []),
    RouteModel(id: "r36", name: "额济纳旗胡杨林", scenario: OutdoorScenario.drive, difficulty: 3, distanceKm: 1200, durationMinutes: 2880, totalClimb: 2200, tags: ["official"]),
    RouteModel(id: "r37", name: "青海小环线", scenario: OutdoorScenario.drive, difficulty: 2, distanceKm: 750, durationMinutes: 1920, totalClimb: 3500, tags: []),
    RouteModel(id: "r38", name: "浙西大峡谷穿越", scenario: OutdoorScenario.drive, difficulty: 2, distanceKm: 260, durationMinutes: 600, totalClimb: 1800, tags: ["official"]),
    RouteModel(id: "r39", name: "苏杭水乡古镇", scenario: OutdoorScenario.drive, difficulty: 1, distanceKm: 200, durationMinutes: 480, totalClimb: 300, tags: []),
    RouteModel(id: "r40", name: "徽杭古道自驾", scenario: OutdoorScenario.drive, difficulty: 3, distanceKm: 320, durationMinutes: 960, totalClimb: 2800, tags: []),
    RouteModel(id: "r4", name: "太行天路", scenario: OutdoorScenario.moto, difficulty: 3, distanceKm: 380, durationMinutes: 960, totalClimb: 2800, tags: []),
    RouteModel(id: "r5", name: "皖南川藏线", scenario: OutdoorScenario.moto, difficulty: 2, distanceKm: 120, durationMinutes: 240, totalClimb: 1500, tags: ["official"]),
    RouteModel(id: "r6", name: "洱海环湖摩旅", scenario: OutdoorScenario.moto, difficulty: 1, distanceKm: 130, durationMinutes: 180, totalClimb: 400, tags: []),
    RouteModel(id: "r41", name: "秦岭分水岭", scenario: OutdoorScenario.moto, difficulty: 3, distanceKm: 180, durationMinutes: 480, totalClimb: 2200, tags: ["official"]),
    RouteModel(id: "r42", name: "广东第一峰", scenario: OutdoorScenario.moto, difficulty: 3, distanceKm: 260, durationMinutes: 720, totalClimb: 3200, tags: []),
    RouteModel(id: "r43", name: "皖浙天路", scenario: OutdoorScenario.moto, difficulty: 4, distanceKm: 180, durationMinutes: 600, totalClimb: 3800, tags: ["official"]),
    RouteModel(id: "r44", name: "荆州公路", scenario: OutdoorScenario.moto, difficulty: 3, distanceKm: 220, durationMinutes: 600, totalClimb: 2800, tags: []),
    RouteModel(id: "r45", name: "环太湖摩旅", scenario: OutdoorScenario.moto, difficulty: 1, distanceKm: 340, durationMinutes: 480, totalClimb: 400, tags: ["official"]),
    RouteModel(id: "r46", name: "平潭环岛", scenario: OutdoorScenario.moto, difficulty: 2, distanceKm: 160, durationMinutes: 360, totalClimb: 800, tags: []),
    RouteModel(id: "r47", name: "草原天路", scenario: OutdoorScenario.moto, difficulty: 2, distanceKm: 280, durationMinutes: 480, totalClimb: 1800, tags: ["official"]),
    RouteModel(id: "r48", name: "张北草原", scenario: OutdoorScenario.moto, difficulty: 2, distanceKm: 350, durationMinutes: 720, totalClimb: 2200, tags: []),
    RouteModel(id: "r49", name: "塞罕坝", scenario: OutdoorScenario.moto, difficulty: 2, distanceKm: 240, durationMinutes: 600, totalClimb: 1600, tags: ["official"]),
    RouteModel(id: "r50", name: "丙察察线", scenario: OutdoorScenario.moto, difficulty: 5, distanceKm: 305, durationMinutes: 1200, totalClimb: 8500, tags: []),
    RouteModel(id: "r51", name: "墨脱公路", scenario: OutdoorScenario.moto, difficulty: 5, distanceKm: 117, durationMinutes: 480, totalClimb: 5200, tags: ["official"]),
    RouteModel(id: "r52", name: "泸亚线", scenario: OutdoorScenario.moto, difficulty: 4, distanceKm: 280, durationMinutes: 960, totalClimb: 6800, tags: []),
    RouteModel(id: "r53", name: "丙中洛-秋那桶", scenario: OutdoorScenario.moto, difficulty: 3, distanceKm: 90, durationMinutes: 300, totalClimb: 2200, tags: ["official"]),
    RouteModel(id: "r54", name: "川西小环线", scenario: OutdoorScenario.moto, difficulty: 3, distanceKm: 650, durationMinutes: 1200, totalClimb: 5200, tags: []),
    RouteModel(id: "r55", name: "理塘-格聂", scenario: OutdoorScenario.moto, difficulty: 4, distanceKm: 220, durationMinutes: 720, totalClimb: 4800, tags: ["official"]),
    RouteModel(id: "r56", name: "泸沽湖环湖摩旅", scenario: OutdoorScenario.moto, difficulty: 2, distanceKm: 76, durationMinutes: 150, totalClimb: 600, tags: []),
    RouteModel(id: "r57", name: "大理-沙溪-丽江", scenario: OutdoorScenario.moto, difficulty: 2, distanceKm: 180, durationMinutes: 300, totalClimb: 1500, tags: ["official"]),
    RouteModel(id: "r58", name: "甘南秘境", scenario: OutdoorScenario.moto, difficulty: 3, distanceKm: 420, durationMinutes: 960, totalClimb: 3200, tags: []),
    RouteModel(id: "r59", name: "若尔盖草原", scenario: OutdoorScenario.moto, difficulty: 2, distanceKm: 380, durationMinutes: 720, totalClimb: 2000, tags: ["official"]),
    RouteModel(id: "r60", name: "扎尕那-郎木寺", scenario: OutdoorScenario.moto, difficulty: 3, distanceKm: 280, durationMinutes: 720, totalClimb: 2600, tags: []),
    RouteModel(id: "r61", name: "乌兰布统", scenario: OutdoorScenario.moto, difficulty: 2, distanceKm: 300, durationMinutes: 720, totalClimb: 1800, tags: ["official"]),
    RouteModel(id: "r62", name: "环千岛湖", scenario: OutdoorScenario.moto, difficulty: 2, distanceKm: 180, durationMinutes: 360, totalClimb: 900, tags: []),
    RouteModel(id: "r63", name: "天目山盘山公路", scenario: OutdoorScenario.moto, difficulty: 3, distanceKm: 150, durationMinutes: 480, totalClimb: 2400, tags: ["official"]),
    RouteModel(id: "r64", name: "四明山盘山", scenario: OutdoorScenario.moto, difficulty: 2, distanceKm: 120, durationMinutes: 240, totalClimb: 1600, tags: []),
    RouteModel(id: "r65", name: "临安大鱼线", scenario: OutdoorScenario.moto, difficulty: 2, distanceKm: 90, durationMinutes: 180, totalClimb: 1200, tags: ["official"]),
    RouteModel(id: "r66", name: "井陉太行天路", scenario: OutdoorScenario.moto, difficulty: 2, distanceKm: 180, durationMinutes: 360, totalClimb: 2200, tags: []),
    RouteModel(id: "r67", name: "张家界-天子山", scenario: OutdoorScenario.moto, difficulty: 3, distanceKm: 240, durationMinutes: 480, totalClimb: 2800, tags: ["official"]),
    RouteModel(id: "r68", name: "北盘江大峡谷", scenario: OutdoorScenario.moto, difficulty: 3, distanceKm: 200, durationMinutes: 480, totalClimb: 2600, tags: []),
    RouteModel(id: "r69", name: "滇南热带雨林", scenario: OutdoorScenario.moto, difficulty: 2, distanceKm: 350, durationMinutes: 720, totalClimb: 1800, tags: ["official"]),
    RouteModel(id: "r70", name: "阿尔山-海拉尔", scenario: OutdoorScenario.moto, difficulty: 3, distanceKm: 400, durationMinutes: 960, totalClimb: 2400, tags: []),
    RouteModel(id: "r71", name: "挂壁公路群", scenario: OutdoorScenario.moto, difficulty: 3, distanceKm: 120, durationMinutes: 360, totalClimb: 2200, tags: ["official"]),
    RouteModel(id: "r72", name: "鸭绿江边境线", scenario: OutdoorScenario.moto, difficulty: 2, distanceKm: 520, durationMinutes: 1200, totalClimb: 2800, tags: []),
    RouteModel(id: "r7", name: "海南东线", scenario: OutdoorScenario.cycle, difficulty: 3, distanceKm: 400, durationMinutes: 2400, totalClimb: 1800, tags: ["official"]),
    RouteModel(id: "r8", name: "千岛湖绿道", scenario: OutdoorScenario.cycle, difficulty: 1, distanceKm: 140, durationMinutes: 480, totalClimb: 800, tags: []),
    RouteModel(id: "r9", name: "青海湖环湖骑行", scenario: OutdoorScenario.cycle, difficulty: 4, distanceKm: 360, durationMinutes: 2160, totalClimb: 2200, tags: ["official"]),
    RouteModel(id: "r73", name: "环太湖骑行", scenario: OutdoorScenario.cycle, difficulty: 2, distanceKm: 260, durationMinutes: 960, totalClimb: 500, tags: []),
    RouteModel(id: "r74", name: "成都天府绿道", scenario: OutdoorScenario.cycle, difficulty: 1, distanceKm: 100, durationMinutes: 360, totalClimb: 200, tags: ["official"]),
    RouteModel(id: "r75", name: "北京妙峰山", scenario: OutdoorScenario.cycle, difficulty: 3, distanceKm: 48, durationMinutes: 240, totalClimb: 1800, tags: []),
    RouteModel(id: "r76", name: "上海崇明环岛", scenario: OutdoorScenario.cycle, difficulty: 1, distanceKm: 100, durationMinutes: 360, totalClimb: 200, tags: ["official"]),
    RouteModel(id: "r77", name: "桂林阳朔骑行", scenario: OutdoorScenario.cycle, difficulty: 2, distanceKm: 80, durationMinutes: 360, totalClimb: 600, tags: []),
    RouteModel(id: "r78", name: "喀纳斯-禾木骑行", scenario: OutdoorScenario.cycle, difficulty: 4, distanceKm: 180, durationMinutes: 720, totalClimb: 3200, tags: ["official"]),
    RouteModel(id: "r79", name: "独库公路骑行段", scenario: OutdoorScenario.cycle, difficulty: 5, distanceKm: 180, durationMinutes: 960, totalClimb: 4200, tags: []),
    RouteModel(id: "r80", name: "环洱海骑行", scenario: OutdoorScenario.cycle, difficulty: 1, distanceKm: 120, durationMinutes: 360, totalClimb: 300, tags: ["official"]),
    RouteModel(id: "r81", name: "丝绸之路骑行", scenario: OutdoorScenario.cycle, difficulty: 5, distanceKm: 1800, durationMinutes: 14400, totalClimb: 12000, tags: []),
    RouteModel(id: "r82", name: "丙察察骑行", scenario: OutdoorScenario.cycle, difficulty: 5, distanceKm: 305, durationMinutes: 2880, totalClimb: 8500, tags: ["official"]),
    RouteModel(id: "r83", name: "G318川藏骑行", scenario: OutdoorScenario.cycle, difficulty: 5, distanceKm: 2150, durationMinutes: 18000, totalClimb: 12000, tags: []),
    RouteModel(id: "r84", name: "环海南岛骑行", scenario: OutdoorScenario.cycle, difficulty: 3, distanceKm: 900, durationMinutes: 5760, totalClimb: 3500, tags: ["official"]),
    RouteModel(id: "r85", name: "西湖环湖骑行", scenario: OutdoorScenario.cycle, difficulty: 1, distanceKm: 28, durationMinutes: 90, totalClimb: 100, tags: []),
    RouteModel(id: "r86", name: "厦门环岛路", scenario: OutdoorScenario.cycle, difficulty: 1, distanceKm: 43, durationMinutes: 150, totalClimb: 200, tags: ["official"]),
    RouteModel(id: "r87", name: "黄山赛段骑行", scenario: OutdoorScenario.cycle, difficulty: 4, distanceKm: 120, durationMinutes: 600, totalClimb: 3800, tags: []),
    RouteModel(id: "r88", name: "秦岭穿越骑行", scenario: OutdoorScenario.cycle, difficulty: 4, distanceKm: 280, durationMinutes: 1440, totalClimb: 5200, tags: ["official"]),
    RouteModel(id: "r89", name: "滇池环湖骑行", scenario: OutdoorScenario.cycle, difficulty: 1, distanceKm: 100, durationMinutes: 300, totalClimb: 250, tags: []),
    RouteModel(id: "r90", name: "婺源花海骑行", scenario: OutdoorScenario.cycle, difficulty: 2, distanceKm: 90, durationMinutes: 420, totalClimb: 800, tags: ["official"]),
    RouteModel(id: "r91", name: "青城山爬坡", scenario: OutdoorScenario.cycle, difficulty: 3, distanceKm: 55, durationMinutes: 300, totalClimb: 1800, tags: []),
    RouteModel(id: "r92", name: "四姑娘山-巴朗山", scenario: OutdoorScenario.cycle, difficulty: 4, distanceKm: 280, durationMinutes: 1440, totalClimb: 4800, tags: ["official"]),
    RouteModel(id: "r93", name: "泸沽湖环湖骑行", scenario: OutdoorScenario.cycle, difficulty: 2, distanceKm: 76, durationMinutes: 300, totalClimb: 600, tags: []),
    RouteModel(id: "r94", name: "赛里木湖环湖", scenario: OutdoorScenario.cycle, difficulty: 2, distanceKm: 90, durationMinutes: 360, totalClimb: 400, tags: ["official"]),
    RouteModel(id: "r95", name: "清远-英西峰林", scenario: OutdoorScenario.cycle, difficulty: 2, distanceKm: 75, durationMinutes: 300, totalClimb: 800, tags: []),
    RouteModel(id: "r96", name: "莫干山爬坡", scenario: OutdoorScenario.cycle, difficulty: 3, distanceKm: 65, durationMinutes: 300, totalClimb: 1600, tags: ["official"]),
    RouteModel(id: "r97", name: "皖南歙县-深渡", scenario: OutdoorScenario.cycle, difficulty: 2, distanceKm: 85, durationMinutes: 360, totalClimb: 900, tags: []),
    RouteModel(id: "r98", name: "镇江-扬州", scenario: OutdoorScenario.cycle, difficulty: 1, distanceKm: 45, durationMinutes: 150, totalClimb: 150, tags: ["official"]),
    RouteModel(id: "r99", name: "希拉穆仁草原", scenario: OutdoorScenario.cycle, difficulty: 3, distanceKm: 120, durationMinutes: 540, totalClimb: 1200, tags: []),
    RouteModel(id: "r100", name: "张家界天门山骑行", scenario: OutdoorScenario.cycle, difficulty: 4, distanceKm: 60, durationMinutes: 360, totalClimb: 2200, tags: ["official"]),
    RouteModel(id: "r101", name: "稻城亚丁环线", scenario: OutdoorScenario.cycle, difficulty: 4, distanceKm: 160, durationMinutes: 840, totalClimb: 3800, tags: []),
    RouteModel(id: "r102", name: "色达-喇荣", scenario: OutdoorScenario.cycle, difficulty: 3, distanceKm: 90, durationMinutes: 420, totalClimb: 2200, tags: ["official"]),
    RouteModel(id: "r103", name: "香格里拉-梅里雪山", scenario: OutdoorScenario.cycle, difficulty: 4, distanceKm: 210, durationMinutes: 1080, totalClimb: 4500, tags: []),
    RouteModel(id: "r104", name: "林芝桃花沟", scenario: OutdoorScenario.cycle, difficulty: 2, distanceKm: 110, durationMinutes: 480, totalClimb: 1200, tags: ["official"]),
    RouteModel(id: "r105", name: "乌兰布统骑行", scenario: OutdoorScenario.cycle, difficulty: 3, distanceKm: 160, durationMinutes: 720, totalClimb: 1600, tags: []),
  ];
}
