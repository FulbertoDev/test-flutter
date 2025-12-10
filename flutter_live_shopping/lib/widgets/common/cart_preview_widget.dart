import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_live_shopping/config/theme_config.dart';
import 'package:flutter_live_shopping/providers/cart_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CartPreviewWidget extends StatelessWidget {
  const CartPreviewWidget({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusL),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingM),
            child: Row(
              children: [
                Text(
                  'Panier',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Consumer<CartProvider>(
              builder: (context, cart, _) {
                if (cart.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Votre panier est vide',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppTheme.paddingM),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusS,
                            ),
                            child: CachedNetworkImage(
                              imageUrl: item.product.thumbnail,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.product.currentPrice.toStringAsFixed(2)} €',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusS,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              if (item.quantity > 1) {
                                                cart.updateQuantity(
                                                  item.product.id,
                                                  item.quantity - 1,
                                                );
                                              } else {
                                                cart.removeItem(
                                                  item.product.id,
                                                );
                                              }
                                            },
                                            borderRadius: BorderRadius.circular(
                                              AppTheme.radiusS,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              child: Icon(
                                                item.quantity > 1
                                                    ? Icons.remove
                                                    : Icons.delete_outline,
                                                size: 16,
                                                color: item.quantity > 1
                                                    ? Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.color
                                                    : AppTheme.errorColor,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            child: Text(
                                              '${item.quantity}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              cart.updateQuantity(
                                                item.product.id,
                                                item.quantity + 1,
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(
                                              AppTheme.radiusS,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              child: const Icon(
                                                Icons.add,
                                                size: 16,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${item.total.toStringAsFixed(2)} €',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              if (cart.items.isEmpty) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(AppTheme.paddingM),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sous-total',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            '${cart.subtotal.toStringAsFixed(2)} €',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Livraison',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            '${cart.shipping.toStringAsFixed(2)} €',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            '${cart.total.toStringAsFixed(2)} €',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/checkout');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Commander'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
