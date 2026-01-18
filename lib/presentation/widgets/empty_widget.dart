import 'package:flutter/material.dart';

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
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
