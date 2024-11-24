import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/dashboard_controller.dart';
import '../../../domain/models/transaction_model.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Dashboard'),
      // ),
      body: Obx(() {
        if (controller.isLoading.value && controller.recentTransactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadDashboardData(),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildMonthSelector(),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 24),
              _buildSavingsRate(),
              const SizedBox(height: 24),
              _buildCategoryBreakdown(),
              const SizedBox(height: 24),
              _buildRecentTransactions(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMonthSelector() {
    return Obx(() {
      final currentMonth = controller.selectedDate.value;
      return Row(
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
      );
    });
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Income',
              controller.totalIncome.value,
              Colors.green,
              Icons.arrow_upward,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'Expense',
              controller.totalExpense.value,
              Colors.red,
              Icons.arrow_downward,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(symbol: '\$').format(amount),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsRate() {
    return Obx(() {
      final savingsRate = controller.getSavingsRate();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Savings Rate',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: savingsRate / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              savingsRate >= 20 ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${savingsRate.toStringAsFixed(1)}%',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCategoryBreakdown() {
    return Obx(() {
      if (controller.categoryTotals.isEmpty) {
        return const SizedBox.shrink();
      }

      final total = controller.categoryTotals.values.fold<double>(0, (sum, amount) => sum + amount);
      
      // Generate sections for pie chart
      final sections = controller.categoryTotals.entries.map((entry) {
        final percentage = (entry.value / total * 100).roundToDouble();
        final color = Colors.primaries[controller.categoryTotals.keys.toList().indexOf(entry.key) % Colors.primaries.length];
        
        return PieChartSectionData(
          value: entry.value,
          title: '$percentage%',
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          radius: 100,
          color: color,
        );
      }).toList();

      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Expense Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                startDegreeOffset: -90,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: controller.categoryTotals.entries.map((entry) {
              final color = Colors.primaries[controller.categoryTotals.keys.toList().indexOf(entry.key) % Colors.primaries.length];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('${entry.key}: ${NumberFormat.currency(symbol: '\$').format(entry.value)}'),
                ],
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget _buildRecentTransactions() {
    return Obx(() {
      if (controller.recentTransactions.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...controller.recentTransactions.map((transaction) {
            return _buildTransactionItem(transaction);
          }).toList(),
        ],
      );
    });
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.type == TransactionType.income
              ? Colors.green[100]
              : Colors.red[100],
          child: Icon(
            transaction.type == TransactionType.income
                ? Icons.arrow_upward
                : Icons.arrow_downward,
            color:
                transaction.type == TransactionType.income ? Colors.green : Colors.red,
          ),
        ),
        title: Text(transaction.title),
        subtitle: Text(
          DateFormat('MMM d, y').format(transaction.date),
        ),
        trailing: Text(
          NumberFormat.currency(symbol: '\$').format(transaction.amount),
          style: TextStyle(
            color: transaction.type == TransactionType.income ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
