class DatabaseConfig {
  const DatabaseConfig._();

  static const host = '10.0.2.2';
  static const port = 3306;
  static const user = 'recipe_user';
  static const password = 'GüçlüBirŞifre';
  static const database = 'flutter_app';

  /// MySQL tablolarındaki kolon isimlerini merkezileştiriyoruz.
  static const recipesTable = 'recipes';
  static const recipeIdColumn = 'id';
  static const recipeTitleColumn = 'title';
  static const recipeDescriptionColumn = 'description';
  static const recipeImageUrlColumn = 'image_url';

  static String selectLatestRecipesQuery({int limit = 20}) => '''
SELECT
  $recipeIdColumn AS id,
  $recipeTitleColumn AS title,
  $recipeDescriptionColumn AS description,
  $recipeImageUrlColumn AS image_url
FROM $recipesTable
ORDER BY $recipeIdColumn DESC
LIMIT $limit
''';
}
