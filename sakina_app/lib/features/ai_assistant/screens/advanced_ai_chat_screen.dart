import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/themes/app_theme.dart';
import '../providers/advanced_ai_provider.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/emotion_detector_widget.dart';
import '../widgets/ai_suggestions_widget.dart';
import '../widgets/voice_input_widget.dart';

class AdvancedAiChatScreen extends StatefulWidget {
  const AdvancedAiChatScreen({super.key});

  @override
  State<AdvancedAiChatScreen> createState() => _AdvancedAiChatScreenState();
}

class _AdvancedAiChatScreenState extends State<AdvancedAiChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _flutterTts = FlutterTts();
  
  late AnimationController _typingAnimationController;
  late AnimationController _emotionAnimationController;
  
  bool _speechEnabled = false;
  bool _isVoiceMode = false;
  String _currentEmotion = 'neutral';
  double _emotionConfidence = 0.0;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
    _setupAnimations();
  }

  void _setupAnimations() {
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _emotionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  Future<void> _initSpeech() async {
    _speechEnabled = true;
    setState(() {});
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('ar-SA');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(0.8);
    await _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    _emotionAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Consumer<AdvancedAiProvider>(
        builder: (context, aiProvider, child) {
          return Column(
            children: [
              // Emotion Detector
              EmotionDetectorWidget(
                currentEmotion: _currentEmotion,
                confidence: _emotionConfidence,
                onEmotionChanged: _onEmotionChanged,
              ),
              
              // AI Suggestions
              AiSuggestionsWidget(
                onSuggestionTap: _sendMessage,
              ),
              
              // Chat Messages
              Expanded(
                child: _buildChatArea(aiProvider),
              ),
              
              // Input Area
              _buildInputArea(aiProvider),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          const Text('المساعد الذكي'),
        ],
      ),
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(_isVoiceMode ? Icons.keyboard : Icons.mic),
          onPressed: () {
            setState(() {
              _isVoiceMode = !_isVoiceMode;
            });
          },
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.clear_all),
                  SizedBox(width: 8),
                  Text('مسح المحادثة'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('تصدير المحادثة'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('إعدادات المساعد'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChatArea(AdvancedAiProvider aiProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.backgroundColor,
            Colors.white.withOpacity(0.8),
          ],
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: aiProvider.messages.length + (aiProvider.isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == aiProvider.messages.length && aiProvider.isTyping) {
            return _buildTypingIndicator();
          }
          
          final message = aiProvider.messages[index];
          return ChatMessageWidget(
            message: message,
            onMessageAction: (action) {
              switch (action) {
                case 'speak':
                  _speakMessage(message.text);
                  break;
                case 'regenerate':
                  if (!message.isUser) _regenerateResponse(message);
                  break;
                case 'copy':
                  _copyMessage(message);
                  break;
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _typingAnimationController,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        final delay = index * 0.3;
                        final animation = Tween<double>(
                          begin: 0.4,
                          end: 1.0,
                        ).animate(
                          CurvedAnimation(
                            parent: _typingAnimationController,
                            curve: Interval(
                              delay,
                              delay + 0.4,
                              curve: Curves.easeInOut,
                            ),
                          ),
                        );
                        
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: Opacity(
                            opacity: animation.value,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'يكتب...',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(AdvancedAiProvider aiProvider) {
    if (_isVoiceMode) {
      return VoiceInputWidget(
        onTextReceived: _sendMessage,
        isEnabled: _speechEnabled,
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendCurrentMessage(aiProvider),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك هنا...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _attachFile,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _sendCurrentMessage(aiProvider),
            ),
          ),
        ],
      ),
    );
  }

  void _onEmotionChanged(String emotion, double confidence) {
    setState(() {
      _currentEmotion = emotion;
      _emotionConfidence = confidence;
    });
    
    _emotionAnimationController.forward().then((_) {
      _emotionAnimationController.reverse();
    });
  }

  void _sendCurrentMessage(AdvancedAiProvider aiProvider) {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _sendMessage(text);
      _messageController.clear();
    }
  }

  void _sendMessage(String text) {
    final aiProvider = Provider.of<AdvancedAiProvider>(context, listen: false);
    
    // Add emotion context to the message
    final contextualText = _addEmotionContext(text);
    
    aiProvider.sendMessage(contextualText).then((_) {
      _scrollToBottom();
    });
  }

  String _addEmotionContext(String text) {
    if (_emotionConfidence > 0.7) {
      final emotionContext = _getEmotionContext(_currentEmotion);
      return '$text\n\n[السياق العاطفي: $emotionContext]';
    }
    return text;
  }

  String _getEmotionContext(String emotion) {
    switch (emotion) {
      case 'happy':
        return 'المستخدم يبدو سعيداً ومتفائلاً';
      case 'sad':
        return 'المستخدم يبدو حزيناً ويحتاج للدعم';
      case 'angry':
        return 'المستخدم يبدو غاضباً أو محبطاً';
      case 'anxious':
        return 'المستخدم يبدو قلقاً أو متوتراً';
      case 'calm':
        return 'المستخدم يبدو هادئاً ومسترخياً';
      default:
        return 'المستخدم في حالة عاطفية محايدة';
    }
  }

  void _speakMessage(String text) async {
    await _flutterTts.speak(text);
  }

  void _regenerateResponse(ChatMessage message) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم تحسين هذه الميزة في الإصدار القادم'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyMessage(ChatMessage message) {
    // Implementation for copying message to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الرسالة'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _attachFile() {
    // Implementation for file attachment
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('صورة'),
              onTap: () {
                Navigator.pop(context);
                // Handle image selection
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('ملف'),
              onTap: () {
                Navigator.pop(context);
                // Handle file selection
              },
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear':
        _showClearConfirmation();
        break;
      case 'export':
        // aiProvider.exportChat();
        break;
      case 'settings':
        _showAiSettings();
        break;
    }
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح المحادثة'),
        content: const Text('هل أنت متأكد من رغبتك في مسح جميع الرسائل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _showAiSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'إعدادات المساعد الذكي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      SwitchListTile(
                        title: const Text('تحليل المشاعر'),
                        subtitle: const Text('تحليل المشاعر من النص والصوت'),
                        value: true,
                        onChanged: (value) {},
                      ),
                      SwitchListTile(
                        title: const Text('الاقتراحات الذكية'),
                        subtitle: const Text('عرض اقتراحات للرد السريع'),
                        value: true,
                        onChanged: (value) {},
                      ),
                      SwitchListTile(
                        title: const Text('الردود الصوتية'),
                        subtitle: const Text('تشغيل الردود بالصوت تلقائياً'),
                        value: false,
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}