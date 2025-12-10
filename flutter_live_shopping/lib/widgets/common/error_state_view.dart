import 'package:flutter/material.dart';
import 'package:flutter_live_shopping/config/theme_config.dart';
import 'package:flutter_live_shopping/providers/live_event_provider.dart';

class ErrorStateView extends StatelessWidget {
  final LiveEventProvider provider;
  const ErrorStateView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            provider.error!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.loadEvents,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
