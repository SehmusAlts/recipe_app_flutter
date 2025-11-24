import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../models/recipe.dart';
import '../models/category.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key, this.recipe});

  final Recipe? recipe;

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _imageUrlController = TextEditingController();

  int? _selectedCategoryId;
  String _selectedDifficulty = 'Orta';
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _titleController.text = widget.recipe!.title;
      _descriptionController.text = widget.recipe!.description;
      _ingredientsController.text = widget.recipe!.ingredients;
      _instructionsController.text = widget.recipe!.instructions;
      _prepTimeController.text = widget.recipe!.prepTime.toString();
      _cookTimeController.text = widget.recipe!.cookTime.toString();
      _servingsController.text = widget.recipe!.servings.toString();
      _imageUrlController.text = widget.recipe!.imageUrl ?? '';
      _selectedCategoryId = widget.recipe!.categoryId;
      _selectedDifficulty = widget.recipe!.difficulty;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final recipeProvider =
        Provider.of<RecipeProvider>(context, listen: false);
    await recipeProvider.loadCategories();
    setState(() {
      _categories = recipeProvider.categories;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    final recipeProvider =
        Provider.of<RecipeProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (widget.recipe != null) {
        await recipeProvider.updateRecipe(
          recipeId: widget.recipe!.id,
          userId: authProvider.currentUser!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          ingredients: _ingredientsController.text.trim(),
          instructions: _instructionsController.text.trim(),
          categoryId: _selectedCategoryId,
          prepTime: int.tryParse(_prepTimeController.text) ?? 0,
          cookTime: int.tryParse(_cookTimeController.text) ?? 0,
          servings: int.tryParse(_servingsController.text) ?? 1,
          difficulty: _selectedDifficulty,
          imageUrl: _imageUrlController.text.trim().isEmpty
              ? null
              : _imageUrlController.text.trim(),
        );
      } else {
        await recipeProvider.createRecipe(
          userId: authProvider.currentUser!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          ingredients: _ingredientsController.text.trim(),
          instructions: _instructionsController.text.trim(),
          categoryId: _selectedCategoryId,
          prepTime: int.tryParse(_prepTimeController.text) ?? 0,
          cookTime: int.tryParse(_cookTimeController.text) ?? 0,
          servings: int.tryParse(_servingsController.text) ?? 1,
          difficulty: _selectedDifficulty,
          imageUrl: _imageUrlController.text.trim().isEmpty
              ? null
              : _imageUrlController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.recipe != null
                  ? 'Tarif güncellendi'
                  : 'Tarif eklendi',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe != null ? 'Tarif Düzenle' : 'Yeni Tarif'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRecipe,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tarif Adı',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen tarif adı girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen açıklama girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Kategori Seçin')),
                ..._categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text('${category.icon ?? ''} ${category.name}'),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                labelText: 'Malzemeler (Her satıra bir malzeme)',
                border: OutlineInputBorder(),
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen malzemeleri girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Yapılışı (Her satıra bir adım)',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen yapılışını girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prepTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Hazırlık (dk)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cookTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Pişirme (dk)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _servingsController,
                    decoration: const InputDecoration(
                      labelText: 'Kaç Kişilik',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    decoration: const InputDecoration(
                      labelText: 'Zorluk',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Kolay', child: Text('Kolay')),
                      DropdownMenuItem(value: 'Orta', child: Text('Orta')),
                      DropdownMenuItem(value: 'Zor', child: Text('Zor')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDifficulty = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Resim URL (Opsiyonel)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveRecipe,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(widget.recipe != null ? 'Güncelle' : 'Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}

