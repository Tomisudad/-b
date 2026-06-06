import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../config/theme.dart';
import '../models/equipment.dart';

/// 装备清单页 — 严格对照 HTML renderSub() equip + cycleEquip() + openAddEquip()
class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  final List<String> _statusCycle = ['ok', 'attention', 'missing'];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('装备清单',
                      style: TextStyle(fontSize: 18, fontWeight: AppTheme.wBold)),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(AppTheme.rCard24),
                      boxShadow: AppTheme.cardShadowList,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: state.equipment.isEmpty
                        ? const Text('还没有装备，点击下方添加',
                              style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)))
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (int i = 0; i < state.equipment.length; i++)
                                _EquipChip(
                                  equipment: state.equipment[i],
                                  onTap: () => _cycleStatus(state, i),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),

            // 底部添加按钮
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showAddPanel(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    foregroundColor: AppTheme.dark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    elevation: 0,
                  ),
                  child: const Text('＋ 添加装备'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _cycleStatus(AppState state, int index) {
    final current = state.equipment[index].status;
    final idx = _statusCycle.indexOf(current);
    final next = _statusCycle[(idx + 1) % _statusCycle.length];
    state.cycleEquipmentStatus(index);
    // 刷新出发面板
    state.refreshDepartPanel();
    setState(() {});
  }

  void _showAddPanel(BuildContext context) {
    final nameController = TextEditingController();
    String selectedEmoji = '🔧';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                left: 24, right: 24,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 拖拽指示条
                  Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('添加装备',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // 输入框
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: '装备名称',
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Emoji 选择栏
                  Wrap(
                    spacing: 8,
                    children: [
                      '⛑️','🧤','🫗','🛞','🔧',
                      '🍬','🧥','🩹','🔋','🕶️',
                    ].map((e) => GestureDetector(
                      onTap: () {
                        setModal(() { selectedEmoji = e; });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedEmoji == e
                              ? AppTheme.primary.withOpacity(0.1)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 24)),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 添加按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        context.read<AppState>().addEquip(
                          name: name,
                          icon: selectedEmoji,
                          status: 'ok',
                        );
                        context.read<AppState>().refreshDepartPanel();
                        Navigator.of(ctx).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('添加'),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 取消按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        foregroundColor: AppTheme.dark,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        elevation: 0,
                      ),
                      child: const Text('取消'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _EquipChip extends StatelessWidget {
  final Equipment equipment;
  final VoidCallback onTap;

  const _EquipChip({required this.equipment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOk = equipment.status == 'ok';
    final isAttention = equipment.status == 'attention';
    final isMissing = equipment.status == 'missing';

    Color borderColor;
    Color bgColor;

    if (isOk) {
      borderColor = const Color(0x4D5A6F45); // rgba(90,111,69,0.3)
      bgColor = const Color(0xFFF4F7F2);
    } else if (isAttention) {
      borderColor = const Color(0x4DF57C00); // rgba(245,124,0,0.3)
      bgColor = const Color(0xFFFFF9F4);
    } else {
      borderColor = const Color(0x4DD94A4A); // rgba(217,74,74,0.3)
      bgColor = const Color(0xFFFFF6F6);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(equipment.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(equipment.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
