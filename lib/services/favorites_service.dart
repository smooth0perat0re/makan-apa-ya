import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/meal.dart';

class FavoritesService {
  static const String boxName = 'favorites';

  Box<String> get _box => Hive.box<String>(boxName);

  List<Meal> getAllFavorites() {
    return _box.values
        .map((jsonString) => Meal.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  bool isFavorite(String mealId) {
    return _box.containsKey(mealId);
  }

  Future<void> addFavorite(Meal meal) async {
    await _box.put(meal.id, jsonEncode(meal.toJson()));
  }

  Future<void> removeFavorite(String mealId) async {
    await _box.delete(mealId);
  }

  Future<bool> toggleFavorite(Meal meal) async {
    if (isFavorite(meal.id)) {
      await removeFavorite(meal.id);
      return false;
    } else {
      await addFavorite(meal);
      return true;
    }
  }
}
