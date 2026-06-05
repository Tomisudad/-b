import 'package:flutter/material.dart';
import 'package:gowild_app/providers/app_state.dart';
import 'package:provider/provider.dart';
import '../widgets/create_route_modal.dart';

/// 出发流程底部面板
/// 状态1：选择出发方式
/// 状态2：出发确认（含装备状态联动）
class DepartModal extends StatefulWidget {
  final String? routeName; // 非空时直接进入确认页
  const DepartModal({super.key, this.routeName});

  @override
  State<DepartModal> createState() => _DepartModalState();
}

class _DepartModalState extends State<DepartModal> {
  bool _showConfirm = false;

  @override
  void initState() {
    super.initState();
    if (widget.routeName != null) {
      // 直接显示确认页
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final state = Provider.of<AppState>(context, listen: false);
        state.setSelectedRoute(widget.routeName);
        setState(() => _showConfirm = true);
      });
    }
  }

  void _openCreateRoute(BuildContext context) {
    Navigator.pop(context);
    // 由调用方负责打开新建路线面板
  }

  void _showDepartConfirm(BuildContext context) {
    setState(() => _showConfirm = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_showConfirm) return _buildConfirm(context);
    return _buildSelection(context);
  }

  Widget _buildSelection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dragHandle(),
          const SizedBox(height: 16),
          const Text('选择出发方式', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _optionTile(context, Icons.map, '选择已有路线出发', () => _showDepartConfirm(context)),
          const SizedBox(height: 10),
          _optionTile(context, Icons.add, '新建路线并出发', () {
            Navigator.pop(context);
            showCreateRouteModal(context);
          }),
          const SizedBox(height: 10),
          _optionTile(context, Icons.play_arrow, '自由记录开始', () {
            final state = Provider.of<AppState>(context, listen: false);
            state.setSelectedRoute(null);
            Navigator.pop(context);
            // 重新打开确认面板
            showDepartConfirm(context);
          }),
          const SizedBox(height: 16),
          _cancelButton(context, '取消'),
        ],
      ),
    );
  }

  Widget _buildConfirm(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final equip = state.equipment;
        final isEmpty = equip.isEmpty;
        final issues = equip.where((e) => e.status != 'ok').toList();
        final sel = state.selectedRoute ?? '自由骑行';

        String equipText;
        if (isEmpty) {
          equipText = '尚未添加装备，请点击添加';
        } else if (issues.isNotEmpty) {
          final names = issues.map((e) => e.name).join('、');
          equipText = '${issues.length}项待处理：$names';
        } else {
          equipText = '全部就绪 ✅';
        }

        final canStart = !isEmpty;

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dragHandle(),
              const SizedBox(height: 16),
              const Text('出发确认', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('路线：$sel', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text('天气：晴 24° 东南风2级', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('装备：', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  if (isEmpty)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        final s = Provider.of<AppState>(context, listen: false);
                        s.openSub('装备清单', 'equip');
                      },
                      child: Text(equipText, style: const TextStyle(color: Color(0xFFD94A4A), decoration: TextDecoration.underline)),
                    )
                  else if (issues.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        final s = Provider.of<AppState>(context, listen: false);
                        s.openSub('装备清单', 'equip');
                      },
                      child: Text(equipText, style: const TextStyle(color: Color(0xFFD94A4A), decoration: TextDecoration.underline)),
                    )
                  else
                    Text(equipText, style: const TextStyle(color: Colors.green)),
                ],
              ),
              const SizedBox(height: 20),
              Opacity(
                opacity: canStart ? 1.0 : 0.4,
                child: AbsorbPointer(
                  absorbing: !canStart,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canStart ? () => _startRide(context) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF57C00),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('▶ 开始骑行'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _cancelButton(context, '取消'),
            ],
          ),
        );
      },
    );
  }

  void _startRide(BuildContext context) {
    Navigator.pop(context);
    final state = Provider.of<AppState>(context, listen: false);
    state.startRide();
  }

  Widget _optionTile(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8F7F4), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF5A6F45)),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _cancelButton(BuildContext context, String label) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _dragHandle() => Center(
        child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
      );
}

/// 顶层函数：关闭面板并触发骑行
void _startRide(BuildContext context) {
  Navigator.pop(context);
  final state = Provider.of<AppState>(context, listen: false);
  state.startRide();
}

void showDepartModal(BuildContext context, {String? routeName}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DepartModal(routeName: routeName),
  );
}

/// 直接打开出发确认面板（用于快速出发）
void showDepartConfirm(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DepartConfirmSheet(),
  );
}

class _DepartConfirmSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final equip = state.equipment;
        final isEmpty = equip.isEmpty;
        final issues = equip.where((e) => e.status != 'ok').toList();
        final sel = state.selectedRoute ?? '自由骑行';

        String equipText;
        if (isEmpty) {
          equipText = '尚未添加装备，请点击添加';
        } else if (issues.isNotEmpty) {
          final names = issues.map((e) => e.name).join('、');
          equipText = '${issues.length}项待处理：$names';
        } else {
          equipText = '全部就绪 ✅';
        }

        final canStart = !isEmpty;

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dragHandle(),
              const SizedBox(height: 16),
              const Text('出发确认', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('路线：$sel', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text('天气：晴 24° 东南风2级', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('装备：', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  if (isEmpty)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Provider.of<AppState>(context, listen: false).openSub('装备清单', 'equip');
                      },
                      child: Text(equipText, style: const TextStyle(color: Color(0xFFD94A4A), decoration: TextDecoration.underline)),
                    )
                  else if (issues.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Provider.of<AppState>(context, listen: false).openSub('装备清单', 'equip');
                      },
                      child: Text(equipText, style: const TextStyle(color: Color(0xFFD94A4A), decoration: TextDecoration.underline)),
                    )
                  else
                    Text(equipText, style: const TextStyle(color: Colors.green)),
                ],
              ),
              const SizedBox(height: 20),
              Opacity(
                opacity: canStart ? 1.0 : 0.4,
                child: AbsorbPointer(
                  absorbing: !canStart,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canStart ? () => _startRide(context) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF57C00),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('▶ 开始骑行'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _cancelButton(context, '取消'),
            ],
          ),
        );
      },
    );
  }
}
