import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.6 骑行维修知识库
/// 从"我的"设置页"骑行维修须知"入口进入
class CyclingRepairPage extends StatefulWidget {
  const CyclingRepairPage({super.key});
  @override
  State<CyclingRepairPage> createState() => _CyclingRepairPageState();
}

class _CyclingRepairPageState extends State<CyclingRepairPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // 知识库分类tab
  static const _categories = [
    (_RepairCat.tire, '轮胎修补', '🔧'),
    (_RepairCat.chain, '链条保养', '⛓️'),
    (_RepairCat.brake, '刹车调整', '🛑'),
    (_RepairCat.gear, '变速调试', '⚙️'),
    (_RepairCat.emergency, '紧急处理', '🚨'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _categories.length, vsync: this);
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
        title: const Text('骑行维修须知', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: AppConfig.cyclePrimary,
          labelColor: AppConfig.cyclePrimary,
          unselectedLabelColor: AppConfig.textSecondary,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: _categories.map((c) => Tab(text: '${c.$3} ${c.$2}')).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: _categories.map((c) => _buildCategoryContent(c.$1)).toList(),
      ),
    );
  }

  Widget _buildCategoryContent(_RepairCat cat) {
    final items = _repairData[cat] ?? [];
    return ListView.separated(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppConfig.cardGap),
      itemBuilder: (_, i) => _buildRepairCard(items[i]),
    );
  }

  Widget _buildRepairCard(_RepairItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        boxShadow: AppConfig.cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppConfig.cyclePrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(item.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary))),
          if (item.difficulty != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _diffColor(item.difficulty!).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(item.difficulty!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: _diffColor(item.difficulty!))),
            ),
          ],
        ]),
        const SizedBox(height: 10),
        Text(item.content, style: const TextStyle(fontSize: 13, color: AppConfig.textBody, height: 1.6)),
        if (item.tips.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConfig.warningOrange.withOpacity(0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppConfig.warningOrange.withOpacity(0.15)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.lightbulb_outline, size: 14, color: AppConfig.warningOrange),
                const SizedBox(width: 4),
                Text('小贴士', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppConfig.warningOrange)),
              ]),
              const SizedBox(height: 6),
              ...item.tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('• ', style: TextStyle(fontSize: 12, color: AppConfig.textBody)),
                  Expanded(child: Text(t, style: const TextStyle(fontSize: 12, color: AppConfig.textBody))),
                ]),
              )),
            ]),
          ),
        ],
      ]),
    );
  }

  Color _diffColor(String d) {
    switch (d) {
      case '简单': return AppConfig.cyclePrimary;
      case '中等': return const Color(0xFF3498DB);
      case '困难': return AppConfig.warningOrange;
      default: return AppConfig.textSecondary;
    }
  }
}

// ===== 数据模型 =====
enum _RepairCat { tire, chain, brake, gear, emergency }

class _RepairItem {
  final String title;
  final String emoji;
  final String content;
  final String? difficulty;
  final List<String> tips;
  const _RepairItem(this.title, this.emoji, this.content, {this.difficulty, this.tips = const []});
}

