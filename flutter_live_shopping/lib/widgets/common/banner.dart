import 'package:flutter/material.dart';
import 'package:flutter_live_shopping/config/theme_config.dart';
import 'package:flutter_live_shopping/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class Banner extends StatelessWidget {
  const Banner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return Text(
                  'Bonjour ${auth.currentUser?.name.split(' ').first ?? 'Invité'} 👋',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge?.copyWith(color: Colors.white),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Découvrez nos événements live shopping',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
