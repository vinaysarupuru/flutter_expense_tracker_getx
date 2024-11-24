import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../domain/models/category_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/constants/category_icons.dart';

class SettingsController extends GetxController {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<CategoryModel> expenseCategories = <CategoryModel>[].obs;
  final RxList<CategoryModel> incomeCategories = <CategoryModel>[].obs;
  final RxBool isDarkMode = false.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString selectedIcon = ''.obs;
  final Rx<MaterialColor> selectedColor = Colors.blue.obs;

  List<String> get availableIcons => selectedCategoryType.value == 'income'
      ? CategoryIcons.getIncomeIcons()
      : CategoryIcons.getExpenseIcons();

  final RxString selectedCategoryType = 'expense'.obs;

  void setSelectedIcon(String icon) {
    selectedIcon.value = icon;
  }

  

  @override
  void onInit() {
    super.onInit();
    loadThemeMode();
    loadCategories();
    // Set default selected icon
    selectedIcon.value = CategoryIcons.getExpenseIcons().first;
  }

  Future<void> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    } catch (e) {
      // print('Error loading theme mode: $e');
      isDarkMode.value = false;
      Get.changeThemeMode(ThemeMode.light);
    }
  }

  Future<void> toggleTheme() async {
    try {
      isDarkMode.value = !isDarkMode.value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDarkMode.value);
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    } catch (e) {
      // print('Error saving theme mode: $e');
      Get.snackbar(
        'Error',
        'Failed to save theme preference',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      error.value = '';

      expenseCategories.value =
          await _categoryRepository.getCategories(type: 'expense');
 
      incomeCategories.value =
          await _categoryRepository.getCategories(type: 'income');
    } catch (e) {
      error.value = 'Error loading categories';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _categoryRepository.addCategory(category);
      await loadCategories(); // Reload categories after adding
    } catch (e) {
      error.value = 'Failed to add category: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addSubcategory(CategoryModel category, String name) async {
    try {
      isLoading.value = true;
      error.value = '';

      if (name.isEmpty) {
        error.value = 'Subcategory name cannot be empty';
        return false;
      }

      final subcategory = SubcategoryModel(
        categoryId: category.id!,
        name: name,
        createdAt: DateTime.now(),
      );

      await _categoryRepository.addSubcategory(subcategory);
      await loadCategories();
      return true;
    } catch (e) {
      error.value = 'Error adding subcategory';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteCategory(CategoryModel category) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _categoryRepository.deleteCategory(category.id!);
      await loadCategories();
      return true;
    } catch (e) {
      error.value = 'Error deleting category';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteSubcategory(SubcategoryModel subcategory) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _categoryRepository.deleteSubcategory(subcategory.id!);
      await loadCategories();
      return true;
    } catch (e) {
      
      error.value = 'Error deleting subcategory';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateCategoryColor(CategoryModel category, Color color) async {
    try {
      isLoading.value = true;
      error.value = '';

      final updatedCategory = category.copyWith(color: color);
      await _categoryRepository.updateCategory(updatedCategory);
      await loadCategories(); // Refresh the categories list
      return true;
    } catch (e) {
      error.value = 'Error updating category color';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      error.value = '';
      await _authController.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      error.value = 'Error signing out';
      Get.snackbar(
        'Error',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
