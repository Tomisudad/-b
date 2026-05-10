import 'package:flutter/material.dart';
import '../config/app_config.dart';
import 'nearby_poi_page.dart';
import 'cycling_knowledge_page.dart';

/// V7.3 我的待办准备 — 出发前检查
/// 系统自动记忆状态，用户看一眼缺啥补啥，所有项目可跳过
class MyTodoPage extends StatefulWidget {
  const MyTodoPage({super.key});

  @override
  State<MyTodoPage> createState() => _MyTodoPageState();
}

class _MyTodoPageState extends State<MyTodoPage> {
  // 装备状态: null=未确认, true=已准备, false=需补充
  final Map<String, _ItemState> _coreGear = {
    '头盔':         _ItemState(icon: '✅', done: true),
    '手套':         _ItemState(icon: '✅', done: true),
    '水壶×2':       _ItemState(icon: '✅', done: true),
    '内胎×2':       _ItemState(icon: '⚠️', done: false, hint: '需补充×1'),
    '打气筒':       _ItemState(icon: '✅', done: true),
    '能量胶×3':     _ItemState(icon: '⚠️', done: false, hint: '只剩1个'),
    '前灯':         _ItemState(icon: '✅', done: true),
    '尾灯':         _ItemState(icon: '✅', done: true),
    '骑行眼镜':     _ItemState(icon: '⬜', done: null),
    '雨衣':         _ItemState(icon: '✅', done: true),
  };

  final Map<String, _ItemState> _bikeStatus = {
    '刹车检查':       _ItemState(icon: '✅', done: true),
    '胎压检查':       _ItemState(icon: '✅', done: true),
    '链条润油':       _ItemState(icon: '⚠️', done: false, hint: '上次: 150km前'),
    '变速检查':       _ItemState(icon: '✅', done: true),
  };

  int _lastCheckKm = 180; // mock: 上次检查距现在180km

  final List<String> _purchases = ['内胎×1', '能量胶×6', '电解质冲剂×5'];
  final TextEditingController _addPurchaseCtrl = TextEditingController();

