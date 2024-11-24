import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String error;
  final EdgeInsets padding;
  final TextStyle? style;

  const ErrorText({
    Key? key,
    required this.error,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (error.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Text(
        error,
        style: style ??
            TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 14,
            ),
      ),
    );
  }
}
