import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../config/scenario_config.dart';

/// V5.2 装备清单模块 — 纯数据管理，无出发检查入口
/// 装备状态: 未检查 / 完好 / 需更换 / 未携带
class ChecklistPage extends StatefulWidget {
  final OutdoorScenario? initialScene;
  const ChecklistPage({super.key, this.initialScene});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

enum _EquipStatus { unchecked, good, needReplace, notCarry }

extension _EquipStatusX on _EquipStatus {
  IconData get icon {
    switch (this) {
      case _EquipStatus.unchecked: return Icons.radio_button_unchecked;
      case _EquipStatus.good: return Icons.check_circle_outline;
      case _EquipStatus.needReplace: return Icons.warning_amber_rounded;
      case _EquipStatus.notCarry: return Icons.remove_circle_outline;
    }
  }
  Color color(Color primary) {
    switch (this) {
      case _EquipStatus.unchecked: return AppConfig.textSecondary;
      case _EquipStatus.good: return AppConfig.cyclePrimary;
      case _EquipStatus.needReplace: return AppConfig.motoPrimary;
      case _EquipStatus.notCarry: return AppConfig.sosRed;
    }
  }
  String get label {
    switch (this) {
      case _EquipStatus.unchecked: return '未检查';
      case _EquipStatus.good: return '完好';
      case _EquipStatus.needReplace: return '需更换';
      case _EquipStatus.notCarry: return '未携带';
    }
  }
}

class _EquipItem {
  String name;
  _EquipStatus status = _EquipStatus.unchecked;
  bool isDurable;
  int usedCount; // 消耗品已用次数
  _EquipItem({required this.name, this.isDurable = true, this.usedCount = 0});
}

class _Checklist {
  String name;
  OutdoorScenario scene;
  List<_EquipItem> items;
  DateTime createdAt;

