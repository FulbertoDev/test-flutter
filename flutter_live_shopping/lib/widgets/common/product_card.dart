import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/product.dart';
import '../../config/theme_config.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onAddToCart;
  final bool showFeaturedBadge;

  const ProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.showFeaturedBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: product.thumbnail,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.borderColor,
                      child: const Icon(Icons.shopping_bag, size: 48),
                    ),
                  ),
                ),
                if (product.isOnSale)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Text(
                        '-${product.discountPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (showFeaturedBadge && product.isFeatured)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'FEATURED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (product.stock <= 5 && product.stock > 0)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Text(
                        'Plus que ${product.stock}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          ' (${product.reviewsCount})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (product.isOnSale) ...[
                          Text(
                            '${product.price.toStringAsFixed(2)} €',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppTheme.textSecondaryColor,
                                ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          '${product.currentPrice.toStringAsFixed(2)} €',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    if (onAddToCart != null) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: product.stock > 0 ? onAddToCart : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            product.stock > 0 ? 'Ajouter' : 'Rupture',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
