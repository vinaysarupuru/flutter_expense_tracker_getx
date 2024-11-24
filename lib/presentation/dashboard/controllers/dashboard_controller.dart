import 'package:get/get.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../domain/models/transaction_model.dart';
import '../../auth/controllers/auth_controller.dart';

class DashboardController extends GetxController {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxList<TransactionModel> recentTransactions = <TransactionModel>[].obs;
  final RxMap<String, double> categoryTotals = <String, double>{}.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {

    try {
      isLoading.value = true;
      error.value = '';

      final userId = _authController.currentUser.value?.id;
      if (userId == null) return;

      final startDate = DateTime(selectedDate.value.year, selectedDate.value.month, 1);
      final endDate = DateTime(selectedDate.value.year, selectedDate.value.month + 1, 0);

      // Get monthly totals
      final totals = await _transactionRepository.getMonthlyTotals(
        userId: userId,
        month: selectedDate.value,
      );
      totalIncome.value = totals['income'] ?? 0.0;
      totalExpense.value = totals['expense'] ?? 0.0;

      // Get recent transactions
      recentTransactions.value = await _transactionRepository.getTransactions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        limit: 5,
      );

      // Get category totals
      final transactions = await _transactionRepository.getTransactions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final Map<String, double> totalsMap = {};
      for (var transaction in transactions) {
        
        if (transaction.type == TransactionType.expense) {
          final category = await _transactionRepository.getCategoryName(transaction.categoryId);
          totalsMap[category] = (totalsMap[category] ?? 0) + transaction.amount;
       
        }
      }
      categoryTotals.value = totalsMap;
   
    } catch (e) {
      error.value = 'Error loading dashboard data';
    } finally {
      isLoading.value = false;
    }
  }

  void changeMonth(DateTime month) {
    selectedDate.value = month;
    loadDashboardData();
  }

  double getCategoryPercentage(String category) {
    if (totalExpense.value == 0) return 0;
    return (categoryTotals[category] ?? 0) / totalExpense.value * 100;
  }

  double getSavingsRate() {
    if (totalIncome.value == 0) return 0;
    return ((totalIncome.value - totalExpense.value) / totalIncome.value * 100)
        .clamp(0, 100);
  }
}
