import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/scenario_provider.dart';
import '../providers/checklist_provider.dart';
import '../config/scenario_config.dart';
import '../theme/app_theme.dart';
import '../services/amap_service.dart';
import '../services/location_service.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _noteCtrl = TextEditingController();
  WeatherInfo? _weather;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final w = await AmapService.instance.fetchWeather(
      LocationService.instance.latitude,
      LocationService.instance.longitude,
    );
    if (mounted) setState(() => _weather = w);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ===== 装备库 Tab =====
  Widget _buildEquipmentTab(ChecklistProvider prov, Color sceneColor) {
    final cats = prov.categories;
    if (cats.isEmpty) {
      // 首次进入加载
      final scenario = context.read<ScenarioProvider>().scenario;
      prov.loadForScenario(scenario);
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return Column(
      children: [
        // 复用上次清单
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: sceneColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.replay, size: 20, color: sceneColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '复用上次的清单？已勾选 ${prov.checkedItems}/$prov.totalItems 项',
                  style: TextStyle(fontSize: 13, color: sceneColor),
                ),
              ),
              GestureDetector(
                onTap: () => prov.loadForScenario(context.read<ScenarioProvider>().scenario),
                child: Text('重置', style: TextStyle(fontSize: 13, color: sceneColor)),
              ),
            ],
          ),
        ),

        // 进度条
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: prov.progress,
                    minHeight: 6,
                    backgroundColor: AppTheme.secondaryBg,
                    valueColor: AlwaysStoppedAnimation<Color>(sceneColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${(prov.progress * 100).toInt()}%', style: TextStyle(fontSize: 14, color: sceneColor, fontWeight: FontWeight.w500)),
            ],
          ),
        ),

        // 装备分类
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: cats.length,
            itemBuilder: (_, ci) {
              final cat = cats[ci];
              final allChecked = cat.items.every((i) => i.checked);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      if (allChecked) const Icon(Icons.check_circle, size: 18, color: Color(0xFF2E7D32)),
                      if (!allChecked) const Icon(Icons.circle_outlined, size: 18, color: AppTheme.textAux),
                      const SizedBox(width: 8),
                      Text(cat.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                      const SizedBox(width: 8),
                      Text('${cat.items.where((i) => i.checked).length}/${cat.items.length}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textAux)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        allChecked ? '取消全选' : '全选',
                        style: TextStyle(fontSize: 12, color: sceneColor),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.expand_more, size: 20, color: sceneColor),
                    ],
                  ),
                  onExpansionChanged: (_) => prov.toggleCategory(ci, !allChecked),
                  children: cat.items.asMap().entries.map((e) {
                    final ii = e.key;
                    final item = e.value;
                    return CheckboxListTile(
                      value: item.checked,
                      onChanged: (_) => prov.toggleItem(ci, ii),
                      title: Text(item.name, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                      activeColor: sceneColor,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ===== 出发确认 Tab =====
  Widget _buildConfirmTab(ChecklistProvider prov, Color sceneColor) {
    final missing = prov.missingItems;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 装备缺失提醒
        if (missing.isNotEmpty) Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_amber, size: 20, color: Color(0xFFE65100)),
                  SizedBox(width: 8),
                  Text('以下装备还未准备：', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFE65100))),
                ],
              ),
              const SizedBox(height: 8),
              ...missing.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('· $m', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              )),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 天气卡片
        if (_weather != null) _buildWeatherCard(),

        const SizedBox(height: 16),

        // 给自己一句话
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('出发前，给自己一句话', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: '比如：今天要慢一点，多看看风景',
                    hintStyle: TextStyle(fontSize: 14, color: AppTheme.textAux),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 出发按钮
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: sceneColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size(double.infinity, 56),
            ),
            child: const Text('出发', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildWeatherCard() {
    final w = _weather!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(w.weatherIcon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${w.temperature}°  ${w.weatherDesc}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Text('风速${w.windSpeed}级 · UV${w.uvIndex}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Column(
              children: [
                Text('日出 ${w.sunrise}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                Text('日落 ${w.sunset}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scenario = context.watch<ScenarioProvider>().scenario;
    final sceneColor = ScenarioConfig.of(scenario).primaryColor;
    final checklist = context.watch<ChecklistProvider>();

    return Scaffold(
      backgroundColor: AppTheme.secondaryBg,
      appBar: AppBar(
        title: const Text('清单'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: sceneColor,
          labelColor: sceneColor,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: '装备库'),
            Tab(text: '出发确认'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildEquipmentTab(checklist, sceneColor),
          _buildConfirmTab(checklist, sceneColor),
        ],
      ),
    );
  }
}
