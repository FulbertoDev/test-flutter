import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../config/theme_config.dart';
import '../../providers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  String _selectedPaymentMethod = 'card';
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finaliser la commande')),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64),
                  const SizedBox(height: 16),
                  const Text('Votre panier est vide'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Continuer les achats'),
                  ),
                ],
              ),
            );
          }

          return ResponsiveBuilder(
            builder: (context, sizingInformation) {
              final isDesktop =
                  sizingInformation.deviceScreenType != DeviceScreenType.mobile;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.paddingL),
                child: Form(
                  key: _formKey,
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildShippingForm(context),
                                  const SizedBox(height: 32),
                                  _buildPaymentMethod(context),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  _buildOrderSummary(context, cart),
                                  const SizedBox(height: 32),
                                  _buildSubmitButton(context),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOrderSummary(context, cart),
                            const SizedBox(height: 32),
                            _buildShippingForm(context),
                            const SizedBox(height: 32),
                            _buildPaymentMethod(context),
                            const SizedBox(height: 32),
                            _buildSubmitButton(context),
                          ],
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Résumé de la commande',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingM),
            child: Column(
              children: [
                ...cart.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                          child: Image.network(
                            item.product.thumbnail,
                            width: 50,
                            height: 50,
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.product.price.toStringAsFixed(2)} €',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.borderColor),
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
                                    cart.removeItem(item.product.id);
                                  }
                                },
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusS,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    item.quantity > 1
                                        ? Icons.remove
                                        : Icons.delete_outline,
                                    size: 18,
                                    color: item.quantity > 1
                                        ? AppTheme.textPrimaryColor
                                        : AppTheme.errorColor,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
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
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.add,
                                    size: 18,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${item.total.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sous-total'),
                    Text('${cart.subtotal.toStringAsFixed(2)} €'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Livraison'),
                    Text('${cart.shipping.toStringAsFixed(2)} €'),
                  ],
                ),
                const SizedBox(height: 12),
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShippingForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adresse de livraison',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nom complet',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _streetController,
          decoration: const InputDecoration(
            labelText: 'Adresse',
            prefixIcon: Icon(Icons.home_outlined),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Ville',
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 150,
              child: TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(labelText: 'Code postal'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mode de paiement',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        RadioListTile(
          value: 'card',
          groupValue: _selectedPaymentMethod,
          onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
          title: const Row(
            children: [
              Icon(Icons.credit_card),
              SizedBox(width: 12),
              Text('Carte bancaire'),
            ],
          ),
        ),
        RadioListTile(
          value: 'paypal',
          groupValue: _selectedPaymentMethod,
          onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
          title: const Row(
            children: [
              Icon(Icons.payment),
              SizedBox(width: 12),
              Text('PayPal'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Confirmer la commande',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final order = await context.read<CartProvider>().checkout(
        shippingAddress: {
          'name': _nameController.text,
          'street': _streetController.text,
          'city': _cityController.text,
          'postalCode': _postalCodeController.text,
          'country': 'France',
        },
        paymentMethod: _selectedPaymentMethod,
      );

      if (order != null && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.successColor),
                SizedBox(width: 12),
                Text('Commande confirmée !'),
              ],
            ),
            content: Text('Votre commande #${order.id} a été confirmée.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/profile');
                },
                child: const Text('Voir mes commandes'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/');
                },
                child: const Text('Continuer'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
