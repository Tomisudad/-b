import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/scenario_config.dart';
import '../config/app_config.dart';
import '../providers/scenario_provider.dart';

// ===== 组队数据模型 =====
enum TeamStatus { recruiting, full, departed, completed }

class TeamModel {
  final String id;
  final String name;
  final String? description;
  final String captainName;
  final DateTime departDate;
  final int currentMembers;
  final int maxMembers;
  final OutdoorScenario scenario;
  final TeamStatus status;

  const TeamModel({
    required this.id,
    required this.name,
    this.description,
    required this.captainName,
    required this.departDate,
    required this.currentMembers,
    required this.maxMembers,
    required this.scenario,
    required this.status,
  });
}

// ===== 场景 Emoji 映射 =====
// ignore: unused_element
String _scenarioEmoji(OutdoorScenario s) {
  switch (s) {
    case OutdoorScenario.drive: return '🚗';
    case OutdoorScenario.moto: return '🏍️';
    case OutdoorScenario.cycle: return '🚴';
  }
}

IconData _scenarioIcon(OutdoorScenario s) {
  switch (s) {
    case OutdoorScenario.drive: return Icons.directions_car;
    case OutdoorScenario.moto: return Icons.two_wheeler;
    case OutdoorScenario.cycle: return Icons.pedal_bike;
  }
}

/// 组队页面
class TeamsListPage extends StatelessWidget {
  const TeamsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scenario = context.watch<ScenarioProvider>().scenario;
    final cfg = ScenarioConfig.of(scenario);
    final sceneColor = cfg.primaryColor;
    final teams = _mockTeams(scenario);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('组队', style: TextStyle(color: AppConfig.textPrimary)),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: teams.length,
        itemBuilder: (context, index) => _buildTeamCard(context, teams[index], sceneColor),
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context, TeamModel team, Color sceneColor) {
    final statusColor = team.status == TeamStatus.recruiting
        ? Colors.green
        : team.status == TeamStatus.full
            ? Colors.orange
            : Colors.grey;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_scenarioIcon(team.scenario), color: sceneColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      team.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      switch (team.status) {
                        TeamStatus.recruiting => '招募中',
                        TeamStatus.full => '已满员',
                        TeamStatus.departed => '已出发',
                        TeamStatus.completed => '已完成',
                      },
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              if (team.description != null) ...[
                const SizedBox(height: 8),
                Text(team.description!,
                  style: const TextStyle(color: AppConfig.textSecondary, fontSize: 13),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: sceneColor.withOpacity(0.1),
                    child: Text(team.captainName[0], style: TextStyle(fontSize: 10, color: sceneColor)),
                  ),
                  const SizedBox(width: 6),
                  Text(team.captainName, style: const TextStyle(fontSize: 12, color: AppConfig.textPrimary)),
                  const SizedBox(width: 16),
                  const Icon(Icons.people, size: 14, color: AppConfig.textSecondary),
                  const SizedBox(width: 3),
                  Text('${team.currentMembers}/${team.maxMembers}',
                    style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.calendar_today, size: 12, color: AppConfig.textSecondary),
                  const SizedBox(width: 3),
                  Text('${team.departDate.month}/${team.departDate.day}',
                    style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sceneColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('加入', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TeamModel> _mockTeams(OutdoorScenario scenario) {
    return [
      TeamModel(
        id: '1', name: '川西秋色自驾队', description: '寻找秋季川西自驾伙伴，成都出发',
        captainName: '自驾达人', departDate: DateTime(2026, 5, 3),
        currentMembers: 3, maxMembers: 5, scenario: scenario, status: TeamStatus.recruiting,
      ),
      TeamModel(
        id: '2', name: '海南摩旅环岛团', description: '冬季海南环岛，五日行程',
        captainName: '机车老张', departDate: DateTime(2026, 5, 10),
        currentMembers: 6, maxMembers: 6, scenario: scenario, status: TeamStatus.full,
      ),
      TeamModel(
        id: '3', name: '千岛湖骑友周末行', description: '周末千岛湖绿道骑行，休闲级',
        captainName: '骑行小新', departDate: DateTime(2026, 5, 2),
        currentMembers: 2, maxMembers: 8, scenario: scenario, status: TeamStatus.recruiting,
      ),
    ];
  }
}
