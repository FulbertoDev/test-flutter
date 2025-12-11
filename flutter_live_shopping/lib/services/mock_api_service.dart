import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/live_event.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/user.dart';
import '../models/chat_message.dart';
import '../utils/app_enums.dart';

class MockApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;
  MockApiService._internal();

  Map<String, dynamic>? _mockData;
  List<CartItem> _cart = [];
  List<Order> _orders = [];
  List<Product> _products = [];

  bool _simulateDelay = true;

  final String _currentUserId = 'user_001';

  Future<void> _loadMockData() async {
    if (_mockData == null) {
      final jsonString = await rootBundle.loadString(
        'assets/mock-api-data.json',
      );
      _mockData = json.decode(jsonString);

      if (_mockData!['orders'] != null) {
        _orders = (_mockData!['orders'] as List)
            .map((json) => Order.fromJson(json))
            .toList();
      }

      if (_mockData!['products'] != null) {
        _products = (_mockData!['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
      }
      if (_mockData!['cart'] != null) {
        final cartData = _mockData!['cart'];
        final items = cartData["items"] as List;

        _cart = items.map((item) {
          final productId = item['productId'] as String;
          final product = _products.firstWhere((p) => p.id == productId);
          final variations =
              (item["selectedVariations"] as Map<String, dynamic>);

          final selectedVariations = <String, String>{};
          for (final entry in variations.entries) {
            selectedVariations[entry.key] = entry.value as String;
          }

          return CartItem(
            id: item['id'],
            productId: item['productId'],
            quantity: item['quantity'],
            product: product,
            selectedVariations: selectedVariations,
          );
        }).toList();
      }
    }
  }

  Future<void> _simulateNetworkDelay() async {
    if (!_simulateDelay) return;
    await Future.delayed(
      Duration(milliseconds: 200 + (DateTime.now().millisecond % 300)),
    );
  }

  Future<List<LiveEvent>> getLiveEvents() async {
    await _loadMockData();
    await _simulateNetworkDelay();

    final eventsData = _mockData!['liveEvents'] as List;
    final productsData = _mockData!['products'] as List;

    return eventsData.map((eventJson) {
      final productIds = (eventJson['products'] as List).cast<String>();
      final products = productIds
          .map((id) {
            final productJson = productsData.firstWhere(
              (p) => p['id'] == id,
              orElse: () => null,
            );
            return productJson != null ? Product.fromJson(productJson) : null;
          })
          .whereType<Product>()
          .toList();

      Product? featuredProduct;
      if (eventJson['featuredProduct'] != null) {
        final featuredId = eventJson['featuredProduct'] as String;
        final featuredJson = productsData.firstWhere(
          (p) => p['id'] == featuredId,
          orElse: () => null,
        );
        if (featuredJson != null) {
          featuredProduct = Product.fromJson(featuredJson);
        }
      }

      return LiveEvent.fromJson(eventJson, products, featuredProduct);
    }).toList();
  }

  Future<LiveEvent?> getLiveEventById(String id) async {
    await _loadMockData();
    await _simulateNetworkDelay();

    final events = await getLiveEvents();
    try {
      return events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Product>> getProducts(String eventId) async {
    await _loadMockData();
    await _simulateNetworkDelay();

    final event = await getLiveEventById(eventId);
    return event?.products ?? [];
  }

  Future<Product?> getProductById(String id) async {
    await _loadMockData();
    await _simulateNetworkDelay();

    final productsData = _mockData!['products'] as List;
    try {
      final productJson = productsData.firstWhere((p) => p['id'] == id);
      return Product.fromJson(productJson);
    } catch (e) {
      return null;
    }
  }

  Future<void> addToCart(
    String productId,
    int quantity, {
    Map<String, String>? variations,
  }) async {
    await _loadMockData();
    await _simulateNetworkDelay();

    final product = await getProductById(productId);
    if (product == null) {
      throw Exception('Produit non trouvé');
    }

    final existingIndex = _cart.indexWhere(
      (item) =>
          item.productId == productId &&
          _mapsEqual(item.selectedVariations, variations ?? {}),
    );

    if (existingIndex >= 0) {
      _cart[existingIndex] = _cart[existingIndex].copyWith(
        quantity: _cart[existingIndex].quantity + quantity,
      );
    } else {
      _cart.add(
        CartItem(
          id: 'cart_item_${DateTime.now().millisecondsSinceEpoch}',
          productId: productId,
          product: product,
          quantity: quantity,
          selectedVariations: variations ?? {},
        ),
      );
    }
  }

  Future<List<CartItem>> getCart() async {
    await _loadMockData();
    await _simulateNetworkDelay();
    return List.from(_cart);
  }

  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    await _loadMockData();
    await _simulateNetworkDelay();

    final index = _cart.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      if (quantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index] = _cart[index].copyWith(quantity: quantity);
      }
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    await _loadMockData();
    await _simulateNetworkDelay();
    _cart.removeWhere((item) => item.id == cartItemId);
  }

  Future<void> clearCart() async {
    await _loadMockData();
    await _simulateNetworkDelay();
    _cart.clear();
  }

  Future<Order> checkout({
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
  }) async {
    await _loadMockData();
    await _simulateNetworkDelay();

    if (_cart.isEmpty) {
      throw Exception('Le panier est vide');
    }

    final cartItems = await getCart();
    final subtotal = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.product.currentPrice * item.quantity),
    );
    const shipping = 5.99;
    final total = subtotal + shipping;

    final order = Order(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUserId,
      liveEventId: '',
      items: cartItems
          .map(
            (item) => OrderItem(
              productId: item.productId,
              name: item.product.name,
              quantity: item.quantity,
              price: item.product.currentPrice,
              selectedVariations: item.selectedVariations,
            ),
          )
          .toList(),
      subtotal: subtotal,
      shipping: shipping,
      total: total,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      shippingAddress: ShippingAddress.fromJson(shippingAddress),
    );

    _orders.add(order);
    await clearCart();

    return order;
  }

  Future<List<Order>> getOrders() async {
    await _loadMockData();
    await _simulateNetworkDelay();
    return _orders.where((order) => order.userId == _currentUserId).toList();
  }

  Future<Order?> getOrderById(String id) async {
    await _loadMockData();
    await _simulateNetworkDelay();
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<User?> getCurrentUser() async {
    await _loadMockData();
    await _simulateNetworkDelay();

    final usersData = _mockData!['users'] as List;
    try {
      final userJson = usersData.firstWhere((u) => u['id'] == _currentUserId);
      return User.fromJson(userJson);
    } catch (e) {
      return null;
    }
  }

  Future<List<ChatMessage>> getChatMessages(String eventId) async {
    await _loadMockData();
    await _simulateNetworkDelay();

    final chatMessages = _mockData!['chatMessages'] as Map<String, dynamic>;
    if (chatMessages.containsKey(eventId)) {
      return (chatMessages[eventId] as List)
          .map((json) => ChatMessage.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<void> featureProduct(String eventId, String productId) async {
    await _loadMockData();
    await _simulateNetworkDelay();

    final eventsData = _mockData!['liveEvents'] as List;
    final eventIndex = eventsData.indexWhere((e) => e['id'] == eventId);

    if (eventIndex >= 0) {
      eventsData[eventIndex]['featuredProduct'] = productId;

      final productsData = _mockData!['products'] as List;
      final productIndex = productsData.indexWhere((p) => p['id'] == productId);
      if (productIndex >= 0) {
        productsData[productIndex]['isFeatured'] = true;
        productsData[productIndex]['featuredAt'] = DateTime.now()
            .toIso8601String();
      }
    }
  }

  bool _mapsEqual(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (var key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  void initMockData(Map<String, dynamic> data) {
    reset();
    _mockData = data;
    _parseData();
  }

  void setSimulateDelay(bool value) {
    _simulateDelay = value;
  }

  void reset() {
    _mockData = null;
    _cart = [];
    _orders = [];
    _products = [];
  }

  void _parseData() {
    if (_mockData!['orders'] != null) {
      _orders = (_mockData!['orders'] as List)
          .map((json) => Order.fromJson(json))
          .toList();
    }

    if (_mockData!['products'] != null) {
      _products = (_mockData!['products'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    }
    if (_mockData!['cart'] != null) {
      final cartData = _mockData!['cart'];
      final items = cartData["items"] as List;

      _cart = items.map((item) {
        final productId = item['productId'] as String;
        final product = _products.firstWhere((p) => p.id == productId);
        final variations = (item["selectedVariations"] as Map<String, dynamic>);

        final selectedVariations = <String, String>{};
        for (final entry in variations.entries) {
          selectedVariations[entry.key] = entry.value as String;
        }

        return CartItem(
          id: item['id'],
          productId: item['productId'],
          quantity: item['quantity'],
          product: product,
          selectedVariations: selectedVariations,
        );
      }).toList();
    }
  }
}
