# Exercices Détaillés - Test Flutter

## Structure du Projet de Test

```
test-flutter/
├── README.md (instructions générales)
├── EXERCICES.md (ce fichier)
└── flutter_live_shopping/ (votre projet Flutter)
    ├── lib/
    ├── web/
    ├── pubspec.yaml
    └── README.md
```

---

## Modèles de Données de Référence

### LiveEvent Model
```dart
class LiveEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime? endTime;
  final LiveEventStatus status;
  final Seller seller;
  final List<Product> products;
  final Product? featuredProduct;
  final int viewerCount;
  final String? streamUrl;
  final String? replayUrl;
  final String thumbnailUrl;
  
  LiveEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.seller,
    required this.products,
    this.featuredProduct,
    this.viewerCount = 0,
    this.streamUrl,
    this.replayUrl,
    required this.thumbnailUrl,
  });
  
  factory LiveEvent.fromJson(Map<String, dynamic> json) {
    // Implementation
  }
  
  Map<String, dynamic> toJson() {
    // Implementation
  }
}

enum LiveEventStatus {
  scheduled,
  live,
  ended
}
```

### Product Model
```dart
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? salePrice;
  final List<String> images;
  final String thumbnail;
  final int stock;
  final Map<String, dynamic>? variations; // {size: ['S', 'M', 'L'], color: ['Red', 'Blue']}
  final bool isFeatured;
  final DateTime? featuredAt;
  
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.salePrice,
    required this.images,
    required this.thumbnail,
    required this.stock,
    this.variations,
    this.isFeatured = false,
    this.featuredAt,
  });
  
  double get currentPrice => salePrice ?? price;
  bool get isOnSale => salePrice != null && salePrice! < price;
  
  factory Product.fromJson(Map<String, dynamic> json) {
    // Implementation
  }
}
```

### ChatMessage Model
```dart
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isVendor;
  final ChatMessage? replyTo;
  final List<String> reactions; // ['👍', '❤️', '😂']
  
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isVendor = false,
    this.replyTo,
    this.reactions = const [],
  });
  
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Implementation
  }
}
```

### CartItem Model
```dart
class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final Map<String, String>? selectedVariations; // {size: 'M', color: 'Red'}
  
  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.selectedVariations,
  });
  
  double get total => product.currentPrice * quantity;
  
  CartItem copyWith({
    int? quantity,
    Map<String, String>? selectedVariations,
  }) {
    // Implementation
  }
}
```

---

## API Endpoints de Référence

### Base URL
```
https://api.liveshopping.example.com/api
```

### Endpoints

#### Authentification
```
POST /auth/login
POST /auth/register
POST /auth/refresh
GET  /auth/me
```

#### Live Events
```
GET    /live-events              # Liste des événements
GET    /live-events/:id          # Détails d'un événement
GET    /live-events/:id/products # Produits d'un événement
POST   /live-events/:id/join    # Rejoindre un événement
POST   /live-events/:id/leave   # Quitter un événement
```

#### Products
```
GET  /products/:id           # Détails d'un produit
POST /products/:id/feature  # Mettre en avant (admin/vendor)
```

#### Cart
```
GET    /cart                 # Récupérer le panier
POST   /cart/add             # Ajouter au panier
PUT    /cart/item/:id        # Modifier un item
DELETE /cart/item/:id        # Supprimer un item
POST   /cart/clear           # Vider le panier
```

#### Orders
```
GET  /orders                 # Liste des commandes
GET  /orders/:id             # Détails d'une commande
POST /orders/checkout        # Finaliser une commande
```

#### Chat
```
GET  /live-events/:id/chat/messages  # Historique des messages
POST /live-events/:id/chat/messages  # Envoyer un message
```

---

## WebSocket Events (Socket.io)

### Événements émis (client → serveur)
```dart
// Rejoindre un événement
socket.emit('join:live-event', {'eventId': '123'});

// Quitter un événement
socket.emit('leave:live-event', {'eventId': '123'});

// Envoyer un message de chat
socket.emit('chat:message', {
  'eventId': '123',
  'message': 'Hello!',
  'replyTo': null, // ou {'id': 'msg-id'}
});

// Ajouter une réaction
socket.emit('chat:reaction', {
  'messageId': 'msg-id',
  'emoji': '👍',
});
```

