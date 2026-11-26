import 'package:flutter/material.dart';

class CurrentWeather {
  final double temperature;
  final int relativeHumidity;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final int isDay; // 1 for Day, 0 for Night

  CurrentWeather({
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    this.isDay = 1,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num).toDouble(),
      relativeHumidity: (json['relative_humidity_2m'] as num).toInt(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
      isDay: json['is_day'] != null ? (json['is_day'] as num).toInt() : 1,
    );
  }
}

class DailyForecastItem {
  final String date;
  final double maxTemperature;
  final double minTemperature;
  final int precipitationProbability;
  final int weatherCode;

  DailyForecastItem({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.precipitationProbability,
    required this.weatherCode,
  });
}

class WeatherModel {
  final CurrentWeather current;
  final List<DailyForecastItem> daily;

  WeatherModel({
    required this.current,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentData = CurrentWeather.fromJson(json['current'] ?? {});

    final dailyJson = json['daily'] ?? {};
    final List<String> times = List<String>.from(dailyJson['time'] ?? []);
    final List<dynamic> maxTemps = dailyJson['temperature_2m_max'] ?? [];
    final List<dynamic> minTemps = dailyJson['temperature_2m_min'] ?? [];
    final List<dynamic> precipProbs =
        dailyJson['precipitation_probability_max'] ?? [];
    final List<dynamic> weatherCodes = dailyJson['weather_code'] ?? [];

    final List<DailyForecastItem> dailyItems = [];
    for (int i = 0; i < times.length; i++) {
      dailyItems.add(
        DailyForecastItem(
          date: times[i],
          maxTemperature:
              i < maxTemps.length ? (maxTemps[i] as num).toDouble() : 0.0,
          minTemperature:
              i < minTemps.length ? (minTemps[i] as num).toDouble() : 0.0,
          precipitationProbability: i < precipProbs.length && precipProbs[i] != null
              ? (precipProbs[i] as num).toInt()
              : 0,
          weatherCode: i < weatherCodes.length && weatherCodes[i] != null
              ? (weatherCodes[i] as num).toInt()
              : 0,
        ),
      );
    }

    return WeatherModel(
      current: currentData,
      daily: dailyItems,
    );
  }

  static String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Sebagian Cerah';
      case 2:
        return 'Cerah Berawan';
      case 3:
        return 'Berawan';
      case 45:
      case 48:
        return 'Kabut';
      case 51:
      case 53:
      case 55:
        return 'Gerimis';
      case 56:
      case 57:
        return 'Gerimis Beku';
      case 61:
        return 'Hujan Ringan';
      case 63:
        return 'Hujan Sedang';
      case 65:
        return 'Hujan Lebat';
      case 66:
      case 67:
        return 'Hujan Beku';
      case 71:
      case 73:
      case 75:
      case 77:
        return 'Salju';
      case 80:
      case 81:
      case 82:
        return 'Hujan Lokal / Deras';
      case 85:
      case 86:
        return 'Hujan Salju';
      case 95:
        return 'Badai Petir';
      case 96:
      case 99:
        return 'Badai Petir & Es';
      default:
        return 'Kondisi Tidak Diketahui';
    }
  }

  static IconData getWeatherIcon(int code, {int isDay = 1}) {
    final bool day = isDay == 1;
    switch (code) {
      case 0:
        return day ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded;
      case 1:
      case 2:
        return day ? Icons.wb_cloudy_rounded : Icons.cloud_rounded;
      case 3:
        return Icons.cloud_rounded;
      case 45:
      case 48:
        return Icons.cloud_queue_rounded;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return Icons.grain_rounded;
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return Icons.umbrella_rounded;
      case 71:
      case 73:
      case 75:
      case 77:
        return Icons.ac_unit_rounded;
      case 80:
      case 81:
      case 82:
        return Icons.thunderstorm_rounded;
      case 85:
      case 86:
        return Icons.ac_unit_rounded;
      case 95:
      case 96:
      case 99:
        return Icons.flash_on_rounded;
      default:
        return day ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded;
    }
  }
}
