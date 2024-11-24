import 'package:flutter/material.dart';
import '../../domain/models/category_model.dart';
import 'category_initial_icon.dart';

class CategoryListTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isExpanded;
  final List<Widget>? children;

  const CategoryListTile({
    Key? key,
    required this.category,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.isExpanded = false,
    this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget tile = ListTile(
      leading: CategoryInitialIcon(
        categoryName: category.name,
        color: category.color,
        icon: category.icon,
        size: 40,
      ),
      title: Text(category.name),
      trailing: showActions
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
            )
          : null,
    );

    if (children != null) {
      return ExpansionTile(
        leading: CategoryInitialIcon(
          categoryName: category.name,
          color: category.color,
          icon: category.icon,
          size: 40,
        ),
        title: Text(category.name),
        trailing: showActions
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
              )
            : null,
        initiallyExpanded: isExpanded,
        children: children!,
      );
    }

    return tile;
  }
}
