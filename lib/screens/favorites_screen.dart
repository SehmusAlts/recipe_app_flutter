import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    final recipeProvider =
        Provider.of<RecipeProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await recipeProvider.loadFavorites(authProvider.currentUser!.id);
      debugPrint('Favoriler yüklendi: ${recipeProvider.favorites.length} adet');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer2<RecipeProvider, AuthProvider>(
      builder: (context, recipeProvider, authProvider, _) {
        debugPrint('FavoritesScreen build: user_id=${authProvider.currentUser?.id}, favorites_count=${recipeProvider.favorites.length}, isLoading=${recipeProvider.isLoading}');
        
        if (authProvider.currentUser == null) {
          return const Center(
            child: Text('Lütfen giriş yapın'),
          );
        }

        if (recipeProvider.isLoading && recipeProvider.favorites.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (recipeProvider.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Henüz favori tarifiniz yok'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _loadFavorites();
                  },
                  child: const Text('Yenile'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => recipeProvider.loadFavorites(
            authProvider.currentUser!.id,
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: recipeProvider.favorites.length,
            itemBuilder: (context, index) {
              final recipe = recipeProvider.favorites[index];
              return RecipeCard(
                recipe: recipe,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipeId: recipe.id),
                    ),
                  );
                },
                onFavoriteToggle: () {
                  recipeProvider.toggleFavorite(
                    authProvider.currentUser!.id,
                    recipe.id,
                    recipe.isFavorite,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

