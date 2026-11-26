import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import 'weather_info_card.dart';

class CurrentWeatherSection extends StatelessWidget {
  final LocationModel location;
  final WeatherModel weather;
  final VoidCallback onToggleFavorite;

  const CurrentWeatherSection({
    super.key,
    required this.location,
    required this.weather,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final conditionText = WeatherModel.getWeatherDescription(current.weatherCode);
    final conditionIcon =
        WeatherModel.getWeatherIcon(current.weatherCode, isDay: current.isDay);
    final isSunny = (current.weatherCode == 0 || current.weatherCode == 1) &&
        current.isDay == 1;

    return Column(
      children: [
        // Main Weather Section Card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Header: Location Name & Favorite Toggle Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (location.country.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 24, top: 2),
                            child: Text(
                              location.admin1 != null && location.admin1 != location.name
                                  ? '${location.admin1}, ${location.country}'
                                  : location.country,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      location.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: location.isFavorite ? Colors.redAccent.shade100 : Colors.white,
                      size: 28,
                    ),
                    tooltip: location.isFavorite
                        ? 'Hapus dari favorit'
                        : 'Simpan ke favorit',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Weather Icon & Temperature Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    conditionIcon,
                    size: 68,
                    color: isSunny ? Colors.amberAccent : Colors.white,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${current.temperature.round()}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 88,
                      fontWeight: FontWeight.w200,
                      height: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                conditionText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),

        // Weather Details Grid Requirements:
        // 1. Kelembapan (current.relative_humidity_2m)
        // 2. Kecepatan angin (current.wind_speed_10m)
        // 3. Curah hujan (current.precipitation)
        // 4. Suhu yang dirasakan (current.apparent_temperature)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: WeatherInfoCard(
                      icon: Icons.thermostat_rounded,
                      label: 'Terasa Seperti',
                      value: '${current.apparentTemperature.round()}°C',
                      iconColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: WeatherInfoCard(
                      icon: Icons.water_drop_rounded,
                      label: 'Kelembapan',
                      value: '${current.relativeHumidity}%',
                      iconColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: WeatherInfoCard(
                      icon: Icons.air_rounded,
                      label: 'Kecepatan Angin',
                      value: '${current.windSpeed.toStringAsFixed(1)} km/h',
                      iconColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: WeatherInfoCard(
                      icon: Icons.umbrella_rounded,
                      label: 'Curah Hujan',
                      value: '${current.precipitation.toStringAsFixed(1)} mm',
                      iconColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
