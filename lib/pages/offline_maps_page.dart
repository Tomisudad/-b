import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/offline_map_provider.dart';
import '../config/app_config.dart';

class OfflineMapsPage extends StatelessWidget {
  const OfflineMapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OfflineMapProvider(),
      child: const _OfflineMapsView(),
    );
  }
}

class _OfflineMapsView extends StatefulWidget {
  const _OfflineMapsView();

  @override
  State<_OfflineMapsView> createState() => _OfflineMapsViewState();
}

class _OfflineMapsViewState extends State<_OfflineMapsView> {
  String _filterProvince = '全部';

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<OfflineMapProvider>();
    final regions = _filterProvince == '全部'
        ? OfflineMapProvider.availableRegions
        : OfflineMapProvider.availableRegions.where((r) => r.province == _filterProvince).toList();

    final provinces = <String>{'全部'}
      ..addAll(OfflineMapProvider.availableRegions.map((r) => r.province).toSet());
    final sortedProvinces = provinces.toList()..sort((a, b) {
      if (a == '全部') return -1;
      if (b == '全部') return 1;
      return a.compareTo(b);
    });

    final downloadedMB = prov.totalDownloadedMB;
    final totalMB = OfflineMapProvider.availableRegions.fold<double>(0, (s, r) => s + r.sizeMB);

    return Scaffold(
      backgroundColor: AppConfig.bgSecondary,
      appBar: AppBar(
        title: const Text('离线地图', style: TextStyle(fontFamily: 'PingFang SC', fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (prov.downloadedCount > 0)
            TextButton.icon(
              onPressed: _showClearAllDialog,
              icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFE53935)),
              label: const Text('清空', style: TextStyle(color: Color(0xFFE53935), fontSize: 13)),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildStorageBar(prov, downloadedMB, totalMB),
          _buildProvinceFilter(sortedProvinces),
          Expanded(
            child: regions.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: regions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _buildRegionCard(regions[i], prov),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageBar(OfflineMapProvider prov, double used, double total) {
    final pct = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('已用空间', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
              const Spacer(),
              Text(
                '${used.toStringAsFixed(0)} / ${total.toStringAsFixed(0)} MB  (${prov.downloadedCount}个城市)',
                style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: const Color(0xFFE5E5E5),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvinceFilter(List<String> provinces) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: provinces.map((p) {
            final isActive = p == _filterProvince;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _filterProvince = p),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF2E7D32) : const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    p,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.white : AppConfig.textSecondary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRegionCard(MapRegion region, OfflineMapProvider prov) {
    final status = prov.statusOf(region.id);
    final progress = prov.progressOf(region.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: status == DownloadStatus.downloaded ? () => _showRegionDetail(context, region) : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_statusIcon(status), size: 22, color: _statusColor(status)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        region.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppConfig.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${region.sizeMB.toStringAsFixed(0)} MB · ${region.tileCount}张瓦片',
                        style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary),
                      ),
                      if (status == DownloadStatus.downloading) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 3,
                            backgroundColor: const Color(0xFFE5E5E5),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildActionButton(status, progress, region, prov),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(DownloadStatus status, double progress, MapRegion region, OfflineMapProvider prov) {
    switch (status) {
      case DownloadStatus.notDownloaded:
        return SizedBox(
          height: 32,
          child: ElevatedButton(
            onPressed: () => prov.download(region.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            child: const Text('下载'),
          ),
        );
      case DownloadStatus.downloading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => prov.pause(region.id),
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.pause, size: 16, color: Color(0xFF888888)),
              ),
            ),
          ],
        );
      case DownloadStatus.paused:
        return GestureDetector(
          onTap: () => prov.resume(region.id),
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.play_arrow, size: 18, color: Color(0xFFE65100)),
          ),
        );
      case DownloadStatus.downloaded:
        return GestureDetector(
          onTap: () => _confirmRemove(region, prov),
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.check, size: 18, color: Color(0xFF2E7D32)),
          ),
        );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_outlined, size: 56, color: AppConfig.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 12),
          const Text('该地区暂无可用地图', style: TextStyle(fontSize: 14, color: AppConfig.textSecondary)),
        ],
      ),
    );
  }

  Color _statusColor(DownloadStatus s) {
    switch (s) {
      case DownloadStatus.notDownloaded: return const Color(0xFF888888);
      case DownloadStatus.downloading: return const Color(0xFF2E7D32);
      case DownloadStatus.paused: return const Color(0xFFE65100);
      case DownloadStatus.downloaded: return const Color(0xFF2E7D32);
    }
  }

  IconData _statusIcon(DownloadStatus s) {
    switch (s) {
      case DownloadStatus.notDownloaded: return Icons.cloud_download_outlined;
      case DownloadStatus.downloading: return Icons.downloading;
      case DownloadStatus.paused: return Icons.pause_circle_outlined;
      case DownloadStatus.downloaded: return Icons.check_circle_outline;
    }
  }

  void _confirmRemove(MapRegion region, OfflineMapProvider prov) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除地图'),
        content: Text('确定删除「${region.name}」离线地图？该操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消', style: TextStyle(color: Color(0xFF888888)))),
          TextButton(
            onPressed: () {
              prov.remove(region.id);
              Navigator.pop(ctx);
            },
            child: const Text('删除', style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空全部'),
        content: const Text('确定清空所有已下载的离线地图？此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消', style: TextStyle(color: Color(0xFF888888)))),
          TextButton(
            onPressed: () {
              final prov = context.read<OfflineMapProvider>();
              for (final r in OfflineMapProvider.availableRegions) {
                if (prov.statusOf(r.id) == DownloadStatus.downloaded) {
                  prov.remove(r.id);
                }
              }
              Navigator.pop(ctx);
            },
            child: const Text('全部清空', style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
  }

  void _showRegionDetail(BuildContext context, MapRegion region) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(region.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
                  child: const Text('已下载', style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32))),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow(Icons.storage_outlined, '大小', '${region.sizeMB.toStringAsFixed(0)} MB'),
            _detailRow(Icons.grid_view_outlined, '瓦片数', '${region.tileCount} 张'),
            _detailRow(Icons.layers_outlined, '级别', '市级地图 (1:100万)'),
            _detailRow(Icons.update_outlined, '更新', '2026-04 版'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final prov = context.read<OfflineMapProvider>();
                  prov.remove(region.id);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFE53935)),
                label: const Text('删除此地图', style: TextStyle(color: Color(0xFFE53935))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0x33E53935)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppConfig.textSecondary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, color: AppConfig.textPrimary)),
        ],
      ),
    );
  }
}
