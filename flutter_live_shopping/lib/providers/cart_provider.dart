import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../services/mock_api_service.dart';

class CartProvider extends ChangeNotifier {
  final MockApiService _apiService;

  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);
  double get shipping => _items.isEmpty ? 0 : 5.99;
  double get total => subtotal + shipping;

  CartProvider({MockApiService? apiService})
    : _apiService = apiService ?? MockApiService() {
    loadCart();
  }

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _apiService.getCart();
      debugPrint('Cart loaded: ${_items.length} items');
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(
    Product product,
    int quantity, {
    Map<String, String>? variations,
  }) async {
    try {
      await _apiService.addToCart(product.id, quantity, variations: variations);
      await loadCart();
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateItemQuantity(String cartItemId, int quantity) async {
    try {
      await _apiService.updateCartItemQuantity(cartItemId, quantity);
      await loadCart();
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      final item = _items.firstWhere(
        (item) => item.product.id == productId,
        orElse: () => throw Exception('Item not found in cart'),
      );
      await updateItemQuantity(item.id, quantity);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeItem(String productId) async {
    try {
      final item = _items.firstWhere(
        (item) => item.product.id == productId,
        orElse: () => throw Exception('Item not found in cart'),
      );
      await _apiService.removeFromCart(item.id);
      await loadCart();
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      await _apiService.clearCart();
      await loadCart();
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Order?> checkout({
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final order = await _apiService.checkout(
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
      );
      await loadCart();
      _error = null;
      return order;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
