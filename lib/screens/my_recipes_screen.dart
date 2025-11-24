import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyRecipes();
    });
  }

  Future<void> _loadMyRecipes() async {
    final recipeProvider =
        Provider.of<RecipeProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await recipeProvider.loadRecipes(
        userId: authProvider.currentUser!.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<RecipeProvider, AuthProvider>(
      builder: (context, recipeProvider, authProvider, _) {
        if (authProvider.currentUser == null) {
          return const Center(
            child: Text('Lütfen giriş yapın'),
          );
        }

        if (recipeProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final myRecipes = recipeProvider.recipes
            .where((r) => r.userId == authProvider.currentUser!.id)
            .toList();

        if (myRecipes.isEmpty) {
          return const Center(
            child: Text('Henüz tarif eklemediniz'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => recipeProvider.loadRecipes(
            userId: authProvider.currentUser!.id,
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: myRecipes.length,
            itemBuilder: (context, index) {
              final recipe = myRecipes[index];
              return RecipeCard(
                recipe: recipe,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipeId: recipe.id),
                    ),
                  ).then((_) => _loadMyRecipes());
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

