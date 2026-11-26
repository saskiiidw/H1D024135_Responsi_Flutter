import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

class LocalStorageService {
  static const String _favoritesKey = 'favorite_locations';
  static const String _lastSelectedKey = 'last_selected_location';

  /// Saves the list of favorite locations to SharedPreferences
  Future<bool> saveFavoriteLocations(List<LocationModel> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> encodedList =
          favorites.map((loc) => json.encode(loc.toJson())).toList();
      return await prefs.setStringList(_favoritesKey, encodedList);
    } catch (e) {
      return false;
    }
  }

  /// Retrieves the list of favorite locations from SharedPreferences
  Future<List<LocationModel>> getFavoriteLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? encodedList = prefs.getStringList(_favoritesKey);
      if (encodedList == null || encodedList.isEmpty) {
        return [];
      }
      return encodedList.map((item) {
        final Map<String, dynamic> decoded = json.decode(item);
        final loc = LocationModel.fromJson(decoded);
        loc.isFavorite = true;
        return loc;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Saves the last viewed location
  Future<bool> saveLastSelectedLocation(LocationModel location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(location.toJson());
      return await prefs.setString(_lastSelectedKey, encoded);
    } catch (e) {
      return false;
    }
  }

  /// Retrieves the last viewed location
  Future<LocationModel?> getLastSelectedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encoded = prefs.getString(_lastSelectedKey);
      if (encoded == null || encoded.isEmpty) {
        return null;
      }
      return LocationModel.fromJson(json.decode(encoded));
    } catch (e) {
      return null;
    }
  }
}
