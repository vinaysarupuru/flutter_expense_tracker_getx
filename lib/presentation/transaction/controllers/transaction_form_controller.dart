import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../domain/models/category_model.dart';
import '../../../domain/models/transaction_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../settings/controllers/settings_controller.dart';

class TransactionFormController extends GetxController {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final AuthController _authController = Get.find<AuthController>();

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final tagController = TextEditingController();

  final Rx<TransactionType> type = TransactionType.expense.obs;
  final Rx<DateTime> date = DateTime.now().obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final Rxn<CategoryModel> selectedCategory = Rxn<CategoryModel>();
  final Rxn<SubcategoryModel> selectedSubcategory = Rxn<SubcategoryModel>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<String> tags = <String>[].obs;
  final RxList<String> tagSuggestions = <String>[].obs;
  final RxBool isLoadingTags = false.obs;
  List<String> _allTags = [];

  TransactionModel? transactionToEdit;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is TransactionModel) {
      transactionToEdit = Get.arguments as TransactionModel;
      _initializeEditForm();
    }
    loadCategories();
    _loadAllTags();
  }

  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    tagController.dispose();
    super.onClose();
  }

  void _initializeEditForm() {
    if (transactionToEdit == null) return;
    
    titleController.text = transactionToEdit!.title;
    amountController.text = transactionToEdit!.amount.toString();
    noteController.text = transactionToEdit!.description ?? '';
    type.value = transactionToEdit!.type;
    date.value = transactionToEdit!.date;
    tags.value = List.from(transactionToEdit!.tags);
  }

  void addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !tags.contains(trimmedTag)) {
      tags.add(trimmedTag);
      tagController.clear();
      tagSuggestions.clear();
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
  }

  Future<void> addSubcategory(String name) async {
    if (selectedCategory.value == null) return;

    try {
      isLoading.value = true;
      error.value = '';

      final newSubcategory = SubcategoryModel(
        name: name,
        categoryId: selectedCategory.value!.id!,
        createdAt: DateTime.now(),
      );
     
      await _categoryRepository.addSubcategory(newSubcategory);
      
      // Store the current category ID before reloading
      final currentCategoryId = selectedCategory.value!.id;
      
      // Reset selections before reloading
      selectedSubcategory.value = null;
      selectedCategory.value = null;
      
      // Reload categories
      await loadCategories();
        Get.find<SettingsController>().loadCategories();

      
      // Reselect the category after reload
      if (currentCategoryId != null) {
        selectedCategory.value = categories.firstWhereOrNull(
          (cat) => cat.id == currentCategoryId
        );
        
        // Find and select the newly added subcategory
        if (selectedCategory.value?.subcategories != null) {
          final addedSubcategory = selectedCategory.value!.subcategories!
              .firstWhereOrNull((sub) => sub.name == name);
          if (addedSubcategory != null) {
            selectedSubcategory.value = addedSubcategory;
          }
        }
      }
    } catch (e) {
      error.value = 'Failed to add subcategory: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final loadedCategories = await _categoryRepository.getCategories(
        type: type.value == TransactionType.expense ? 'expense' : 'income'
      );
      categories.value = loadedCategories;
      
      if (categories.isEmpty) {
        error.value = 'No categories found';
        return;
      }

      if (transactionToEdit != null) {
        selectedCategory.value = categories.firstWhereOrNull(
          (category) => category.id == transactionToEdit!.categoryId
        );

        if (selectedCategory.value != null && 
            selectedCategory.value!.subcategories != null && 
            transactionToEdit!.subcategoryId != null) {
          selectedSubcategory.value = selectedCategory.value!.subcategories!
              .firstWhereOrNull((sub) => sub.id == transactionToEdit!.subcategoryId);
        }
      }
    } catch (e) {
      error.value = 'Failed to load categories';
      Get.snackbar(
        'Error',
        'Failed to load categories',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAllTags() async {
    try {
      isLoadingTags.value = true;
      _allTags = await _transactionRepository.getAllTags();
    } catch (e) {
      error.value = 'Failed to load tags';
    } finally {
      isLoadingTags.value = false;
    }
  }

  void updateTagSuggestions(String query) {
    if (query.isEmpty) {
      tagSuggestions.clear();
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    tagSuggestions.value = _allTags
        .where((tag) => 
            tag.toLowerCase().contains(lowercaseQuery) && 
            !tags.contains(tag))
        .toList();
  }

  void setType(TransactionType newType) {
    if (type.value != newType) {
      type.value = newType;
      selectedCategory.value = null;
      selectedSubcategory.value = null;
      loadCategories();
    }
  }

  void setDate(DateTime newDate) {
    date.value = newDate;
  }

  void setCategory(CategoryModel? category) {
    if (category != selectedCategory.value) {
      selectedCategory.value = category;
      selectedSubcategory.value = null;
    }
  }

  void setSubcategory(SubcategoryModel? subcategory) {
    selectedSubcategory.value = subcategory;
  }

  String? validateCategory(CategoryModel? value) {
    if (value == null) {
      return 'Please select a category';
    }
    return null;
  }

  String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    
    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Please enter a valid number';
    }
    
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    
    return null;
  }

  Future<bool> saveTransaction() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (titleController.text.trim().isEmpty) {
      error.value = 'Please enter a title';
      return false;
    }

    try {
      isLoading.value = true;
      error.value = '';

      final userId = _authController.currentUser.value?.id;
      if (userId == null) {
        error.value = 'User not authenticated';
        return false;
      }

      final transaction = TransactionModel(
        id: transactionToEdit?.id,
        userId: userId,
        amount: double.parse(amountController.text),
        type: type.value,
        title: titleController.text.trim(),
        description: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
        tags: List.from(tags), // Create a new list to avoid reference issues
        date: date.value,
        categoryId: selectedCategory.value!.id!,
        subcategoryId: selectedSubcategory.value?.id,
        createdAt: DateTime.now(),
      );

      if (transactionToEdit == null) {
        await _transactionRepository.addTransaction(transaction);
      } else {
        await _transactionRepository.updateTransaction(transaction);
      }

      // Refresh home screen
      final homeController = Get.find<HomeController>();
      homeController.fetchTransactions(refresh: true);
      homeController.fetchMonthlyTotals();
      Get.find<DashboardController>().loadDashboardData();

      // Reset form fields
      return true;
    } catch (e) {
      error.value = 'Error saving transaction';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
