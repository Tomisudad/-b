import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.3 骑行维修须知 — 离线知识库
class CyclingKnowledgePage extends StatefulWidget {
  const CyclingKnowledgePage({super.key});

  @override
  State<CyclingKnowledgePage> createState() => _CyclingKnowledgePageState();
}

class _CyclingKnowledgePageState extends State<CyclingKnowledgePage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _sections = [
    _KSection('🚲', '补胎与换胎', _tireContent),
    _KSection('🔗', '链条维修', _chainContent),
    _KSection('🛑', '刹车调整', _brakeContent),
    _KSection('⚙️', '变速器调整', _gearContent),
    _KSection('🩹', '骑行安全与应急', _safetyContent),
    _KSection('🌧️', '特殊天气应对', _weatherContent),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _sections.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('骑行维修须知', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            labelColor: AppConfig.textPrimary,
            unselectedLabelColor: AppConfig.textSecondary,
            indicatorColor: AppConfig.primary,
            tabs: _sections.map((s) => Tab(text: '${s.emoji} ${s.title}')).toList(),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: _sections.map((s) => _buildContent(s)).toList(),
      ),
    );
  }

  Widget _buildContent(_KSection section) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: section.content.map((item) => _buildItem(item)).toList(),
      ),
    );
  }

  Widget _buildItem(_KItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        boxShadow: AppConfig.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppConfig.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(item.icon, style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(item.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppConfig.textPrimary))),
          ]),
          const SizedBox(height: 12),
          ...item.steps.asMap().entries.map((e) {
            final stepNum = e.key + 1;
            final stepText = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(color: AppConfig.primary, borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text('$stepNum', style: const TextStyle(fontSize: 11, color: Colors.white))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(stepText, style: const TextStyle(fontSize: 13, color: AppConfig.textPrimary, height: 1.5))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _KSection {
  final String emoji;
  final String title;
  final List<_KItem> content;
  const _KSection(this.emoji, this.title, this.content);
}

class _KItem {
  final String icon;
  final String title;
  final List<String> steps;
  const _KItem(this.icon, this.title, this.steps);
}

// ===== 知识内容 =====
const _tireContent = [
  _KItem('🔍', '找漏气点方法', [
    '浸水法：把内胎浸入水中，冒泡处即为漏点',
    '听声法：靠近耳朵缓慢转动内胎，听嘶嘶声',
    '注意：找到一处后继续检查，可能有多个漏点',
  ]),
  _KItem('🔧', '补胎5步', [
    '拆轮：松开刹车，快拆或拆轴螺母，取下轮组',
    '撬胎：用撬胎棒从气门对侧撬入，沿轮圈滑动分离外胎',
    '找漏：取出内胎，充气后浸水找漏点，标记位置',
    '打磨涂胶：用砂纸打磨漏点周围2cm，涂补胎胶水，晾至半干',
    '贴片装回：贴上补胎片压实，装回内胎和外胎，充气检查',
  ]),
  _KItem('🔄', '换内胎4步', [
    '拆轮取胎：同补胎步骤拆下轮组和内胎',
    '检查外胎：用手摸外胎内侧，确认无尖锐物残留',
    '装新内胎：给新内胎稍微充气（不鼓起），放入外胎内',
    '装轮充气：装回外胎和轮组，充气至推荐胎压',
  ]),
];

const _chainContent = [
  _KItem('🔩', '链条断裂接合', [
    '用打链器将断裂处的销钉推出',
    '用链条魔术扣连接两端（推荐常备魔术扣）',
    '若无魔术扣，用打链器重新压入销钉',
    '注意：接合后链条会变短，避免使用大齿比',
  ]),
  _KItem('💧', '链条上油步骤', [
    '用抹布擦去链条表面油污',
    '用专用链条清洁刷清理齿隙',
    '每个链节滴一滴链条油',
    '静置5分钟后用抹布擦去表面多余油',
    '注意：每200-300km上油一次',
  ]),
  _KItem('📏', '链条更换判断', [
    '用链条测量卡尺测量拉伸量',
    '拉伸超过0.75%建议更换',
    '或数12节链节长度，超过308mm需更换',
    '注意：链条磨损会加速飞轮磨损',
  ]),
];

const _brakeContent = [
  _KItem('🔧', '线拉碟刹调节', [
    '找到刹车手柄上的调节旋钮',
    '逆时针旋转增加刹车行程',
    '顺时针旋转减少刹车行程',
    '理想状态：手柄捏到一半时刹车开始介入',
  ]),
  _KItem('🔊', '碟刹异响处理', [
    '用酒精清洁碟片表面',
    '检查来令片磨损程度',
    '调整卡钳位置使碟片居中',
    '若来令片沾油，需用砂纸打磨表面',
  ]),
  _KItem('⚙️', '圈刹调节', [
    '松开刹车固定螺丝调整刹车块位置',
    '刹车块应与轮圈平行，距轮圈边缘1-2mm',
    '拧紧螺丝后测试刹车效果',
    '注意：刹车块磨损到标线需更换',
  ]),
];

const _gearContent = [
  _KItem('🎯', '变速不准调节', [
    '后拨链器上H螺丝控制最小飞，L螺丝控制最大飞',
    '逆时针旋转增加线张力（链条向大飞移动）',
    '顺时针旋转减少线张力（链条向小飞移动）',
    '微调旋钮用于精细调节',
  ]),
  _KItem('⚠️', '限位螺丝注意', [
    'H螺丝（High）：限制链条向最小飞过度移动',
    'L螺丝（Low）：限制链条向最大飞过度移动',
    '调节时每次旋转1/4圈，逐步调整',
    '错误调节可能导致链条掉入辐条',
  ]),
];

const _safetyContent = [
  _KItem('🩹', '摔伤处理', [
    '轻微擦伤：用生理盐水冲洗，涂碘伏消毒',
    '伤口较大：用干净纱布按压止血，及时就医',
    '怀疑骨折：不要移动伤处，等待救援',
  ]),
  _KItem('🦵', '抽筋应对', [
    '立即停止骑行，下车休息',
    '小腿抽筋：扶墙站立，脚跟着地拉伸小腿',
    '大腿抽筋：躺下，用手拉住脚踝向后拉伸',
    '补充电解质水或运动饮料',
  ]),
  _KItem('🪖', '头盔佩戴', [
    '头盔前沿应与眉毛齐平',
    '扣带Y字叉位于耳垂下方',
    '扣带松紧度：可容纳两指',
    '头盔不能前后晃动',
  ]),
  _KItem('🖐️', '骑行手语', [
    '左转：左臂水平伸出',
    '右转：左臂向上弯曲或右臂水平伸出',
    '减速/停车：手臂向下摆动',
    '路面危险：指向危险位置',
  ]),
];

const _weatherContent = [
  _KItem('🌧️', '雨天骑行', [
    '降低胎压10-15psi增加抓地力',
    '避免急刹车和急转弯',
    '白线和井盖特别湿滑，尽量避开',
    '穿着鲜艳颜色增加能见度',
  ]),
  _KItem('☀️', '高温骑行', [
    '选择早晚时段骑行',
    '每15-20分钟补充水分',
    '佩戴遮阳帽、防晒臂套',
    '注意中暑症状：头晕、恶心立即停止',
  ]),
  _KItem('❄️', '寒冷骑行', [
    '穿着分层：排汗内层+保暖中层+防风外层',
    '保护好手、脚、耳朵等末端部位',
    '热身后再开始骑行',
    '注意路面结冰，特别是阴影处',
  ]),
];