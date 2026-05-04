import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../config/scenario_config.dart';
import '../providers/scenario_provider.dart';

// ============================================================
// 出行攻略模块 — Section 6
// ============================================================

// ---- 攻略条目模型 ----
class _GuideEntry {
  final String id, title, content;
  final _GuideCategory category;
  final List<String> photoUrls;
  final DateTime createdAt;

  const _GuideEntry({
    required this.id, required this.title, required this.content,
    required this.category, this.photoUrls = const [],
    required this.createdAt,
  });
}

enum _GuideCategory {
  food('🍜', '餐饮'),
  lodging('🏨', '住宿'),
  transport('🚴', '行'),
  supply('💧', '补给点');

  final String emoji, label;
  const _GuideCategory(this.emoji, this.label);
}

// ---- 主页面 ----
class TravelGuidePage extends StatefulWidget {
  const TravelGuidePage({super.key});

  @override
  State<TravelGuidePage> createState() => _TravelGuidePageState();
}

class _TravelGuidePageState extends State<TravelGuidePage> {
  // mock 攻略条目
  final _entries = <_GuideEntry>[
    _GuideEntry(
      id: '1', title: '山脚农家菜馆', content: '老板热情，推荐土鸡煲和竹笋炒肉，人均40元',
      category: _GuideCategory.food, createdAt: DateTime(2026, 5, 1),
    ),
    _GuideEntry(
      id: '2', title: '骑行路段注意事项', content: '3公里处为碎石路段，建议下车推行；7公里坡陡弯急',
      category: _GuideCategory.transport, createdAt: DateTime(2026, 5, 2),
    ),
  ];

  _GuideCategory? _selectedCat;

  List<_GuideEntry> get _filtered {
    if (_selectedCat == null) return _entries;
    return _entries.where((e) => e.category == _selectedCat).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scenario = context.watch<ScenarioProvider>().scenario;
    final cfg = ScenarioConfig.of(scenario);

    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        title: const Text('出行攻略'),
        backgroundColor: AppConfig.glassBg,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 24),
            onPressed: () => _openEditor(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 分类筛选
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
            decoration: const BoxDecoration(
              color: AppConfig.glassBg,
              border: Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedCat = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _selectedCat == null ? cfg.primaryColor.withOpacity(0.08) : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('全部', style: TextStyle(
                      fontSize: 13,
                      fontWeight: _selectedCat == null ? FontWeight.w600 : FontWeight.w400,
                      color: _selectedCat == null ? cfg.primaryColor : AppConfig.textSecondary,
                    )),
                  ),
                ),
                ..._GuideCategory.values.map((cat) {
                  final active = _selectedCat == cat;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCat = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? cfg.primaryColor.withOpacity(0.08) : null,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text('${cat.emoji} ${cat.label}', style: TextStyle(
                          fontSize: 13,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          color: active ? cfg.primaryColor : AppConfig.textSecondary,
                        )),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // 内容
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('📒', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 12),
                        const Text('还没有攻略', style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500, color: AppConfig.textPrimary,
                        )),
                        const SizedBox(height: 4),
                        const Text('记录沿途的衣食住行', style: TextStyle(
                          fontSize: 13, color: AppConfig.textSecondary,
                        )),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _openEditor(),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('添加第一条攻略'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cfg.primaryColor,
                            foregroundColor: AppConfig.textInverse,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppConfig.pageMargin),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppConfig.cardGap),
                    itemBuilder: (ctx, i) => _buildEntryCard(_filtered[i], cfg.primaryColor),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(_GuideEntry entry, Color primaryColor) {
    final cat = entry.category;
    return GestureDetector(
      onTap: () => _openEditor(entry: entry),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('${cat.emoji} ${cat.label}', style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w500, color: primaryColor,
                  )),
                ),
                const Spacer(),
                Text(
                  '${entry.createdAt.month}/${entry.createdAt.day}',
                  style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(entry.title, style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
            )),
            const SizedBox(height: 6),
            Text(entry.content, style: const TextStyle(
              fontSize: 14, color: AppConfig.textSecondary, height: 1.5,
            ), maxLines: 3, overflow: TextOverflow.ellipsis),

            if (entry.photoUrls.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: entry.photoUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, j) => Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.image_outlined, size: 24, color: primaryColor.withOpacity(0.3)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openEditor({_GuideEntry? entry}) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _GuideEditorPage(entry: entry),
    )).then((result) {
      if (result != null && result is _GuideEntry) {
        setState(() {
          if (entry != null) {
            final idx = _entries.indexWhere((e) => e.id == entry.id);
            if (idx >= 0) _entries[idx] = result;
          } else {
            _entries.insert(0, result);
          }
        });
      }
    });
  }
}

// ---- 编辑器 ----
class _GuideEditorPage extends StatefulWidget {
  final _GuideEntry? entry;
  const _GuideEditorPage({this.entry});

  @override
  State<_GuideEditorPage> createState() => __GuideEditorPageState();
}

class __GuideEditorPageState extends State<_GuideEditorPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late _GuideCategory _category;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.entry?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.entry?.content ?? '');
    _category = widget.entry?.category ?? _GuideCategory.food;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scenario = context.watch<ScenarioProvider>().scenario;
    final cfg = ScenarioConfig.of(scenario);
    final isEdit = widget.entry != null;

    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        title: Text(isEdit ? '编辑攻略' : '添加攻略'),
        backgroundColor: AppConfig.glassBg,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('保存', style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: cfg.primaryColor,
            )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分类选择
            const Text('分类', style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textSecondary,
            )),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _GuideCategory.values.map((cat) {
                final active = _category == cat;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? cfg.primaryColor.withOpacity(0.08) : AppConfig.cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: active ? cfg.primaryColor.withOpacity(0.3) : AppConfig.divider,
                      ),
                    ),
                    child: Text('${cat.emoji} ${cat.label}', style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? cfg.primaryColor : AppConfig.textPrimary,
                    )),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 标题
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(fontSize: 16, color: AppConfig.textPrimary),
              decoration: InputDecoration(
                hintText: '标题（如：推荐餐厅、注意事项）',
                hintStyle: const TextStyle(fontSize: 14, color: AppConfig.textSecondary),
                filled: true,
                fillColor: AppConfig.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConfig.inputRadius),
                  borderSide: const BorderSide(color: AppConfig.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConfig.inputRadius),
                  borderSide: BorderSide(color: cfg.primaryColor),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 内容
            TextField(
              controller: _contentCtrl,
              maxLines: 8,
              style: const TextStyle(fontSize: 15, color: AppConfig.textPrimary),
              decoration: InputDecoration(
                hintText: '详细描述…',
                hintStyle: const TextStyle(fontSize: 14, color: AppConfig.textSecondary),
                filled: true,
                fillColor: AppConfig.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConfig.inputRadius),
                  borderSide: const BorderSide(color: AppConfig.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConfig.inputRadius),
                  borderSide: BorderSide(color: cfg.primaryColor),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 添加照片
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('照片上传功能开发中')),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConfig.cardBg,
                  borderRadius: BorderRadius.circular(AppConfig.inputRadius),
                  border: Border.all(color: AppConfig.divider, style: BorderStyle.solid),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 20, color: AppConfig.textSecondary),
                    SizedBox(width: 8),
                    Text('添加照片', style: TextStyle(fontSize: 14, color: AppConfig.textSecondary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('标题和内容不能为空')),
      );
      return;
    }

    final result = _GuideEntry(
      id: widget.entry?.id ?? 'guide_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      category: _category,
      createdAt: widget.entry?.createdAt ?? DateTime.now(),
    );

    Navigator.pop(context, result);
  }
}
