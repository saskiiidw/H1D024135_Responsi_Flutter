import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/weather_background_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, WeatherViewModel viewModel) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      viewModel.searchCities(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherViewModel>(
      builder: (context, viewModel, child) {
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
                  // Header Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Container(
                            height: 46,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Cari nama kota...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                ),
                                icon: const Icon(Icons.search_rounded,
                                    color: Colors.white70, size: 20),
                              ),
                              onChanged: (query) =>
                                  _onSearchChanged(query, viewModel),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                color: Colors.white),
                            onPressed: () {
                              _searchController.clear();
                              viewModel.clearSearch();
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Search Results / Favorites Body
                  Expanded(
                    child: _buildBody(context, viewModel),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel viewModel) {
    // 1. Loading search results
    if (viewModel.isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Mencari lokasi...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    // 2. Search Error State
    if (viewModel.searchErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                viewModel.searchErrorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  viewModel.searchCities(_searchController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF5D91B9),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Search Results State (when query is typed)
    if (_searchController.text.trim().isNotEmpty) {
      if (viewModel.searchResults.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: Colors.white70),
              SizedBox(height: 12),
              Text(
                'Lokasi tidak ditemukan',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                'Coba gunakan kata kunci nama kota lain',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: viewModel.searchResults.length,
        itemBuilder: (context, index) {
          final location = viewModel.searchResults[index];
          final isFav = viewModel.isFavorite(location);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_city_rounded,
                    color: Colors.white, size: 20),
              ),
              title: Text(
                location.name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                location.admin1 != null && location.admin1 != location.name
                    ? '${location.admin1}, ${location.country}'
                    : location.country,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
              ),
              trailing: IconButton(
                icon: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFav ? Colors.redAccent.shade100 : Colors.white70,
                ),
                onPressed: () {
                  viewModel.toggleFavorite(location);
                },
              ),
              onTap: () {
                viewModel.selectLocation(location);
                Navigator.pop(context);
              },
            ),
          );
        },
      );
    }

    // 4. Saved Favorites View (when search query is empty)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: Row(
            children: [
              const Icon(Icons.favorite_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'LOKASI FAVORIT (${viewModel.favorites.length})',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: viewModel.favorites.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_border_rounded,
                        size: 48,
                        color: Colors.white70,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada lokasi favorit',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Cari nama kota di atas untuk menambahkan ke favorit',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: viewModel.favorites.length,
                  itemBuilder: (context, index) {
                    final favLocation = viewModel.favorites[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.star_rounded),
                        ),
                        title: Text(
                          favLocation.name,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          favLocation.admin1 != null &&
                                  favLocation.admin1 != favLocation.name
                              ? '${favLocation.admin1}, ${favLocation.country}'
                              : favLocation.country,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75)),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline_rounded,
                              color: Colors.redAccent.shade100),
                          tooltip: 'Hapus Favorit',
                          onPressed: () {
                            viewModel.toggleFavorite(favLocation);
                          },
                        ),
                        onTap: () {
                          viewModel.selectLocation(favLocation);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
