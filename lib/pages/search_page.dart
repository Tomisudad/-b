import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _ctrl = TextEditingController();
  final _history = ['川西环线', '318国道', '西湖骑行', '皖南川藏线', '房车营地'];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '搜索路线、装备、帖子...',
            hintStyle: TextStyle(fontSize: 14, color: AppTheme.textAux),
            border: InputBorder.none,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 搜索历史
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('搜索历史', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
              GestureDetector(
                onTap: () => setState(() => _history.clear()),
                child: const Icon(Icons.delete_outline, size: 18, color: AppTheme.textAux),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _history.map((h) => Chip(
              label: Text(h, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              backgroundColor: AppTheme.secondaryBg,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onDeleted: () => setState(() => _history.remove(h)),
              deleteIcon: const Icon(Icons.close, size: 14, color: AppTheme.textAux),
            )).toList(),
          ),

          const SizedBox(height: 24),

          // 热门搜索
          const Text('大家都在搜', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          ...['露营装备推荐', '长途摩旅路线', '骑行头盔测评', '亲子自驾行程', '高原反应准备'].map((h) => ListTile(
            dense: true,
            leading: const Icon(Icons.trending_up, size: 18, color: AppTheme.textAux),
            title: Text(h, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
            contentPadding: EdgeInsets.zero,
            onTap: () {},
          )),
        ],
      ),
    );
  }
}
