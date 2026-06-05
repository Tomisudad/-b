import 'package:flutter/material.dart';
import 'package:gowild_app/config/app_theme.dart';

class WeatherCapsule extends StatelessWidget {
  final String condition;
  final int temperature;
  final String wind;
  final String humidity;

  const WeatherCapsule({
    super.key,
    required this.condition,
    required this.temperature,
    required this.wind,
    required this.humidity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(condition),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$temperature¬∞',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                condition,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetail('È£?, wind),
              const SizedBox(height: 4),
              _buildDetail('Êπ?, humidity),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(String condition) {
    String icon;
    switch (condition) {
      case 'Êô?:
        icon = '‚òÄÔ∏?;
        break;
      case 'Â§ö‰∫ë':
        icon = '‚õ?;
        break;
      case 'Èò?:
        icon = '‚òÅÔ∏è';
        break;
      case 'Èõ?:
        icon = 'üåßÔ∏?;
        break;
      case 'Èõ?:
        icon = '‚ùÑÔ∏è';
        break;
      default:
        icon = 'üå§Ô∏?;
    }
    return Text(
      icon,
      style: const TextStyle(fontSize: 28),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
