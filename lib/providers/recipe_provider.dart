import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../models/category.dart' as models;
import '../services/mysql_service.dart';

class RecipeProvider with ChangeNotifier {
  final MySqlService _mysqlService = MySqlService();
  List<Recipe> _recipes = [];
  List<models.Category> _categories = [];
  List<Recipe> _favorites = [];
  bool _isLoading = false;
  int? _selectedCategoryId;

  List<Recipe> get recipes => _recipes;
  List<models.Category> get categories => _categories;
  List<Recipe> get favorites => _favorites;
  bool get isLoading => _isLoading;
  int? get selectedCategoryId => _selectedCategoryId;

  Future<void> loadCategories() async {
    try {
      await _mysqlService.connect();
      _categories = await _mysqlService.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Kategoriler yüklenemedi: $e');
    }
  }

  Future<void> loadRecipes({int? categoryId, int? userId, int? currentUserId}) async {
    _isLoading = true;
    _selectedCategoryId = categoryId;
    notifyListeners();

    try {
      await _mysqlService.connect();
      _recipes = await _mysqlService.getRecipes(
        categoryId: categoryId,
        userId: userId,
        currentUserId: currentUserId,
      );
    } catch (e) {
      debugPrint('Tarifler yüklenemedi: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Recipe?> getRecipeById(int recipeId, {int? userId}) async {
    try {
      await _mysqlService.connect();
      return await _mysqlService.getRecipeById(recipeId, userId: userId);
    } catch (e) {
      debugPrint('Tarif yüklenemedi: $e');
      return null;
    }
  }

  Future<void> loadFavorites(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _mysqlService.connect();
      _favorites = await _mysqlService.getFavorites(userId);
      debugPrint('loadFavorites tamamlandı: ${_favorites.length} adet favori yüklendi');
    } catch (e) {
      debugPrint('Favoriler yüklenemedi: $e');
      _favorites = []; // Hata durumunda listeyi temizle
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Recipe> createRecipe({
    required int userId,
    required String title,
    required String description,
    required String ingredients,
    required String instructions,
    int? categoryId,
    int prepTime = 0,
    int cookTime = 0,
    int servings = 1,
    String difficulty = 'Orta',
    String? imageUrl,
  }) async {
    try {
      await _mysqlService.connect();
      final recipe = await _mysqlService.createRecipe(
        userId: userId,
        title: title,
        description: description,
        ingredients: ingredients,
        instructions: instructions,
        categoryId: categoryId,
        prepTime: prepTime,
        cookTime: cookTime,
        servings: servings,
        difficulty: difficulty,
        imageUrl: imageUrl,
      );
      await loadRecipes(categoryId: _selectedCategoryId);
      return recipe;
    } catch (e) {
      debugPrint('Tarif oluşturulamadı: $e');
      rethrow;
    }
  }

  Future<Recipe> updateRecipe({
    required int recipeId,
    required int userId,
    String? title,
    String? description,
    String? ingredients,
    String? instructions,
    int? categoryId,
    int? prepTime,
    int? cookTime,
    int? servings,
    String? difficulty,
    String? imageUrl,
  }) async {
    try {
      await _mysqlService.connect();
      final recipe = await _mysqlService.updateRecipe(
        recipeId: recipeId,
        userId: userId,
        title: title,
        description: description,
        ingredients: ingredients,
        instructions: instructions,
        categoryId: categoryId,
        prepTime: prepTime,
        cookTime: cookTime,
        servings: servings,
        difficulty: difficulty,
        imageUrl: imageUrl,
      );
      await loadRecipes(categoryId: _selectedCategoryId);
      return recipe;
    } catch (e) {
      debugPrint('Tarif güncellenemedi: $e');
      rethrow;
    }
  }

  Future<void> deleteRecipe(int recipeId, int userId) async {
    try {
      await _mysqlService.connect();
      await _mysqlService.deleteRecipe(recipeId, userId);
      await loadRecipes(categoryId: _selectedCategoryId);
      if (_favorites.any((r) => r.id == recipeId)) {
        await loadFavorites(userId);
      }
    } catch (e) {
      debugPrint('Tarif silinemedi: $e');
      rethrow;
    }
  }

  Future<void> toggleFavorite(int userId, int recipeId, bool isFavorite) async {
    try {
      await _mysqlService.connect();
      if (isFavorite) {
        await _mysqlService.removeFromFavorites(userId, recipeId);
      } else {
        await _mysqlService.addToFavorites(userId, recipeId);
      }
      await loadRecipes(categoryId: _selectedCategoryId, currentUserId: userId);
      await loadFavorites(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Favori güncellenemedi: $e');
    }
  }

  Future<void> addRating({
    required int userId,
    required int recipeId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _mysqlService.connect();
      await _mysqlService.addOrUpdateRating(
        userId: userId,
        recipeId: recipeId,
        rating: rating,
        comment: comment,
      );
      await loadRecipes(categoryId: _selectedCategoryId);
    } catch (e) {
      debugPrint('Puan eklenemedi: $e');
    }
  }
}

