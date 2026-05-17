import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.7: 全局网络异常横幅
/// 监听 window.navigator.onLine + online/offline 事件
class NetworkBanner extends StatefulWidget {
  final Widget child;
  const NetworkBanner({super.key, required this.child});

  @override
  State<NetworkBanner> createState() => _NetworkBannerState();
}

class _NetworkBannerState extends State<NetworkBanner> {
  bool _isOnline = true;
  late StreamSubscription<html.Event> _onSub, _offSub;

  @override
  void initState() {
    super.initState();
    _isOnline = html.window.navigator.onLine ?? true;
    _onSub = html.window.onOnline.listen((_) {
      if (mounted) {
        setState(() => _isOnline = true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ 网络已恢复'),
          backgroundColor: AppConfig.cyclePrimary,
          duration: Duration(seconds: 2),
        ));
      }
    });
    _offSub = html.window.onOffline.listen((_) {
      if (mounted) setState(() => _isOnline = false);
    });
  }

  @override
  void dispose() {
    _onSub.cancel();
    _offSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return Column(children: [
      AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: _isOnline ? const SizedBox.shrink() : Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: MediaQuery.of(ctx).padding.top, bottom: 8),
          color: AppConfig.sosRed,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(children: [
              Icon(Icons.wifi_off, size: 14, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('网络连接已断开，部分功能可能不可用', style: TextStyle(fontSize: 12, color: Colors.white))),
              Text('点击重试', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70)),
            ]),
          ),
        ),
      ),
      Expanded(child: widget.child),
    ]);
  }
}