import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/favorites_service.dart';

class MealDetailSheet extends StatefulWidget {
  final Meal meal;

  const MealDetailSheet({super.key, required this.meal});

  @override
  State<MealDetailSheet> createState() => _MealDetailSheetState();
}

class _MealDetailSheetState extends State<MealDetailSheet> {
  final FavoritesService _favoritesService = FavoritesService();
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = _favoritesService.isFavorite(widget.meal.id);
  }

  Future<void> _toggleFavorite() async {
    final result = await _favoritesService.toggleFavorite(widget.meal);
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
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Image.network(
                        widget.meal.imageUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 250,
                            color: Colors.orange.shade100,
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 64),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name and favorite button
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.meal.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: _isFavorite ? Colors.red : Colors.grey,
                                    size: 28,
                                  ),
                                  onPressed: _toggleFavorite,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Tags
                            Row(
                              children: [
                                _buildTag(widget.meal.category, Icons.restaurant_menu),
                                const SizedBox(width: 8),
                                _buildTag(widget.meal.area, Icons.location_on),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Ingredients
                            Text(
                              'Bahan-bahan:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...widget.meal.ingredients.map(
                              (ingredient) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '• ',
                                      style: TextStyle(color: Colors.orange.shade700),
                                    ),
                                    Expanded(child: Text(ingredient)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Instructions
                            Text(
                              'Cara Membuat:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.meal.instructions,
                              style: const TextStyle(height: 1.6),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
}