  @override
  void dispose() {
    _addPurchaseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoreGear(),
            const SizedBox(height: AppConfig.cardGap),
            _buildBikeStatus(),
            const SizedBox(height: AppConfig.cardGap),
            _buildPurchases(),
            const SizedBox(height: AppConfig.sectionGap),
            _buildSkillEntry(),
            const SizedBox(height: AppConfig.sectionGap),
            _buildPostRideCollection(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    // 概览条
    final total = _coreGear.length + _bikeStatus.length;
    final ready = _coreGear.values.where((s) => s.done == true).length +
        _bikeStatus.values.where((s) => s.done == true).length;
    final needFix = _coreGear.values.where((s) => s.done == false).length +
        _bikeStatus.values.where((s) => s.done == false).length;

    return AppBar(
      backgroundColor: AppConfig.cardBg,
      title: const Text('出发前准备', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          margin: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 0, AppConfig.pageMargin, 10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: needFix > 0 ? AppConfig.warningOrange.withOpacity(0.08) : AppConfig.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          ),
          child: Row(
            children: [
              Text('$ready/$total 项已就绪', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: needFix > 0 ? AppConfig.warningOrange : AppConfig.primary)),
              if (needFix > 0) ...[
                const SizedBox(width: 8),
                Text('$needFix 项需关注', style: const TextStyle(fontSize: 13, color: AppConfig.warningOrange)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ===== 核心装备 =====
  Widget _buildCoreGear() {
    return _sectionCard(
      '🛡️ 核心装备',
      '每项可点击切换状态：✅已准备 → ⚠️需补充 → ⬜未确认',
      Column(
        children: _coreGear.entries.map((e) {
          final state = e.value;
          final icon = state.done == true ? '✅' : state.done == false ? '⚠️' : '⬜';
          final color = state.done == true ? AppConfig.primary : state.done == false ? AppConfig.warningOrange : AppConfig.textSecondary;
          return GestureDetector(
            onTap: () => setState(() {
              if (state.done == true) { state.done = false; state.icon = '⚠️'; }
              else if (state.done == false) { state.done = null; state.icon = '⬜'; }
              else { state.done = true; state.icon = '✅'; }
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5))),
              child: Row(children: [
                Text(icon, style: TextStyle(fontSize: 16, color: color)),
                const SizedBox(width: 10),
                Expanded(child: Text(e.key, style: const TextStyle(fontSize: 14, color: AppConfig.textPrimary))),
                if (state.done == false && state.hint != null)
                  Text(state.hint!, style: const TextStyle(fontSize: 11, color: AppConfig.warningOrange)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ===== 车辆状态 =====
  Widget _buildBikeStatus() {
    // 超过200km自动提醒
    final needRemind = _lastCheckKm > 200;

    return _sectionCard(
      '🔧 车辆状态',
      '上次检查: ${_lastCheckKm}km 前${needRemind ? "（建议检查）" : ""}',
      Column(
        children: [
          if (needRemind)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppConfig.warningOrange.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
              child: const Row(children: [
                Text('⚠️', style: TextStyle(fontSize: 14)),
                SizedBox(width: 8),
                Expanded(child: Text('超过200km未检查，建议检查车辆状态', style: TextStyle(fontSize: 12, color: AppConfig.warningOrange))),
              ]),
            ),
          ..._bikeStatus.entries.map((e) {
            final state = e.value;
            final icon = state.done == true ? '✅' : state.done == false ? '⚠️' : '⬜';
            final color = state.done == true ? AppConfig.primary : state.done == false ? AppConfig.warningOrange : AppConfig.textSecondary;
            return GestureDetector(
              onTap: () => setState(() => state.done = !state.done!),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5))),
                child: Row(children: [
                  Text(icon, style: TextStyle(fontSize: 16, color: color)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(e.key, style: const TextStyle(fontSize: 14, color: AppConfig.textPrimary))),
                  if (state.done == false && state.hint != null)
                    Text(state.hint!, style: const TextStyle(fontSize: 11, color: AppConfig.warningOrange)),
                ]),
              ),
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: () => setState(() {
                _lastCheckKm = 0;
                for (final s in _bikeStatus.values) { s.done = true; s.icon = '✅'; }
              }),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConfig.primary,
                side: const BorderSide(color: AppConfig.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
              ),
              child: const Text('✅ 一键已检查', style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  // ===== 需要采购 =====
  Widget _buildPurchases() {
    return _sectionCard(
      '📦 需要采购',
      '上次消耗自动出现在这里',
      Column(
        children: [
          ..._purchases.map((p) => Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5))),
                child: Row(children: [
                  const Text('🛒', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(p, style: const TextStyle(fontSize: 14, color: AppConfig.textPrimary))),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyPoiPage(category: '便利店'))),
                    child: Text('🔍 附近购买', style: TextStyle(fontSize: 12, color: AppConfig.primary)),
                  ),
                ]),
              )),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _addPurchaseCtrl,
                decoration: const InputDecoration(
                  hintText: '添加采购项...',
                  hintStyle: TextStyle(fontSize: 13, color: AppConfig.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: () {
                final t = _addPurchaseCtrl.text.trim();
                if (t.isNotEmpty) {
                  setState(() => _purchases.add(t));
                  _addPurchaseCtrl.clear();
                }
              },
              child: const Text('添加', style: TextStyle(fontSize: 13)),
            ),
          ]),
        ],
      ),
    );
  }

  // ===== 技能准备入口 =====
  Widget _buildSkillEntry() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CyclingKnowledgePage())),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          boxShadow: AppConfig.cardShadow,
        ),
        child: const Row(children: [
          Text('🔧', style: TextStyle(fontSize: 20)),
          SizedBox(width: 10),
          Expanded(child: Text('骑行维修须知', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary))),
          Text('离线可用 →', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
        ]),
      ),
    );
  }

  // ===== 骑行结束后采集 =====
  Widget _buildPostRideCollection() {
    return _sectionCard(
      '📋 骑行结束后（三个问题，都可跳过）',
      '',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Q1
          const Text('Q1: 本次消耗了什么？', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: ['内胎', '能量胶', '水', '其他'].map((item) => _choiceChip(item)).toList()),
          const SizedBox(height: 16),
          // Q2
          const Text('Q2: 车辆状态如何？', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: ['正常', '需要检查', '需要维修'].map((item) => _choiceChip(item)).toList()),
          const SizedBox(height: 16),
          // Q3
          const Text('Q3: 花了多少钱？（可选）', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '金额',
                  hintStyle: const TextStyle(fontSize: 13, color: AppConfig.textSecondary),
                  prefixIcon: const Text('¥ ', style: TextStyle(fontSize: 14, color: AppConfig.textPrimary)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.inputRadius),
                    borderSide: const BorderSide(color: AppConfig.divider),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                style: const TextStyle(fontSize: 13),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppConfig.divider)),
                child: const Text('跳过', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: AppConfig.primaryBtnH,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已保存，下次出发前会自动更新待办清单')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
              ),
              child: const Text('提交记录', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _choiceChip(String label) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.tagRadius),
          border: Border.all(color: AppConfig.divider),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13, color: AppConfig.textPrimary)),
      ),
    );
  }

  Widget _sectionCard(String title, String subtitle, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
        boxShadow: AppConfig.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ItemState {
  String icon;
  bool? done;
  String? hint;

  _ItemState({required this.icon, this.done, this.hint});
}