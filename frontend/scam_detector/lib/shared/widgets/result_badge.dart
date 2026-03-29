import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ResultBadge extends StatelessWidget {
  final String result;
  final bool large;

  const ResultBadge({super.key, required this.result, this.large = false});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.resultColor(result);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: large ? 16 : 10, vertical: large ? 8 : 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(large ? 12 : 8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        result.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: large ? 16 : 11,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
