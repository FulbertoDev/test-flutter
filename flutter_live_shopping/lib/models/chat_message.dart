import 'package:json_annotation/json_annotation.dart';

part 'chat_message.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatMessageReply {
  final String id;
  final String sender;
  final String message;

  ChatMessageReply({
    required this.id,
    required this.sender,
    required this.message,
  });

  factory ChatMessageReply.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageReplyFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageReplyToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isVendor;
  final ChatMessageReply? replyTo;
  final List<String> reactions;

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

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? message,
    DateTime? timestamp,
    bool? isVendor,
    ChatMessageReply? replyTo,
    List<String>? reactions,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isVendor: isVendor ?? this.isVendor,
      replyTo: replyTo ?? this.replyTo,
      reactions: reactions ?? this.reactions,
    );
  }
}
