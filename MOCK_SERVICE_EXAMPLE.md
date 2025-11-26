# Exemple de Service Mock

Ce fichier contient des exemples de code pour implémenter les services mock utilisant le fichier `mock-api-data.json`.

## Configuration du fichier JSON dans pubspec.yaml

```yaml
flutter:
  assets:
    - assets/mock-api-data.json
```

## Exemple de MockApiService

```dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/live_event.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class MockApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;
  MockApiService._internal();

  Map<String, dynamic>? _mockData;
  List<CartItem> _cart = [];
  List<Order> _orders = [];
  String? _currentUserId = 'user_001';

  Future<void> _loadMockData() async {
    if (_mockData == null) {
      final jsonString = await rootBundle.loadString('assets/mock-api-data.json');
      _mockData = json.decode(jsonString);
      
      // Initialiser le panier depuis les données mock
      if (_mockData!['cart'] != null) {
        final cartData = _mockData!['cart'];
        // Convertir les données du panier en CartItem
      }
      
      // Initialiser les commandes
      if (_mockData!['orders'] != null) {
        _orders = (_mockData!['orders'] as List)
            .map((json) => Order.fromJson(json))
            .toList();
      }
    }
  }

  // Simule un délai réseau
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 200 + (DateTime.now().millisecond % 300)));
  }

  // Récupérer tous les événements
  Future<List<LiveEvent>> getLiveEvents() async {
    await _loadMockData();
    await _simulateNetworkDelay();
    
    final eventsData = _mockData!['liveEvents'] as List;
    final productsData = _mockData!['products'] as List;
    
    return eventsData.map((eventJson) {
      // Récupérer les produits de l'événement
      final productIds = (eventJson['products'] as List).cast<String>();
      final products = productIds.map((id) {
        final productJson = productsData.firstWhere(
          (p) => p['id'] == id,
          orElse: () => null,
        );
        return productJson != null ? Product.fromJson(productJson) : null;
      }).whereType<Product>().toList();
      
      // Récupérer le produit featured
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
      
      return LiveEvent.fromJson({
        ...eventJson,
        'products': products.map((p) => p.toJson()).toList(),
        'featuredProduct': featuredProduct?.toJson(),
      });
    }).toList();
  }

  // Récupérer un événement par ID
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

  // Récupérer les produits d'un événement
  Future<List<Product>> getProducts(String eventId) async {
    await _loadMockData();
    await _simulateNetworkDelay();
    
    final event = await getLiveEventById(eventId);
    return event?.products ?? [];
  }

  // Récupérer un produit par ID
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

  // Ajouter au panier
  Future<void> addToCart(String productId, int quantity, {Map<String, String>? variations}) async {
    await _loadMockData();
    await _simulateNetworkDelay();
    
    final product = await getProductById(productId);
    if (product == null) {
      throw Exception('Produit non trouvé');
    }
    
    // Vérifier si le produit est déjà dans le panier
    final existingIndex = _cart.indexWhere(
      (item) => item.productId == productId && 
                _mapsEqual(item.selectedVariations, variations),
    );
    
    if (existingIndex >= 0) {
      // Mettre à jour la quantité
      _cart[existingIndex] = _cart[existingIndex].copyWith(
        quantity: _cart[existingIndex].quantity + quantity,
      );
    } else {
      // Ajouter un nouvel item
      _cart.add(CartItem(
        id: 'cart_item_${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        product: product,
        quantity: quantity,
        selectedVariations: variations ?? {},
      ));
    }
  }

  // Récupérer le panier
  Future<List<CartItem>> getCart() async {
    await _loadMockData();
    await _simulateNetworkDelay();
    return List.from(_cart);
  }

  // Retirer du panier
  Future<void> removeFromCart(String cartItemId) async {
    await _loadMockData();
    await _simulateNetworkDelay();
    _cart.removeWhere((item) => item.id == cartItemId);
  }

  // Vider le panier
  Future<void> clearCart() async {
    await _loadMockData();
    await _simulateNetworkDelay();
    _cart.clear();
  }

  // Finaliser la commande
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
      userId: _currentUserId!,
      liveEventId: '', // À déterminer selon le contexte
      items: cartItems.map((item) => OrderItem(
        productId: item.productId,
        name: item.product.name,
        quantity: item.quantity,
        price: item.product.currentPrice,
        selectedVariations: item.selectedVariations,
      )).toList(),
      subtotal: subtotal,
      shipping: shipping,
      total: total,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      shippingAddress: shippingAddress,
    );
    
    _orders.add(order);
    await clearCart();
    
    return order;
  }

  // Récupérer les commandes de l'utilisateur
  Future<List<Order>> getOrders() async {
    await _loadMockData();
    await _simulateNetworkDelay();
    return _orders.where((order) => order.userId == _currentUserId).toList();
  }

  // Récupérer une commande par ID
  Future<Order?> getOrderById(String id) async {
    await _loadMockData();
    await _simulateNetworkDelay();
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  // Mettre en avant un produit
  Future<void> featureProduct(String eventId, String productId) async {
    await _loadMockData();
    await _simulateNetworkDelay();
    
    // Mettre à jour les données mockées
    final eventsData = _mockData!['liveEvents'] as List;
    final eventIndex = eventsData.indexWhere((e) => e['id'] == eventId);
    
    if (eventIndex >= 0) {
      eventsData[eventIndex]['featuredProduct'] = productId;
      
      // Mettre à jour le produit dans la liste des produits
      final productsData = _mockData!['products'] as List;
      final productIndex = productsData.indexWhere((p) => p['id'] == productId);
      if (productIndex >= 0) {
        productsData[productIndex]['isFeatured'] = true;
        productsData[productIndex]['featuredAt'] = DateTime.now().toIso8601String();
      }
    }
  }

  // Helper pour comparer les maps
  bool _mapsEqual(Map<String, String>? a, Map<String, String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}
```

