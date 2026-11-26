import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class WeatherViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalStorageService _storageService = LocalStorageService();

  LocationModel? _currentLocation;
  WeatherModel? _weather;
  bool _isLoadingWeather = false;
  String? _weatherErrorMessage;

  List<LocationModel> _searchResults = [];
  bool _isSearching = false;
  String? _searchErrorMessage;

  List<LocationModel> _favorites = [];

  // Default fallback location if no last selected location is found
  static final LocationModel defaultLocation = LocationModel(
    id: 1621177,
    name: 'Yogyakarta',
    country: 'Indonesia',
    admin1: 'Special Region of Yogyakarta',
    latitude: -7.7956,
    longitude: 110.3695,
  );

  // Getters
  LocationModel? get currentLocation => _currentLocation;
  WeatherModel? get weather => _weather;
  bool get isLoadingWeather => _isLoadingWeather;
  String? get weatherErrorMessage => _weatherErrorMessage;

  List<LocationModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchErrorMessage => _searchErrorMessage;

  List<LocationModel> get favorites => _favorites;

  WeatherViewModel() {
    init();
  }

  /// Initialize view model: load saved favorites, last location, and fetch weather
  Future<void> init() async {
    await loadFavorites();
    final lastLoc = await _storageService.getLastSelectedLocation();
    
    // Check if the last loaded or default location is in favorites
    final locToLoad = lastLoc ?? defaultLocation;
    locToLoad.isFavorite = isFavorite(locToLoad);

    await selectLocation(locToLoad);
  }

  /// Load favorite locations from local storage
  Future<void> loadFavorites() async {
    _favorites = await _storageService.getFavoriteLocations();
    notifyListeners();
  }

  /// Check whether a location is marked as favorite
  bool isFavorite(LocationModel location) {
    return _favorites.any((fav) =>
        (fav.latitude == location.latitude && fav.longitude == location.longitude) ||
        (fav.name.toLowerCase() == location.name.toLowerCase() &&
            fav.country.toLowerCase() == location.country.toLowerCase()));
  }

  /// Toggle favorite status of a location
  Future<void> toggleFavorite(LocationModel location) async {
    final existingIndex = _favorites.indexWhere((fav) =>
        (fav.latitude == location.latitude && fav.longitude == location.longitude) ||
        (fav.name.toLowerCase() == location.name.toLowerCase() &&
            fav.country.toLowerCase() == location.country.toLowerCase()));

    if (existingIndex >= 0) {
      _favorites.removeAt(existingIndex);
      location.isFavorite = false;
      if (_currentLocation != null && _currentLocation == location) {
        _currentLocation!.isFavorite = false;
      }
    } else {
      location.isFavorite = true;
      _favorites.add(location);
      if (_currentLocation != null && _currentLocation == location) {
        _currentLocation!.isFavorite = true;
      }
    }

    await _storageService.saveFavoriteLocations(_favorites);
    notifyListeners();
  }

  /// Select location and fetch its weather data
  Future<void> selectLocation(LocationModel location) async {
    _currentLocation = location;
    _currentLocation!.isFavorite = isFavorite(location);
    await _storageService.saveLastSelectedLocation(location);
    notifyListeners();

    await fetchWeatherForCurrentLocation();
  }

  /// Fetch weather for the current selected location
  Future<void> fetchWeatherForCurrentLocation() async {
    if (_currentLocation == null) return;

    _isLoadingWeather = true;
    _weatherErrorMessage = null;
    notifyListeners();

    try {
      final weatherData = await _apiService.fetchWeatherData(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      );
      _weather = weatherData;
      _weatherErrorMessage = null;
    } catch (e) {
      _weatherErrorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingWeather = false;
      notifyListeners();
    }
  }

  /// Perform live search for locations by city name
  Future<void> searchCities(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _isSearching = false;
      _searchErrorMessage = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchErrorMessage = null;
    notifyListeners();

    try {
      final results = await _apiService.searchLocations(query);
      for (var item in results) {
        item.isFavorite = isFavorite(item);
      }
      _searchResults = results;
      _searchErrorMessage = null;
    } catch (e) {
      _searchErrorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Clear current search results
  void clearSearch() {
    _searchResults = [];
    _isSearching = false;
    _searchErrorMessage = null;
    notifyListeners();
  }
}
