import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/cart_provider.dart';
import '../../services/mock_api_service.dart';
import '../../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  int _quantity = 1;
  final Map<String, String> _selectedVariations = {};

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await MockApiService().getProductById(widget.productId);
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Produit')),
        body: const Center(child: Text('Produit non trouvé')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Détails du produit')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 400,
              child: PageView.builder(
                itemCount: _product!.images.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: _product!.images[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _product!.name,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (_product!.isOnSale) ...[
                        Text(
                          '${_product!.price.toStringAsFixed(2)} €',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: AppTheme.textSecondaryColor,
                              ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        '${_product!.currentPrice.toStringAsFixed(2)} €',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(Icons.star, color: AppTheme.warningColor),
                      const SizedBox(width: 4),
                      Text(
                        '${_product!.rating} (${_product!.reviewsCount} avis)',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product!.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  if (_product!.variations != null) ...[
                    ..._buildVariations(),
                    const SizedBox(height: 24),
                  ],

                  Text(
                    'Quantité',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.borderColor),
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                        child: Text(
                          '$_quantity',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      IconButton(
                        onPressed: _quantity < _product!.stock
                            ? () => setState(() => _quantity++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      const Spacer(),
                      Text(
                        '${_product!.stock} en stock',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingM),
          child: ElevatedButton(
            onPressed: _product!.stock > 0 ? _addToCart : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              _product!.stock > 0
                  ? 'Ajouter au panier - ${(_product!.currentPrice * _quantity).toStringAsFixed(2)} €'
                  : 'Rupture de stock',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildVariations() {
    final variations = _product!.variations!;
    final widgets = <Widget>[];

    variations.forEach((key, value) {
      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              key.substring(0, 1).toUpperCase() + key.substring(1),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (value as List).map<Widget>((option) {
                final isSelected = _selectedVariations[key] == option;
                return ChoiceChip(
                  label: Text(option.toString()),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedVariations[key] = option.toString();
                      } else {
                        _selectedVariations.remove(key);
                      }
                    });
                  },
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppTheme.textPrimaryColor,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    });

    return widgets;
  }

  void _addToCart() {
    context.read<CartProvider>().addItem(
      _product!,
      _quantity,
      variations: _selectedVariations,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_product!.name} ajouté au panier'),
        action: SnackBarAction(label: 'Voir', onPressed: () {}),
      ),
    );

    Navigator.pop(context);
  }
}
