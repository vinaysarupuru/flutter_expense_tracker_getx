import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/models/category_model.dart';
import '../../../domain/models/transaction_model.dart';
import '../controllers/settings_controller.dart';

import '../../widgets/custom_button.dart';

import '../../widgets/category_color_picker.dart';
import '../../widgets/category_initial_icon.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Settings'),
      // ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.expenseCategories.isEmpty &&
            controller.incomeCategories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: [
            _buildThemeSection(),
            const Divider(),
            _buildCategoriesSection('Expense Categories',
                controller.expenseCategories, TransactionType.expense.name),
            const Divider(),
            _buildCategoriesSection('Income Categories',
                controller.incomeCategories, TransactionType.income.name),
            const Divider(),
            _buildAccountSection(),
          ],
        );
      }),
    );
  }

  Widget _buildThemeSection() {
    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: const Text('Dark Mode'),
      trailing: Obx(() {
        return Switch(
          value: controller.isDarkMode.value,
          onChanged: (value) => controller.toggleTheme(),
        );
      }),
    );
  }

  Widget _buildCategoriesSection(
      String title, List<CategoryModel> categories, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddCategoryDialog(type),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryTile(category);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryTile(CategoryModel category) {
    return ExpansionTile(
      leading: CategoryInitialIcon(
        categoryName: category.name,
        color: category.color,
        icon: category.icon,
        size: 40,
      ),
      title: Text(category.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSubcategoryDialog(category),
          ),
          //if category.isDefault == false then show edit and delete
          if (!category.isDefault)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditCategoryDialog(category),
            ),
          if (!category.isDefault)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteCategoryDialog(category),
            ),
        ],
      ),
      children: [
        if (category.subcategories != null &&
            category.subcategories!.isNotEmpty)
          ...category.subcategories!.map((subcategory) => ListTile(
                title: Text(subcategory.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteSubcategoryDialog(subcategory),
                ),
              )),
      ],
    );
  }

  Future<void> _showAddCategoryDialog(String type) async {
    final TextEditingController nameController = TextEditingController();
    final controller = Get.find<SettingsController>();
    controller.selectedColor.value = Colors.blue;

    await Get.dialog(
      AlertDialog(
        title: Text('Add ${type.capitalizeFirst} Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => CategoryColorPicker(
                    selectedColor: controller.selectedColor.value,
                    onColorSelected: (color) {
                      controller.selectedColor.value = color;
                    },
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter a category name',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              final category = CategoryModel(
                name: nameController.text,
                type: type,
                color: controller.selectedColor.value,
                isDefault: false,
                createdAt: DateTime.now(),
              );

              await controller.addCategory(category);
              Get.back();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSubcategoryDialog(CategoryModel category) async {
    final TextEditingController nameController = TextEditingController();

    await Get.dialog(
      AlertDialog(
        title: const Text('Add Subcategory'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Subcategory Name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final success = await controller.addSubcategory(
                  category,
                  nameController.text.trim(),
                );
                if (success) {
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Subcategory added successfully',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    controller.error.value,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditCategoryDialog(CategoryModel category) async {
    final TextEditingController nameController =
        TextEditingController(text: category.name);
    final Rx<Color> selectedColor = category.color.obs;

    await Get.dialog(
      AlertDialog(
        title: const Text('Edit Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                enabled: false,
                decoration: const InputDecoration(
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => CategoryColorPicker(
                    selectedColor: selectedColor.value,
                    onColorSelected: (color) {
                      selectedColor.value = color;
                    },
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.updateCategoryColor(category, selectedColor.value);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteCategoryDialog(CategoryModel category) async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await controller.deleteCategory(category);

              Get.back();
              if (controller.error.value.isNotEmpty) {
                Get.snackbar(
                  'Error',
                  controller.error.value,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteSubcategoryDialog(
      SubcategoryModel subcategory) async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Delete Subcategory'),
        content: Text('Are you sure you want to delete "${subcategory.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await controller.deleteSubcategory(subcategory);
              Get.back();

              if (controller.error.value.isNotEmpty) {
                Get.snackbar(
                  'Error',
                  controller.error.value,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomButton(
        onPressed: () => controller.signOut(),
        text: 'Sign Out',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      ),
    );
  }
}