  _Checklist({required this.name, required this.scene, required this.items, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final List<_Checklist> _checklists = _mockChecklists();

  static List<_Checklist> _mockChecklists() => [
    _Checklist(
      name: '骑行基础装备',
      scene: OutdoorScenario.cycle,
      items: [
        _EquipItem(name: '头盔', isDurable: true),
        _EquipItem(name: '骑行手套', isDurable: true),
        _EquipItem(name: '备胎×2', isDurable: true),
        _EquipItem(name: '打气筒', isDurable: true),
        _EquipItem(name: '码表', isDurable: true),
        _EquipItem(name: '前灯', isDurable: true),
        _EquipItem(name: '尾灯', isDurable: true),
        _EquipItem(name: '骑行眼镜', isDurable: true),
        _EquipItem(name: '能量胶×6', isDurable: false, usedCount: 4),
        _EquipItem(name: '电解质冲剂', isDurable: false, usedCount: 2),
        _EquipItem(name: '水壶×2', isDurable: true),
        _EquipItem(name: '急救包', isDurable: true),
      ],
    ),
    _Checklist(
      name: '摩旅出行装备',
      scene: OutdoorScenario.moto,
      items: [
        _EquipItem(name: '全盔', isDurable: true),
        _EquipItem(name: '骑行服', isDurable: true),
        _EquipItem(name: '护膝护肘', isDurable: true),
        _EquipItem(name: '骑行靴', isDurable: true),
        _EquipItem(name: '补胎工具包', isDurable: true),
        _EquipItem(name: '链条油', isDurable: false, usedCount: 3),
        _EquipItem(name: '备用油', isDurable: true),
        _EquipItem(name: 'GPS定位器', isDurable: true),
        _EquipItem(name: '运动相机', isDurable: true),
        _EquipItem(name: '雨衣', isDurable: true),
      ],
    ),
    _Checklist(
      name: '自驾露营装备',
      scene: OutdoorScenario.drive,
      items: [
        _EquipItem(name: '备胎', isDurable: true),
        _EquipItem(name: '千斤顶', isDurable: true),
        _EquipItem(name: '三角警示牌', isDurable: true),
        _EquipItem(name: '灭火器', isDurable: true),
        _EquipItem(name: '帐篷', isDurable: true),
        _EquipItem(name: '睡袋', isDurable: true),
        _EquipItem(name: '防潮垫', isDurable: true),
        _EquipItem(name: '露营灯', isDurable: true),
        _EquipItem(name: '折叠桌椅', isDurable: true),
        _EquipItem(name: '饮用水(4L)', isDurable: false, usedCount: 2),
        _EquipItem(name: '压缩饼干', isDurable: false, usedCount: 5),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        title: const Text('装备清单', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () => _showCreateSheet(),
            child: const Text('+', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: AppConfig.textSecondary)),
          ),
        ],
      ),
      body: _checklists.isEmpty
          ? _emptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 8, AppConfig.pageMargin, AppConfig.pageMargin),
              itemCount: _checklists.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppConfig.cardGap),
              itemBuilder: (_, i) => _buildChecklistCard(_checklists[i]),
            ),
    );
  }

  Widget _buildChecklistCard(_Checklist cl) {
    final color = cl.scene.primaryColor;
    final durableItems = cl.items.where((it) => it.isDurable).toList();
    final consumableItems = cl.items.where((it) => !it.isDurable).toList();
    final unchecked = cl.items.where((it) => it.status == _EquipStatus.unchecked).length;
    final needReplace = cl.items.where((it) => it.status == _EquipStatus.needReplace).length;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => _ChecklistDetailPage(checklist: cl, onUpdate: () => setState(() {})),
      )),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text(cl.scene.emoji, style: const TextStyle(fontSize: 18))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(cl.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(cl.scene.label, style: TextStyle(fontSize: 10, color: color)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 状态汇总
            Row(
              children: [
                _summaryChip('总 ${cl.items.length} 项'),
                const SizedBox(width: 8),
                if (unchecked > 0)
                  _summaryChip('$unchecked 未检查', AppConfig.textSecondary),
                if (needReplace > 0) ...[
                  const SizedBox(width: 8),
                  _summaryChip('$needReplace 需更换', AppConfig.motoPrimary),
                ],
              ],
            ),
            const SizedBox(height: 10),
            // 持久装备 预览（前4项）
            if (durableItems.isNotEmpty) ...[
              Text('持久装备', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppConfig.textSecondary.withOpacity(0.7))),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: durableItems.take(4).map((it) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: it.status == _EquipStatus.needReplace
                        ? AppConfig.motoPrimary.withOpacity(0.08)
                        : AppConfig.bgMain,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(it.status.icon, size: 12, color: it.status.color(color)),
                      const SizedBox(width: 3),
                      Text(it.name, style: TextStyle(fontSize: 11, color: it.status == _EquipStatus.needReplace ? AppConfig.motoPrimary : AppConfig.textSecondary)),
                    ],
                  ),
                )).toList(),
              ),
              if (durableItems.length > 4)
                Text('+${durableItems.length - 4} 项', style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary)),
            ],
            if (consumableItems.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('消耗品', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppConfig.textSecondary.withOpacity(0.7))),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: consumableItems.take(4).map((it) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppConfig.bgMain,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(it.name, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
                      const SizedBox(width: 3),
                      Text('×${it.usedCount}', style: TextStyle(fontSize: 10, color: color)),
                    ],
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryChip(String text, [Color? color]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (color ?? AppConfig.textSecondary).withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: color ?? AppConfig.textSecondary)),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppConfig.cyclePrimary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.checklist_outlined, size: 36, color: AppConfig.cyclePrimary),
        ),
        const SizedBox(height: 16),
        const Text('还没有装备清单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
        const SizedBox(height: 6),
        const Text('点击右上角 + 创建清单', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
      ],
    ),
  );

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.pageMargin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('创建清单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
                const SizedBox(height: 16),
                ...ScenarioConfig.all.map((cfg) => Material(
                  color: AppConfig.bgMain,
                  borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                    onTap: () {
                      Navigator.pop(context);
                      _createFromTemplate(cfg);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Text(cfg.scenario.emoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cfg.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                                Text('${cfg.flatEquipmentItems.length} 项装备', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                              ],
                            ),
                          ),
                          Icon(Icons.add, size: 18, color: cfg.primaryColor),
                        ],
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createFromTemplate(ScenarioConfig cfg) {
    final items = cfg.flatEquipmentItems.map((name) => _EquipItem(name: name)).toList();
    setState(() {
      _checklists.add(_Checklist(
        name: '${cfg.label}装备',
        scene: cfg.scenario,
        items: items,
      ));
    });
  }
}

/// 清单详情页（勾选状态，无出发）
class _ChecklistDetailPage extends StatefulWidget {
  final _Checklist checklist;
  final VoidCallback onUpdate;
  const _ChecklistDetailPage({required this.checklist, required this.onUpdate});

  @override
  State<_ChecklistDetailPage> createState() => _ChecklistDetailPageState();
}

class _ChecklistDetailPageState extends State<_ChecklistDetailPage> {
  late _Checklist _cl;
  bool _shared = false;

  @override
  void initState() {
    super.initState();
    _cl = widget.checklist;
  }

  @override
  Widget build(BuildContext context) {
    final color = _cl.scene.primaryColor;
    final durableItems = _cl.items.where((it) => it.isDurable).toList();
    final consumableItems = _cl.items.where((it) => !it.isDurable).toList();

    final good = _cl.items.where((it) => it.status == _EquipStatus.good).length;
    final total = _cl.items.length;

    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        title: Text(_cl.name),
        actions: [
          IconButton(
            icon: Icon(_shared ? Icons.favorite : Icons.favorite_border, color: _shared ? AppConfig.sosRed : AppConfig.textSecondary),
            onPressed: () { setState(() => _shared = !_shared); widget.onUpdate(); },
          ),
          IconButton(icon: const Icon(Icons.ios_share), onPressed: () {}),
          PopupMenuButton(
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('重命名')),
              const PopupMenuItem(value: 'delete', child: Text('删除', style: TextStyle(color: AppConfig.sosRed))),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        children: [
          // 进度条
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$good / $total 项完好', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                    Text('${(good / total * 100).round()}%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: good / total,
                    backgroundColor: AppConfig.bgMain,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConfig.cardGap),
          // 持久装备
          if (durableItems.isNotEmpty) ...[
            _sectionHeader('持久装备', durableItems.length),
            const SizedBox(height: 6),
            ...List.generate(durableItems.length, (i) => _equipTile(durableItems[i], i, color)),
          ],
          const SizedBox(height: AppConfig.cardGap),
          // 消耗品
          if (consumableItems.isNotEmpty) ...[
            _sectionHeader('消耗品', consumableItems.length),
            const SizedBox(height: 6),
            ...List.generate(consumableItems.length, (i) => _equipTile(consumableItems[i], i, color)),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Row(
      children: [
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textSecondary.withOpacity(0.7))),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: AppConfig.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count', style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
        ),
      ],
    );
  }

  Widget _equipTile(_EquipItem item, int index, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
      ),
      child: ListTile(
        dense: true,
        leading: GestureDetector(
          onTap: () => _cycleStatus(item),
          child: Icon(item.status.icon, size: 22, color: item.status.color(color)),
        ),
        title: Text(item.name, style: TextStyle(
          fontSize: 14,
          color: item.status == _EquipStatus.notCarry ? AppConfig.textSecondary : AppConfig.textPrimary,
          decoration: item.status == _EquipStatus.notCarry ? TextDecoration.lineThrough : null,
        )),
        subtitle: item.isDurable
            ? Text(item.status.label, style: TextStyle(fontSize: 11, color: item.status.color(color)))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('已用 ', style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
                  GestureDetector(
                    onTap: () => setState(() { if (item.usedCount > 0) item.usedCount--; widget.onUpdate(); }),
                    child: Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: AppConfig.bgMain,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(child: Text('−', style: TextStyle(fontSize: 14, color: AppConfig.textSecondary))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text('${item.usedCount}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                  ),
                  GestureDetector(
                    onTap: () => setState(() { item.usedCount++; widget.onUpdate(); }),
                    child: Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(child: Text('+', style: TextStyle(fontSize: 14, color: color))),
                    ),
                  ),
                ],
              ),
        trailing: !item.isDurable ? null : PopupMenuButton<_EquipStatus>(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.more_vert, size: 18, color: AppConfig.textSecondary),
          onSelected: (s) => setState(() { item.status = s; widget.onUpdate(); }),
          itemBuilder: (_) => _EquipStatus.values.map((s) => PopupMenuItem(
            value: s,
            child: Row(
              children: [
                Icon(s.icon, size: 16, color: s.color(color)),
                const SizedBox(width: 8),
                Text(s.label, style: TextStyle(fontSize: 13, color: s == _EquipStatus.notCarry ? AppConfig.sosRed : AppConfig.textPrimary)),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _cycleStatus(_EquipItem item) {
    setState(() {
      const cycle = [_EquipStatus.unchecked, _EquipStatus.good, _EquipStatus.needReplace, _EquipStatus.notCarry];
      final idx = cycle.indexOf(item.status);
      item.status = cycle[(idx + 1) % cycle.length];
    });
    widget.onUpdate();
  }
}
