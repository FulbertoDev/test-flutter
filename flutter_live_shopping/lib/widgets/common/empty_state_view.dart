import 'package:flutter/material.dart';
import 'package:flutter_live_shopping/config/theme_config.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppTheme.paddingXL),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun événement trouvé',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Essayez de modifier vos filtres',
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
