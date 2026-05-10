import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// V7.5 我的待办 — 可持久化的骑行待办系统
/// 三阶段：出发前 / 骑行中 / 骑行后
/// 支持：预置装备清单 + 自由添加待办 + 状态持久化
class MyTodoPage extends StatefulWidget {
  const MyTodoPage({super.key});

  @override
  State<MyTodoPage> createState() => _MyTodoPageState();
}

class _MyTodoPageState extends State<MyTodoPage> {
  late SharedPreferences _prefs;

  // 三阶段待办
  final Map<TodoPhase, List<TodoItem>> _todos = {
    TodoPhase.preRide: [],
    TodoPhase.duringRide: [],
    TodoPhase.postRide: [],
  };

  // 当前筛选
  TodoPhase _filter = TodoPhase.all;

  // 编辑模式
  bool _isEditing = false;
  final TextEditingController _addCtrl = TextEditingController();
  TodoPhase _addPhase = TodoPhase.preRide;

  bool _loaded = false;

  // 预置出发前装备（首次使用时加载）
  static const _defaultPreRideItems = [
    ('头盔', true),
    ('手套', true),
    ('水壶×2', true),
    ('内胎×2', false),
    ('打气筒', true),
    ('能量胶×3', false),
    ('前灯', true),
    ('尾灯', true),
    ('骑行眼镜', null),
    ('雨衣', true),
  ];

