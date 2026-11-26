import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/current_weather_section.dart';
import '../widgets/daily_forecast_card.dart';
import '../widgets/weather_background_widget.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherViewModel>(
      builder: (context, viewModel, child) {
        final location = viewModel.currentLocation;
        final weather = viewModel.weather;
        final int weatherCode = weather?.current.weatherCode ?? 0;
        final int isDay = weather?.current.isDay ?? 1;

        return Scaffold(
          body: WeatherBackgroundWidget(
            weatherCode: weatherCode,
            isDay: isDay,
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informasi Cuaca',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (location != null)
                              Text(
                                location.shortDisplayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.search_rounded,
                              color: Colors.white),
                          tooltip: 'Cari Kota',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Refreshable Body
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await viewModel.fetchWeatherForCurrentLocation();
                      },
                      color: const Color(0xFF5D91B9),
                      backgroundColor: Colors.white,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Quick Access Favorite Cities Bar
                            if (viewModel.favorites.isNotEmpty)
                              Container(
                                height: 42,
                                margin:
                                    const EdgeInsets.only(top: 4, bottom: 8),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  itemCount: viewModel.favorites.length,
                                  itemBuilder: (context, index) {
                                    final fav = viewModel.favorites[index];
                                    final isSelected = location != null &&
                                        location.latitude == fav.latitude &&
                                        location.longitude == fav.longitude;

                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(fav.name),
                                        selected: isSelected,
                                        labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        selectedColor: Colors.white
                                            .withValues(alpha: 0.35),
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.16),
                                        side: BorderSide(
                                          color: Colors.white.withValues(
                                              alpha: isSelected ? 0.45 : 0.2),
                                        ),
                                        onSelected: (_) {
                                          viewModel.selectLocation(fav);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),

                            // Loading State
                            if (viewModel.isLoadingWeather)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 80),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                          color: Colors.white),
                                      SizedBox(height: 16),
                                      Text(
                                        'Mengambil data cuaca...',
                                        style:
                                            TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            // Error State
                            else if (viewModel.weatherErrorMessage != null)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.all(24),
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white
                                          .withValues(alpha: 0.35)),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Gagal Memuat Cuaca',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      viewModel.weatherErrorMessage!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        viewModel
                                            .fetchWeatherForCurrentLocation();
                                      },
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: const Text('Coba Lagi'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor:
                                            const Color(0xFF5D91B9),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            // Weather Content Display
                            else if (location != null && weather != null) ...[
                              CurrentWeatherSection(
                                location: location,
                                weather: weather,
                                onToggleFavorite: () {
                                  viewModel.toggleFavorite(location);
                                },
                              ),

                              // Horizontal Forecast Header
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 18, 20, 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 14,
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'PERKIRAAN CUACA HARIAN',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.8,
                                        color: Colors.white
                                            .withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Horizontal Multi-Day Forecast List
                              SizedBox(
                                height: 148,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  itemCount: weather.daily.length,
                                  itemBuilder: (context, index) {
                                    return DailyForecastCard(
                                      item: weather.daily[index],
                                      isToday: index == 0,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                            ] else
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Text(
                                    'Pilih lokasi untuk melihat data cuaca.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
