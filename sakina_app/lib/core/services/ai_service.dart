import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

/// خدمة الذكاء الاصطناعي للتفاعل مع نماذج الذكاء الاصطناعي
class AiService {
  static AiService? _instance;
  static AiService get instance => _instance ??= AiService._();
  
  final Dio _dio;
  
  AiService._() : _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }
  
  /// توليد رد من الذكاء الاصطناعي
  Future<String> generateResponse(String prompt) async {
    try {
      // محاكاة استجابة الذكاء الاصطناعي
      // في التطبيق الحقيقي، ستتصل بـ API مثل OpenAI أو Google AI
      await Future.delayed(const Duration(seconds: 1));
      
      return _generateMockResponse(prompt);
    } catch (e) {
      if (kDebugMode) {
        print('Error generating AI response: $e');
      }
      return 'عذراً، لا أستطيع الرد في الوقت الحالي. يرجى المحاولة مرة أخرى.';
    }
  }
  
  /// توليد اقتراحات للمحادثة
  Future<List<String>> generateSuggestions(String context) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      return _generateMockSuggestions(context);
    } catch (e) {
      if (kDebugMode) {
        print('Error generating suggestions: $e');
      }
      return [];
    }
  }
  
  /// تحليل المشاعر من النص
  Future<Map<String, dynamic>> analyzeSentiment(String text) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      return _analyzeMockSentiment(text);
    } catch (e) {
      if (kDebugMode) {
        print('Error analyzing sentiment: $e');
      }
      return {
        'emotion': 'neutral',
        'confidence': 0.5,
        'positive': 0.5,
        'negative': 0.5,
      };
    }
  }
  
  /// توليد رد وهمي للاختبار
  String _generateMockResponse(String prompt) {
    final responses = [
      'أفهم مشاعرك، وأقدر ثقتك في مشاركتها معي. كيف يمكنني مساعدتك اليوم؟',
      'شكراً لك على المشاركة. هذا يتطلب شجاعة. ما الذي تشعر به الآن؟',
      'أسمعك وأفهم ما تمر به. هل تريد أن نتحدث أكثر عن هذا الموضوع؟',
      'مشاعرك مهمة ومفهومة. دعنا نعمل معاً على إيجاد طرق للتعامل معها.',
      'أقدر صراحتك معي. هل هناك شيء محدد تريد التركيز عليه؟',
    ];
    
    // اختيار رد بناءً على محتوى الرسالة
    if (prompt.contains('حزين') || prompt.contains('مكتئب')) {
      return 'أفهم أنك تمر بوقت صعب. الحزن شعور طبيعي، ومن المهم أن نتعامل معه بطريقة صحية. هل تريد أن نتحدث عما يجعلك تشعر بهذا الشكل؟';
    } else if (prompt.contains('قلق') || prompt.contains('خائف')) {
      return 'القلق شعور مفهوم، وكثير من الناس يمرون به. دعنا نعمل معاً على تقنيات للتهدئة والاسترخاء. هل تريد أن نجرب تمرين تنفس؟';
    } else if (prompt.contains('سعيد') || prompt.contains('جيد')) {
      return 'أسعدني أن أسمع أنك تشعر بالإيجابية! هذا رائع. هل تريد أن نتحدث عما يجعلك تشعر بهذا الشكل الجيد؟';
    }
    
    return responses[DateTime.now().millisecond % responses.length];
  }
  
  /// توليد اقتراحات وهمية
  List<String> _generateMockSuggestions(String context) {
    final suggestions = [
      'كيف كان يومك؟',
      'هل تريد أن نتحدث عن مشاعرك؟',
      'ما الذي يجعلك تشعر بالراحة؟',
      'هل جربت تمارين التأمل؟',
      'كيف تتعامل مع التوتر؟',
      'ما هي أهدافك للأسبوع القادم؟',
      'هل تريد نصائح للنوم الأفضل؟',
      'كيف يمكنني مساعدتك اليوم؟',
    ];
    
    suggestions.shuffle();
    return suggestions.take(3).toList();
  }
  
  /// تحليل وهمي للمشاعر
  Map<String, dynamic> _analyzeMockSentiment(String text) {
    final words = text.toLowerCase().split(' ');
    
    final positiveWords = ['سعيد', 'جيد', 'رائع', 'ممتاز', 'أحب', 'مبهج', 'متفائل'];
    final negativeWords = ['حزين', 'سيء', 'مكتئب', 'قلق', 'خائف', 'غاضب', 'محبط'];
    
    double positiveScore = 0;
    double negativeScore = 0;
    
    for (String word in words) {
      if (positiveWords.any((pw) => word.contains(pw))) positiveScore++;
      if (negativeWords.any((nw) => word.contains(nw))) negativeScore++;
    }
    
    String emotion = 'neutral';
    double confidence = 0.5;
    
    if (positiveScore > negativeScore) {
      emotion = 'positive';
      confidence = 0.7 + (positiveScore / words.length) * 0.3;
    } else if (negativeScore > positiveScore) {
      emotion = 'negative';
      confidence = 0.7 + (negativeScore / words.length) * 0.3;
    }
    
    return {
      'emotion': emotion,
      'confidence': confidence.clamp(0.0, 1.0),
      'positive': positiveScore / words.length,
      'negative': negativeScore / words.length,
      'neutral': 1.0 - ((positiveScore + negativeScore) / words.length),
    };
  }
}

/// نموذج رسالة المحادثة
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