  static const _defaultPreRideBike = [
    ('刹车检查', true),
    ('胎压检查', true),
    ('链条润油', false),
    ('变速检查', true),
  ];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs.getString('v75_todos');
    if (saved != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(saved);
        for (final phase in TodoPhase.values.where((p) => p != TodoPhase.all)) {
          final list = decoded[phase.name] as List<dynamic>?;
          if (list != null) {
            _todos[phase] = list.map((e) => TodoItem.fromJson(e)).toList();
          }
        }
      } catch (_) {}
    }

    // 首次使用：加载预置装备
    if (_todos[TodoPhase.preRide]!.isEmpty) {
      _todos[TodoPhase.preRide] = [
        ..._defaultPreRideItems.map((e) => TodoItem(
              text: e.$1,
              phase: TodoPhase.preRide,
              done: e.$2,
              isDefault: true,
            )),
        ..._defaultPreRideBike.map((e) => TodoItem(
              text: e.$1,
              phase: TodoPhase.preRide,
              done: e.$2,
              isDefault: true,
              category: 'bike',
            )),
      ];
      _saveTodos();
    }

    setState(() => _loaded = true);
  }

  Future<void> _saveTodos() async {
    final Map<String, dynamic> toSave = {};
    for (final phase in TodoPhase.values.where((p) => p != TodoPhase.all)) {
      toSave[phase.name] = _todos[phase]!.map((e) => e.toJson()).toList();
    }
    await _prefs.setString('v75_todos', json.encode(toSave));
  }

  void _toggleDone(TodoPhase phase, int index) {
    setState(() {
      _todos[phase]![index].done = !(_todos[phase]![index].done ?? false);
    });
    _saveTodos();
  }

  void _addTodo() {
    final text = _addCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _todos[_addPhase]!.add(TodoItem(
        text: text,
        phase: _addPhase,
        done: false,
      ));
    });
    _addCtrl.clear();
    _saveTodos();
  }

  void _deleteTodo(TodoPhase phase, int index) {
    setState(() {
      _todos[phase]!.removeAt(index);
    });
    _saveTodos();
  }

  void _resetPreRide() {
    setState(() {
      _todos[TodoPhase.preRide] = [
        ..._defaultPreRideItems.map((e) => TodoItem(
              text: e.$1,
              phase: TodoPhase.preRide,
              done: e.$2,
              isDefault: true,
            )),
        ..._defaultPreRideBike.map((e) => TodoItem(
              text: e.$1,
              phase: TodoPhase.preRide,
              done: e.$2,
              isDefault: true,
              category: 'bike',
            )),
      ];
    });
    _saveTodos();
  }

  int _getDoneCount(TodoPhase phase) {
    return _todos[phase]?.where((t) => t.done == true).length ?? 0;
  }

  int _getTotalCount(TodoPhase phase) {
    return _todos[phase]?.length ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: AppConfig.bgMain,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgressOverview(),
          _buildFilterBar(),
          _buildQuickAdd(),
          Expanded(child: _buildTodoList()),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppConfig.cardBg,
      elevation: 0,
      title: const Text(
        '我的待办',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary),
      ),
      actions: [
        if (!_isEditing)
          TextButton(
            onPressed: () => setState(() => _isEditing = true),
            child: const Text('编辑', style: TextStyle(fontSize: 14, color: AppConfig.primary)),
          )
        else
          TextButton(
            onPressed: () => setState(() => _isEditing = false),
            child: const Text('完成', style: TextStyle(fontSize: 14, color: AppConfig.primary)),
          ),
      ],
    );
  }

  Widget _buildProgressOverview() {
    final phases = [TodoPhase.preRide, TodoPhase.duringRide, TodoPhase.postRide];
    return Container(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      child: Row(
        children: phases.map((phase) {
          final done = _getDoneCount(phase);
          final total = _getTotalCount(phase);
          final pct = total > 0 ? done / total : 0.0;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Text(
                    phase.label,
                    style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppConfig.divider,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: pct,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppConfig.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$done/$total',
                    style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TodoPhase.values.map((phase) {
            final selected = _filter == phase;
            return GestureDetector(
              onTap: () => setState(() => _filter = phase),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? AppConfig.primary : AppConfig.cardBg,
                  borderRadius: BorderRadius.circular(AppConfig.tagRadius),
                  border: Border.all(color: selected ? AppConfig.primary : AppConfig.divider),
                ),
                child: Text(
                  phase.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected ? AppConfig.textInverse : AppConfig.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildQuickAdd() {
    return Container(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      child: Row(
        children: [
          // Phase selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppConfig.cardBg,
              borderRadius: BorderRadius.circular(AppConfig.inputRadius),
              border: Border.all(color: AppConfig.divider),
            ),
            child: DropdownButton<TodoPhase>(
              value: _addPhase,
              underline: const SizedBox(),
              isDense: true,
              items: [TodoPhase.preRide, TodoPhase.duringRide, TodoPhase.postRide]
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.label, style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _addPhase = v ?? TodoPhase.preRide),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _addCtrl,
              decoration: const InputDecoration(
                hintText: '添加待办...',
                hintStyle: TextStyle(fontSize: 14, color: AppConfig.textSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: const TextStyle(fontSize: 14),
              onSubmitted: (_) => _addTodo(),
            ),
          ),
          IconButton(
            onPressed: _addTodo,
            icon: const Icon(Icons.add, color: AppConfig.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    final phasesToShow = _filter == TodoPhase.all
        ? [TodoPhase.preRide, TodoPhase.duringRide, TodoPhase.postRide]
        : [_filter];

    return ListView(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      children: phasesToShow.map((phase) {
        final todos = _todos[phase]!;
        if (todos.isEmpty && _filter != TodoPhase.all) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                '暂无${phase.label}',
                style: const TextStyle(fontSize: 14, color: AppConfig.textSecondary),
              ),
            ),
          );
        }
        return _buildPhaseSection(phase, todos);
      }).toList(),
    );
  }

  Widget _buildPhaseSection(TodoPhase phase, List<TodoItem> todos) {
    if (todos.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: AppConfig.cardGap),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
        boxShadow: AppConfig.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5)),
            ),
            child: Row(
              children: [
                Text(
                  phase.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  phase.label,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary),
                ),
                const Spacer(),
                Text(
                  '${_getDoneCount(phase)}/${_getTotalCount(phase)}',
                  style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary),
                ),
              ],
            ),
          ),
          // Items
          ...todos.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return _buildTodoItem(phase, idx, item);
          }),
          // Reset button for pre-ride
          if (phase == TodoPhase.preRide && _isEditing)
            Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                  onPressed: _resetPreRide,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConfig.primary,
                    side: const BorderSide(color: AppConfig.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConfig.buttonRadius),
                    ),
                  ),
                  child: const Text('重置为默认清单', style: TextStyle(fontSize: 13)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(TodoPhase phase, int index, TodoItem item) {
    final done = item.done == true;
    final needFix = item.done == false;

    return Dismissible(
      key: Key('${phase.name}_$index'),
      direction: _isEditing ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppConfig.sosRed,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteTodo(phase, index),
      child: GestureDetector(
        onTap: () => _toggleDone(phase, index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5)),
          ),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? AppConfig.primary.withOpacity(0.15)
                      : needFix
                          ? AppConfig.warningOrange.withOpacity(0.15)
                          : Colors.transparent,
                  border: Border.all(
                    color: done
                        ? AppConfig.primary
                        : needFix
                            ? AppConfig.warningOrange
                            : AppConfig.divider,
                    width: 1.5,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check, size: 14, color: AppConfig.primary)
                    : needFix
                        ? const Text('!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppConfig.warningOrange))
                        : null,
              ),
              const SizedBox(width: 12),
              // Text
              Expanded(
                child: Text(
                  item.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: done ? AppConfig.textSecondary : AppConfig.textPrimary,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              // Category badge
              if (item.category == 'bike')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppConfig.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('车辆', style: TextStyle(fontSize: 10, color: AppConfig.textSecondary)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 待办阶段
enum TodoPhase {
  all('全部', '📋'),
  preRide('出发前', '🛡️'),
  duringRide('骑行中', '🚴'),
  postRide('骑行后', '📝');

  final String label;
  final String emoji;
  const TodoPhase(this.label, this.emoji);
}

/// 待办项
class TodoItem {
  final String text;
  final TodoPhase phase;
  bool? done;
  final bool isDefault;
  final String? category;

  TodoItem({
    required this.text,
    required this.phase,
    this.done,
    this.isDefault = false,
    this.category,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'phase': phase.name,
        'done': done,
        'isDefault': isDefault,
        'category': category,
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        text: json['text'] as String,
        phase: TodoPhase.values.firstWhere((p) => p.name == json['phase']),
        done: json['done'] as bool?,
        isDefault: json['isDefault'] as bool? ?? false,
        category: json['category'] as String?,
      );
}
