# Test Technique - Développeur Flutter (App Web)

## Contexte du Projet

Vous postulez pour un poste de **Développeur Flutter** sur une plateforme de **Live Shopping** (shopping en direct). La plateforme permet aux vendeurs de diffuser des vidéos en direct pour présenter leurs produits, avec un système de chat en temps réel, de gestion de panier, et de paiement.

Votre mission est de créer une **application web Flutter** qui permettra aux utilisateurs de :
- Regarder des événements live shopping
- Interagir via le chat en temps réel
- Ajouter des produits au panier
- Effectuer des achats
- Gérer leur profil et leurs commandes

## Stack Technique

- **Framework** : Flutter Web
- **Langage** : Dart
- **État** : Provider, Riverpod, ou Bloc (au choix)
- **HTTP** : Dio ou http (pour charger le fichier JSON mock)
- **WebSocket** : Simulation avec Streams Dart (pas de serveur réel nécessaire)
- **Vidéo** : video_player ou chewie (pour les replays)
- **Mock Backend** : Fichier JSON fourni (`mock-api-data.json`)

## ⚠️ Important : Environnement Mock

**Ce test peut être réalisé sans environnement externe.** Un fichier JSON mock (`mock-api-data.json`) est fourni avec toutes les données nécessaires pour simuler le backend.

Vous devez créer un **service mock** qui :
- Charge les données depuis le fichier JSON
- Simule les appels API avec des délais réalistes
- Gère les opérations CRUD (créer, lire, mettre à jour, supprimer)
- Simule les événements WebSocket avec des Streams Dart

## Objectif du Test

Ce test évalue vos compétences en développement Flutter pour créer une **application web** complète. Vous devrez démontrer votre capacité à :
- Créer une architecture Flutter scalable
- Gérer l'état de l'application efficacement
- Intégrer des APIs REST
- Implémenter la communication temps réel (WebSocket)
- Créer une UI moderne et responsive
- Gérer la lecture vidéo et le streaming
- Optimiser les performances web

---

## Partie 1 : Architecture et Setup - 1h

### Exercice 1.1 : Initialisation du Projet (30 min)

**Tâches** :
1. Créer un nouveau projet Flutter Web
2. Configurer la structure de dossiers suivante :
   ```
   lib/
   ├── main.dart
   ├── app.dart
   ├── config/
   │   ├── api_config.dart
   │   └── theme_config.dart
   ├── models/
   │   ├── live_event.dart
   │   ├── product.dart
   │   ├── user.dart
   │   └── order.dart
   ├── services/
   │   ├── api_service.dart
   │   ├── socket_service.dart
   │   └── auth_service.dart
   ├── providers/ (ou bloc/ ou riverpod/)
   │   ├── live_event_provider.dart
   │   ├── cart_provider.dart
   │   └── auth_provider.dart
   ├── screens/
   │   ├── home/
   │   ├── live/
   │   ├── product/
   │   └── profile/
   ├── widgets/
   │   ├── common/
   │   └── live/
   └── utils/
       ├── constants.dart
       └── helpers.dart
   ```
3. Configurer les dépendances dans `pubspec.yaml`
4. Créer un système de routing (go_router ou auto_route)
5. Configurer le thème de l'application (light/dark mode)

**Critères d'évaluation** :
- Structure de projet claire et organisée
- Configuration appropriée des dépendances
- Routing fonctionnel
- Thème cohérent

---

### Exercice 1.2 : Modèles de Données (30 min)

**Tâches** :
1. Créer les modèles Dart suivants avec `json_serializable` :
   - `LiveEvent` : événement live shopping
   - `Product` : produit
   - `ChatMessage` : message de chat
   - `Order` : commande
   - `User` : utilisateur
   
2. Implémenter les méthodes `fromJson` et `toJson`
3. Ajouter la validation des données
4. Créer des factories pour les données de test

**Exemple de structure LiveEvent** :
```dart
class LiveEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime? endTime;
  final LiveEventStatus status;
  final List<Product> products;
  final Product? featuredProduct;
  final int viewerCount;
  final String? streamUrl;
  final String? replayUrl;
  
  // ... constructors, fromJson, toJson
}

enum LiveEventStatus {
  scheduled,
  live,
  ended
}
```

**Critères d'évaluation** :
- Modèles bien structurés
- Sérialisation JSON correcte
- Validation appropriée
- Code généré proprement

---

## Partie 2 : Services et API - 1h30

### Exercice 2.1 : Service API REST Mock (45 min)

**Contexte** : Créer un service mock pour simuler l'API backend en utilisant le fichier `mock-api-data.json`.

