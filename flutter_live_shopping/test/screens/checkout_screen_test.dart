import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_live_shopping/screens/checkout/checkout_screen.dart';
import 'package:flutter_live_shopping/providers/cart_provider.dart';
import 'package:flutter_live_shopping/models/product.dart';
import 'package:flutter_live_shopping/services/mock_api_service.dart';

import '../helpers/test_http_overrides.dart';

void main() {
  Widget createWidgetUnderTest(CartProvider cartProvider) {
    return MaterialApp(
      home: ChangeNotifierProvider<CartProvider>.value(
        value: cartProvider,
        child: const CheckoutScreen(),
      ),
    );
  }

  group('CheckoutScreen', () {
    late CartProvider cartProvider;
    late String jsonString;
    late Product product;

    setUpAll(() async {
      final file = File('assets/mock-api-data.json');
      jsonString = await file.readAsString();
    });

    tearDownAll(() {
      HttpOverrides.global = null;
    });

    setUp(() async {
      final mockData = json.decode(jsonString);
      final apiService = MockApiService();

      mockData['cart'] = null;
      apiService.initMockData(mockData);
      apiService.setSimulateDelay(false);

      cartProvider = CartProvider(apiService: apiService);

      final productsJson = mockData['products'] as List;
      product = Product.fromJson(productsJson.first);

      await cartProvider.addItem(product, 1);
    });

    testWidgets('affiche les champs du formulaire',
        (WidgetTester tester) async {
      await HttpOverrides.runZoned(() async {
        tester.view.physicalSize = const Size(2400, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createWidgetUnderTest(cartProvider));
        await tester.pumpAndSettle();

        expect(find.text('Adresse de livraison'), findsOneWidget);
        expect(find.text('Nom complet'), findsOneWidget);
        expect(find.text('Adresse'), findsOneWidget);
        expect(find.text('Ville'), findsOneWidget);
        expect(find.text('Code postal'), findsOneWidget);
      }, createHttpClient: (context) => MockHttpClient());
    });

    testWidgets('affiche les moyens de paiement', (WidgetTester tester) async {
      await HttpOverrides.runZoned(() async {
        tester.view.physicalSize = const Size(2400, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createWidgetUnderTest(cartProvider));
        await tester.pumpAndSettle();

        expect(find.text('Mode de paiement'), findsOneWidget);
        expect(find.text('Carte bancaire'), findsOneWidget);
        expect(find.text('PayPal'), findsOneWidget);
      }, createHttpClient: (context) => MockHttpClient());
    });

    testWidgets('affiche le résumé de la commande',
        (WidgetTester tester) async {
      await HttpOverrides.runZoned(() async {
        tester.view.physicalSize = const Size(2400, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createWidgetUnderTest(cartProvider));
        await tester.pumpAndSettle();

        expect(find.text('Résumé de la commande'), findsOneWidget);
        expect(find.text(product.name), findsWidgets);
        expect(find.text('${product.currentPrice.toStringAsFixed(2)} €'),
            findsWidgets);
      }, createHttpClient: (context) => MockHttpClient());
    });

    testWidgets(
        'affiche des erreurs de validation lors de la soumission d\'un formulaire vide',
        (WidgetTester tester) async {
      await HttpOverrides.runZoned(() async {
        tester.view.physicalSize = const Size(2400, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createWidgetUnderTest(cartProvider));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Confirmer la commande'));
        await tester.pump();

        expect(find.text('Requis'), findsAtLeastNWidgets(1));
      }, createHttpClient: (context) => MockHttpClient());
    });
  });
}
