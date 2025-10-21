import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/advanced_ai_provider.dart';

/// ويدجت اقتراحات الذكاء الاصطناعي
class AiSuggestionsWidget extends StatelessWidget {
  final Function(String)? onSuggestionTap;
  final bool showTitle;
  final EdgeInsetsGeometry? padding;
  
  const AiSuggestionsWidget({
    super.key,
    this.onSuggestionTap,
    this.showTitle = true,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AdvancedAiProvider>(
      builder: (context, provider, child) {
        if (provider.suggestions.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: padding ?? const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showTitle) ...[
                Text(
                  'اقتراحات مفيدة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.suggestions.map((suggestion) {
                  return _SuggestionChip(
                    suggestion: suggestion,
                    onTap: () => onSuggestionTap?.call(suggestion),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// شريحة الاقتراح
class _SuggestionChip extends StatelessWidget {
  final String suggestion;
  final VoidCallback? onTap;
  
  const _SuggestionChip({
    required this.suggestion,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                suggestion,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ويدجت اقتراحات سريعة
class QuickSuggestionsWidget extends StatelessWidget {
  final Function(String)? onSuggestionTap;
  
  const QuickSuggestionsWidget({
    super.key,
    this.onSuggestionTap,
  });
  
  static const List<String> quickSuggestions = [
    'كيف يمكنني تحسين مزاجي؟',
    'أشعر بالقلق، ما النصائح؟',
    'تمارين الاسترخاء',
    'كيف أتعامل مع التوتر؟',
    'نصائح للنوم الجيد',
    'تقنيات التأمل',
    'كيف أبني الثقة بالنفس؟',
    'التعامل مع الضغوط',
  ];
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اقتراحات سريعة',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: quickSuggestions.length,
            itemBuilder: (context, index) {
              final suggestion = quickSuggestions[index];
              return _QuickSuggestionCard(
                suggestion: suggestion,
                onTap: () => onSuggestionTap?.call(suggestion),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// بطاقة الاقتراح السريع
class _QuickSuggestionCard extends StatelessWidget {
  final String suggestion;
  final VoidCallback? onTap;
  
  const _QuickSuggestionCard({
    required this.suggestion,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Text(
              suggestion,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

/// ويدجت اقتراحات ذكية بناءً على السياق
class ContextualSuggestionsWidget extends StatelessWidget {
  final String? currentMood;
  final List<String>? recentTopics;
  final Function(String)? onSuggestionTap;
  
  const ContextualSuggestionsWidget({
    super.key,
    this.currentMood,
    this.recentTopics,
    this.onSuggestionTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final suggestions = _generateContextualSuggestions();
    
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'اقتراحات ذكية',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...suggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ContextualSuggestionTile(
              suggestion: suggestion,
              onTap: () => onSuggestionTap?.call(suggestion['text']!),
            ),
          )),
        ],
      ),
    );
  }
  
  List<Map<String, String>> _generateContextualSuggestions() {
    final suggestions = <Map<String, String>>[];
    
    // اقتراحات بناءً على المزاج
    if (currentMood != null) {
      switch (currentMood!.toLowerCase()) {
        case 'حزين':
        case 'مكتئب':
          suggestions.addAll([
            {
              'text': 'تمارين لتحسين المزاج',
              'icon': 'mood',
              'description': 'أنشطة تساعد في رفع المعنويات'
            },
            {
              'text': 'كيف أتعامل مع الحزن؟',
              'icon': 'help',
              'description': 'استراتيجيات للتعامل مع المشاعر السلبية'
            },
          ]);
          break;
        case 'قلق':
        case 'متوتر':
          suggestions.addAll([
            {
              'text': 'تقنيات تهدئة القلق',
              'icon': 'self_improvement',
              'description': 'طرق فعالة لتقليل التوتر'
            },
            {
              'text': 'تمارين التنفس العميق',
              'icon': 'air',
              'description': 'تقنيات التنفس للاسترخاء'
            },
          ]);
          break;
        case 'غاضب':
        case 'منزعج':
          suggestions.addAll([
            {
              'text': 'إدارة الغضب بطريقة صحية',
              'icon': 'psychology',
              'description': 'استراتيجيات للتحكم في الغضب'
            },
            {
              'text': 'تمارين الاسترخاء السريع',
              'icon': 'spa',
              'description': 'طرق سريعة للهدوء'
            },
          ]);
          break;
      }
    }
    
    // اقتراحات بناءً على المواضيع الأخيرة
    if (recentTopics != null && recentTopics!.isNotEmpty) {
      for (final topic in recentTopics!.take(2)) {
        if (topic.contains('نوم')) {
          suggestions.add({
            'text': 'نصائح لتحسين جودة النوم',
            'icon': 'bedtime',
            'description': 'عادات صحية للنوم الجيد'
          });
        } else if (topic.contains('عمل') || topic.contains('وظيفة')) {
          suggestions.add({
            'text': 'التوازن بين العمل والحياة',
            'icon': 'work_life_balance',
            'description': 'استراتيجيات لإدارة ضغوط العمل'
          });
        } else if (topic.contains('علاقة') || topic.contains('أصدقاء')) {
          suggestions.add({
            'text': 'تحسين العلاقات الاجتماعية',
            'icon': 'people',
            'description': 'مهارات التواصل الفعال'
          });
        }
      }
    }
    
    // اقتراحات عامة إذا لم تكن هناك اقتراحات محددة
    if (suggestions.isEmpty) {
      suggestions.addAll([
        {
          'text': 'تقييم الحالة النفسية',
          'icon': 'assessment',
          'description': 'فهم أفضل لحالتك النفسية'
        },
        {
          'text': 'خطة العناية الذاتية',
          'icon': 'favorite',
          'description': 'أنشطة للاهتمام بنفسك'
        },
      ]);
    }
    
    return suggestions.take(3).toList();
  }
}

/// بلاطة الاقتراح السياقي
class _ContextualSuggestionTile extends StatelessWidget {
  final Map<String, String> suggestion;
  final VoidCallback? onTap;
  
  const _ContextualSuggestionTile({
    required this.suggestion,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            _getIconData(suggestion['icon'] ?? 'lightbulb'),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          suggestion['text'] ?? '',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: suggestion['description'] != null
            ? Text(
                suggestion['description']!,
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
  
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'mood':
        return Icons.mood;
      case 'help':
        return Icons.help_outline;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'air':
        return Icons.air;
      case 'psychology':
        return Icons.psychology;
      case 'spa':
        return Icons.spa;
      case 'bedtime':
        return Icons.bedtime;
      case 'work_life_balance':
        return Icons.work_outline;
      case 'people':
        return Icons.people;
      case 'assessment':
        return Icons.assessment;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.lightbulb_outline;
    }
  }
}