import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';

class AIResponse {
  final String content;
  final MessageCategory category;
  final List<String> suggestions;
  final Map<String, dynamic>? metadata;

  AIResponse({
    required this.content,
    required this.category,
    this.suggestions = const [],
    this.metadata,
  });
}

class AIService {
  final Random _random = Random();
  
  // Predefined responses for different categories
  final Map<MessageCategory, List<String>> _responses = {
    MessageCategory.anxiety: [
      'أفهم شعورك بالقلق. هذا أمر طبيعي ويمكن التعامل معه. هل تريد أن نجرب تمرين تنفس بسيط؟',
      'القلق جزء من الحياة، لكن يمكننا تعلم كيفية إدارته. ما الذي يسبب لك القلق تحديداً؟',
      'عندما نشعر بالقلق، جسمنا يحاول حمايتنا. دعنا نعمل معاً على تهدئة هذا الشعور.',
    ],
    MessageCategory.depression: [
      'أقدر شجاعتك في التحدث عن مشاعرك. الحزن والاكتئاب أمور يمكن التعامل معها بالدعم المناسب.',
      'مشاعرك مهمة ومفهومة. هل تريد أن نتحدث عما يجعلك تشعر بهذا الشكل؟',
      'أنت لست وحدك في هذا الشعور. دعنا نعمل معاً على إيجاد طرق للتحسن.',
    ],
    MessageCategory.stress: [
      'الضغط والتوتر جزء من الحياة العصرية. المهم هو كيف نتعامل معه. ما مصادر التوتر في حياتك؟',
      'أفهم أن الضغط يمكن أن يكون مرهقاً. هل جربت تقنيات الاسترخاء من قبل؟',
      'التوتر إشارة من جسمك أنه يحتاج للراحة. دعنا نجد طرق صحية للتعامل معه.',
    ],
    MessageCategory.mood: [
      'مشاعرك طبيعية ومهمة. كل إنسان يمر بتقلبات مزاجية. كيف تشعر الآن تحديداً؟',
      'تتبع المزاج يساعدنا على فهم أنفسنا أكثر. ما الذي أثر على مزاجك اليوم؟',
      'المشاعر مثل الطقس، تتغير وتمر. دعنا نتحدث عما تشعر به.',
    ],
    MessageCategory.meditation: [
      'التأمل والاسترخاء من أفضل الطرق للعناية بالصحة النفسية. هل تريد تمرين تأمل موجه؟',
      'ممتاز! التنفس العميق يساعد على تهدئة العقل والجسم. دعنا نبدأ بتمرين بسيط.',
      'الاسترخاء مهارة يمكن تعلمها وتطويرها. سأرشدك خلال بعض التقنيات المفيدة.',
    ],
    MessageCategory.therapy: [
      'طلب المساعدة المهنية خطوة شجاعة ومهمة. يمكنني مساعدتك في العثور على المعالج المناسب.',
      'العلاج النفسي فعال جداً في تحسين الصحة النفسية. ما نوع الدعم الذي تبحث عنه؟',
      'المعالجون المختصون يمكنهم تقديم دعم متخصص. هل تريد معلومات عن أنواع العلاج المختلفة؟',
    ],
    MessageCategory.crisis: [
      'أقدر ثقتك في التحدث معي. إذا كنت تواجه أزمة، من المهم طلب المساعدة الفورية من المختصين.',
      'سلامتك أهم شيء. إذا كنت في خطر، يرجى الاتصال بخط المساعدة الطارئة أو التوجه لأقرب مستشفى.',
      'أنت مهم وحياتك لها قيمة. دعني أساعدك في العثور على الدعم المناسب فوراً.',
    ],
    MessageCategory.general: [
      'أهلاً بك! كيف يمكنني مساعدتك اليوم؟',
      'أنا هنا للاستماع ومساعدتك. ما الذي تريد التحدث عنه؟',
      'شكراً لك على التواصل معي. كيف تشعر اليوم؟',
    ],
  };

  final Map<MessageCategory, List<String>> _suggestions = {
    MessageCategory.anxiety: [
      'علمني تمرين تنفس',
      'كيف أتعامل مع نوبة القلق؟',
      'ما هي أعراض القلق؟',
      'تمارين الاسترخاء',
    ],
    MessageCategory.depression: [
      'كيف أحسن مزاجي؟',
      'أنشطة تساعد على التحسن',
      'متى أطلب مساعدة مهنية؟',
      'تمارين رياضية للمزاج',
    ],
    MessageCategory.stress: [
      'تقنيات إدارة الوقت',
      'كيف أقلل التوتر في العمل؟',
      'تمارين الاسترخاء السريعة',
      'نصائح للنوم الجيد',
    ],
    MessageCategory.mood: [
      'كيف أتتبع مزاجي؟',
      'ما يؤثر على المزاج؟',
      'أنشطة تحسن المزاج',
      'التعامل مع تقلبات المزاج',
    ],
    MessageCategory.meditation: [
      'تمرين تأمل للمبتدئين',
      'تأمل لمدة 5 دقائق',
      'تقنيات التنفس العميق',
      'تأمل قبل النوم',
    ],
    MessageCategory.therapy: [
      'أنواع العلاج النفسي',
      'كيف أختار معالج؟',
      'ما أتوقعه من الجلسة الأولى؟',
      'العلاج عبر الإنترنت',
    ],
    MessageCategory.crisis: [
      'أرقام الطوارئ',
      'كيف أطلب مساعدة فورية؟',
      'علامات الخطر',
      'دعم الأزمات',
    ],
    MessageCategory.general: [
      'أشعر بالقلق',
      'أريد تحسين مزاجي',
      'تمارين الاسترخاء',
      'كيف أتعامل مع التوتر؟',
    ],
  };

