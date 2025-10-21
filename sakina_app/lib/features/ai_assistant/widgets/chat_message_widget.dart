import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/themes/app_theme.dart';
import '../providers/advanced_ai_provider.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessage message;
  final Function(String)? onSuggestionTap;
  final Function(String)? onMessageAction;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.onSuggestionTap,
    this.onMessageAction,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  final bool _isExpanded = false;
  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startEntryAnimation();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.message.isUser ? 1.0 : -1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);
  }

  void _startEntryAnimation() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _slideController.forward();
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Column(
            crossAxisAlignment: widget.message.isUser 
                ? CrossAxisAlignment.end 
                : CrossAxisAlignment.start,
            children: [
              _buildMessageBubble(),
              if (widget.message.suggestions != null && widget.message.suggestions!.isNotEmpty)
                _buildSuggestions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble() {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          _showActions = !_showActions;
        });
        HapticFeedback.mediumImpact();
      },
      onTap: () {
        if (_showActions) {
          setState(() {
            _showActions = false;
          });
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: widget.message.isUser 
              ? CrossAxisAlignment.end 
              : CrossAxisAlignment.start,
          children: [
            // Message bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: widget.message.isUser
                    ? LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.8),
                        ],
                      )
                    : widget.message.isError
                        ? LinearGradient(
                            colors: [
                              Colors.red.withOpacity(0.1),
                              Colors.red.withOpacity(0.05),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.grey.withOpacity(0.1),
                              Colors.grey.withOpacity(0.05),
                            ],
                          ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(widget.message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(widget.message.isUser ? 4 : 16),
                ),
                border: widget.message.isError
                    ? Border.all(color: Colors.red.withOpacity(0.3))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emotion indicator for user messages
                  if (widget.message.isUser && widget.message.emotion != null)
                    _buildEmotionIndicator(),
                  
                  // Message text
                  Text(
                    widget.message.text,
                    style: TextStyle(
                      color: widget.message.isUser 
                          ? Colors.white 
                          : widget.message.isError
                              ? Colors.red[700]
                              : Colors.black87,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            // Message metadata
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(widget.message.timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                  if (widget.message.isUser && widget.message.confidence != null)
                    ..._buildConfidenceIndicator(),
                ],
              ),
            ),
            
            // Action buttons
            if (_showActions)
              _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionIndicator() {
    final emotionData = _getEmotionData(widget.message.emotion!);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            emotionData['icon'],
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            emotionData['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConfidenceIndicator() {
    final confidence = widget.message.confidence!;
    final color = confidence > 0.7 
        ? Colors.green 
        : confidence > 0.5 
            ? Colors.orange 
            : Colors.red;
    
    return [
      const SizedBox(width: 8),
      Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        '${(confidence * 100).toInt()}%',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 10,
        ),
      ),
    ];
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            icon: Icons.copy,
            label: 'نسخ',
            onTap: () => widget.onMessageAction?.call('copy'),
          ),
          const SizedBox(width: 8),
          if (!widget.message.isUser) ...[
            _buildActionButton(
              icon: Icons.volume_up,
              label: 'استماع',
              onTap: () => widget.onMessageAction?.call('speak'),
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.refresh,
              label: 'إعادة توليد',
              onTap: () => widget.onMessageAction?.call('regenerate'),
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.thumb_up_outlined,
              label: 'مفيد',
              onTap: () => _rateMessage(true),
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.thumb_down_outlined,
              label: 'غير مفيد',
              onTap: () => _rateMessage(false),
            ),
            const SizedBox(width: 8),
          ],
          _buildActionButton(
            icon: Icons.share,
            label: 'مشاركة',
            onTap: () => _shareMessage(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: widget.message.suggestions!.map((suggestion) {
          return GestureDetector(
            onTap: () => widget.onSuggestionTap?.call(suggestion),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                suggestion,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
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

  Map<String, dynamic> _getEmotionData(String emotion) {
    final emotions = {
      'happy': {'name': 'سعيد', 'icon': Icons.sentiment_very_satisfied},
      'sad': {'name': 'حزين', 'icon': Icons.sentiment_very_dissatisfied},
      'angry': {'name': 'غاضب', 'icon': Icons.sentiment_dissatisfied},
      'anxious': {'name': 'قلق', 'icon': Icons.psychology},
      'calm': {'name': 'هادئ', 'icon': Icons.self_improvement},
      'neutral': {'name': 'محايد', 'icon': Icons.sentiment_neutral},
    };
    
    return emotions[emotion] ?? emotions['neutral']!;
  }

  void _copyMessage() {
    Clipboard.setData(ClipboardData(text: widget.message.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الرسالة'),
        duration: Duration(seconds: 1),
      ),
    );
    setState(() {
      _showActions = false;
    });
  }

  void _rateMessage(bool isHelpful) {
    widget.onMessageAction?.call(isHelpful ? 'helpful' : 'not_helpful');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isHelpful ? 'شكراً لتقييمك الإيجابي' : 'شكراً لملاحظاتك'),
        duration: const Duration(seconds: 1),
      ),
    );
    setState(() {
      _showActions = false;
    });
  }

  void _shareMessage() {
    // Implement share functionality
    widget.onMessageAction?.call('share');
    setState(() {
      _showActions = false;
    });
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _animations = List.generate(3, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index * 0.2,
          (index * 0.2) + 0.4,
          curve: Curves.easeInOut,
        ),
      ));
    });
    
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _animations[index],
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: Transform.scale(
                        scale: 0.5 + (_animations[index].value * 0.5),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}