import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/themes/app_theme.dart';

class ChatInputWidget extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function()? onVoiceToggle;
  final Function()? onAttachment;
  final bool isVoiceMode;
  final bool isLoading;
  final List<String> suggestions;

  const ChatInputWidget({
    super.key,
    required this.onSendMessage,
    this.onVoiceToggle,
    this.onAttachment,
    this.isVoiceMode = false,
    this.isLoading = false,
    this.suggestions = const [],
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  late AnimationController _voiceController;
  late AnimationController _sendController;
  late AnimationController _suggestionsController;
  
  late Animation<double> _voiceAnimation;
  late Animation<double> _sendAnimation;
  late Animation<double> _suggestionsAnimation;
  
  bool _isRecording = false;
  bool _showSuggestions = false;
  String _currentText = '';
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTextListener();
  }

  void _setupAnimations() {
    _voiceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _sendController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _suggestionsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _voiceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _voiceController,
      curve: Curves.easeInOut,
    ));
    
    _sendAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sendController,
      curve: Curves.elasticOut,
    ));
    
    _suggestionsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _suggestionsController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _setupTextListener() {
    _textController.addListener(() {
      final newText = _textController.text;
      if (newText != _currentText) {
        setState(() {
          _currentText = newText;
        });
        
        if (newText.isNotEmpty && !_sendController.isCompleted) {
          _sendController.forward();
        } else if (newText.isEmpty && _sendController.isCompleted) {
          _sendController.reverse();
        }
        
        _updateSuggestions(newText);
      }
    });
    
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.suggestions.isNotEmpty) {
        _showSuggestionsPanel();
      } else {
        _hideSuggestionsPanel();
      }
    });
  }

  void _updateSuggestions(String text) {
    if (text.isEmpty) {
      if (widget.suggestions.isNotEmpty) {
        _showSuggestionsPanel();
      }
    } else {
      _hideSuggestionsPanel();
    }
  }

  void _showSuggestionsPanel() {
    if (!_showSuggestions) {
      setState(() {
        _showSuggestions = true;
      });
      _suggestionsController.forward();
    }
  }

  void _hideSuggestionsPanel() {
    if (_showSuggestions) {
      _suggestionsController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _showSuggestions = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _voiceController.dispose();
    _sendController.dispose();
    _suggestionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Suggestions panel
        if (_showSuggestions)
          _buildSuggestionsPanel(),
        
        // Input area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Attachment button
                _buildAttachmentButton(),
                const SizedBox(width: 8),
                
                // Text input
                Expanded(
                  child: _buildTextInput(),
                ),
                const SizedBox(width: 8),
                
                // Voice/Send button
                _buildActionButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsPanel() {
    return AnimatedBuilder(
      animation: _suggestionsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _suggestionsAnimation.value) * 50),
          child: Opacity(
            opacity: _suggestionsAnimation.value,
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'اقتراحات للمحادثة',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.suggestions.length,
                      itemBuilder: (context, index) {
                        return _buildSuggestionChip(widget.suggestions[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _selectSuggestion(suggestion),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.primaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            suggestion,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return GestureDetector(
      onTap: widget.onAttachment,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.attach_file,
          color: Colors.grey[600],
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 40,
        maxHeight: 120,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _focusNode.hasFocus 
              ? AppTheme.primaryColor.withOpacity(0.5)
              : Colors.transparent,
        ),
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        maxLines: null,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          hintText: widget.isVoiceMode 
              ? 'اضغط للتحدث...' 
              : 'اكتب رسالتك هنا...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          height: 1.4,
        ),
        onSubmitted: (text) {
          if (text.trim().isNotEmpty) {
            _sendMessage();
          }
        },
      ),
    );
  }

  Widget _buildActionButton() {
    if (widget.isLoading) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
        ),
      );
    }

    if (_currentText.isNotEmpty) {
      return AnimatedBuilder(
        animation: _sendAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _sendAnimation.value,
            child: GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: widget.onVoiceToggle,
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      child: AnimatedBuilder(
        animation: _voiceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isRecording ? _voiceAnimation.value : 1.0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isRecording
                      ? [
                          Colors.red,
                          Colors.red.withOpacity(0.8),
                        ]
                      : widget.isVoiceMode
                          ? [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withOpacity(0.8),
                            ]
                          : [
                              Colors.grey.withOpacity(0.3),
                              Colors.grey.withOpacity(0.2),
                            ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _isRecording 
                    ? Icons.stop 
                    : widget.isVoiceMode 
                        ? Icons.mic 
                        : Icons.mic_none,
                color: _isRecording || widget.isVoiceMode 
                    ? Colors.white 
                    : Colors.grey[600],
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectSuggestion(String suggestion) {
    _textController.text = suggestion;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    _hideSuggestionsPanel();
    HapticFeedback.lightImpact();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _textController.clear();
      _hideSuggestionsPanel();
      HapticFeedback.lightImpact();
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
    });
    _voiceController.repeat(reverse: true);
    HapticFeedback.heavyImpact();
    
    // Simulate voice recording
    Future.delayed(const Duration(seconds: 3), () {
      if (_isRecording) {
        _stopRecording();
        _textController.text = 'مرحباً، هذا نص تم تحويله من الصوت';
      }
    });
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
    });
    _voiceController.stop();
    _voiceController.reset();
    HapticFeedback.lightImpact();
  }
}

class QuickActionsWidget extends StatelessWidget {
  final Function(String) onActionTap;
  
  const QuickActionsWidget({
    super.key,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'icon': Icons.mood,
        'label': 'تسجيل المزاج',
        'action': 'mood_tracking',
        'color': Colors.green,
      },
      {
        'icon': Icons.self_improvement,
        'label': 'تمرين تنفس',
        'action': 'breathing_exercise',
        'color': Colors.blue,
      },
      {
        'icon': Icons.psychology,
        'label': 'جلسة علاج',
        'action': 'therapy_session',
        'color': Colors.purple,
      },
      {
        'icon': Icons.analytics,
        'label': 'التقارير',
        'action': 'analytics',
        'color': Colors.orange,
      },
    ];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onActionTap(action['action'] as String),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (action['color'] as Color),
                          (action['color'] as Color).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['label'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}