  Future<AIResponse> generateResponse(
    String userMessage,
    List<ChatMessage> conversationHistory,
    MessageCategory category,
  ) async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 1000 + _random.nextInt(2000)));

    try {
      // Handle crisis messages with priority
      if (category == MessageCategory.crisis) {
        return _generateCrisisResponse(userMessage);
      }

      // Generate contextual response based on conversation history
      final response = _generateContextualResponse(userMessage, category, conversationHistory);
      
      return AIResponse(
        content: response,
        category: category,
        suggestions: _getSuggestions(category),
        metadata: {
          'timestamp': DateTime.now().toIso8601String(),
          'confidence': _random.nextDouble() * 0.3 + 0.7, // 0.7-1.0
          'response_time': _random.nextInt(2000) + 1000,
        },
      );
    } catch (e) {
      debugPrint('Error generating AI response: $e');
      return AIResponse(
        content: 'عذراً، حدث خطأ في معالجة رسالتك. يرجى المحاولة مرة أخرى.',
        category: MessageCategory.general,
      );
    }
  }

  AIResponse _generateCrisisResponse(String userMessage) {
    return AIResponse(
      content: 'أقدر ثقتك في التحدث معي. إذا كنت تواجه أزمة نفسية أو تفكر في إيذاء نفسك، يرجى الاتصال فوراً بخط المساعدة النفسية على الرقم: 920033360 أو التوجه لأقرب مستشفى. حياتك مهمة وهناك من يهتم بك.',
      category: MessageCategory.crisis,
      suggestions: [
        'أرقام الطوارئ',
        'مراكز الدعم النفسي',
        'كيف أطلب مساعدة فورية؟',
        'أريد التحدث مع مختص',
      ],
      metadata: {
        'priority': 'high',
        'requires_immediate_attention': true,
        'emergency_contacts': [
          {'name': 'خط المساعدة النفسية', 'number': '920033360'},
          {'name': 'الطوارئ', 'number': '997'},
        ],
      },
    );
  }

  String _generateContextualResponse(
    String userMessage,
    MessageCategory category,
    List<ChatMessage> history,
  ) {
    final responses = _responses[category] ?? _responses[MessageCategory.general]!;
    
    // Check if this is a follow-up question
    if (history.length > 1) {
      final lastAssistantMessage = history
          .where((m) => m.type == MessageType.assistant)
          .lastOrNull;
      
      if (lastAssistantMessage != null) {
        // Generate follow-up response
        return _generateFollowUpResponse(userMessage, category, lastAssistantMessage);
      }
    }
    
    // Return random response from category
    return responses[_random.nextInt(responses.length)];
  }

  String _generateFollowUpResponse(
    String userMessage,
    MessageCategory category,
    ChatMessage lastMessage,
  ) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('نعم') || lowerMessage.contains('أريد') || lowerMessage.contains('موافق')) {
      switch (category) {
        case MessageCategory.anxiety:
          return 'ممتاز! سنبدأ بتمرين التنفس العميق. اجلس بوضعية مريحة، أغلق عينيك، وتنفس ببطء من الأنف لمدة 4 ثوان، احبس النفس لثانيتين، ثم أخرج الهواء من الفم لمدة 6 ثوان. كرر هذا 5 مرات.';
        case MessageCategory.meditation:
          return 'رائع! دعنا نبدأ بتمرين تأمل بسيط. اجلس بوضعية مريحة، أغلق عينيك، وركز على تنفسك الطبيعي. عندما تلاحظ أن عقلك يتشتت، أعد تركيزك بلطف على التنفس.';
        default:
          return 'شكراً لك على اهتمامك. دعنا نتابع معاً خطوة بخطوة.';
      }
    } else if (lowerMessage.contains('لا') || lowerMessage.contains('ليس')) {
      return 'لا بأس، يمكننا تجربة شيء آخر. ما الذي تشعر بالراحة في تجربته؟';
    }
    
    // Default follow-up
    final responses = _responses[category] ?? _responses[MessageCategory.general]!;
    return responses[_random.nextInt(responses.length)];
  }

  List<String> _getSuggestions(MessageCategory category) {
    final suggestions = _suggestions[category] ?? _suggestions[MessageCategory.general]!;
    
    // Return 3-4 random suggestions
    final shuffled = List<String>.from(suggestions)..shuffle(_random);
    return shuffled.take(3 + _random.nextInt(2)).toList();
  }

  // Method to analyze user sentiment (basic implementation)
  double analyzeSentiment(String message) {
    final positiveWords = ['سعيد', 'جيد', 'ممتاز', 'رائع', 'أحسن', 'مرتاح'];
    final negativeWords = ['حزين', 'سيء', 'قلق', 'خائف', 'متعب', 'مكتئب'];
    
    final words = message.toLowerCase().split(' ');
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (final word in words) {
      if (positiveWords.any((pw) => word.contains(pw))) {
        positiveCount++;
      } else if (negativeWords.any((nw) => word.contains(nw))) {
        negativeCount++;
      }
    }
    
    if (positiveCount + negativeCount == 0) return 0.0;
    return (positiveCount - negativeCount) / (positiveCount + negativeCount);
  }
}