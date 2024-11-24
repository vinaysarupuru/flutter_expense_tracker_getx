import 'package:flutter/material.dart';
import '../../core/constants/category_icons.dart';

class CategoryIconPicker extends StatelessWidget {
  final String selectedIcon;
  final List<String> availableIcons;
  final Function(String) onIconSelected;
  final double iconSize;
  final double gridSpacing;
  final int crossAxisCount;
  final double height;

  const CategoryIconPicker({
    Key? key,
    required this.selectedIcon,
    required this.availableIcons,
    required this.onIconSelected,
    this.iconSize = 24,
    this.gridSpacing = 8,
    this.crossAxisCount = 4,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Scrollbar(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: gridSpacing,
            mainAxisSpacing: gridSpacing,
          ),
          itemCount: availableIcons.length,
          itemBuilder: (context, index) {
            final iconName = availableIcons[index];
            final isSelected = selectedIcon == iconName;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onIconSelected(iconName),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CategoryIcons.getIcon(
                      iconName,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          :null,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
