import 'package:flutter/material.dart';

class AIAssistantProvider extends ChangeNotifier {
  bool _isLoading = false;
  final List<ChatMessage> _messages = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<ChatMessage> get messages => _messages;
  String? get errorMessage => _errorMessage;

  Future<void> sendMessage(String message) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // إضافة رسالة المستخدم
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));

      // محاكاة استجابة المساعد الذكي
      await Future.delayed(const Duration(seconds: 2));

      // إضافة رد المساعد
      _messages.add(ChatMessage(
        text: _generateResponse(message),
        isUser: false,
        timestamp: DateTime.now(),
      ));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'حدث خطأ في إرسال الرسالة';
      notifyListeners();
    }
  }

  String _generateResponse(String message) {
    // محاكاة ردود المساعد الذكي
    final responses = [
      'أفهم مشاعرك، وأنا هنا لمساعدتك. هل يمكنك إخباري المزيد عن ما تشعر به؟',
      'شكراً لك على مشاركة هذا معي. من المهم أن تعبر عن مشاعرك.',
      'أقدر ثقتك في مشاركة هذا معي. كيف يمكنني مساعدتك اليوم؟',
      'أنا هنا للاستماع إليك. هل تريد أن نتحدث عن استراتيجيات للتعامل مع هذا الشعور؟',
      'شعورك طبيعي ومفهوم. هل جربت تقنيات التنفس العميق من قبل؟',
    ];

    return responses[DateTime.now().millisecond % responses.length];
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
