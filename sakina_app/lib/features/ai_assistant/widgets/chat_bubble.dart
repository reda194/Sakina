import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/themes/app_theme.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String)? onSuggestionTap;

  const ChatBubble({
    super.key,
    required this.message,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser 
                ? MainAxisAlignment.end 
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) _buildAvatar(),
              if (!isUser) const SizedBox(width: 8),
              Flexible(
                child: _buildMessageBubble(context, isUser),
              ),
              if (isUser) const SizedBox(width: 8),
              if (isUser) _buildUserAvatar(),
            ],
          ),
          if (!isUser && message.suggestions.isNotEmpty)
            _buildSuggestions(context),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.psychology,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, bool isUser) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser 
              ? AppTheme.primaryColor 
              : Colors.grey[100],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isUser) _buildCategoryChip(),
                const Spacer(),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: isUser 
                        ? Colors.white.withOpacity(0.7) 
                        : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip() {
    if (message.category == MessageCategory.general) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _getCategoryText(),
        style: TextStyle(
          color: _getCategoryColor(),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, right: 40),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: message.suggestions.map((suggestion) {
          return GestureDetector(
            onTap: () => onSuggestionTap?.call(suggestion),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                suggestion,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('نسخ النص'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.content));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم نسخ النص'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            if (message.type == MessageType.assistant)
              ListTile(
                leading: const Icon(Icons.thumb_up_outlined),
                title: const Text('مفيد'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement feedback
                },
              ),
            if (message.type == MessageType.assistant)
              ListTile(
                leading: const Icon(Icons.thumb_down_outlined),
                title: const Text('غير مفيد'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement feedback
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} د';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} س';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  Color _getCategoryColor() {
    switch (message.category) {
      case MessageCategory.anxiety:
        return Colors.orange;
      case MessageCategory.depression:
        return Colors.blue;
      case MessageCategory.stress:
        return Colors.red;
      case MessageCategory.mood:
        return Colors.purple;
      case MessageCategory.meditation:
        return Colors.green;
      case MessageCategory.therapy:
        return Colors.teal;
      case MessageCategory.crisis:
        return Colors.red[700]!;
      case MessageCategory.general:
        return AppTheme.primaryColor;
    }
  }

  String _getCategoryText() {
    switch (message.category) {
      case MessageCategory.anxiety:
        return 'قلق';
      case MessageCategory.depression:
        return 'اكتئاب';
      case MessageCategory.stress:
        return 'توتر';
      case MessageCategory.mood:
        return 'مزاج';
      case MessageCategory.meditation:
        return 'تأمل';
      case MessageCategory.therapy:
        return 'علاج';
      case MessageCategory.crisis:
        return 'طوارئ';
      case MessageCategory.general:
        return 'عام';
    }
  }
}