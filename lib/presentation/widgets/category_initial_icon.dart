import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/category_icons.dart';

class CategoryInitialIcon extends StatelessWidget {
  final String categoryName;
  final Color color;
  final double size;
  final String? icon;

  const CategoryInitialIcon({
    Key? key,
    required this.categoryName,
    required this.color,
    this.size = 24,
    this.icon,
  }) : super(key: key);

  String _getInitials() {
    final words = categoryName.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words[0].substring(0, math.min(2, words[0].length)).toUpperCase();
    }
    return (words[0][0] + words[words.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: icon != null && icon!.isNotEmpty
            ? 
            CategoryIcons.getIcon(icon!,color: color,
                size: size * 0.6)
                
           
            : Text(
                _getInitials(),
                style: TextStyle(
                  color: color,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
