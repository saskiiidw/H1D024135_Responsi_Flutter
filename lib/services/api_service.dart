import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/weather_model.dart';

class ApiService {
  static const String _geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String _weatherBaseUrl =
      'https://api.open-meteo.com/v1/forecast';

  /// Searches locations by city name using Open-Meteo Geocoding API
  Future<List<LocationModel>> searchLocations(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final Uri url = Uri.parse(
      '$_geocodingBaseUrl?name=${Uri.encodeComponent(query)}&count=10&language=en&format=json',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('results') && data['results'] != null) {
          final List<dynamic> results = data['results'];
          return results
              .map((jsonItem) => LocationModel.fromJson(jsonItem))
              .toList();
        }
        return [];
      } else {
        throw Exception(
            'Gagal mengambil data lokasi. Server merespons (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Silakan periksa jaringan Anda.');
    } on http.ClientException {
      throw Exception('Gagal menghubungi server.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  /// Fetches current weather and daily forecast using Open-Meteo Weather Forecast API
  Future<WeatherModel> fetchWeatherData(
      double latitude, double longitude) async {
    final Uri url = Uri.parse(
      '$_weatherBaseUrl?latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,is_day'
      '&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weather_code'
      '&timezone=auto',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception(
            'Gagal mengambil data cuaca. Kode status: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Silakan periksa jaringan Anda.');
    } on http.ClientException {
      throw Exception('Gagal menghubungi server API.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}
