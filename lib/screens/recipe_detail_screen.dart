import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../models/recipe.dart';
import '../models/rating.dart';
import '../services/mysql_service.dart';
import 'add_recipe_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  final int recipeId;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Recipe? _recipe;
  List<Rating> _ratings = [];
  bool _isLoading = true;
  int _userRating = 0;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    final recipeProvider =
        Provider.of<RecipeProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      final recipe = await recipeProvider.getRecipeById(
        widget.recipeId,
        userId: authProvider.currentUser?.id,
      );

      if (recipe != null) {
        final mysqlService = MySqlService();
        await mysqlService.connect();
        final ratings = await mysqlService.getRecipeRatings(widget.recipeId);
        setState(() {
          _recipe = recipe;
          _ratings = ratings;
          _userRating = recipe.userRating ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_recipe == null) return;

    final recipeProvider =
        Provider.of<RecipeProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await recipeProvider.toggleFavorite(
      authProvider.currentUser!.id,
      _recipe!.id,
      _recipe!.isFavorite,
    );

    await _loadRecipe();
  }

  Future<void> _rateRecipe(int rating) async {
    final recipeProvider =
        Provider.of<RecipeProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await recipeProvider.addRating(
      userId: authProvider.currentUser!.id,
      recipeId: widget.recipeId,
      rating: rating,
    );

    await _loadRecipe();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tarif Detayı')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_recipe == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tarif Detayı')),
        body: const Center(child: Text('Tarif bulunamadı')),
      );
    }

    final recipe = _recipe!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOwner = authProvider.currentUser?.id == recipe.userId;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: recipe.imageUrl != null &&
                      recipe.imageUrl!.isNotEmpty
                  ? Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 64),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant_menu, size: 64),
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: recipe.isFavorite ? Colors.red : null,
                ),
                onPressed: _toggleFavorite,
              ),
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => AddRecipeScreen(recipe: recipe),
                          ),
                        )
                        .then((_) => _loadRecipe());
                  },
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (recipe.categoryName != null)
                        Chip(label: Text(recipe.categoryName!)),
                      const Spacer(),
                      if (recipe.averageRating != null &&
                          recipe.averageRating! > 0)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.averageRating!.toStringAsFixed(1)} (${recipe.ratingCount})',
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.access_time,
                        '${recipe.totalTime} dk',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.people,
                        '${recipe.servings} kişi',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.trending_up,
                        recipe.difficulty,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    recipe.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Divider(height: 32),
                  Text(
                    'Malzemeler',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.ingredients,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Divider(height: 32),
                  Text(
                    'Yapılışı',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.instructions,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Divider(height: 32),
                  Text(
                    'Puan Ver',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      final rating = index + 1;
                      return IconButton(
                        icon: Icon(
                          rating <= _userRating
                              ? Icons.star
                              : Icons.star_border,
                          color: rating <= _userRating ? Colors.amber : null,
                        ),
                        onPressed: () => _rateRecipe(rating),
                      );
                    }),
                  ),
                  const Divider(height: 32),
                  Text(
                    'Yorumlar (${_ratings.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (_ratings.isEmpty)
                    const Text('Henüz yorum yapılmamış.')
                  else
                    ..._ratings.map((rating) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(rating.username?[0].toUpperCase() ?? 'U'),
                            ),
                            title: Row(
                              children: [
                                Text(rating.username ?? 'Kullanıcı'),
                                const SizedBox(width: 8),
                                ...List.generate(5, (i) {
                                  return Icon(
                                    i < rating.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: i < rating.rating
                                        ? Colors.amber
                                        : Colors.grey,
                                  );
                                }),
                              ],
                            ),
                            subtitle: rating.comment != null &&
                                    rating.comment!.isNotEmpty
                                ? Text(rating.comment!)
                                : null,
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      padding: EdgeInsets.zero,
    );
  }
}

