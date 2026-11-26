import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class DailyForecastCard extends StatelessWidget {
  final DailyForecastItem item;
  final bool isToday;

  const DailyForecastCard({
    super.key,
    required this.item,
    this.isToday = false,
  });

  String _formatDayName(String dateStr) {
    try {
      final DateTime parsed = DateTime.parse(dateStr);
      final now = DateTime.now();
      if (parsed.year == now.year &&
          parsed.month == now.month &&
          parsed.day == now.day) {
        return 'Hari Ini';
      }
      final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Ming'];
      return days[parsed.weekday - 1];
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateNum(String dateStr) {
    try {
      final DateTime parsed = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      return '${parsed.day} ${months[parsed.month - 1]}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final conditionIcon = WeatherModel.getWeatherIcon(item.weatherCode);
    final dayName = _formatDayName(item.date);
    final dateNum = _formatDateNum(item.date);
    final isSunny = item.weatherCode == 0 || item.weatherCode == 1;

    return Container(
      width: 105,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: isToday
            ? Colors.white.withValues(alpha: 0.28)
            : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isToday
              ? Colors.white.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Day Name & Date
          Column(
            children: [
              Text(
                dayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateNum,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 11,
                ),
              ),
            ],
          ),

          // Weather Icon (Yellow accent ONLY for sunny)
          Icon(
            conditionIcon,
            color: isSunny ? Colors.amberAccent : Colors.white,
            size: 32,
          ),

          // Rain chance %
          if (item.precipitationProbability > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop_rounded,
                  size: 11,
                  color: Colors.lightBlueAccent.shade100,
                ),
                const SizedBox(width: 2),
                Text(
                  '${item.precipitationProbability}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.lightBlueAccent.shade100,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            const SizedBox(height: 14),

          // Temperatures (Max / Min)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${item.maxTemperature.round()}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${item.minTemperature.round()}°',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
