import 'package:flutter/material.dart';
import '../config/app_config.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('隐私政策')),
      body: ListView(padding: const EdgeInsets.all(20), children: const [
        Text('隐私政策', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        SizedBox(height: 16),
        Text('更新日期：2026年4月30日\n\n'
          '去野（以下简称"我们"）深知个人信息对您的重要性，并会全力保护您的个人信息安全。\n\n'
          '1. 我们收集的信息\n'
          '- 位置信息：为您提供导航、轨迹记录、安全预警等服务\n'
          '- 设备信息：优化应用体验，适配不同设备\n'
          '- 账号信息：用于个人中心和数据同步\n\n'
          '2. 信息使用\n'
          '- 位置数据仅用于本地导航和轨迹记录\n'
          '- 不会将您的个人信息用于其他目的\n'
          '- 不会将数据分享给第三方\n\n'
          '3. 信息安全\n'
          '- 采用业界标准的安全措施保护您的信息\n'
          '- 定期进行安全审计\n\n'
          '4. 您的权利\n'
          '- 可随时查看、修改个人信息\n'
          '- 可选择关闭位置权限\n'
          '- 可申请删除账号和所有数据\n\n'
          '5. 联系我们\n'
          '如有隐私相关问题，请通过应用内反馈渠道联系我们。',
          style: TextStyle(fontSize: 15, height: 1.8, color: AppConfig.textPrimary)),
      ]),
    );
  }
}
