import 'package:flutter/material.dart';
import '../config/app_config.dart';

class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户协议')),
      body: ListView(padding: const EdgeInsets.all(20), children: const [
        Text('用户协议', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        SizedBox(height: 16),
        Text('更新日期：2026年4月30日\n\n'
          '欢迎使用去野！\n\n'
          '一、服务说明\n'
          '去野是一款户外出行辅助工具，提供导航、轨迹记录、路线规划、社区互动等功能。\n\n'
          '二、用户责任\n'
          '1. 户外活动存在风险，请根据自身能力理性选择路线\n'
          '2. 应用提供的安全预警仅供参考，不替代专业判断\n'
          '3. 请遵守当地法律法规和交通规则\n\n'
          '三、免责条款\n'
          '1. 由于户外环境的复杂性，我们不对因使用本应用导致的任何直接或间接损失承担责任\n'
          '2. GPS信号和网络覆盖可能受环境影响，不保证100%精度\n'
          '3. 紧急求助功能依赖网络连接，极端环境下可能无法正常工作\n\n'
          '四、行为规范\n'
          '用户不得利用社区功能发布违法、违规或不当内容。\n\n'
          '五、协议修改\n'
          '我们保留修改本协议的权利，修改后将通过应用内通知。',
          style: TextStyle(fontSize: 15, height: 1.8, color: AppConfig.textPrimary)),
      ]),
    );
  }
}
