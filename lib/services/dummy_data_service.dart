import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mysql_client/mysql_client.dart';
import '../models/category.dart';

class DummyDataService {
  static const String dummyRecipesUrl =
      'https://raw.githubusercontent.com/abuanwar072/Recipe-App---Flutter/main/assets/recipes.json';

  static Future<void> loadDummyRecipes(MySQLConnection connection) async {
    try {
      final response = await http.get(Uri.parse(dummyRecipesUrl));
      if (response.statusCode != 200) {
        throw Exception('Dummy veriler yüklenemedi');
      }

      final List<dynamic> data = json.decode(response.body);
      final categories = await _getCategories(connection);

      for (final item in data) {
        final categoryName = item['category'] as String? ?? 'Ana Yemek';
        final category = categories.firstWhere(
          (c) => c.name == categoryName,
          orElse: () => categories.first,
        );

        final ingredients = (item['ingredients'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .join('\n') ??
            '';
        final instructions = (item['steps'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .join('\n') ??
            '';

        final stmt = await connection.prepare(
          '''INSERT IGNORE INTO recipes 
            (user_id, category_id, title, description, ingredients, instructions, 
             prep_time, cook_time, servings, difficulty, image_url)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
        );
        await stmt.execute([
          1, // Default user
          category.id,
          item['title'] as String? ?? 'Tarif',
          item['description'] as String? ?? '',
          ingredients,
          instructions,
          item['duration'] as int? ?? 30,
          0,
          item['servings'] as int? ?? 4,
          'Orta',
          item['imageUrl'] as String? ?? '',
        ]);
      }
    } catch (e) {
      // Fallback: Manuel örnek veriler
      await _loadManualRecipes(connection);
    }
  }

  static Future<List<Category>> _getCategories(MySQLConnection connection) async {
    final result = await connection.execute('SELECT id, name FROM categories');
    return result.rows.map((row) {
      return Category(
        id: int.parse(row.colByName('id').toString()),
        name: row.colByName('name').toString(),
      );
    }).toList();
  }

  static Future<void> _loadManualRecipes(MySQLConnection connection) async {
    final categories = await _getCategories(connection);
    final breakfastCategory = categories.firstWhere(
      (c) => c.name == 'Kahvaltı',
      orElse: () => categories.first,
    );
    final mainCategory = categories.firstWhere(
      (c) => c.name == 'Ana Yemek',
      orElse: () => categories.first,
    );

    final recipes = [
      {
        'title': 'Menemen',
        'description': 'Klasik Türk kahvaltısı',
        'category_id': breakfastCategory.id,
        'ingredients': '4 yumurta\n2 domates\n1 yeşil biber\n1 soğan\nZeytinyağı\nTuz, karabiber',
        'instructions': '1. Soğanı ince doğrayın\n2. Domatesleri küp küp kesin\n3. Biberleri ekleyin\n4. Yumurtaları kırın ve karıştırın',
        'prep_time': 10,
        'cook_time': 15,
        'servings': 2,
      },
      {
        'title': 'Köfte',
        'description': 'Lezzetli köfte tarifi',
        'category_id': mainCategory.id,
        'ingredients': '500g kıyma\n1 soğan\n1 yumurta\nEkmek içi\nBaharatlar',
        'instructions': '1. Kıymayı yoğurun\n2. Soğanı rendeleyin\n3. Tüm malzemeleri karıştırın\n4. Şekil verin ve pişirin',
        'prep_time': 20,
        'cook_time': 30,
        'servings': 4,
      },
    ];

    for (final recipe in recipes) {
      final stmt = await connection.prepare(
        '''INSERT IGNORE INTO recipes 
          (user_id, category_id, title, description, ingredients, instructions, 
           prep_time, cook_time, servings, difficulty)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      );
      await stmt.execute([
        1,
        recipe['category_id'] as int,
        recipe['title'] as String,
        recipe['description'] as String,
        recipe['ingredients'] as String,
        recipe['instructions'] as String,
        recipe['prep_time'] as int,
        recipe['cook_time'] as int,
        recipe['servings'] as int,
        'Orta',
      ]);
    }
  }
}

