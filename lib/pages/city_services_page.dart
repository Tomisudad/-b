import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.6 沿途城市服务
/// 显示路线沿途城市的补给站、车店、医院等POI
class CityServicesPage extends StatefulWidget {
  final String? routeName;
  const CityServicesPage({super.key, this.routeName});

  @override
  State<CityServicesPage> createState() => _CityServicesPageState();
}

class _CityServicesPageState extends State<CityServicesPage> {
  _ServiceCat? _filterCat;
  String _searchText = '';

  // Mock: 沿途城市服务点
  static const _services = [
    _CityService('杭州', '西湖区', _ServiceCat.bikeShop, '捷安特西湖店', '杭州市西湖区文三路138号', 1.2, '10:00-21:00', '8条评价'),
    _CityService('杭州', '西湖区', _ServiceCat.hospital, '杭州市第一人民医院', '杭州市上城区浣纱路261号', 2.5, '24小时', '三甲医院'),
    _CityService('杭州', '西湖区', _ServiceCat.restStop, '龙井村休息点', '龙井路满觉陇路口', 0.5, '全天', '补给/饮水/厕所'),
    _CityService('杭州', '西湖区', _ServiceCat.bikeShop, '闪电概念店', '杭州市西湖区天目山路18号', 3.8, '09:00-20:00', '高端整车/维修'),
    _CityService('杭州', '西湖区', _ServiceCat.gas, '中石化古荡加油站', '杭州市西湖区古墩路168号', 2.1, '24小时', '92#/95#/98#'),
    _CityService('杭州', '临安区', _ServiceCat.bikeShop, '千里达车行', '临安区锦城镇城中街52号', 45.0, '08:00-19:00', '维修/配件'),
    _CityService('杭州', '临安区', _ServiceCat.restStop, '青山湖绿道驿站', '青山湖环湖绿道北入口', 42.0, '06:00-22:00', '休息/饮水/工具'),
    _CityService('杭州', '临安区', _ServiceCat.hospital, '临安区人民医院', '临安区锦城镇衣锦街5号', 44.0, '24小时', '急诊'),
    _CityService('湖州', '德清县', _ServiceCat.restStop, '莫干山骑行驿站', '德清县莫干山镇庾村广场', 68.0, '08:00-18:00', '咖啡/简餐/维修工具'),
    _CityService('湖州', '德清县', _ServiceCat.bikeShop, '德清骑友之家', '德清县武康镇中兴路88号', 66.0, '09:00-20:00', '车店兼休息站'),
    _CityService('湖州', '安吉县', _ServiceCat.restStop, '天荒坪驿站', '安吉县天荒坪镇江南天池入口', 95.0, '07:00-19:00', '补给/观景/厕所'),
    _CityService('湖州', '安吉县', _ServiceCat.hospital, '安吉县人民医院', '安吉县递铺镇天目路', 90.0, '24小时', '门诊/急诊'),
    _CityService('黄山', '歙县', _ServiceCat.restStop, '徽州古城游客中心', '歙县徽城镇中和街', 155.0, '08:00-21:00', '休息/医疗包/地图'),
    _CityService('黄山', '歙县', _ServiceCat.bikeShop, '新安骑行俱乐部', '歙县徽城镇新安路126号', 153.0, '09:00-18:00', '维修/租车'),
    _CityService('宣城', '绩溪县', _ServiceCat.restStop, '龙川景区停车场', '绩溪县瀛洲镇龙川村', 175.0, '08:00-17:30', '停车/休息'),
  ];

  List<_CityService> get _filtered {
    var list = _services;
    if (_filterCat != null) {
      list = list.where((s) => s.cat == _filterCat).toList();
    }
    if (_searchText.isNotEmpty) {
      list = list.where((s) =>
        s.city.contains(_searchText) ||
        s.name.contains(_searchText) ||
        s.district.contains(_searchText)
      ).toList();
    }
    list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list.toList();
  }

