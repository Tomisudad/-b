import 'package:flutter/material.dart';
import 'package:gowild_app/providers/app_state.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/ride_record.dart';

/// 记录页 — 严格对照 HTML renderRecord()
class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final records = state.records;
        final now = DateTime.now();
        final thisMonth = now.month;
        final monthRecords = records.where((r) {
          final d = r.date;
          if (d == '今天' || d == '刚刚') return true;
          final parts = d.split('/');
          if (parts.length == 2) {
            return int.tryParse(parts[0]) == thisMonth;
          }
          return false;
        }).toList();

        final totalDist = monthRecords.fold<double>(
          0, (sum, r) => sum + (double.tryParse(r.distance.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0));
        final totalClimb = monthRecords.fold<int>(
          0, (sum, r) => sum + (int.tryParse(r.climb.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0));
        final totalCount = monthRecords.length;

        return Column(
          children: [
            // 本月统计卡片
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(AppTheme.rCard24),
                boxShadow: AppTheme.cardShadowList,
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statColumn('${totalDist.toInt()}', '本月公里'),
                  _statColumn('$totalCount', '骑行次数'),
                  _statColumn('${(totalClimb / 1000).toStringAsFixed(1)}k', '爬升m'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 最近记录列表
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(AppTheme.rCard24),
                      boxShadow: AppTheme.cardShadowList,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('最近记录',
                            style: TextStyle(fontSize: 18, fontWeight: AppTheme.wBold)),
                        const SizedBox(height: 16),
                        ...records.map((r) => _RecordItem(record: r)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 查看路书回放按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        state.openSub('路书回放', 'playback');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('🎬 查看路书回放'),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statColumn(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppTheme.primary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
      ],
    );
  }
}

class _RecordItem extends StatelessWidget {
  final RideRecord record;
  const _RecordItem({required this.record});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<AppState>().openSub(record.name, 'rec-detail');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0x1A5A6F45),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.map, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.name,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                  Text('${record.date} · ${record.distance} · ${record.time} · ${record.climb}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
            Text('${record.speed} km/h',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
