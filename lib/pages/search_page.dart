import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../config/scenario_config.dart';
import '../providers/scenario_provider.dart';
import 'route_library_page.dart';

// ============================================================
// 全球搜索页 — Section 13
// ============================================================
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _query = '';

  // 历史搜索
  static const _history = ['独库公路', '杭州周边骑行', '318川藏线', '加油站'];

  // mock 搜索结果
  final _myRoutes = <_SearchResult>[];
  final _publicRoutes = <_SearchResult>[];
  final _supplyPoints = <_SearchResult>[];

  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _doSearch(String q) {
    setState(() {
      _query = q;
      _searched = true;

      // mock: 过滤
      _myRoutes.clear();
      _publicRoutes.clear();
      _supplyPoints.clear();

      if (q.isNotEmpty) {
        _myRoutes.addAll([
          _SearchResult('$q 路线A', '自驾 · 120km', Icons.route_outlined),
          _SearchResult('$q 路线B', '骑行 · 45km', Icons.route_outlined),
        ]);
        _publicRoutes.addAll([
          _SearchResult('$q 公开路线X', '摩旅 · 230km', Icons.public_outlined),
        ]);
        _supplyPoints.addAll([
          _SearchResult('$q 加油站', '距你 2.3km', Icons.local_gas_station_outlined),
          _SearchResult('$q 营地', '距你 5.1km', Icons.cabin_outlined),
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scenario = context.watch<ScenarioProvider>().scenario;
    final cfg = ScenarioConfig.of(scenario);

    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.glassBg,
        titleSpacing: 8,
        title: TextField(
          controller: _ctrl,
          focusNode: _focus,
          autofocus: true,
          style: const TextStyle(fontSize: 16, color: AppConfig.textPrimary),
          decoration: InputDecoration(
            hintText: '搜索路线、补给点、离线区域...',
            hintStyle: const TextStyle(fontSize: 15, color: AppConfig.textSecondary),
            border: InputBorder.none,
            fillColor: Colors.transparent,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() {
                        _query = '';
                        _searched = false;
                      });
                    },
                  )
                : null,
          ),
          onChanged: _doSearch,
          onSubmitted: _doSearch,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(fontSize: 15, color: AppConfig.textPrimary)),
          ),
        ],
      ),
      body: _searched && _query.isNotEmpty
          ? _buildResults(cfg)
          : _buildHistory(),
    );
  }

  // ===== 历史 =====
  Widget _buildHistory() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('历史搜索', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textSecondary,
              )),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('清空')),
                  );
                },
                child: const Icon(Icons.delete_outline, size: 18, color: AppConfig.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _history.map((h) => GestureDetector(
              onTap: () {
                _ctrl.text = h;
                _doSearch(h);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppConfig.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppConfig.divider),
                ),
                child: Text(h, style: const TextStyle(fontSize: 13, color: AppConfig.textPrimary)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // ===== 结果 =====
  Widget _buildResults(ScenarioConfig cfg) {
    final allEmpty = _myRoutes.isEmpty && _publicRoutes.isEmpty && _supplyPoints.isEmpty;

    if (allEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 56, color: AppConfig.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 12),
            const Text('未找到相关结果', style: TextStyle(
              fontSize: 15, color: AppConfig.textSecondary,
            )),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_myRoutes.isNotEmpty) ...[
            _resultSection('我的路线', cfg.primaryColor, _myRoutes),
            const SizedBox(height: AppConfig.cardGap),
          ],
          if (_publicRoutes.isNotEmpty) ...[
            _resultSection('公开路线', AppConfig.motoPrimary, _publicRoutes),
            const SizedBox(height: AppConfig.cardGap),
          ],
          if (_supplyPoints.isNotEmpty) ...[
            _resultSection('补给点', AppConfig.drivePrimary, _supplyPoints),
          ],
        ],
      ),
    );
  }

  Widget _resultSection(String title, Color color, List<_SearchResult> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: color,
        )),
        const SizedBox(height: 8),
        ...items.map((r) => GestureDetector(
          onTap: () {
            if (title == '我的路线') {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const RouteLibraryPage(),
              ));
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppConfig.cardBg,
              borderRadius: BorderRadius.circular(AppConfig.cardRadius),
              boxShadow: AppConfig.cardShadow,
            ),
            child: Row(
              children: [
                Icon(r.icon, size: 20, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.name, style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500, color: AppConfig.textPrimary,
                      )),
                      const SizedBox(height: 2),
                      Text(r.desc, style: const TextStyle(
                        fontSize: 12, color: AppConfig.textSecondary,
                      )),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18, color: AppConfig.textSecondary),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class _SearchResult {
  final String name, desc;
  final IconData icon;
  const _SearchResult(this.name, this.desc, this.icon);
}
