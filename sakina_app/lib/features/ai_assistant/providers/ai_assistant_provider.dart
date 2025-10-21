import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../../../core/services/storage_service.dart';

class AIAssistantProvider extends ChangeNotifier {
  final AIService _aiService = AIService();
  final StorageService _storageService = StorageService();
  final Uuid _uuid = const Uuid();

  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isInitialized = false;
  String? _currentSessionId;

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get isInitialized => _isInitialized;
  String? get currentSessionId => _currentSessionId;

  Future<void> initializeChat() async {
    if (_isInitialized) return;

    try {
      // Load previous messages from storage
      await _loadPreviousMessages();
      
      // Create new session if no messages exist
      if (_messages.isEmpty) {
        _currentSessionId = _uuid.v4();
        await _addWelcomeMessage();
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing chat: $e');
    }
  }

  Future<void> _loadPreviousMessages() async {
    try {
      final messagesData = await _storageService.getMessages();
      _messages = messagesData.map((data) => ChatMessage.fromJson(data)).toList();
      
      // Sort messages by timestamp
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      debugPrint('Error loading previous messages: $e');
      _messages = [];
    }
  }

  Future<void> _addWelcomeMessage() async {
    final welcomeMessage = ChatMessage(
      id: _uuid.v4(),
      content: 'مرحباً بك في سكينة! أنا مساعدك الذكي المختص في الصحة النفسية. كيف يمكنني مساعدتك اليوم؟',
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      category: MessageCategory.general,
      suggestions: [
        'أشعر بالقلق',
        'أحتاج للتحدث عن مشاعري',
        'أريد تمارين الاسترخاء',
        'كيف أتعامل مع التوتر؟',
      ],
    );

    _messages.add(welcomeMessage);
    await _saveMessage(welcomeMessage);
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _isTyping) return;

    // Add user message
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
      category: _categorizeMessage(content),
    );

    _messages.add(userMessage);
    await _saveMessage(userMessage);
    notifyListeners();

    // Set typing indicator
    _isTyping = true;
    notifyListeners();

    try {
      // Get AI response
      final response = await _aiService.generateResponse(
        content,
        _messages,
        userMessage.category,
      );

      // Add assistant message
      final assistantMessage = ChatMessage(
        id: _uuid.v4(),
        content: response.content,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
        category: response.category,
        suggestions: response.suggestions,
        metadata: response.metadata,
      );

      _messages.add(assistantMessage);
      await _saveMessage(assistantMessage);
    } catch (e) {
      debugPrint('Error getting AI response: $e');
      
      // Add error message
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        content: 'عذراً، حدث خطأ في الاتصال. يرجى المحاولة مرة أخرى.',
        type: MessageType.assistant,
        timestamp: DateTime.now(),
        category: MessageCategory.general,
      );

      _messages.add(errorMessage);
      await _saveMessage(errorMessage);
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  MessageCategory _categorizeMessage(String content) {
    final lowerContent = content.toLowerCase();
    
    if (lowerContent.contains('قلق') || lowerContent.contains('خوف') || lowerContent.contains('توتر')) {
      return MessageCategory.anxiety;
    } else if (lowerContent.contains('حزن') || lowerContent.contains('اكتئاب') || lowerContent.contains('يأس')) {
      return MessageCategory.depression;
    } else if (lowerContent.contains('ضغط') || lowerContent.contains('إجهاد') || lowerContent.contains('عمل')) {
      return MessageCategory.stress;
    } else if (lowerContent.contains('مزاج') || lowerContent.contains('مشاعر') || lowerContent.contains('أحاسيس')) {
      return MessageCategory.mood;
    } else if (lowerContent.contains('تأمل') || lowerContent.contains('استرخاء') || lowerContent.contains('تنفس')) {
      return MessageCategory.meditation;
    } else if (lowerContent.contains('علاج') || lowerContent.contains('طبيب') || lowerContent.contains('معالج')) {
      return MessageCategory.therapy;
    } else if (lowerContent.contains('أزمة') || lowerContent.contains('طوارئ') || lowerContent.contains('انتحار')) {
      return MessageCategory.crisis;
    }
    
    return MessageCategory.general;
  }

  Future<void> _saveMessage(ChatMessage message) async {
    try {
      await _storageService.saveMessage(message.toJson());
    } catch (e) {
      debugPrint('Error saving message: $e');
    }
  }

  Future<void> clearChat() async {
    try {
      await _storageService.clearMessages();
      _messages.clear();
      _currentSessionId = _uuid.v4();
      await _addWelcomeMessage();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing chat: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      _messages.removeWhere((message) => message.id == messageId);
      await _storageService.deleteMessage(messageId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting message: $e');
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      final messageIndex = _messages.indexWhere((m) => m.id == messageId);
      if (messageIndex != -1) {
        _messages[messageIndex] = _messages[messageIndex].copyWith(isRead: true);
        await _saveMessage(_messages[messageIndex]);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking message as read: $e');
    }
  }

  List<ChatMessage> getMessagesByCategory(MessageCategory category) {
    return _messages.where((message) => message.category == category).toList();
  }

  int get unreadMessagesCount {
    return _messages.where((message) => 
        message.type == MessageType.assistant && !message.isRead
    ).length;
  }
}