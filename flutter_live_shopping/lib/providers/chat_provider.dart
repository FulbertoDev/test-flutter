import 'package:flutter/foundation.dart';
import 'package:flutter_live_shopping/services/mock_api_service.dart';
import '../models/chat_message.dart';
import '../services/mock_socket_service.dart';

class ChatProvider extends ChangeNotifier {
  final MockSocketService _socketService = MockSocketService();
  final MockApiService _apiService = MockApiService();

  List<ChatMessage> _messages = [];
  final bool _isConnected = false;

  List<ChatMessage> get messages => _messages;
  bool get isConnected => _isConnected;
  Stream<ChatMessage> get messageStream => _socketService.chatMessages;

  ChatProvider() {
    _setupListeners();
  }

  void _setupListeners() {
    _socketService.chatMessages.listen((message) {
      _messages.add(message);
      notifyListeners();
    });
  }

  Future<void> sendMessage(String message, {ChatMessageReply? replyTo}) async {
    try {
      await _socketService.sendChatMessage(message, replyTo: replyTo);
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  Future<void> loadMessages(String eventId) async {
    _messages.clear();
    notifyListeners();
    _messages = await _apiService.getChatMessages(eventId);
    notifyListeners();
  }

  void addReaction(String messageId, String emoji) {
    _socketService.addReaction(messageId, emoji);
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