  @override
  Widget build(BuildContext context) {
    final services = _filtered;
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        title: Text(widget.routeName ?? '沿途服务', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 0, AppConfig.pageMargin, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchText = v),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: '搜索城市或服务名称',
                hintStyle: const TextStyle(fontSize: 13, color: AppConfig.textSecondary),
                prefixIcon: const Icon(Icons.search, size: 18, color: AppConfig.textSecondary),
                filled: true,
                fillColor: AppConfig.bgMain,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppConfig.divider),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(children: [
        _buildCatFilter(),
        Expanded(
          child: services.isEmpty
              ? _emptySearch()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
                  itemCount: services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppConfig.cardGap),
                  itemBuilder: (_, i) => _buildServiceCard(services[i]),
                ),
        ),
      ]),
    );
  }

  Widget _buildCatFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 0, AppConfig.pageMargin, 8),
      child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
        _catChip(null),
        const SizedBox(width: 6),
        ..._ServiceCat.values.map((c) => Padding(padding: const EdgeInsets.only(right: 6), child: _catChip(c))),
      ])),
    );
  }

  Widget _catChip(_ServiceCat? cat) {
    final active = _filterCat == cat;
    final color = cat?.color ?? AppConfig.textSecondary;
    final label = cat?.label ?? '全部';
    return GestureDetector(
      onTap: () => setState(() => _filterCat = cat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.08) : AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.tagRadius),
          border: Border.all(color: active ? color : AppConfig.divider, width: active ? 1.2 : 0.8),
        ),
        child: Text('${cat?.emoji ?? ''} $label', style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? color : AppConfig.textSecondary)),
      ),
    );
  }

  Widget _buildServiceCard(_CityService s) {
    return GestureDetector(
      onTap: () => _showDetail(s),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          boxShadow: AppConfig.cardShadow,
          border: Border(left: BorderSide(color: s.cat.color, width: 3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: s.cat.color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text(s.cat.emoji, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
              const SizedBox(height: 2),
              Text(s.address, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${s.distanceKm.toStringAsFixed(1)}km', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: s.cat.color)),
              Text(s.hours, style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary)),
            ]),
          ]),
          if (s.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: s.cat.color.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(s.note, style: TextStyle(fontSize: 10, color: s.cat.color.withOpacity(0.8))),
              ),
              const Spacer(),
              Text('${s.city}·${s.district}', style: TextStyle(fontSize: 10, color: AppConfig.textSecondary.withOpacity(0.6))),
            ]),
          ],
        ]),
      ),
    );
  }

  void _showDetail(_CityService s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
        ),
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: SafeArea(child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(children: [
              Text(s.cat.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Text(s.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            ]),
            const SizedBox(height: 8),
            _detailRow(Icons.location_on_outlined, s.address),
            _detailRow(Icons.access_time, s.hours),
            if (s.note.isNotEmpty) _detailRow(Icons.info_outline, s.note),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.navigation_outlined, size: 16),
                label: const Text('导航'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppConfig.cyclePrimary,
                  side: const BorderSide(color: AppConfig.cyclePrimary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.phone_outlined, size: 16),
                label: const Text('拨打电话'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.cyclePrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
                ),
              )),
            ])),
            const SizedBox(height: 8),
          ],
        )),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: AppConfig.textSecondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppConfig.textBody))),
      ]),
    );
  }

  Widget _emptySearch() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.search_off, size: 48, color: AppConfig.textSecondary.withOpacity(0.3)),
        const SizedBox(height: 12),
        const Text('未找到匹配的服务点', style: TextStyle(fontSize: 14, color: AppConfig.textSecondary)),
      ]),
    );
  }
}

// ===== 数据模型 =====
enum _ServiceCat {
  bikeShop,
  hospital,
  restStop,
  gas,
}

extension _ServiceCatX on _ServiceCat {
  String get label => switch (this) {
    _ServiceCat.bikeShop => '车店',
    _ServiceCat.hospital => '医院',
    _ServiceCat.restStop => '休息点',
    _ServiceCat.gas => '加油站',
  };
  String get emoji => switch (this) {
    _ServiceCat.bikeShop => '🚲',
    _ServiceCat.hospital => '🏥',
    _ServiceCat.restStop => '☕',
    _ServiceCat.gas => '⛽',
  };
  Color get color => switch (this) {
    _ServiceCat.bikeShop => AppConfig.cyclePrimary,
    _ServiceCat.hospital => AppConfig.sosRed,
    _ServiceCat.restStop => const Color(0xFFF39C12),
    _ServiceCat.gas => const Color(0xFFE74C3C),
  };
}

class _CityService {
  final String city;
  final String district;
  final _ServiceCat cat;
  final String name;
  final String address;
  final double distanceKm;
  final String hours;
  final String note;

  const _CityService(this.city, this.district, this.cat, this.name, this.address, this.distanceKm, this.hours, this.note);
}