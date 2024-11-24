import 'package:get/get.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../domain/models/transaction_model.dart';
import '../../../domain/models/category_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class HomeController extends GetxController {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxDouble monthlyIncome = 0.0.obs;
  final RxDouble monthlyExpense = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt currentPage = 0.obs;
  final Rx<DateTime> selectedMonth = DateTime.now().obs;

  static const int pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions(refresh: true);
    fetchMonthlyTotals();
  }

  void changeMonth(DateTime month) {
    selectedMonth.value = month;
    fetchTransactions(refresh: true);
    fetchMonthlyTotals();
  }

  Future<void> fetchTransactions({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 0;
      transactions.clear();
    }

    if (isLoading.value) return;

    try {
      isLoading.value = true;
      error.value = '';

      final userId = _authController.currentUser.value?.id;
      if (userId == null) return;

      final startDate = DateTime(
        selectedMonth.value.year,
        selectedMonth.value.month,
        1,
      );
      final endDate = DateTime(
        selectedMonth.value.year,
        selectedMonth.value.month + 1,
        0,
      );

      final newTransactions = await _transactionRepository.getTransactions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        limit: pageSize,
        offset: currentPage.value * pageSize,
      );

      if (newTransactions.isEmpty) {
        // No more transactions to load
        return;
      }

      transactions.addAll(newTransactions);
      currentPage.value++;
    } catch (e) {
      error.value = 'Error fetching transactions';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMonthlyTotals() async {
    try {
      final userId = _authController.currentUser.value?.id;
      if (userId == null) return;

      final totals = await _transactionRepository.getMonthlyTotals(
        userId: userId,
        month: selectedMonth.value,
      );

      monthlyIncome.value = totals['income'] ?? 0.0;
      monthlyExpense.value = totals['expense'] ?? 0.0;
    } catch (e) {
      error.value = 'Error fetching monthly totals';
    }
  }

  // Future<void> addTransaction(TransactionModel transaction) async {
  //   try {
  //     isLoading.value = true;
  //     error.value = '';

  //     await _transactionRepository.addTransaction(transaction);
      
  //     // Refresh the transactions list and monthly totals
  //     fetchTransactions(refresh: true);
  //     fetchMonthlyTotals();
  //   } catch (e) {
  //     error.value = 'Error adding transaction';
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> deleteTransaction(int id) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Remove the transaction from the list immediately
      final deletedTransaction = transactions.firstWhere((t) => t.id == id);
      final index = transactions.indexOf(deletedTransaction);
      transactions.removeAt(index);

      final success = await _transactionRepository.deleteTransaction(id);
      if (success) {
        // Refresh monthly totals
        await fetchMonthlyTotals();
        Get.find<DashboardController>().loadDashboardData();
      } else {
        // If deletion failed, restore the transaction
        transactions.insert(index, deletedTransaction);
        error.value = 'Failed to delete transaction';
        Get.snackbar(
          'Error',
          'Failed to delete transaction',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      error.value = 'Error deleting transaction';
      Get.snackbar(
        'Error',
        'Error deleting transaction',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<CategoryModel>> getCategories(String type) async {
    try {
      return await _categoryRepository.getCategories(type: type);
    } catch (e) {
      error.value = 'Error fetching categories';
      return [];
    }
  }

  Future<String> getCategoryName(int categoryId) async {
    try {
      final category = await _categoryRepository.getCategoryById(categoryId);
      return category.name;
    } catch (e) {
      return 'Unknown Category';
    }
  }
}
