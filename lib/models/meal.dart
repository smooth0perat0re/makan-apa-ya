class Meal {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String imageUrl;
  final List<String> ingredients;

  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.imageUrl,
    required this.ingredients,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    List<String> ingredients;

    // Check if ingredients are already parsed (from local storage)
    if (json['ingredients'] != null && json['ingredients'] is List) {
      ingredients = List<String>.from(json['ingredients']);
    } else {
      // Parse from API format (strIngredient1-20)
      ingredients = [];
      for (int i = 1; i <= 20; i++) {
        String? ingredient = json['strIngredient$i'];
        String? measure = json['strMeasure$i'];

        if (ingredient != null && ingredient.trim().isNotEmpty) {
          String item = ingredient.trim();
          if (measure != null && measure.trim().isNotEmpty) {
            item = '${measure.trim()} $item';
          }
          ingredients.add(item);
        }
      }
    }

    return Meal(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? 'Unknown',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      instructions: json['strInstructions'] ?? '',
      imageUrl: json['strMealThumb'] ?? '',
      ingredients: ingredients,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strMealThumb': imageUrl,
      'ingredients': ingredients,
    };
  }
}
