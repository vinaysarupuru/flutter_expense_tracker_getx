import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryIcons {
  static String _getIconPath(String name) => 'assets/icons/$name.svg';

  static Widget getIcon(String iconName, {double? size, Color? color}) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final effectiveColor = color ?? (isDarkMode ? Colors.white : Colors.black87);
        
        return SvgPicture.asset(
          _getIconPath(iconName),
          height: size ?? 24,
          width: size ?? 24,
          colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
          theme: SvgTheme(
            currentColor: effectiveColor,
            fontSize: size ?? 24,
          ),
          placeholderBuilder: (BuildContext context) => SizedBox(
            height: size ?? 24,
            width: size ?? 24,
            child: Center(
              child: Icon(
                Icons.error_outline,
                size: (size ?? 24) * 0.8,
                color: effectiveColor,
              ),
            ),
          ),
        );
      }
    );
  }

  static List<String> getIncomeIcons() {
    return [
      'salary',
      'business',
      'investment',
      'gift',
      'other_income',
    ];
  }

  static List<String> getExpenseIcons() {
    return [
      'food',
      'transport',
      'shopping',
      'entertainment',
      'health',
      'education',
      'bills',
      'rent',
      'groceries',
      'travel',
      'fitness',
      'clothing',
      'electronics',
      'pets',
      'gifts',
      'charity',
      'other_expense',
    ];
  }

  static List<String> getAllIcons() {
    return [...getIncomeIcons(), ...getExpenseIcons()];
  }
}
