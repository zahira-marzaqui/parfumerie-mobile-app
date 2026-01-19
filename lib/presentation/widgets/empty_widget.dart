import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/text_styles.dart';

/// Widget pour état vide
class EmptyWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  
  const EmptyWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.description.copyWith(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
