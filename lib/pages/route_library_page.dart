import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../config/scenario_config.dart';
import '../data/routes.dart';
import '../models/route_model.dart';
import '../providers/scenario_provider.dart';
import 'departure_page.dart';

/// 路线库 —— 按场景展示路线列表
class RouteLibraryPage extends StatelessWidget {
  final bool forDeparture;
  const RouteLibraryPage({super.key, this.forDeparture = false});

  String _scenarioEmoji(OutdoorScenario s) => '🚴';

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
        cacheExtent: 500,
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
              if (forDeparture)
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DeparturePage(fromRoute: route))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: goldGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text('出发', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                )
              else
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
    return PresetRoutes.forScenario(s);
  }
}
