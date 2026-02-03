import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';

class RandomFoodPage extends StatefulWidget {
  const RandomFoodPage({super.key});

  @override
  State<RandomFoodPage> createState() => _RandomFoodPageState();
}

class _RandomFoodPageState extends State<RandomFoodPage> {
  final ApiService _apiService = ApiService();
  final FavoritesService _favoritesService = FavoritesService();

  Meal? currentMeal;
  bool isLoading = false;
  String? errorMessage;
  bool isRecipeExpanded = false;
  bool _isFavorite = false;

  Future<void> getRandomFood() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      isRecipeExpanded = false;
    });

    final meal = await _apiService.getRandomMeal();

    if (meal != null) {
      setState(() {
        currentMeal = meal;
        _isFavorite = _favoritesService.isFavorite(meal.id);
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = 'Gagal mengambil data';
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final meal = currentMeal;
    if (meal == null) return;

    final result = await _favoritesService.toggleFavorite(meal);
    setState(() => _isFavorite = result);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result ? 'Ditambahkan ke favorit!' : 'Dihapus dari favorit',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getRandomFood();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text(
          'Makan Apa Ya?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          if (currentMeal != null)
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorWidget()
              : _buildContent(),
    );
  }

  Widget _buildErrorWidget() {
    final error = errorMessage;
    if (error == null) return const SizedBox();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.orange.shade300),
          const SizedBox(height: 16),
          Text(
            error,
            style: TextStyle(color: Colors.orange.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: getRandomFood,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final meal = currentMeal;
    if (meal == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Gambar makanan
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              meal.imageUrl,
              height: 280,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 280,
                  color: Colors.orange.shade100,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 280,
                  color: Colors.orange.shade100,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 64),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Nama makanan
          Text(
            meal.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Kategori dan Area
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (meal.category.isNotEmpty)
                _buildTag(meal.category, Icons.restaurant_menu),
              if (meal.area.isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildTag(meal.area, Icons.location_on),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Tombol "Makanan Lain?"
          ElevatedButton(
            onPressed: getRandomFood,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Makanan Lain?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Expandable Card untuk Resep
          _buildRecipeCard(),
        ],
      ),
    );
  }

  Widget _buildTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header - Clickable
          InkWell(
            onTap: () {
              setState(() {
                isRecipeExpanded = !isRecipeExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
              bottom: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Lihat Resep',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isRecipeExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content - Expandable
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: _buildRecipeContent(),
            crossFadeState: isRecipeExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeContent() {
    final meal = currentMeal;
    if (meal == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),

          // Bahan-bahan
          Text(
            'Bahan-bahan:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 8),
          ...meal.ingredients.map(
            (ingredient) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: Colors.orange.shade700)),
                  Expanded(child: Text(ingredient)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Instruksi
          Text(
            'Cara Membuat:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            meal.instructions,
            style: const TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }
}
