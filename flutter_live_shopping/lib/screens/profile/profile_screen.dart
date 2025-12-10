import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';
import '../../utils/app_enums.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (auth.currentUser == null) {
            return const Center(child: Text('Non connecté'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  padding: const EdgeInsets.all(AppTheme.paddingL),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: CachedNetworkImageProvider(
                          auth.currentUser!.avatar,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        auth.currentUser!.name,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.currentUser!.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mes commandes',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      if (auth.orders.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(Icons.shopping_bag_outlined, size: 64),
                                SizedBox(height: 16),
                                Text('Aucune commande'),
                              ],
                            ),
                          ),
                        )
                      else
                        ResponsiveBuilder(
                          builder: (context, sizingInformation) {
                            final count = switch ((
                              sizingInformation.isDesktop,
                              sizingInformation.isTablet,
                            )) {
                              (true, _) => 3,
                              (false, true) => 2,
                              (false, false) => 1,
                            };
                            final ratio = switch ((
                              sizingInformation.isDesktop,
                              sizingInformation.isTablet,
                            )) {
                              (true, _) => 1.5,
                              (false, true) => 1.2,
                              (false, false) => 1.5,
                            };
                            return GridView.count(
                              crossAxisCount: count,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              shrinkWrap: true,
                              childAspectRatio: ratio,
                              physics: const ClampingScrollPhysics(),
                              children: auth.orders
                                  .map((order) => _OrderCard(order: order))
                                  .toList(),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande #${order.id.substring(order.id.length - 8)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('d MMMM yyyy à HH:mm').format(order.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 24),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.name} x${item.quantity}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${item.total.toStringAsFixed(2)} €',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Livraison',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${(order.shipping).toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: Theme.of(context).textTheme.headlineSmall),
                Text(
                  '${order.total.toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.pending:
        color = AppTheme.warningColor;
        text = 'En attente';
        break;
      case OrderStatus.confirmed:
        color = AppTheme.primaryColor;
        text = 'Confirmée';
        break;
      case OrderStatus.shipped:
        color = AppTheme.primaryColor;
        text = 'Expédiée';
        break;
      case OrderStatus.delivered:
      case OrderStatus.completed:
        color = AppTheme.successColor;
        text = 'Livrée';
        break;
      case OrderStatus.cancelled:
        color = AppTheme.errorColor;
        text = 'Annulée';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
