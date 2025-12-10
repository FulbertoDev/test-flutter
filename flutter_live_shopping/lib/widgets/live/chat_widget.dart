import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_message.dart';
import '../../providers/chat_provider.dart';
import '../../config/theme_config.dart';
import 'package:intl/intl.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<ChatProvider>().sendMessage(message);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingM),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? AppTheme.darkBorderColor
                      : AppTheme.borderColor,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 20,
                  color: isDark
                      ? AppTheme.darkTextPrimaryColor
                      : AppTheme.textPrimaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Chat en direct',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),

          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chat, _) {
                if (chat.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_outlined,
                          size: 48,
                          color: AppTheme.textSecondaryColor.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun message pour le moment',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondaryColor),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppTheme.paddingM),
                  itemCount: chat.messages.length,
                  itemBuilder: (context, index) {
                    return _ChatMessageBubble(message: chat.messages[index]);
                  },
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(AppTheme.paddingM),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? AppTheme.darkBorderColor
                      : AppTheme.borderColor,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Votre message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingM,
                        vertical: AppTheme.paddingS,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                message.senderName,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: message.isVendor
                      ? AppTheme.primaryColor
                      : AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (message.isVendor) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'VENDEUR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                DateFormat.Hm().format(message.timestamp),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (message.replyTo != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 4, left: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    (isDark ? AppTheme.darkBorderColor : AppTheme.borderColor)
                        .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                border: const Border(
                  left: BorderSide(color: AppTheme.primaryColor, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.replyTo!.sender,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    message.replyTo!.message,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: message.isVendor
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : (isDark
                        ? AppTheme.darkCardColor
                        : AppTheme.backgroundColor),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Text(
              message.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (message.reactions.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: message.reactions.map((emoji) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCardColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.darkBorderColor
                          : AppTheme.borderColor,
                    ),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
