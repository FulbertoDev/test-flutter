import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_live_shopping/models/product.dart';
import 'package:flutter_live_shopping/providers/cart_provider.dart';
import 'package:flutter_live_shopping/services/mock_api_service.dart';

void main() {
  group('CartProvider', () {
    late CartProvider cartProvider;
    late Product testProduct;
    late String jsonString;

    setUpAll(() async {
      final file = File('assets/mock-api-data.json');
      jsonString = await file.readAsString();
    });

    setUp(() {
      final Map<String, dynamic> mockData = json.decode(jsonString);
      // clear cart for tests
      mockData['cart'] = null;

      final productsJson = mockData['products'] as List;
      final products = productsJson
          .map((json) => Product.fromJson(json))
          .toList();
      testProduct = products.first;

      final apiService = MockApiService();
      apiService.initMockData(mockData);
      cartProvider = CartProvider(apiService: apiService);
    });

    test('addItem adds a new item to the cart', () async {
      await cartProvider.addItem(testProduct, 1);
      expect(cartProvider.items.length, 1);
      expect(cartProvider.items.first.product.id, testProduct.id);
      expect(cartProvider.items.first.quantity, 1);
    });

    test('addItem increments quantity if item already exists', () async {
      await cartProvider.addItem(testProduct, 1);
      await cartProvider.addItem(testProduct, 1);
      expect(cartProvider.items.length, 1);
      expect(cartProvider.items.first.quantity, 2);
    });

    test('removeItem removes the item from the cart', () async {
      await cartProvider.addItem(testProduct, 1);
      await cartProvider.removeItem(testProduct.id);
      expect(cartProvider.items.isEmpty, true);
    });

    test('updateQuantity updates the quantity of an item', () async {
      await cartProvider.addItem(testProduct, 1);
      await cartProvider.updateQuantity(testProduct.id, 5);
      expect(
        cartProvider.items
            .firstWhere((item) => item.product.id == testProduct.id)
            .quantity,
        5,
      );
    });

    test('updateQuantity removes item if quantity is 0', () async {
      await cartProvider.addItem(testProduct, 1);
      await cartProvider.updateQuantity(testProduct.id, 0);
      expect(cartProvider.items.isEmpty, true);
    });

    test('clear empties the cart', () async {
      await cartProvider.addItem(testProduct, 1);
      await cartProvider.clearCart();
      expect(cartProvider.items.isEmpty, true);
    });

    test('calculations are correct', () async {
      final file = File('assets/mock-api-data.json');
      final jsonString = await file.readAsString();
      final Map<String, dynamic> data = json.decode(jsonString);
      final productsJson = data['products'] as List;
      final products = productsJson
          .map((json) => Product.fromJson(json))
          .toList();
      final product2 = products[1];

      await cartProvider.addItem(testProduct, 1);
      await cartProvider.addItem(product2, 1);

      final price1 = testProduct.salePrice ?? testProduct.price;
      final price2 = product2.salePrice ?? product2.price;
      final expectedSubtotal = price1 + price2;

      expect(cartProvider.subtotal, expectedSubtotal);
    });
  });
}