**Tâches** :
1. Créer une classe `MockApiService` qui :
   - Charge les données depuis `mock-api-data.json` (placé dans `assets/`)
   - Simule les délais réseau avec `Future.delayed()` (200-500ms)
   - Gère les erreurs simulées (404, 500, etc.)
   - Implémente un cache en mémoire
   - **Important** : Structurez le code pour pouvoir facilement remplacer par une vraie API plus tard

2. Créer des méthodes pour :
   - `getLiveEvents()` : récupérer la liste des événements
   - `getLiveEventById(String id)` : récupérer un événement
   - `getProducts(String eventId)` : récupérer les produits d'un événement
   - `addToCart(String productId, int quantity)` : ajouter au panier (mise à jour du mock)
   - `getCart()` : récupérer le panier
   - `checkout()` : finaliser la commande (créer une nouvelle commande dans le mock)
   - `getOrders()` : récupérer les commandes de l'utilisateur

3. Gérer les états de chargement et d'erreur

**Exemple de structure** :
```dart
class MockApiService {
  Map<String, dynamic>? _data;
  
  Future<void> _loadMockData() async {
    if (_data == null) {
      final jsonString = await rootBundle.loadString('assets/mock-api-data.json');
      _data = json.decode(jsonString);
    }
  }
  
  Future<List<LiveEvent>> getLiveEvents() async {
    await _loadMockData();
    await Future.delayed(Duration(milliseconds: 300)); // Simule le délai réseau
    // ... traitement des données
  }
}
```

**Structure attendue** :
```dart
class ApiService {
  late final Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
    ));
    
    _setupInterceptors();
  }
  
  Future<List<LiveEvent>> getLiveEvents() async {
    // Implementation
  }
  
  // ... autres méthodes
}
```

**Critères d'évaluation** :
- Architecture du service mock
- Simulation réaliste des délais réseau
- Gestion des erreurs
- Structure permettant de remplacer facilement par une vraie API
- Gestion des opérations CRUD sur les données mockées

---

### Exercice 2.2 : Service WebSocket Mock (45 min)

**Contexte** : Créer un service mock pour simuler la communication temps réel avec des Streams Dart.

**Tâches** :
1. Créer une classe `MockSocketService` qui :
   - Simule une connexion WebSocket avec des Streams Dart
   - Gère les états de connexion (connected, disconnected, connecting)
   - Émet des événements périodiques pour simuler les mises à jour temps réel
   - Utilise `StreamController` pour créer les streams d'événements

2. Implémenter les événements suivants (simulés) :
   - `joinLiveEvent(String eventId)` : simule la connexion à un événement
   - `leaveLiveEvent(String eventId)` : simule la déconnexion
   - `sendChatMessage(String message)` : ajoute un message au chat (avec délai simulé)
   - Stream `chatMessages` : émet les nouveaux messages
   - Stream `productFeatured` : émet quand un produit est mis en avant
   - Stream `viewerCount` : émet des mises à jour du nombre de viewers (simulé avec Timer)
   - Stream `newOrder` : émet quand une nouvelle commande est créée

3. Créer un stream pour chaque type d'événement

**Exemple de structure** :
```dart
class MockSocketService {
  final _chatController = StreamController<ChatMessage>.broadcast();
  final _viewerCountController = StreamController<int>.broadcast();
  Timer? _viewerCountTimer;
  
  Stream<ChatMessage> get chatMessages => _chatController.stream;
  Stream<int> get viewerCount => _viewerCountController.stream;
  
  void joinLiveEvent(String eventId) {
    // Simule la connexion
    // Démarre un timer pour simuler les mises à jour de viewers
    _viewerCountTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      // Émet une mise à jour simulée
      _viewerCountController.add(Random().nextInt(50) + 200);
    });
  }
  
  void sendChatMessage(String message) {
    // Simule l'envoi avec un délai
    Future.delayed(Duration(milliseconds: 200), () {
      final chatMessage = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'current_user',
        senderName: 'Vous',
        message: message,
        timestamp: DateTime.now(),
      );
      _chatController.add(chatMessage);
    });
  }
}
```

**Structure attendue** :
```dart
class SocketService {
  Socket? _socket;
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  
  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  
  Future<void> connect() async {
    // Implementation
  }
  
  void joinLiveEvent(String eventId) {
    // Implementation
  }
  
  void sendChatMessage(String message) {
    // Implementation
  }
  
  // ... autres méthodes
}
```

**Critères d'évaluation** :
- Simulation réaliste de WebSocket avec Streams
- Streams bien implémentés et performants
- Gestion des timers et événements périodiques
- Structure permettant de remplacer facilement par un vrai WebSocket

---

## Partie 3 : UI/UX - 2h30