## Exemple de MockSocketService

```dart
import 'dart:async';
import 'dart:math';
import '../models/chat_message.dart';
import '../models/product.dart';

class MockSocketService {
  static final MockSocketService _instance = MockSocketService._internal();
  factory MockSocketService() => _instance;
  MockSocketService._internal();

  final _chatController = StreamController<ChatMessage>.broadcast();
  final _productFeaturedController = StreamController<String>.broadcast();
  final _viewerCountController = StreamController<int>.broadcast();
  final _newOrderController = StreamController<Map<String, dynamic>>.broadcast();
  
  Timer? _viewerCountTimer;
  String? _currentEventId;
  int _baseViewerCount = 200;
  final Random _random = Random();
  List<ChatMessage> _chatHistory = [];

  // Streams
  Stream<ChatMessage> get chatMessages => _chatController.stream;
  Stream<String> get productFeatured => _productFeaturedController.stream;
  Stream<int> get viewerCount => _viewerCountController.stream;
  Stream<Map<String, dynamic>> get newOrder => _newOrderController.stream;

  bool get isConnected => _currentEventId != null;

  // Rejoindre un événement
  Future<void> joinLiveEvent(String eventId) async {
    _currentEventId = eventId;
    
    // Simuler le chargement de l'historique du chat
    await Future.delayed(Duration(milliseconds: 300));
    // Charger l'historique depuis mock-api-data.json si disponible
    
    // Démarrer la simulation des mises à jour de viewers
    _startViewerCountSimulation();
    
    // Simuler quelques messages automatiques
    _simulateAutomaticMessages();
  }

  // Quitter un événement
  void leaveLiveEvent(String eventId) {
    if (_currentEventId == eventId) {
      _currentEventId = null;
      _viewerCountTimer?.cancel();
      _viewerCountTimer = null;
    }
  }

  // Envoyer un message de chat
  Future<void> sendChatMessage(String message, {ChatMessage? replyTo}) async {
    if (_currentEventId == null) {
      throw Exception('Pas connecté à un événement');
    }
    
    // Simuler le délai d'envoi
    await Future.delayed(Duration(milliseconds: 150));
    
    final chatMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user',
      senderName: 'Vous',
      message: message,
      timestamp: DateTime.now(),
      isVendor: false,
      replyTo: replyTo,
      reactions: [],
    );
    
    _chatHistory.add(chatMessage);
    _chatController.add(chatMessage);
    
    // Simuler une réponse automatique du vendeur (optionnel)
    if (_random.nextDouble() > 0.7) {
      Future.delayed(Duration(seconds: 2 + _random.nextInt(3)), () {
        final vendorReply = ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'seller_001',
          senderName: 'Vendeur',
          message: _generateVendorReply(message),
          timestamp: DateTime.now(),
          isVendor: true,
          replyTo: chatMessage,
          reactions: [],
        );
        _chatHistory.add(vendorReply);
        _chatController.add(vendorReply);
      });
    }
  }

  // Ajouter une réaction à un message
  void addReaction(String messageId, String emoji) {
    final messageIndex = _chatHistory.indexWhere((m) => m.id == messageId);
    if (messageIndex >= 0) {
      final message = _chatHistory[messageIndex];
      final updatedReactions = List<String>.from(message.reactions)..add(emoji);
      final updatedMessage = ChatMessage(
        id: message.id,
        senderId: message.senderId,
        senderName: message.senderName,
        message: message.message,
        timestamp: message.timestamp,
        isVendor: message.isVendor,
        replyTo: message.replyTo,
        reactions: updatedReactions,
      );
      _chatHistory[messageIndex] = updatedMessage;
      _chatController.add(updatedMessage);
    }
  }

  // Simuler les mises à jour du nombre de viewers
  void _startViewerCountSimulation() {
    _viewerCountTimer?.cancel();
    _viewerCountTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentEventId == null) {
        timer.cancel();
        return;
      }
      
      // Simuler des variations aléatoires du nombre de viewers
      _baseViewerCount += _random.nextInt(10) - 5; // Variation de -5 à +5
      _baseViewerCount = _baseViewerCount.clamp(150, 300);
      _viewerCountController.add(_baseViewerCount);
    });
  }

  // Simuler des messages automatiques
  void _simulateAutomaticMessages() {
    Timer.periodic(Duration(seconds: 30), (timer) {
      if (_currentEventId == null) {
        timer.cancel();
        return;
      }
      
      if (_random.nextDouble() > 0.5) {
        final autoMessages = [
          'Superbe produit ! 👍',
          'J\'adore cette collection !',
          'Quand sera-t-il disponible ?',
          'Y a-t-il d\'autres couleurs ?',
        ];
        
        final message = ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'user_${_random.nextInt(10)}',
          senderName: 'Utilisateur ${_random.nextInt(100)}',
          message: autoMessages[_random.nextInt(autoMessages.length)],
          timestamp: DateTime.now(),
          isVendor: false,
          replyTo: null,
          reactions: [],
        );
        
        _chatHistory.add(message);
        _chatController.add(message);
      }
    });
  }

  // Générer une réponse automatique du vendeur
  String _generateVendorReply(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('taille') || lowerMessage.contains('size')) {
      return 'Je recommande la taille M pour une coupe ajustée !';
    } else if (lowerMessage.contains('couleur') || lowerMessage.contains('color')) {
      return 'Nous avons plusieurs couleurs disponibles. Regardez les variations sur la fiche produit !';
    } else if (lowerMessage.contains('prix') || lowerMessage.contains('price')) {
      return 'Le prix actuel est en promotion ! Profitez-en maintenant.';
    } else {
      return 'Merci pour votre intérêt ! N\'hésitez pas si vous avez des questions.';
    }
  }

  // Simuler la mise en avant d'un produit
  void simulateProductFeatured(String productId) {
    _productFeaturedController.add(productId);
  }

  // Simuler une nouvelle commande
  void simulateNewOrder(Map<String, dynamic> orderData) {
    _newOrderController.add(orderData);
  }

  // Récupérer l'historique du chat
  List<ChatMessage> getChatHistory() {
    return List.from(_chatHistory);
  }

  // Nettoyer les ressources
  void dispose() {
    _viewerCountTimer?.cancel();
    _chatController.close();
    _productFeaturedController.close();
    _viewerCountController.close();
    _newOrderController.close();
  }
}
```

