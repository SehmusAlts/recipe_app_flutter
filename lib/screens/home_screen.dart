import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../services/mysql_service.dart';
import 'recipe_detail_screen.dart';
import 'favorites_screen.dart';
import 'add_recipe_screen.dart';
import 'my_recipes_screen.dart';
import 'login_screen.dart';
import '../widgets/recipe_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final recipeProvider =
        Provider.of<RecipeProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await recipeProvider.loadCategories();
    await recipeProvider.loadRecipes(
      currentUserId: authProvider.currentUser?.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Örnek Tarifleri Yükle',
            onPressed: () async {
              final mysqlService = MySqlService();
              try {
                await mysqlService.loadDummyData();
                
                final recipeProvider =
                    Provider.of<RecipeProvider>(context, listen: false);
                await recipeProvider.loadRecipes();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Örnek tarifler yüklendi!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              final navigator = Navigator.of(context);
              await authProvider.logout();
              if (mounted) {
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Favoriler sekmesine geçildiğinde favorileri yükle
          if (index == 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final recipeProvider =
                  Provider.of<RecipeProvider>(context, listen: false);
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              if (authProvider.currentUser != null) {
                debugPrint('Favoriler sekmesine geçildi, favoriler yükleniyor: user_id=${authProvider.currentUser!.id}');
                recipeProvider.loadFavorites(authProvider.currentUser!.id);
              }
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Tariflerim',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddRecipeScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const FavoritesScreen();
      case 2:
        return const MyRecipesScreen();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return Consumer2<RecipeProvider, AuthProvider>(
      builder: (context, recipeProvider, authProvider, _) {
        if (recipeProvider.isLoading && recipeProvider.recipes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Kategori Filtreleri
            if (recipeProvider.categories.isNotEmpty)
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: recipeProvider.categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FilterChip(
                          label: const Text('Tümü'),
                          selected: recipeProvider.selectedCategoryId == null,
                          onSelected: (_) {
                            recipeProvider.loadRecipes(
                              currentUserId: authProvider.currentUser?.id,
                            );
                          },
                        ),
                      );
                    }
                    final category =
                        recipeProvider.categories[index - 1];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FilterChip(
                        label: Text('${category.icon ?? ''} ${category.name}'),
                        selected:
                            recipeProvider.selectedCategoryId == category.id,
                        onSelected: (_) {
                          recipeProvider.loadRecipes(
                            categoryId: category.id,
                            currentUserId: authProvider.currentUser?.id,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            // Tarif Listesi
            Expanded(
              child: recipeProvider.recipes.isEmpty
                  ? const Center(
                      child: Text('Henüz tarif bulunmuyor'),
                    )
                  : RefreshIndicator(
                      onRefresh: () => recipeProvider.loadRecipes(
                        categoryId: recipeProvider.selectedCategoryId,
                        currentUserId: authProvider.currentUser?.id,
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: recipeProvider.recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = recipeProvider.recipes[index];
                          return RecipeCard(
                            recipe: recipe,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RecipeDetailScreen(
                                    recipeId: recipe.id,
                                  ),
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
                    ),
            ),
          ],
        );
      },
    );
  }
}