### Exercice 3.1 : Page d'Accueil (45 min)

**Tâches** :
1. Créer une page `HomeScreen` qui affiche :
   - Header avec navigation (logo, menu, profil)
   - Section "Événements en direct" avec liste des événements live
   - Section "Événements à venir" avec liste des événements programmés
   - Section "Replays" avec les événements terminés
   - Footer

2. Pour chaque événement, afficher :
   - Image de preview
   - Titre
   - Nom du vendeur
   - Nombre de viewers (si live)
   - Badge "LIVE" (si en cours)
   - Date/heure (si programmé)

3. Implémenter :
   - Recherche d'événements
   - Filtres (catégorie, date, statut)
   - Pagination infinie (scroll)
   - Pull-to-refresh

4. Design responsive (mobile, tablette, desktop)

**Critères d'évaluation** :
- UI moderne et attrayante
- Responsive design
- Performance (lazy loading, pagination)
- UX fluide

---

### Exercice 3.2 : Page de Visionnage Live (1h30)

**Contexte** : Page principale pour regarder un événement live.

**Tâches** :
1. Créer une page `LiveEventScreen` avec :
   - **Zone vidéo** :
     - Lecteur vidéo (streaming ou replay)
     - Contrôles (play/pause, volume, plein écran)
     - Overlay avec informations de l'événement
     - Compteur de viewers en temps réel
   
   - **Sidebar produits** :
     - Produit featured (mis en avant)
     - Liste des produits de l'événement
     - Carte produit avec image, nom, prix, bouton "Ajouter au panier"
     - Badge "FEATURED" sur le produit mis en avant
   
   - **Chat** :
     - Zone de messages en temps réel
     - Input pour envoyer un message
     - Indicateur "typing..."
     - Réactions émojis sur les messages
     - Auto-scroll vers les nouveaux messages
     - Badge de messages non lus
   
   - **Panier** :
     - Icône avec badge du nombre d'items
     - Drawer/Modal avec liste des produits
     - Possibilité de modifier les quantités
     - Total et bouton "Checkout"

2. Gérer les états :
   - Chargement initial
   - Erreur de connexion
   - Reconnexion automatique
   - État du stream (buffering, playing, paused)

3. Optimisations :
   - Lazy loading des produits
   - Virtualisation de la liste de chat (si beaucoup de messages)
   - Cache des images

4. Responsive :
   - Layout adaptatif (mobile : vidéo plein écran, chat en overlay)
   - Desktop : layout en colonnes

**Structure attendue** :
```
screens/
  live/
    live_event_screen.dart
widgets/
  live/
    video_player_widget.dart
    product_card.dart
    chat_widget.dart
    cart_drawer.dart
```

**Critères d'évaluation** :
- Architecture des widgets
- Intégration vidéo/streaming
- Chat temps réel fonctionnel
- Gestion du panier
- Performance et optimisations
- Responsive design

---

### Exercice 3.3 : Page de Détails Produit (30 min)

**Tâches** :
1. Créer une page `ProductDetailScreen` avec :
   - Carousel d'images
   - Nom et description
   - Prix (régulier et promo)
   - Sélecteur de variations (taille, couleur, etc.)
   - Stock disponible
   - Bouton "Ajouter au panier"
   - Bouton "Acheter maintenant"
   - Section "Avis clients" (mock)
   - Produits similaires

2. Gérer les variations de produit
3. Animations de transition
4. Partage social (bonus)

**Critères d'évaluation** :
- UI claire et informative
- Gestion des variations
- Animations fluides

---

### Exercice 3.4 : Page de Checkout (30 min)

**Tâches** :
1. Créer une page `CheckoutScreen` avec :
   - Récapitulatif des produits
   - Formulaire d'adresse de livraison
   - Sélection du mode de paiement
   - Récapitulatif des frais (sous-total, livraison, total)
   - Bouton "Confirmer la commande"
   
2. Validation du formulaire
3. Intégration avec le service mock de paiement (simuler le processus de paiement)
4. Page de confirmation après paiement

**Critères d'évaluation** :
- Formulaire bien structuré
- Validation appropriée
- UX claire du processus

---

## Partie 4 : Gestion d'État - 1h

### Exercice 4.1 : Providers/Bloc (1h)

**Contexte** : Implémenter la gestion d'état pour les fonctionnalités principales.

**Tâches** :
1. Créer les providers/blocs suivants :
   - `LiveEventProvider` : gestion des événements live
   - `CartProvider` : gestion du panier
   - `AuthProvider` : gestion de l'authentification
   - `ChatProvider` : gestion du chat (optionnel)

