import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/category_icons.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/models/category_model.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  final TransactionRepository _transactionRepository = Get.find<TransactionRepository>();

  TransactionListItem({
    Key? key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM d, y');

    return FutureBuilder<CategoryModel?>(
      future: _transactionRepository.getCategory(transaction.categoryId),
      builder: (context, snapshot) {
        final category = snapshot.data;
        
        return ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: transaction.type == TransactionType.expense
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CategoryIcons.getIcon(
              category?.icon ?? 'default',
              color: transaction.type == TransactionType.expense
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(category?.name ?? 'Loading...'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormat.format(transaction.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (transaction.description?.isNotEmpty ?? false)
                Text(
                  transaction.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currencyFormat.format(transaction.amount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: transaction.type == TransactionType.expense
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (showActions) ...[
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
