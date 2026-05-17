import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.3 附近实用点位
class NearbyPoiPage extends StatefulWidget {
  final String? category;
  const NearbyPoiPage({super.key, this.category});

  @override
  State<NearbyPoiPage> createState() => _NearbyPoiPageState();
}

class _NearbyPoiPageState extends State<NearbyPoiPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _alongRouteMode = false;

  static const _categories = [
    _PoiCat('🏪', '便利店', Color(0xFF2ECC71)),
    _PoiCat('🔧', '修车铺', Color(0xFFE67E22)),
    _PoiCat('🍜', '餐饮店', Color(0xFFE74C3C)),
    _PoiCat('🏥', '药店', Color(0xFF3498DB)),
    _PoiCat('🏨', '住宿', Color(0xFF9B59B6)),
    _PoiCat('🚻', '卫生间', Color(0xFF1ABC9C)),
  ];

  final List<_Poi> _pois = [
    _Poi('全家便利店(学院路店)', '🏪', 0.32, '学院路158号', 4.7, '0571-88881234'),
    _Poi('7-Eleven(文三路店)', '🏪', 0.48, '文三路478号', 4.5, '0571-88882345'),
    _Poi('喜士多(古翠路店)', '🏪', 0.65, '古翠路76号', 4.6, '0571-88883456'),
    _Poi('捷安特专业维修', '🔧', 0.82, '文二西路234号', 4.9, '0571-88884567'),
    _Poi('美利达自行车行', '🔧', 1.24, '益乐路56号', 4.8, '0571-88885678'),
    _Poi('老王修车铺', '🔧', 1.56, '文一路与教工路交叉口', 4.7, '0571-88886789'),
    _Poi('沙县小吃', '🍜', 0.45, '文三路328号', 4.3, '0571-88881111'),
    _Poi('兰州拉面', '🍜', 0.68, '学院路88号', 4.5, '0571-88882222'),
    _Poi('大食堂', '🍜', 0.92, '古翠路128号', 4.6, '0571-88883333'),
    _Poi('老百姓大药房', '🏥', 0.72, '文三路256号', 4.8, '0571-88884444'),
    _Poi('益丰大药房', '🏥', 1.15, '文二西路156号', 4.7, '0571-88885555'),
    _Poi('如家酒店', '🏨', 1.82, '文三路508号', 4.5, '0571-88886666'),
    _Poi('全季酒店', '🏨', 2.35, '学院路268号', 4.8, '0571-88887777'),
    _Poi('公共卫生间', '🚻', 0.28, '古翠路地铁站旁', 4.0, null),
    _Poi('公共卫生间', '🚻', 0.55, '文三路与教工路交叉口', 4.0, null),
  ];

  @override
  void initState() {
    super.initState();
    final initIdx = widget.category != null
        ? _categories.indexWhere((c) => c.label.contains(widget.category!))
        : 0;
    _tabCtrl = TabController(length: _categories.length, vsync: this, initialIndex: initIdx.clamp(0, _categories.length - 1));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('附近实用点位', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            labelColor: AppConfig.textPrimary,
            unselectedLabelColor: AppConfig.textSecondary,
            indicatorColor: AppConfig.primary,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: _categories.map((c) => Tab(text: '${c.emoji} ${c.label}')).toList(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_alongRouteMode ? Icons.route : Icons.route_outlined, color: _alongRouteMode ? AppConfig.primary : AppConfig.textSecondary),
            onPressed: () => setState(() => _alongRouteMode = !_alongRouteMode),
            tooltip: '沿途模式',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: _categories.map((cat) => _buildPoiList(cat)).toList(),
      ),
    );
  }

  Widget _buildPoiList(_PoiCat cat) {
    final filtered = _pois.where((p) => p.categoryEmoji == cat.emoji).toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return Column(
      children: [
        if (_alongRouteMode)
          Container(
            margin: const EdgeInsets.all(AppConfig.pageMargin),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppConfig.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.route, size: 16, color: AppConfig.primary),
              const SizedBox(width: 8),
              const Text('沿途模式已开启', style: TextStyle(fontSize: 13, color: AppConfig.primary)),
              const Spacer(),
              const Text('仅显示偏离路线≤2km', style: TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
            ]),
          ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('附近暂无此类点位', style: TextStyle(fontSize: 14, color: AppConfig.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConfig.pageMargin),
                  cacheExtent: 500,
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _buildPoiItem(filtered[i], i, cat.color),
                ),
        ),
      ],
    );
  }

  Widget _buildPoiItem(_Poi poi, int index, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        boxShadow: AppConfig.cardShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(poi.categoryEmoji, style: const TextStyle(fontSize: 20))),
        ),
        title: Text(poi.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(poi.address, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
            const SizedBox(height: 2),
            Row(children: [
              Text('${poi.distanceKm.toStringAsFixed(2)}km', style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
              const SizedBox(width: 8),
              Text('评分 ${poi.rating}', style: const TextStyle(fontSize: 11, color: AppConfig.primary)),
            ]),
          ],
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (poi.phone != null)
            IconButton(
              icon: const Icon(Icons.phone_outlined, size: 20, color: AppConfig.textSecondary),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('拨打: ${poi.phone}')));
              },
            ),
          IconButton(
            icon: const Icon(Icons.near_me_outlined, size: 20, color: AppConfig.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('开始导航...')));
            },
          ),
        ]),
      ),
    );
  }
}

class _PoiCat {
  final String emoji;
  final String label;
  final Color color;
  const _PoiCat(this.emoji, this.label, this.color);
}

class _Poi {
  final String name;
  final String categoryEmoji;
  final double distanceKm;
  final String address;
  final double rating;
  final String? phone;

  const _Poi(this.name, this.categoryEmoji, this.distanceKm, this.address, this.rating, this.phone);
}