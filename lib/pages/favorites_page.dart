import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/favorites_service.dart';
import '../widgets/meal_list_item.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesService _favoritesService = FavoritesService();

  @override
  Widget build(BuildContext context) {
    final favorites = _favoritesService.getAllFavorites();

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text(
          'Favorit Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: favorites.isEmpty ? _buildEmptyState() : _buildFavoritesList(favorites),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.orange.shade200),
          const SizedBox(height: 16),
          Text(
            'Belum ada favorit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan icon hati untuk menyimpan makanan',
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<Meal> favorites) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        return MealListItem(
          meal: favorites[index],
          showFavoriteButton: true,
          onFavoriteChanged: () {
            setState(() {});
          },
        );
      },
    );
  }
}
