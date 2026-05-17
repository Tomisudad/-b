import 'package:flutter/material.dart';

import '../../config/app_config.dart';

/// V6.1 GPX 导入选择页面
class GpxImportStep extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onImportSuccess;

  const GpxImportStep({
    super.key,
    required this.onBack,
    required this.onImportSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(title: const Text('导入GPX轨迹')),
      body: Padding(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('导入方式', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            const SizedBox(height: 20),
            _methodCard('📁', '选择本地文件', '支持 .gpx 格式', AppConfig.cyclePrimary, () => _handleGpxFile(context)),
            const SizedBox(height: 12),
            _methodCard('🔗', '粘贴链接', '输入GPX文件的URL', AppConfig.accentBlue, () => _handleGpxUrl(context)),
            const SizedBox(height: 12),
            _methodCard('📷', '扫码导入', '扫描二维码获取轨迹', AppConfig.accentOrange, () => _handleGpxScan(context)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onBack,
                child: const Text('← 返回', style: TextStyle(fontSize: 14, color: AppConfig.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodCard(String emoji, String title, String desc, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary, height: 1.3)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  void _handleGpxFile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GPX 文件解析成功！'), backgroundColor: AppConfig.cyclePrimary),
    );
    onImportSuccess();
  }

  void _handleGpxUrl(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.dialogRadius)),
        title: const Text('输入 GPX 链接'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'https://...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(onPressed: () { Navigator.pop(ctx); _handleGpxFile(context); }, child: const Text('确认')),
        ],
      ),
    );
  }

  void _handleGpxScan(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('扫码功能开发中，已模拟成功'), backgroundColor: AppConfig.accentOrange),
    );
    onImportSuccess();
  }
}