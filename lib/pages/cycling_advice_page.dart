import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.5 骑行建议
class CyclingAdvicePage extends StatelessWidget {
  const CyclingAdvicePage({super.key});

  static const _tips = [
    _Tip('🌱', '春季骑行',
        '温差大时注意分层穿着、防水夹克随身穿戴、聚合柳絮谨防过敏、新手适合短途适应'),
    _Tip('☀️', '夏季骑行',
        '避开正午时段、多补充水分和电解质、防晒装备必不可少、注意中暑症状'),
    _Tip('🍂', '秋季骑行',
        '最佳骑行季节、路面落叶可能湿滑、日照缩短注意照明、层层叠穿方便脱换'),
    _Tip('❄️', '冬季骑行',
        '保暖优先、降低胎压增加抓地力、窄胎更安全、注意路面结冰'),
    _Tip('📏', '长途骑行',
        '提前规划路线、备足补给、每小时休息10分钟、携带位置分享'),
    _Tip('🧠', '新手入门',
        '从10km开始逐步增加、正确调整坐垫高度、学习基本修补、加入骑行社群'),
    _Tip('💪', '体能提升',
        '间歇训练提升快、核心训练优先、计划休息日、记录训练数据'),
    _Tip('🍽️', '骑行饮食',
        '骑行前1-2小时进食、途中每30分钟补充碳水、骑行后补充蛋白质'),
  ];

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('💡 骑行建议', style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: AppConfig.textPrimary)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        itemCount: _tips.length,
        itemBuilder: (_, i) => _buildCard(_tips[i]),
      ),
    );
  }

  Widget _buildCard(_Tip t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        boxShadow: AppConfig.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppConfig.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
            child: Center(
                child: Text(t.emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.title, style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppConfig.textPrimary)),
              const SizedBox(height: 6),
              Text(t.content, style: const TextStyle(
                  fontSize: 12, color: AppConfig.textSecondary,
                  height: 1.5)),
            ],
          )),
        ]),
      ),
    );
  }
}

class _Tip {
  final String emoji, title, content;
  const _Tip(this.emoji, this.title, this.content);
}