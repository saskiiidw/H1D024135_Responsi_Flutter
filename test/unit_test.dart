import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsi_flutter/models/location_model.dart';
import 'package:responsi_flutter/models/weather_model.dart';
import 'package:responsi_flutter/services/api_service.dart';
import 'package:responsi_flutter/services/local_storage_service.dart';
import 'package:responsi_flutter/viewmodels/weather_viewmodel.dart';
import 'package:responsi_flutter/widgets/weather_background_widget.dart';

class AllowHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = AllowHttpOverrides();

  group('1. API Integration & Model Parsing Tests', () {
    final apiService = ApiService();

    test('Geocoding API returns real live search results for "Jakarta"', () async {
      final results = await apiService.searchLocations('Jakarta');
      expect(results, isNotEmpty);
      final jakarta = results.firstWhere((loc) => loc.name.contains('Jakarta'));
      expect(jakarta.name, contains('Jakarta'));
      expect(jakarta.latitude, isNotNull);
      expect(jakarta.longitude, isNotNull);
      expect(jakarta.country, isNotEmpty);
    });

    test('Weather Forecast API returns real live weather data for Jakarta coordinates', () async {
      // Jakarta coordinates: -6.2088, 106.8456
      final weather = await apiService.fetchWeatherData(-6.2088, 106.8456);
      
      // Verify Current Weather required fields
      expect(weather.current.temperature, isA<double>());
      expect(weather.current.relativeHumidity, isA<int>());
      expect(weather.current.apparentTemperature, isA<double>());
      expect(weather.current.precipitation, isA<double>());
      expect(weather.current.weatherCode, isA<int>());
      expect(weather.current.windSpeed, isA<double>());
      expect(weather.current.isDay, anyOf(equals(0), equals(1)));

      // Verify Daily Forecast required fields
      expect(weather.daily, isNotEmpty);
      final firstDay = weather.daily.first;
      expect(firstDay.date, isNotEmpty);
      expect(firstDay.maxTemperature, isA<double>());
      expect(firstDay.minTemperature, isA<double>());
      expect(firstDay.precipitationProbability, isA<int>());
      expect(firstDay.weatherCode, isA<int>());
    });

    test('WeatherModel converts WMO weather code to Indonesian description and Icon', () {
      final desc = WeatherModel.getWeatherDescription(0);
      expect(desc, equals('Cerah'));
      final iconDay = WeatherModel.getWeatherIcon(0, isDay: 1);
      final iconNight = WeatherModel.getWeatherIcon(0, isDay: 0);
      expect(iconDay, isNotNull);
      expect(iconNight, isNotNull);
    });

    test('Dynamic Weather Atmosphere correctly maps day/night and weather codes', () {
      expect(WeatherBackgroundWidget.getAtmosphereType(0, 1), WeatherAtmosphereType.sunnyDay);
      expect(WeatherBackgroundWidget.getAtmosphereType(0, 0), WeatherAtmosphereType.sunnyNight);
      expect(WeatherBackgroundWidget.getAtmosphereType(3, 1), WeatherAtmosphereType.cloudyDay);
      expect(WeatherBackgroundWidget.getAtmosphereType(3, 0), WeatherAtmosphereType.cloudyNight);
      expect(WeatherBackgroundWidget.getAtmosphereType(61, 1), WeatherAtmosphereType.rainyDay);
      expect(WeatherBackgroundWidget.getAtmosphereType(61, 0), WeatherAtmosphereType.rainyNight);
      expect(WeatherBackgroundWidget.getAtmosphereType(95, 1), WeatherAtmosphereType.thunderstorm);
    });
  });

  group('2. Local Storage Tests', () {
    late LocalStorageService storageService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storageService = LocalStorageService();
    });

    test('Saves and retrieves favorite locations correctly', () async {
      final testLocation = LocationModel(
        id: 12345,
        name: 'Bandung',
        country: 'Indonesia',
        admin1: 'West Java',
        latitude: -6.9175,
        longitude: 107.6191,
        isFavorite: true,
      );

      final saveResult = await storageService.saveFavoriteLocations([testLocation]);
      expect(saveResult, isTrue);

      final favorites = await storageService.getFavoriteLocations();
      expect(favorites.length, equals(1));
      expect(favorites.first.name, equals('Bandung'));
      expect(favorites.first.isFavorite, isTrue);
    });

    test('Saves and retrieves last selected location across app sessions', () async {
      final testLocation = LocationModel(
        id: 67890,
        name: 'Surabaya',
        country: 'Indonesia',
        admin1: 'East Java',
        latitude: -7.2575,
        longitude: 112.7521,
      );

      await storageService.saveLastSelectedLocation(testLocation);
      final lastLoc = await storageService.getLastSelectedLocation();
      expect(lastLoc, isNotNull);
      expect(lastLoc!.name, equals('Surabaya'));
    });
  });

  group('3. WeatherViewModel Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initializes with fallback location and fetches weather', () async {
      final viewModel = WeatherViewModel();
      await viewModel.init();

      expect(viewModel.currentLocation, isNotNull);
      expect(viewModel.isLoadingWeather, isFalse);
    });

    test('Toggles favorite status in state and updates list', () async {
      final viewModel = WeatherViewModel();
      await viewModel.init();

      final testLoc = LocationModel(
        id: 111,
        name: 'Medan',
        country: 'Indonesia',
        latitude: 3.5952,
        longitude: 98.6722,
      );

      expect(viewModel.isFavorite(testLoc), isFalse);

      await viewModel.toggleFavorite(testLoc);
      expect(viewModel.isFavorite(testLoc), isTrue);
      expect(viewModel.favorites.length, equals(1));

      await viewModel.toggleFavorite(testLoc);
      expect(viewModel.isFavorite(testLoc), isFalse);
      expect(viewModel.favorites, isEmpty);
    });
  });
}
