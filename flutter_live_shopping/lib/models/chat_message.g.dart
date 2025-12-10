// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageReply _$ChatMessageReplyFromJson(Map<String, dynamic> json) =>
    ChatMessageReply(
      id: json['id'] as String,
      sender: json['sender'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$ChatMessageReplyToJson(ChatMessageReply instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender': instance.sender,
      'message': instance.message,
    };

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  id: json['id'] as String,
  senderId: json['senderId'] as String,
  senderName: json['senderName'] as String,
  message: json['message'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  isVendor: json['isVendor'] as bool? ?? false,
  replyTo: json['replyTo'] == null
      ? null
      : ChatMessageReply.fromJson(json['replyTo'] as Map<String, dynamic>),
  reactions:
      (json['reactions'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
      'isVendor': instance.isVendor,
      'replyTo': instance.replyTo?.toJson(),
      'reactions': instance.reactions,
    };
