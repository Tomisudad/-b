import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/route_model.dart';

/// 我的路线卡片 — 严格对照 HTML renderHome() 路线列表部分
/// 标题 + 路线列表 + 每项右侧橙色出发按钮 + 新建路线入口
class RouteCard extends StatelessWidget {
  final List<RouteModel> routes;
  final void Function(String routeName)? onRouteTap;
  final void Function(String routeName)? onQuickDepart;
  final VoidCallback? onNewRoute;

  const RouteCard({
    Key? key,
    required this.routes,
    this.onRouteTap,
    this.onQuickDepart,
    this.onNewRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.rCard24),
        boxShadow: AppTheme.cardShadowList,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行：书本图标 + "我的路线" + 新建按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.menu_book,
                        color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '我的路线',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: AppTheme.wBold,
                      color: AppTheme.dark,
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: AppTheme.primary, size: 20),
                  onPressed: onNewRoute,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 路线列表
          ...routes.asMap().entries.map((entry) {
            final i = entry.key;
            final r = entry.value;
            return Column(
              children: [
                _buildRouteItem(context, r, i == routes.length - 1),
                if (i < routes.length - 1)
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
              ],
            );
          }).toList(),
          const SizedBox(height: 8),
          // 新建路线入口
          _buildNewRouteItem(),
        ],
      ),
    );
  }

  Widget _buildRouteItem(BuildContext context, RouteModel r, bool isLast) {
    return GestureDetector(
      onTap: () => onRouteTap?.call(r.name),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // 左侧地图图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.map, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            // 路线名 + 距离/时间/爬升
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: AppTheme.wMedium,
                      color: AppTheme.dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${r.distance} · ${r.time} · ${r.elevation}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 右侧出发箭头 "→"
            GestureDetector(
              onTap: () => onQuickDepart?.call(r.name),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '→',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewRouteItem() => GestureDetector(
        onTap: onNewRoute,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add,
                    color: Color(0xFF9CA3AF), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '新建路线',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right,
                  color: Color(0xFFD1D5DB), size: 20),
            ],
          ),
        ),
      );
}
