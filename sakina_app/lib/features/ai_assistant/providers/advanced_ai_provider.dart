import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../../../core/services/ai_service.dart';

class AdvancedAiProvider with ChangeNotifier {
  final AiService _aiService;
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final bool _isTyping = false;
  String _currentEmotion = 'neutral';
  double _emotionConfidence = 0.0;
  Map<String, dynamic> _sentimentAnalysis = {};
  List<String> _aiSuggestions = [];
  bool _isVoiceMode = false;
  bool _isSpeaking = false;
  String _conversationContext = '';
  Map<String, dynamic> _userProfile = {};
  List<String> _conversationHistory = [];
  
  AdvancedAiProvider(this._aiService) {
    _loadConversationHistory();
    _loadUserProfile();
  }

  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String get currentEmotion => _currentEmotion;
  double get emotionConfidence => _emotionConfidence;
  Map<String, dynamic> get sentimentAnalysis => _sentimentAnalysis;
  List<String> get aiSuggestions => _aiSuggestions;
  List<String> get suggestions => _aiSuggestions;
  bool get isVoiceMode => _isVoiceMode;
  bool get isSpeaking => _isSpeaking;
  String get conversationContext => _conversationContext;
  Map<String, dynamic> get userProfile => _userProfile;

  // Send message with advanced processing
  Future<void> sendMessage(String text, {String? emotion}) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      emotion: emotion ?? _currentEmotion,
      confidence: _emotionConfidence,
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      // Analyze sentiment
      await _analyzeSentiment(text);
      
      // Update conversation context
      _updateConversationContext(text);
      
