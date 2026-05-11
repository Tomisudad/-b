import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.5 骑行记账
class CyclingAccountingPage extends StatefulWidget {
  const CyclingAccountingPage({super.key});
  @override
  State<CyclingAccountingPage> createState() => _CyclingAccountingPageState();
}

class _CyclingAccountingPageState extends State<CyclingAccountingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final _expenses = [
    _Expense('🚲 新车', 4999, '装备', '2026-04-15', '购买 Specialized Allez'),
    _Expense('⛰️ 千岛湖旅行', 1280, '出行', '2026-04-28', '住宿+餐饮+门票'),
    _Expense('🔗 链条清洁', 88, '保养', '2026-05-02', '链条清洗套装'),
    _Expense('🦷 骑行裤', 299, '装备', '2026-05-05', '夏季骑行裤'),
    _Expense('🏔️ 莫干山路餐', 320, '出行', '2026-05-10', '中途补给+午餐'),
    _Expense('🛞 轮胎更换', 356, '保养', '2026-05-08', '前后轮胎更换'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }
  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  double get _total =>
      _expenses.fold(0.0, (s, e) => s + e.amount);

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('💰 骑行记账', style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: AppConfig.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: TabBar(
            controller: _tabCtrl,
            labelColor: AppConfig.textPrimary,
            unselectedLabelColor: AppConfig.textSecondary,
            indicatorColor: AppConfig.primary,
            tabs: const [
              Tab(text: '全部'),
              Tab(text: '装备'),
              Tab(text: '保养'),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppConfig.primary),
            onPressed: () {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('记账功能开发中')));
            },
          ),
        ],
      ),
      body: Column(children: [
        _buildTotalHeader(),
        Expanded(
          child: TabBarView(controller: _tabCtrl, children: [
            _buildList(null),
            _buildList('装备'),
            _buildList('保养'),
          ]),
        ),
      ]),
    );
  }

  Widget _buildTotalHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppConfig.pageMargin),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        boxShadow: AppConfig.cardShadow,
      ),
      child: Row(children: [
        const Text('总支出', style: TextStyle(
            fontSize: 13, color: AppConfig.textSecondary)),
        const Spacer(),
        Text('¥${_total.toStringAsFixed(0)}',
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w800,
                color: AppConfig.primary)),
      ]),
    );
  }

  Widget _buildList(String? category) {
    final items = category == null
        ? _expenses
        : _expenses.where((e) => e.category == category).toList();
    if (items.isEmpty) return const Center(child: Text('暂无记录',
        style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildItem(items[i]),
    );
  }

  Widget _buildItem(_Expense e) {
    final emoji = e.emoji.split(' ').last;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        boxShadow: AppConfig.cardShadow,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: AppConfig.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 16)),
          ),
        ),
        title: Text(e.emoji.split(' ').first, style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: AppConfig.textPrimary)),
        subtitle: Text('📅 ${e.date}  ${e.note}', style: const TextStyle(
            fontSize: 10, color: AppConfig.textSecondary)),
        trailing: Text('¥${e.amount}',
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: AppConfig.textPrimary)),
      ),
    );
  }
}

class _Expense {
  final String emoji, category, date, note;
  final int amount;
  const _Expense(this.emoji, this.amount, this.category, this.date, this.note);
}