## Utilisation dans un Provider

```dart
class LiveEventProvider extends ChangeNotifier {
  final MockApiService _apiService = MockApiService();
  final MockSocketService _socketService = MockSocketService();
  
  LiveEvent? _currentEvent;
  List<LiveEvent> _events = [];
  bool _isLoading = false;
  String? _error;
  
  LiveEventProvider() {
    _setupSocketListeners();
  }
  
  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _events = await _apiService.getLiveEvents();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> joinEvent(String eventId) async {
    try {
      _currentEvent = await _apiService.getLiveEventById(eventId);
      await _socketService.joinLiveEvent(eventId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  void _setupSocketListeners() {
    _socketService.viewerCount.listen((count) {
      if (_currentEvent != null) {
        _currentEvent = _currentEvent!.copyWith(viewerCount: count);
        notifyListeners();
      }
    });
    
    _socketService.productFeatured.listen((productId) {
      // Mettre à jour le produit featured
      notifyListeners();
    });
  }
}
```

## Notes importantes

1. **Structure modulaire** : Organisez le code pour pouvoir facilement remplacer les services mock par de vrais services API/WebSocket plus tard.

2. **Interface commune** : Créez des interfaces/abstract classes pour `ApiService` et `SocketService` pour faciliter le remplacement.

3. **Gestion d'état** : Les services mock doivent mettre à jour leur état interne pour simuler un comportement réaliste.

4. **Erreurs simulées** : Ajoutez parfois des erreurs simulées pour tester la gestion d'erreurs de l'application.

5. **Performance** : Les délais simulés ne doivent pas être trop longs pour garder une bonne UX pendant le développement.