      // Generate AI response with context
      final response = await _generateContextualResponse(text);
      
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        suggestions: _generateFollowUpSuggestions(response),
      );

      _messages.add(aiMessage);
      
      // Generate new AI suggestions
      await _generateAiSuggestions();
      
      // Save conversation
      await _saveConversationHistory();
      
    } catch (e) {
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'عذراً، حدث خطأ في معالجة رسالتك. يرجى المحاولة مرة أخرى.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Analyze sentiment of user input
  Future<void> _analyzeSentiment(String text) async {
    try {
      // Simulate sentiment analysis
      final words = text.toLowerCase().split(' ');
      
      final positiveWords = ['سعيد', 'جيد', 'رائع', 'ممتاز', 'أحب', 'مبهج', 'متفائل'];
      final negativeWords = ['حزين', 'سيء', 'مكتئب', 'قلق', 'خائف', 'غاضب', 'محبط'];
      final anxiousWords = ['قلق', 'متوتر', 'خائف', 'مضطرب', 'عصبي'];
      
      double positiveScore = 0;
      double negativeScore = 0;
      double anxiousScore = 0;
      
      for (String word in words) {
        if (positiveWords.contains(word)) positiveScore++;
        if (negativeWords.contains(word)) negativeScore++;
        if (anxiousWords.contains(word)) anxiousScore++;
      }
      
      String detectedEmotion = 'neutral';
      double confidence = 0.5;
      
      if (positiveScore > negativeScore && positiveScore > anxiousScore) {
        detectedEmotion = 'happy';
        confidence = math.min(0.9, 0.6 + (positiveScore / words.length));
      } else if (negativeScore > positiveScore && negativeScore > anxiousScore) {
        detectedEmotion = 'sad';
        confidence = math.min(0.9, 0.6 + (negativeScore / words.length));
      } else if (anxiousScore > 0) {
        detectedEmotion = 'anxious';
        confidence = math.min(0.9, 0.6 + (anxiousScore / words.length));
      }
      
      _currentEmotion = detectedEmotion;
      _emotionConfidence = confidence;
      
      _sentimentAnalysis = {
        'emotion': detectedEmotion,
        'confidence': confidence,
        'positive_score': positiveScore,
        'negative_score': negativeScore,
        'anxious_score': anxiousScore,
        'text_length': words.length,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
    } catch (e) {
      print('Error analyzing sentiment: $e');
    }
  }

  // Generate contextual AI response
  Future<String> _generateContextualResponse(String userInput) async {
    try {
      final context = _buildConversationContext();
      final prompt = _buildPrompt(userInput, context);
      
      final response = await _aiService.generateResponse(prompt);
      return response;
    } catch (e) {
      return _generateFallbackResponse(userInput);
    }
  }

  // Build conversation context
  String _buildConversationContext() {
    final recentMessages = _messages.take(10).toList();
    final context = StringBuffer();
    
    context.writeln('السياق الحالي:');
    context.writeln('المشاعر المكتشفة: $_currentEmotion (ثقة: ${(_emotionConfidence * 100).toInt()}%)');
    
    if (_userProfile.isNotEmpty) {
      context.writeln('ملف المستخدم: ${_userProfile.toString()}');
    }
    
    context.writeln('الرسائل الأخيرة:');
    for (var message in recentMessages.reversed) {
      context.writeln('${message.isUser ? "المستخدم" : "المساعد"}: ${message.text}');
    }
    
    return context.toString();
  }

  // Build AI prompt
  String _buildPrompt(String userInput, String context) {
    return '''
أنت مساعد ذكي متخصص في الصحة النفسية والعلاج النفسي.
يجب أن تكون متعاطفاً ومفيداً ومهنياً.

$context

رسالة المستخدم الحالية: $userInput

يرجى الرد بطريقة مناسبة ومفيدة، مع مراعاة الحالة العاطفية للمستخدم.
''';
  }

  // Generate fallback response
  String _generateFallbackResponse(String userInput) {
    final responses = {
      'happy': [
        'أشعر بسعادتك! هذا رائع. كيف يمكنني مساعدتك اليوم؟',
        'يسعدني أن أراك في مزاج جيد! ما الذي تود التحدث عنه؟',
        'مزاجك الإيجابي معدي! كيف يمكنني دعمك؟',
      ],
      'sad': [
        'أفهم أنك تمر بوقت صعب. أنا هنا للاستماع إليك.',
        'أشعر بحزنك، وهذا أمر طبيعي. هل تريد التحدث عما يضايقك؟',
        'من الطبيعي أن نشعر بالحزن أحياناً. كيف يمكنني مساعدتك؟',
      ],
      'anxious': [
        'أشعر بقلقك. دعنا نتنفس معاً ونتحدث عما يقلقك.',
        'القلق شعور صعب. هل تريد أن نجرب بعض تقنيات الاسترخاء؟',
        'أفهم توترك. ما الذي يمكننا فعله لتهدئة هذا القلق؟',
      ],
      'neutral': [
        'أهلاً بك! كيف يمكنني مساعدتك اليوم؟',
        'مرحباً! ما الذي تود التحدث عنه؟',
        'أنا هنا للاستماع إليك. كيف حالك؟',
      ],
    };
    
    final emotionResponses = responses[_currentEmotion] ?? responses['neutral']!;
    final random = math.Random();
    return emotionResponses[random.nextInt(emotionResponses.length)];
  }

  // Generate AI suggestions
  Future<void> _generateAiSuggestions() async {
    final suggestions = <String>[];
    
    switch (_currentEmotion) {
      case 'happy':
        suggestions.addAll([
          'شاركني المزيد عن سبب سعادتك',
          'كيف يمكنك الحفاظ على هذا المزاج الإيجابي؟',
          'هل تريد تسجيل هذه اللحظة السعيدة؟',
        ]);
        break;
      case 'sad':
        suggestions.addAll([
          'هل تريد التحدث عن مشاعرك؟',
          'دعنا نجرب تمرين تنفس مهدئ',
          'ما رأيك في الاستماع لموسيقى هادئة؟',
        ]);
        break;
      case 'anxious':
        suggestions.addAll([
          'دعنا نجرب تقنية التأمل',
          'هل تريد تمرين استرخاء سريع؟',
          'ما رأيك في كتابة مخاوفك؟',
        ]);
        break;
      default:
        suggestions.addAll([
          'كيف كان يومك؟',
          'هل تريد تسجيل مزاجك؟',
          'ما رأيك في جلسة تأمل قصيرة؟',
        ]);
    }
    
    _aiSuggestions = suggestions;
  }

  // Generate follow-up suggestions
  List<String> _generateFollowUpSuggestions(String response) {
    return [
      'أخبرني المزيد',
      'كيف أشعر بذلك؟',
      'ما النصيحة التالية؟',
      'هل يمكنك مساعدتي أكثر؟',
    ];
  }

  // Update conversation context
  void _updateConversationContext(String userInput) {
    _conversationContext = userInput;
    _conversationHistory.add(userInput);
    
    // Keep only last 50 messages
    if (_conversationHistory.length > 50) {
      _conversationHistory.removeAt(0);
    }
  }

  // Voice mode functions
  void toggleVoiceMode() {
    _isVoiceMode = !_isVoiceMode;
    notifyListeners();
  }

  void setIsSpeaking(bool speaking) {
    _isSpeaking = speaking;
    notifyListeners();
  }

  // Update emotion
  void updateEmotion(String emotion, double confidence) {
    _currentEmotion = emotion;
    _emotionConfidence = confidence;
    notifyListeners();
  }

  // Clear conversation
  void clearConversation() {
    _messages.clear();
    _conversationHistory.clear();
    _conversationContext = '';
    _saveConversationHistory();
    notifyListeners();
  }

  // Save conversation history
  Future<void> _saveConversationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messages.map((m) => m.toJson()).toList();
      await prefs.setString('ai_conversation_history', jsonEncode(messagesJson));
      await prefs.setStringList('conversation_context', _conversationHistory);
    } catch (e) {
      print('Error saving conversation: $e');
    }
  }

  // Load conversation history
  Future<void> _loadConversationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesString = prefs.getString('ai_conversation_history');
      final contextList = prefs.getStringList('conversation_context');
      
      if (messagesString != null) {
        final messagesJson = jsonDecode(messagesString) as List;
        _messages = messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
      }
      
      if (contextList != null) {
        _conversationHistory = contextList;
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading conversation: $e');
    }
  }

  // Load user profile
  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileString = prefs.getString('user_profile');
      
      if (profileString != null) {
        _userProfile = jsonDecode(profileString);
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> profile) async {
    try {
      _userProfile = profile;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', jsonEncode(_userProfile));
      notifyListeners();
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  // Get conversation insights
  Map<String, dynamic> getConversationInsights() {
    final totalMessages = _messages.length;
    final userMessages = _messages.where((m) => m.isUser).length;
    final aiMessages = _messages.where((m) => !m.isUser).length;
    
    final emotionCounts = <String, int>{};
    for (var message in _messages.where((m) => m.isUser)) {
      final emotion = message.emotion ?? 'neutral';
      emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
    }
    
    return {
      'total_messages': totalMessages,
      'user_messages': userMessages,
      'ai_messages': aiMessages,
      'emotion_distribution': emotionCounts,
      'current_emotion': _currentEmotion,
      'emotion_confidence': _emotionConfidence,
      'conversation_length': _conversationHistory.length,
    };
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? emotion;
  final double? confidence;
  final List<String>? suggestions;
  final bool isError;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.emotion,
    this.confidence,
    this.suggestions,
    this.isError = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'emotion': emotion,
      'confidence': confidence,
      'suggestions': suggestions,
      'isError': isError,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      emotion: json['emotion'],
      confidence: json['confidence']?.toDouble(),
      suggestions: json['suggestions']?.cast<String>(),
      isError: json['isError'] ?? false,
    );
  }
}