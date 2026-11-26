import 'dart:convert';

class LocationModel {
  final int id;
  final String name;
  final String country;
  final String? admin1; // State / Province / Region
  final double latitude;
  final double longitude;
  bool isFavorite;

  LocationModel({
    required this.id,
    required this.name,
    required this.country,
    this.admin1,
    required this.latitude,
    required this.longitude,
    this.isFavorite = false,
  });

  String get displayName {
    if (admin1 != null && admin1!.isNotEmpty && admin1 != name) {
      return '$name, $admin1, $country';
    }
    return '$name, $country';
  }

  String get shortDisplayName {
    return name;
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] is int ? json['id'] : (json['id']?.hashCode ?? DateTime.now().millisecondsSinceEpoch),
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      admin1: json['admin1'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'admin1': admin1,
      'latitude': latitude,
      'longitude': longitude,
      'isFavorite': isFavorite,
    };
  }

  String encodeJson() => json.encode(toJson());

  factory LocationModel.decodeJson(String source) =>
      LocationModel.fromJson(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.name == name;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode ^ name.hashCode;
}