// ===== 知识库内容 =====
const _repairData = {
  _RepairCat.tire: [
    _RepairItem('补胎步骤', '🔧', 
      '1. 找到破洞位置（水中冒泡法）\n2. 用砂纸打磨破洞周围\n3. 涂抹胶水，等待半干\n4. 贴上补胎片，压紧压实\n5. 装回内胎，打气检查',
      difficulty: '中等',
      tips: ['出发前多带2-3条备用内胎', '补胎片要比破洞大至少1cm', '沙漠/碎石路建议用防刺胎垫'],
    ),
    _RepairItem('更换内胎', '🔄',
      '1. 扒开外胎一侧\n2. 取出旧内胎\n3. 检查外胎内是否有异物\n4. 装入新内胎（先打一点气）\n5. 把外胎装回，打气至标准气压',
      difficulty: '简单',
      tips: ['新内胎先打一点气再装，避免夹胎', '装胎最后一段用拇指推，不用撬胎棒'],
    ),
    _RepairItem('快速补胎液使用', '💨',
      '补胎液是紧急救急方案，不是长久之计。\n1. 拔出气门芯\n2. 摇匀补胎液瓶\n3. 倒入约50-100ml\n4. 装回气门芯，打气\n5. 骑行几分钟让液体分布均匀',
      difficulty: '简单',
      tips: ['补胎液效果一般维持2-3个月', '之后还是要正式补胎或换内胎', '夏天高温时补胎液可能干得更快'],
    ),
  ],
  _RepairCat.chain: [
    _RepairItem('链条日常清洁', '🧹',
      '每200-300km清洁一次：\n1. 用干布擦去表面灰尘\n2. 用链条清洁刷清理缝隙\n3. 可用专用链条清洗器\n4. 清洁后等链条完全干燥',
      difficulty: '简单',
      tips: ['雨天骑行后务必清洁', '泥沙是链条最大杀手', '别用WD-40当链条油'],
    ),
    _RepairItem('链条上油', '💧',
      '1. 确保链条干燥清洁\n2. 滴油到每个链节内侧\n3. 等待5-10分钟渗透\n4. 擦去表面多余油\n5. 转动脚踏几圈让油分布均匀',
      difficulty: '简单',
      tips: ['干性链条油适合晴天，湿性适合雨天', '上油后一定要擦表面多余油', '太多油反而吸附灰尘'],
    ),
    _RepairItem('断链应急修复', '🔗',
      '1. 找到断点，用链条工具\n2. 把断销顶出\n3. 重新连接链条两端\n4. 顶入新销（或用魔术扣）\n5. 检查连接是否顺畅',
      difficulty: '困难',
      tips: ['随身带魔术扣最方便', '链条工具是长途必备', '修复后避免大功率踩踏'],
    ),
  ],
  _RepairCat.brake: [
    _RepairItem('刹车块更换', '🛑',
      '1. 用内六角松开刹车块螺丝\n2. 取下旧刹车块\n3. 装上新刹车块\n4. 调整角度：刹车块与轮圈平行\n5. 拧紧螺丝，测试刹车效果',
      difficulty: '中等',
      tips: ['刹车块磨损到指示线必须换', '左右刹车块磨损速度可能不同', '换后要重新调整刹车线张力'],
    ),
    _RepairItem('碟刹蹭碟处理', '💿',
      '碟刹发出摩擦声？\n1. 松开卡钳固定螺丝（2颗）\n2. 捏紧刹车把手\n3. 保持刹车，依次拧紧螺丝\n4. 松开刹车，转动轮子检查\n5. 若还有声音，微调卡钳位置',
      difficulty: '中等',
      tips: ['新车或拆装后容易蹭碟', '来令片磨损后也可能蹭碟', '严重蹭碟建议去车店调'],
    ),
    _RepairItem('刹车线调整', '📐',
      '刹车手感松？\n1. 先检查刹车块磨损情况\n2. 松开刹车线固定螺丝\n3. 拉紧刹车线到合适张力\n4. 拧紧固定螺丝\n5. 测试刹车行程是否合适',
      difficulty: '简单',
      tips: ['正常刹车行程约1/3把手行程', '太紧影响手感，太松刹不住', '调整完记得锁紧所有螺丝'],
    ),
  ],
  _RepairCat.gear: [
    _RepairItem('后拨链器调整', '⚙️',
      '换档不顺畅？\n1. H螺丝：调整最小飞轮位置\n2. L螺丝：调整最大飞轮位置\n3. 变速线微调旋钮：调整线张力\n4. 测试每个档位是否顺畅\n5. 边骑边调效果最好',
      difficulty: '困难',
      tips: ['先检查变速线是否松动', '后拨歪了要先校准导轮', '不确定就去车店调'],
    ),
    _RepairItem('前拨链器调整', '🔧',
      '1. 高低限螺丝（H/L）调整范围\n2. 变速线张力微调\n3. 拨链器高度：距大盘2-3mm\n4. 拨链器角度：与牙盘平行\n5. 测试升降档是否顺畅',
      difficulty: '困难',
      tips: ['前拨比后拨更难调', '调不好容易掉链', '建议找专业技师调'],
    ),
    _RepairItem('链条跳齿处理', '⚠️',
      '踩踏时打滑？\n1. 检查飞轮和牙盘磨损\n2. 检查链条是否拉长\n3. 链条拉长超过0.75%必须换\n4. 飞轮磨损严重也要换\n5. 建议整套更换',
      difficulty: '中等',
      tips: ['链条飞轮最好配套换', '用链条尺测量最准确', '跳齿很危险，下坡尤其'],
    ),
  ],
  _RepairCat.emergency: [
    _RepairItem('摔车后自检', '🏥',
      '1. 先检查自己有无受伤\n2. 再检查车辆状况\n3. 检查刹车是否正常\n4. 检查轮组是否偏摆\n5. 检查链条是否脱落',
      tips: ['头盔磕碰后必须换新', '肋骨疼要去医院检查', '伤筋动骨一百天'],
    ),
    _RepairItem('断辐条处理', '🚴',
      '1. 立即停止骑行\n2. 检查轮圈偏摆程度\n3. 若偏摆不大，可慢骑回城\n4. 断辐条要尽快更换\n5. 多根断裂必须叫车',
      tips: ['长途带1-2根备用辐条', '断辐条后别用力踩踏', '严重的偏摆可能蹭车架'],
    ),
    _RepairItem('夜间无灯骑行', '🌙',
      '若被迫夜间骑行：\n1. 找安全路段等待救援\n2. 打电话给队友或家人\n3. 使用手机闪光灯警示\n4. 穿亮色衣服\n5. 尽量靠边推行',
      tips: ['长途必须带前后灯', '手机灯当尾灯也行', '别在主路骑，危险'],
    ),
    _RepairItem('中暑处理', '☀️',
      '症状：头晕、恶心、皮肤发烫\n1. 立即停止骑行\n2. 找阴凉处休息\n3. 补充水和电解质\n4. 用湿毛巾降温\n5. 严重拨打120',
      tips: ['避开中午最热时段', '多喝水别等口渴', '感觉不适立即停下'],
    ),
  ],
};