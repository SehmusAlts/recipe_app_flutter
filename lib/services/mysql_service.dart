import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:mysql_client/mysql_client.dart';

import '../config/database_config.dart';
import '../models/recipe.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/rating.dart';
import 'dummy_data_service.dart';

class MySqlService {
  MySQLConnection? _connection;

  Future<void> connect() async {
    if (_connection != null && !_connection!.connected) {
      _connection = null;
    }
    if (_connection == null) {
      _connection = await MySQLConnection.createConnection(
        host: DatabaseConfig.host,
        port: DatabaseConfig.port,
        userName: DatabaseConfig.user,
        password: DatabaseConfig.password,
        databaseName: DatabaseConfig.database,
      );
      await _connection!.connect(timeoutMs: 10000);
    }
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }

  MySQLConnection get _conn {
    if (_connection == null || !_connection!.connected) {
      throw StateError('MySQL bağlantısı kurulmamış.');
    }
    return _connection!;
  }

  // Authentication
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    await connect();
    final hashedPassword = _hashPassword(password);

    try {
      final stmt = await _conn.prepare(
        'INSERT INTO users (username, email, password_hash, full_name) VALUES (?, ?, ?, ?)',
      );
      await stmt.execute([username, email, hashedPassword, fullName ?? '']);

      final stmt2 = await _conn.prepare(
        'SELECT id, username, email, full_name, created_at FROM users WHERE username = ?',
      );
      final result = await stmt2.execute([username]);

      if (result.rows.isNotEmpty) {
        final row = result.rows.first;
        return User(
          id: int.parse(row.colByName('id').toString()),
          username: row.colByName('username').toString(),
          email: row.colByName('email').toString(),
          fullName: row.colByName('full_name')?.toString(),
          createdAt: row.colByName('created_at') != null
              ? DateTime.parse(row.colByName('created_at').toString())
              : null,
        );
      }
      return null;
    } catch (e) {
      if (e.toString().contains('Duplicate entry')) {
        throw Exception('Kullanıcı adı veya e-posta zaten kullanılıyor.');
      }
      rethrow;
    }
  }

  Future<User?> login(String usernameOrEmail, String password) async {
    await connect();
    final hashedPassword = _hashPassword(password);

    final stmt = await _conn.prepare(
      'SELECT id, username, email, password_hash, full_name, created_at FROM users WHERE (username = ? OR email = ?) AND password_hash = ?',
    );
    final result =
        await stmt.execute([usernameOrEmail, usernameOrEmail, hashedPassword]);

    if (result.rows.isEmpty) {
      return null;
    }

    final row = result.rows.first;
    return User(
      id: int.parse(row.colByName('id').toString()),
      username: row.colByName('username').toString(),
      email: row.colByName('email').toString(),
      fullName: row.colByName('full_name')?.toString(),
      createdAt: row.colByName('created_at') != null
          ? DateTime.parse(row.colByName('created_at').toString())
          : null,
    );
  }

  // Categories
  Future<List<Category>> getCategories() async {
    await connect();
    final result = await _conn
        .execute('SELECT id, name, icon FROM categories ORDER BY name');

    return result.rows.map((row) {
      return Category(
        id: int.parse(row.colByName('id').toString()),
        name: row.colByName('name').toString(),
        icon: row.colByName('icon')?.toString(),
      );
    }).toList();
  }

  // Recipes
  Future<List<Recipe>> getRecipes({
    int? categoryId,
    int? userId,
    int? currentUserId,
    int limit = 50,
    int offset = 0,
  }) async {
    await connect();

    String query = '''
      SELECT 
        r.id,
        r.user_id,
        r.category_id,
        c.name AS category_name,
        r.title,
        r.description,
        r.ingredients,
        r.instructions,
        r.prep_time,
        r.cook_time,
        r.servings,
        r.difficulty,
        r.image_url,
        COALESCE(AVG(rat.rating), 0) AS average_rating,
        COUNT(rat.id) AS rating_count,
        r.created_at,
        r.updated_at
    ''';

    // Eğer currentUserId varsa, is_favorite bilgisini de çek
    if (currentUserId != null) {
      query += ', (SELECT COUNT(*) FROM favorites WHERE user_id = ? AND recipe_id = r.id) AS is_favorite';
    } else {
      query += ', 0 AS is_favorite';
    }

    query += '''
      FROM recipes r
      LEFT JOIN categories c ON r.category_id = c.id
      LEFT JOIN ratings rat ON r.id = rat.recipe_id
    ''';

    final conditions = <String>[];
    final params = <dynamic>[];

    // currentUserId'yi params'a ekle (eğer varsa)
    if (currentUserId != null) {
      params.add(currentUserId);
    }

    if (categoryId != null) {
      conditions.add('r.category_id = ?');
      params.add(categoryId);
    }
    if (userId != null) {
      conditions.add('r.user_id = ?');
      params.add(userId);
    }

    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }

    query += ' GROUP BY r.id ORDER BY r.created_at DESC LIMIT ? OFFSET ?';
    params.addAll([limit, offset]);

    final stmt = await _conn.prepare(query);
    final result = await stmt.execute(params);

    return result.rows.map((row) {
      return Recipe.fromMap({
        'id': row.colByName('id'),
        'user_id': row.colByName('user_id'),
        'category_id': row.colByName('category_id'),
        'category_name': row.colByName('category_name'),
        'title': row.colByName('title'),
        'description': row.colByName('description'),
        'ingredients': row.colByName('ingredients'),
        'instructions': row.colByName('instructions'),
        'prep_time': row.colByName('prep_time'),
        'cook_time': row.colByName('cook_time'),
        'servings': row.colByName('servings'),
        'difficulty': row.colByName('difficulty'),
        'image_url': row.colByName('image_url'),
        'average_rating': row.colByName('average_rating'),
        'rating_count': row.colByName('rating_count'),
        'is_favorite': row.colByName('is_favorite'),
        'created_at': row.colByName('created_at')?.toString(),
        'updated_at': row.colByName('updated_at')?.toString(),
      });
    }).toList();
  }

  Future<Recipe?> getRecipeById(int recipeId, {int? userId}) async {
    await connect();

    String query = '''
      SELECT 
        r.id,
        r.user_id,
        r.category_id,
        c.name AS category_name,
        r.title,
        r.description,
        r.ingredients,
        r.instructions,
        r.prep_time,
        r.cook_time,
        r.servings,
        r.difficulty,
        r.image_url,
        COALESCE(AVG(rat.rating), 0) AS average_rating,
        COUNT(rat.id) AS rating_count,
        r.created_at,
        r.updated_at
    ''';

    if (userId != null) {
      query +=
          ', (SELECT COUNT(*) FROM favorites WHERE user_id = ? AND recipe_id = r.id) AS is_favorite';
      query +=
          ', (SELECT rating FROM ratings WHERE user_id = ? AND recipe_id = r.id) AS user_rating';
    } else {
      query += ', 0 AS is_favorite, NULL AS user_rating';
    }

    query += '''
      FROM recipes r
      LEFT JOIN categories c ON r.category_id = c.id
      LEFT JOIN ratings rat ON r.id = rat.recipe_id
      WHERE r.id = ?
      GROUP BY r.id
    ''';

    final params = userId != null ? [userId, userId, recipeId] : [recipeId];
    final stmt = await _conn.prepare(query);
    final result = await stmt.execute(params);

    if (result.rows.isEmpty) return null;

    final row = result.rows.first;
    return Recipe.fromMap({
      'id': row.colByName('id'),
      'user_id': row.colByName('user_id'),
      'category_id': row.colByName('category_id'),
      'category_name': row.colByName('category_name'),
      'title': row.colByName('title'),
      'description': row.colByName('description'),
      'ingredients': row.colByName('ingredients'),
      'instructions': row.colByName('instructions'),
      'prep_time': row.colByName('prep_time'),
      'cook_time': row.colByName('cook_time'),
      'servings': row.colByName('servings'),
      'difficulty': row.colByName('difficulty'),
      'image_url': row.colByName('image_url'),
      'average_rating': row.colByName('average_rating'),
      'rating_count': row.colByName('rating_count'),
      'is_favorite': row.colByName('is_favorite'),
      'user_rating': row.colByName('user_rating'),
      'created_at': row.colByName('created_at')?.toString(),
      'updated_at': row.colByName('updated_at')?.toString(),
    });
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
    await connect();

    final stmt = await _conn.prepare(
      '''INSERT INTO recipes 
        (user_id, category_id, title, description, ingredients, instructions, 
         prep_time, cook_time, servings, difficulty, image_url)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
    );
    await stmt.execute([
      userId,
      categoryId,
      title,
      description,
      ingredients,
      instructions,
      prepTime,
      cookTime,
      servings,
      difficulty,
      imageUrl ?? '',
    ]);

    final stmt2 = await _conn.prepare(
      'SELECT id FROM recipes WHERE user_id = ? ORDER BY id DESC LIMIT 1',
    );
    final result = await stmt2.execute([userId]);

    final recipeId = int.parse(result.rows.first.colByName('id').toString());
    return (await getRecipeById(recipeId))!;
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
    await connect();

    final updates = <String>[];
    final params = <dynamic>[];

    if (title != null) {
      updates.add('title = ?');
      params.add(title);
    }
    if (description != null) {
      updates.add('description = ?');
      params.add(description);
    }
    if (ingredients != null) {
      updates.add('ingredients = ?');
      params.add(ingredients);
    }
    if (instructions != null) {
      updates.add('instructions = ?');
      params.add(instructions);
    }
    if (categoryId != null) {
      updates.add('category_id = ?');
      params.add(categoryId);
    }
    if (prepTime != null) {
      updates.add('prep_time = ?');
      params.add(prepTime);
    }
    if (cookTime != null) {
      updates.add('cook_time = ?');
      params.add(cookTime);
    }
    if (servings != null) {
      updates.add('servings = ?');
      params.add(servings);
    }
    if (difficulty != null) {
      updates.add('difficulty = ?');
      params.add(difficulty);
    }
    if (imageUrl != null) {
      updates.add('image_url = ?');
      params.add(imageUrl);
    }

    if (updates.isEmpty) {
      return (await getRecipeById(recipeId))!;
    }

    params.addAll([recipeId, userId]);
    final stmt = await _conn.prepare(
      'UPDATE recipes SET ${updates.join(', ')} WHERE id = ? AND user_id = ?',
    );
    await stmt.execute(params);

    return (await getRecipeById(recipeId))!;
  }

  Future<void> deleteRecipe(int recipeId, int userId) async {
    await connect();
    final stmt = await _conn.prepare(
      'DELETE FROM recipes WHERE id = ? AND user_id = ?',
    );
    await stmt.execute([recipeId, userId]);
  }

  // Favorites
  Future<void> addToFavorites(int userId, int recipeId) async {
    await connect();
    try {
      final stmt = await _conn.prepare(
        'INSERT IGNORE INTO favorites (user_id, recipe_id) VALUES (?, ?)',
      );
      await stmt.execute([userId, recipeId]);
      foundation.debugPrint('Favori eklendi: user_id=$userId, recipe_id=$recipeId');
    } catch (e) {
      foundation.debugPrint('Favori eklenirken hata: $e');
      rethrow;
    }
  }

  Future<void> removeFromFavorites(int userId, int recipeId) async {
    await connect();
    final stmt = await _conn.prepare(
      'DELETE FROM favorites WHERE user_id = ? AND recipe_id = ?',
    );
    await stmt.execute([userId, recipeId]);
    foundation.debugPrint('Favori kaldırıldı: user_id=$userId, recipe_id=$recipeId');
  }

  Future<List<Recipe>> getFavorites(int userId) async {
    await connect();
    foundation.debugPrint('getFavorites çağrıldı: user_id=$userId');

    final stmt = await _conn.prepare(
      '''SELECT 
        r.id,
        r.user_id,
        r.category_id,
        c.name AS category_name,
        r.title,
        r.description,
        r.ingredients,
        r.instructions,
        r.prep_time,
        r.cook_time,
        r.servings,
        r.difficulty,
        r.image_url,
        COALESCE(AVG(rat.rating), 0) AS average_rating,
        COUNT(rat.id) AS rating_count,
        r.created_at,
        r.updated_at,
        MAX(f.created_at) AS favorite_created_at
      FROM favorites f
      JOIN recipes r ON f.recipe_id = r.id
      LEFT JOIN categories c ON r.category_id = c.id
      LEFT JOIN ratings rat ON r.id = rat.recipe_id
      WHERE f.user_id = ?
      GROUP BY r.id, r.user_id, r.category_id, c.name, r.title, r.description, 
               r.ingredients, r.instructions, r.prep_time, r.cook_time, 
               r.servings, r.difficulty, r.image_url, r.created_at, r.updated_at
      ORDER BY favorite_created_at DESC''',
    );
    final result = await stmt.execute([userId]);
    foundation.debugPrint('Favoriler sorgusu sonucu: ${result.rows.length} adet tarif bulundu');

    return result.rows.map((row) {
      return Recipe.fromMap({
        'id': row.colByName('id'),
        'user_id': row.colByName('user_id'),
        'category_id': row.colByName('category_id'),
        'category_name': row.colByName('category_name'),
        'title': row.colByName('title'),
        'description': row.colByName('description'),
        'ingredients': row.colByName('ingredients'),
        'instructions': row.colByName('instructions'),
        'prep_time': row.colByName('prep_time'),
        'cook_time': row.colByName('cook_time'),
        'servings': row.colByName('servings'),
        'difficulty': row.colByName('difficulty'),
        'image_url': row.colByName('image_url'),
        'average_rating': row.colByName('average_rating'),
        'rating_count': row.colByName('rating_count'),
        'is_favorite': 1, // Favoriler listesindeki tüm tarifler favori
        'created_at': row.colByName('created_at')?.toString(),
        'updated_at': row.colByName('updated_at')?.toString(),
      });
    }).toList();
  }

  // Ratings
  Future<void> addOrUpdateRating({
    required int userId,
    required int recipeId,
    required int rating,
    String? comment,
  }) async {
    await connect();
    final stmt = await _conn.prepare(
      '''INSERT INTO ratings (user_id, recipe_id, rating, comment)
         VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE rating = ?, comment = ?''',
    );
    await stmt.execute(
        [userId, recipeId, rating, comment ?? '', rating, comment ?? '']);
  }

  Future<List<Rating>> getRecipeRatings(int recipeId) async {
    await connect();
    final stmt = await _conn.prepare(
      '''SELECT r.id, r.user_id, r.recipe_id, r.rating, r.comment, 
                r.created_at, u.username
         FROM ratings r
         JOIN users u ON r.user_id = u.id
         WHERE r.recipe_id = ?
         ORDER BY r.created_at DESC''',
    );
    final result = await stmt.execute([recipeId]);

    return result.rows.map((row) {
      return Rating.fromMap({
        'id': row.colByName('id'),
        'user_id': row.colByName('user_id'),
        'recipe_id': row.colByName('recipe_id'),
        'rating': row.colByName('rating'),
        'comment': row.colByName('comment'),
        'created_at': row.colByName('created_at')?.toString(),
        'username': row.colByName('username'),
      });
    }).toList();
  }

  // Dummy data yükleme
  Future<void> loadDummyData() async {
    await connect();
    await DummyDataService.loadDummyRecipes(_conn);
  }
}
