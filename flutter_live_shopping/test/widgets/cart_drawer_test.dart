import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_live_shopping/widgets/common/cart_preview_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_live_shopping/providers/cart_provider.dart';
import 'package:flutter_live_shopping/models/product.dart';
import 'package:flutter_live_shopping/services/mock_api_service.dart';
import '../helpers/test_http_overrides.dart';

void main() {
  Widget createWidgetUnderTest(CartProvider cartProvider) {
    return MaterialApp(
      home: ChangeNotifierProvider<CartProvider>.value(
        value: cartProvider,
        child: Scaffold(
          body: Builder(
            builder: (context) =>
                CartPreviewWidget(scrollController: ScrollController()),
          ),
        ),
      ),
    );
  }

  group('CartDrawer', () {
    late String jsonString;
    late Map<String, dynamic> mockData;

    setUpAll(() async {
      final file = File('assets/mock-api-data.json');
      jsonString = await file.readAsString();
    });

    setUp(() {
      mockData = json.decode(jsonString);
      mockData['cart'] = null;
    });

    testWidgets(
      'CartDrawer affiche un message vide lorsque le panier est vide',
      (WidgetTester tester) async {
        await HttpOverrides.runZoned(() async {
          tester.view.physicalSize = const Size(2400, 1600);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);

          final apiService = MockApiService();
          apiService.initMockData(mockData);
          apiService.setSimulateDelay(false);

          final cartProvider = CartProvider(apiService: apiService);

          await tester.pumpWidget(createWidgetUnderTest(cartProvider));
          await tester.pumpAndSettle();

          expect(find.text('Panier'), findsOneWidget);
          expect(find.text('Votre panier est vide'), findsOneWidget);
          expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
        }, createHttpClient: (context) => MockHttpClient());
      },
    );

    testWidgets('CartDrawer affiche les articles et les totaux', (
      WidgetTester tester,
    ) async {
      await HttpOverrides.runZoned(() async {
        tester.view.physicalSize = const Size(2400, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final apiService = MockApiService();
        apiService.initMockData(mockData);
        apiService.setSimulateDelay(false);

        final cartProvider = CartProvider(apiService: apiService);

        final productsJson = mockData['products'] as List;
        final product = Product.fromJson(productsJson.first);

        await cartProvider.addItem(product, 1);

        await tester.pumpWidget(createWidgetUnderTest(cartProvider));
        await tester.pumpAndSettle();

        expect(find.text(product.name), findsWidgets);
        expect(
          find.text('${product.currentPrice.toStringAsFixed(2)} €'),
          findsWidgets,
        );
        expect(find.text('1'), findsWidgets);

        expect(find.text('Sous-total'), findsWidgets);
        expect(find.text('Livraison'), findsWidgets);
        expect(find.text('Total'), findsWidgets);
      }, createHttpClient: (context) => MockHttpClient());
    });
  });
}
