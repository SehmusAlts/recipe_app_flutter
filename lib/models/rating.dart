class Rating {
  const Rating({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.rating,
    this.comment,
    this.createdAt,
    this.username,
  });

  final int id;
  final int userId;
  final int recipeId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final String? username;

  factory Rating.fromMap(Map<String, dynamic> map) {
    int? _parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return Rating(
      id: _parseInt(map['id']) ?? 0,
      userId: _parseInt(map['user_id']) ?? 0,
      recipeId: _parseInt(map['recipe_id']) ?? 0,
      rating: _parseInt(map['rating']) ?? 0,
      comment: map['comment']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      username: map['username']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'recipe_id': recipeId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

