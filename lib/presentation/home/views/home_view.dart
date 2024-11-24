import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/home_controller.dart';
import '../../../domain/models/transaction_model.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Expense Tracker'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.settings),
      //       onPressed: () => Get.toNamed('/settings'),
      //     ),
      //   ],
      // ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchTransactions(refresh: true),
        child: Column(
          children: [
            _buildMonthSelector(),
            _buildSummaryCard(),
            Expanded(
              child: _buildTransactionsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-transaction'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Obx(() {
      final currentMonth = controller.selectedMonth.value;
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                controller.changeMonth(
                  DateTime(currentMonth.year, currentMonth.month - 1),
                );
              },
            ),
            Text(
              DateFormat('MMMM yyyy').format(currentMonth),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                controller.changeMonth(
                  DateTime(currentMonth.year, currentMonth.month + 1),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryCard() {
    return Obx(() {
      return Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryItem(
                    'Income',
                    controller.monthlyIncome.value,
                    Colors.green,
                  ),
                  _buildSummaryItem(
                    'Expense',
                    controller.monthlyExpense.value,
                    Colors.red,
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildSummaryItem(
                'Balance',
                controller.monthlyIncome.value - controller.monthlyExpense.value,
                Colors.blue,
                large: true,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSummaryItem(
    String label,
    double amount,
    Color color, {
    bool large = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: large ? 18 : 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(symbol: '\$').format(amount),
          style: TextStyle(
            fontSize: large ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    return Obx(() {
      if (controller.isLoading.value && controller.transactions.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error.isNotEmpty) {
        return Center(
          child: Text(
            controller.error.value,
            style: const TextStyle(color: Colors.red),
          ),
        );
      }

      if (controller.transactions.isEmpty) {
        return const Center(
          child: Text('No transactions found'),
        );
      }

      return ListView.builder(
        itemCount: controller.transactions.length + 1,
        itemBuilder: (context, index) {
          if (index == controller.transactions.length) {
            return Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return const SizedBox.shrink();
            });
          }

          final transaction = controller.transactions[index];
     
          return _buildTransactionItem(transaction);
        },
      );
    });
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    return Dismissible(
      key: Key('transaction_${transaction.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: Get.context!,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Transaction'),
              content: const Text('Are you sure you want to delete this transaction?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        await controller.deleteTransaction(transaction.id!);
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.type == TransactionType.income
              ? Colors.green[100]
              : Colors.red[100],
          child: Icon(
            transaction.type == TransactionType.income
                ? Icons.arrow_upward
                : Icons.arrow_downward,
            color: transaction.type == TransactionType.income 
                ? Colors.green 
                : Colors.red,
          ),
        ),
        title: Text(transaction.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMM d, y').format(transaction.date),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            FutureBuilder<String>(
              future: controller.getCategoryName(transaction.categoryId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        trailing: Text(
          NumberFormat.currency(symbol: '\$').format(transaction.amount),
          style: TextStyle(
            color: transaction.type == TransactionType.income ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => Get.toNamed(
          '/edit-transaction',
          arguments: transaction,
        ),
      ),
    );
  }
}
