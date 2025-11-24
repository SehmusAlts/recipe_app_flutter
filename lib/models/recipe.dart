class Recipe {
  const Recipe({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    this.categoryId,
    this.categoryName,
    this.prepTime = 0,
    this.cookTime = 0,
    this.servings = 1,
    this.difficulty = 'Orta',
    this.imageUrl,
    this.averageRating,
    this.ratingCount = 0,
    this.isFavorite = false,
    this.userRating,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int userId;
  final int? categoryId;
  final String? categoryName;
  final String title;
  final String description;
  final String ingredients;
  final String instructions;
  final int prepTime;
  final int cookTime;
  final int servings;
  final String difficulty;
  final String? imageUrl;
  final double? averageRating;
  final int ratingCount;
  final bool isFavorite;
  final int? userRating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get totalTime => (prepTime + cookTime).toString();

  factory Recipe.fromMap(Map<String, dynamic> map) {
    int? _parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return Recipe(
      id: _parseInt(map['id']) ?? 0,
      userId: _parseInt(map['user_id']) ?? 0,
      categoryId: _parseInt(map['category_id']),
      categoryName: map['category_name']?.toString(),
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      ingredients: map['ingredients']?.toString() ?? '',
      instructions: map['instructions']?.toString() ?? '',
      prepTime: _parseInt(map['prep_time']) ?? 0,
      cookTime: _parseInt(map['cook_time']) ?? 0,
      servings: _parseInt(map['servings']) ?? 1,
      difficulty: map['difficulty']?.toString() ?? 'Orta',
      imageUrl: map['image_url']?.toString(),
      averageRating: map['average_rating'] != null
          ? (map['average_rating'] is num
              ? (map['average_rating'] as num).toDouble()
              : double.tryParse(map['average_rating'].toString()))
          : null,
      ratingCount: _parseInt(map['rating_count']) ?? 0,
      isFavorite: _parseInt(map['is_favorite']) == 1,
      userRating: _parseInt(map['user_rating']),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'prep_time': prepTime,
      'cook_time': cookTime,
      'servings': servings,
      'difficulty': difficulty,
      'image_url': imageUrl,
    };
  }
}