2. Pour chaque provider, implémenter :
   - État (loading, data, error)
   - Méthodes pour modifier l'état
   - Streams pour les mises à jour temps réel
   - Persistence locale (SharedPreferences ou Hive)

3. Exemple avec `CartProvider` :
```dart
class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  
  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  double get total => _items.fold(0, (sum, item) => sum + item.total);
  
  Future<void> addItem(Product product, int quantity) async {
    // Implementation
  }
  
  Future<void> removeItem(String productId) async {
    // Implementation
  }
  
  Future<void> checkout() async {
    // Implementation
  }
}
```

**Critères d'évaluation** :
- Architecture de gestion d'état
- Séparation des responsabilités
- Performance (éviter les rebuilds inutiles)
- Persistence locale

---

## Partie 5 : Optimisations et Bonus - 1h

### Exercice 5.1 : Performance Web (30 min)

**Tâches** :
1. Optimiser le chargement initial :
   - Code splitting
   - Lazy loading des routes
   - Préchargement des assets critiques
   
2. Optimiser les images :
   - Utiliser des formats modernes (WebP)
   - Lazy loading des images
   - Placeholders pendant le chargement
   
3. Optimiser les rebuilds :
   - Utiliser `const` constructors
   - `RepaintBoundary` pour isoler les repaints
   - `AutomaticKeepAliveClientMixin` pour préserver l'état

4. Mesurer les performances :
   - Lighthouse score
   - Temps de chargement initial
   - FPS pendant les animations

**Critères d'évaluation** :
- Amélioration mesurable des performances
- Bonnes pratiques Flutter Web
- Lighthouse score > 80

---

### Exercice 5.2 : Features Bonus (30 min)

Choisir 2-3 features parmi :
- **Mode hors ligne** : Cache des données, synchronisation
- **Notifications push** : Notifications pour nouveaux événements
- **Thème personnalisable** : Plusieurs thèmes disponibles
- **Accessibilité** : Support screen reader, navigation clavier
- **Internationalisation** : Support multi-langues (i18n)
- **Tests** : Tests unitaires et widget tests
- **Animations avancées** : Transitions fluides, micro-interactions

**Critères d'évaluation** :
- Qualité de l'implémentation
- Utilité de la feature
- Code maintenable

---

## Livrables Attendus

1. **Code source complet** dans un repository Git
2. **README.md** expliquant :
   - Comment lancer l'application
   - Structure du projet
   - Choix techniques (état management, packages, etc.)
   - Difficultés rencontrées
   - Améliorations possibles
3. **Screenshots/Vidéo** de l'application en fonctionnement
4. **Documentation** des APIs utilisées
5. **Tests** (unitaires et widget) - bonus mais apprécié

---

## Instructions de Soumission

1. **Copier le fichier `mock-api-data.json`** dans le dossier `assets/` de votre projet Flutter
2. Créer un repository Git (GitHub, GitLab, etc.)
3. Commiter votre code avec des messages clairs
4. Ajouter un fichier `.gitignore` approprié
5. Envoyer le lien du repository + un README détaillé
6. Temps estimé total : **7h30** (vous pouvez répartir sur plusieurs jours)

## Fichiers Fournis

- **`mock-api-data.json`** : Fichier JSON contenant toutes les données mockées (événements, produits, messages, commandes, etc.)
- **`MOCK_SERVICE_EXAMPLE.md`** : Exemples de code pour implémenter les services mock

Consultez `MOCK_SERVICE_EXAMPLE.md` pour des exemples détaillés d'implémentation des services mock.

---

## Critères Généraux d'Évaluation

- ✅ **Architecture** : Structure claire, scalable, maintenable
- ✅ **Code Quality** : Lisibilité, conventions Dart/Flutter
- ✅ **UI/UX** : Design moderne, responsive, intuitif
- ✅ **Performance** : Optimisations web, temps de chargement
- ✅ **Gestion d'État** : Architecture appropriée, performance
- ✅ **Intégration** : APIs REST, WebSocket fonctionnels
- ✅ **Tests** : Couverture, qualité (bonus)
- ✅ **Documentation** : Clarté, exhaustivité

---

## Ressources Utiles

- [Flutter Web Documentation](https://docs.flutter.dev/platform-integration/web)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)
- [Riverpod](https://riverpod.dev/)
- [Bloc](https://bloclibrary.dev/)
- [Dio](https://pub.dev/packages/dio)
- [Socket.io Client](https://pub.dev/packages/socket_io_client)

---

## Questions ?

N'hésitez pas à poser des questions si quelque chose n'est pas clair. Nous valorisons la communication et la compréhension du besoin avant l'implémentation.

**Bonne chance ! 🚀**

