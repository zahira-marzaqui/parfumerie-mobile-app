import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/text_styles.dart';

/// Widget de chargement
class LoadingWidget extends StatelessWidget {
  final String? message;
  
  const LoadingWidget({super.key, this.message});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.goldPrimary,
            strokeWidth: 2,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTextStyles.description,
            ),
          ],
        ],
      ),
    );
  }
}