### Événements reçus (serveur → client)
```dart
// Nouveau message de chat
socket.on('chat:new-message', (data) {
  // data: ChatMessage
});

// Produit mis en avant
socket.on('product:featured', (data) {
  // data: {'productId': '123', 'eventId': '456'}
});

// Nouveau viewer
socket.on('viewer:joined', (data) {
  // data: {'viewerCount': 150}
});

// Nouvelle commande (pour le vendeur)
socket.on('order:new', (data) {
  // data: Order
});

// Indicateur de frappe
socket.on('user:typing', (data) {
  // data: {'userId': '123', 'userName': 'John'}
});
```

---

## Exemples de Code

### Configuration API Service
```dart
// config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://api.liveshopping.example.com/api';
  static const String socketUrl = 'https://socket.liveshopping.example.com';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

### Exemple de Provider
```dart
// providers/live_event_provider.dart
class LiveEventProvider extends ChangeNotifier {
  final ApiService _apiService;
  final SocketService _socketService;
  
  LiveEvent? _currentEvent;
  List<LiveEvent> _events = [];
  bool _isLoading = false;
  String? _error;
  
  LiveEvent? get currentEvent => _currentEvent;
  List<LiveEvent> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  LiveEventProvider(this._apiService, this._socketService) {
    _setupSocketListeners();
  }
  
  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _events = await _apiService.getLiveEvents();
      _error = null;
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
      _socketService.joinLiveEvent(eventId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  void _setupSocketListeners() {
    _socketService.viewerCountStream.listen((count) {
      if (_currentEvent != null) {
        _currentEvent = _currentEvent!.copyWith(viewerCount: count);
        notifyListeners();
      }
    });
    
    _socketService.productFeaturedStream.listen((productId) {
      // Update featured product
      notifyListeners();
    });
  }
}
```

### Exemple de Widget
```dart
// widgets/live/video_player_widget.dart
class VideoPlayerWidget extends StatefulWidget {
  final String? streamUrl;
  final String? replayUrl;
  final bool isLive;
  
  const VideoPlayerWidget({
    Key? key,
    this.streamUrl,
    this.replayUrl,
    required this.isLive,
  }) : super(key: key);
  
  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isBuffering = false;
  
  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }
  
  Future<void> _initializePlayer() async {
    final url = widget.isLive ? widget.streamUrl : widget.replayUrl;
    if (url == null) return;
    
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await _controller!.initialize();
    _controller!.addListener(_videoListener);
    setState(() {});
  }
  
  void _videoListener() {
    if (_controller!.value.isBuffering != _isBuffering) {
      setState(() {
        _isBuffering = _controller!.value.isBuffering;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
        if (_isBuffering)
          const Center(child: CircularProgressIndicator()),
        // Contrôles overlay
        _buildControls(),
      ],
    );
  }
  
  Widget _buildControls() {
    // Implementation des contrôles
  }
  
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
```

---

## Checklist de Validation

### Architecture
- [ ] Structure de projet claire
- [ ] Séparation des responsabilités
- [ ] Modèles de données complets
- [ ] Services bien organisés

### Fonctionnalités
- [ ] Liste des événements
- [ ] Visionnage live
- [ ] Chat temps réel
- [ ] Gestion du panier
- [ ] Checkout
- [ ] Authentification

### UI/UX
- [ ] Design moderne
- [ ] Responsive (mobile, tablette, desktop)
- [ ] Animations fluides
- [ ] États de chargement
- [ ] Gestion des erreurs

### Performance
- [ ] Temps de chargement acceptable
- [ ] Optimisation des images
- [ ] Lazy loading
- [ ] Code splitting

### Code Quality
- [ ] Conventions Dart respectées
- [ ] Code lisible et commenté
- [ ] Gestion d'erreurs appropriée
- [ ] Tests (bonus)

---

## Conseils

1. **Commencez par l'architecture** : Planifiez avant de coder
2. **Utilisez des packages éprouvés** : Ne réinventez pas la roue
3. **Testez régulièrement** : Vérifiez sur différents navigateurs
4. **Optimisez progressivement** : Performance après fonctionnalité
5. **Documentez votre code** : Commentaires clairs
6. **Gérez les erreurs** : UX même en cas d'erreur
7. **Pensez responsive** : Testez sur différentes tailles d'écran

---

## Ressources Utiles

- [Flutter Web Best Practices](https://docs.flutter.dev/platform-integration/web/best-practices)
- [Flutter Performance](https://docs.flutter.dev/perf)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Socket.io Dart Client](https://pub.dev/packages/socket_io_client)

Bon courage ! 💪

