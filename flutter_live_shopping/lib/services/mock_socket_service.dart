import 'dart:async';
import 'dart:math';
import '../models/chat_message.dart';

class MockSocketService {
  static final MockSocketService _instance = MockSocketService._internal();
  factory MockSocketService() => _instance;
  MockSocketService._internal();

  final _chatController = StreamController<ChatMessage>.broadcast();
  final _productFeaturedController = StreamController<String>.broadcast();
  final _viewerCountController = StreamController<int>.broadcast();

  Timer? _viewerCountTimer;
  String? _currentEventId;
  int _baseViewerCount = 200;
  final Random _random = Random();
  final List<ChatMessage> _chatHistory = [];

  Stream<ChatMessage> get chatMessages => _chatController.stream;
  Stream<String> get productFeatured => _productFeaturedController.stream;
  Stream<int> get viewerCount => _viewerCountController.stream;

  bool get isConnected => _currentEventId != null;

  Future<void> joinLiveEvent(String eventId) async {
    _currentEventId = eventId;

    await Future.delayed(const Duration(milliseconds: 300));

    _startViewerCountSimulation();

    _simulateAutomaticMessages();
  }

  void leaveLiveEvent(String eventId) {
    if (_currentEventId == eventId) {
      _currentEventId = null;
      _viewerCountTimer?.cancel();
      _viewerCountTimer = null;
    }
  }

  Future<void> sendChatMessage(String message,
      {ChatMessageReply? replyTo}) async {
    if (_currentEventId == null) {
      throw Exception('Pas connecté à un événement');
    }

    await Future.delayed(const Duration(milliseconds: 150));

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

    if (_random.nextDouble() > 0.7) {
      Future.delayed(Duration(seconds: 2 + _random.nextInt(3)), () {
        if (_currentEventId != null) {
          final vendorReply = ChatMessage(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            senderId: 'seller_001',
            senderName: 'Vendeur',
            message: _generateVendorReply(message),
            timestamp: DateTime.now(),
            isVendor: true,
            replyTo: ChatMessageReply(
              id: chatMessage.id,
              sender: chatMessage.senderName,
              message: chatMessage.message,
            ),
            reactions: [],
          );
          _chatHistory.add(vendorReply);
          _chatController.add(vendorReply);
        }
      });
    }
  }

  void addReaction(String messageId, String emoji) {
    final messageIndex = _chatHistory.indexWhere((m) => m.id == messageId);
    if (messageIndex >= 0) {
      final message = _chatHistory[messageIndex];
      final updatedReactions = List<String>.from(message.reactions)..add(emoji);
      final updatedMessage = message.copyWith(reactions: updatedReactions);
      _chatHistory[messageIndex] = updatedMessage;
      _chatController.add(updatedMessage);
    }
  }

  void _startViewerCountSimulation() {
    _viewerCountTimer?.cancel();
    _viewerCountTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentEventId == null) {
        timer.cancel();
        return;
      }

      _baseViewerCount += _random.nextInt(10) - 5;
      _baseViewerCount = _baseViewerCount.clamp(150, 300);
      _viewerCountController.add(_baseViewerCount);
    });
  }

  void _simulateAutomaticMessages() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_currentEventId == null) {
        timer.cancel();
        return;
      }

      if (_random.nextDouble() > 0.5) {
        final autoMessages = [
          'Superbe produit ! 👍',
          "J'adore cette collection !",
          'Quand sera-t-il disponible ?',
          "Y a-t-il d'autres couleurs ?",
          'Quelle est la taille recommandée ?',
          'Prix très intéressant ! 💯',
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

  String _generateVendorReply(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('taille') || lowerMessage.contains('size')) {
      return 'Je recommande la taille M pour une coupe ajustée !';
    } else if (lowerMessage.contains('couleur') ||
        lowerMessage.contains('color')) {
      return 'Nous avons plusieurs couleurs disponibles. Regardez les variations sur la fiche produit !';
    } else if (lowerMessage.contains('prix') ||
        lowerMessage.contains('price')) {
      return 'Le prix actuel est en promotion ! Profitez-en maintenant.';
    } else {
      return "Merci pour votre intérêt ! N'hésitez pas si vous avez des questions.";
    }
  }

  void simulateProductFeatured(String productId) {
    _productFeaturedController.add(productId);
  }

  List<ChatMessage> getChatHistory() {
    return List.from(_chatHistory);
  }

  void loadChatHistory(List<ChatMessage> messages) {
    _chatHistory.clear();
    _chatHistory.addAll(messages);
    for (final message in messages) {
      _chatController.add(message);
    }
  }

  void dispose() {
    _viewerCountTimer?.cancel();
    _chatController.close();
    _productFeaturedController.close();
    _viewerCountController.close();
  }
}
