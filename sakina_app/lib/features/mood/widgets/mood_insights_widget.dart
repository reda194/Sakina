import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../../../core/themes/app_theme.dart';

class MoodInsightsWidget extends StatefulWidget {
  final List<MoodEntry> moodEntries;

  const MoodInsightsWidget({
    super.key,
    required this.moodEntries,
  });

  @override
  State<MoodInsightsWidget> createState() => _MoodInsightsWidgetState();
}

class _MoodInsightsWidgetState extends State<MoodInsightsWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _selectedInsightIndex = 0;
  final PageController _pageController = PageController();
  
  List<MoodInsight> _insights = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generateInsights();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _fadeController.forward();
    _slideController.forward();
  }

  void _generateInsights() {
    if (widget.moodEntries.isEmpty) {
      _insights = [
        const MoodInsight(
          title: 'ابدأ رحلتك',
          description: 'سجل مزاجك يومياً للحصول على رؤى شخصية مفيدة',
          icon: Icons.psychology,
          color: AppTheme.primaryColor,
          type: InsightType.motivational,
        ),
      ];
      return;
    }
    
    _insights = [];
    
    // Mood trend analysis
    _analyzeMoodTrend();
    
    // Factor analysis
    _analyzeFactors();
    
    // Sleep correlation
    _analyzeSleepCorrelation();
    
    // Energy correlation
    _analyzeEnergyCorrelation();
    
    // Stress analysis
    _analyzeStress();
    
    // Weekly patterns
    _analyzeWeeklyPatterns();
    
    // Consistency analysis
    _analyzeConsistency();
    
    // Recommendations
    _generateRecommendations();
    
    // Sort insights by importance
    _insights.sort((a, b) => b.importance.compareTo(a.importance));
  }

  void _analyzeMoodTrend() {
    if (widget.moodEntries.length < 3) return;
    
    final recent = widget.moodEntries.take(7).toList();
    final older = widget.moodEntries.skip(7).take(7).toList();
    
    if (older.isEmpty) return;
    
    final recentAvg = recent.map((e) => e.mood).reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.map((e) => e.mood).reduce((a, b) => a + b) / older.length;
    
    final difference = recentAvg - olderAvg;
    
    if (difference > 0.5) {
      _insights.add(MoodInsight(
        title: 'تحسن ملحوظ! 📈',
        description: 'مزاجك يتحسن بمعدل ${difference.toStringAsFixed(1)} نقطة مقارنة بالأسبوع الماضي',
        icon: Icons.trending_up,
        color: Colors.green,
        type: InsightType.positive,
        importance: 9,
      ));
    } else if (difference < -0.5) {
      _insights.add(MoodInsight(
        title: 'انتبه لمزاجك 📉',
        description: 'مزاجك انخفض بمعدل ${(-difference).toStringAsFixed(1)} نقطة. حان وقت الاهتمام بنفسك',
        icon: Icons.trending_down,
        color: Colors.orange,
        type: InsightType.warning,
        importance: 8,
      ));
    } else {
      _insights.add(const MoodInsight(
        title: 'استقرار جيد 📊',
        description: 'مزاجك مستقر نسبياً. استمر في الحفاظ على روتينك الحالي',
        icon: Icons.timeline,
        color: Colors.blue,
        type: InsightType.neutral,
        importance: 5,
      ));
    }
  }

  void _analyzeFactors() {
    final factorCounts = <String, int>{};
    final factorMoodSum = <String, double>{};
    
    for (var entry in widget.moodEntries) {
      for (var factor in entry.factors) {
        factorCounts[factor] = (factorCounts[factor] ?? 0) + 1;
        factorMoodSum[factor] = (factorMoodSum[factor] ?? 0) + entry.mood;
      }
    }
    
    if (factorCounts.isEmpty) return;
    
    // Find most positive factor
    String? bestFactor;
    double bestAverage = 0;
    
    factorCounts.forEach((factor, count) {
      if (count >= 3) { // Only consider factors with at least 3 occurrences
        final average = factorMoodSum[factor]! / count;
        if (average > bestAverage) {
          bestAverage = average;
          bestFactor = factor;
        }
      }
    });
    
    if (bestFactor != null && bestAverage > 3.5) {
      _insights.add(MoodInsight(
        title: 'عامل إيجابي قوي! ✨',
        description: '$bestFactor يحسن مزاجك بمعدل ${bestAverage.toStringAsFixed(1)}/5',
        icon: Icons.star,
        color: Colors.amber,
        type: InsightType.positive,
        importance: 7,
      ));
    }
    
    // Find most negative factor
    String? worstFactor;
    double worstAverage = 5;
    
    factorCounts.forEach((factor, count) {
      if (count >= 3) {
        final average = factorMoodSum[factor]! / count;
        if (average < worstAverage) {
          worstAverage = average;
          worstFactor = factor;
        }
      }
    });
    
    if (worstFactor != null && worstAverage < 2.5) {
      _insights.add(MoodInsight(
        title: 'عامل سلبي ⚠️',
        description: '$worstFactor يؤثر سلباً على مزاجك (${worstAverage.toStringAsFixed(1)}/5)',
        icon: Icons.warning,
        color: Colors.red,
        type: InsightType.warning,
        importance: 8,
      ));
    }
  }

  void _analyzeSleepCorrelation() {
    if (widget.moodEntries.length < 5) return;
    
    final goodSleepEntries = widget.moodEntries.where((e) => e.sleep >= 4).toList();
    final poorSleepEntries = widget.moodEntries.where((e) => e.sleep <= 2).toList();
    
    if (goodSleepEntries.length >= 3 && poorSleepEntries.length >= 3) {
      final goodSleepMood = goodSleepEntries.map((e) => e.mood).reduce((a, b) => a + b) / goodSleepEntries.length;
      final poorSleepMood = poorSleepEntries.map((e) => e.mood).reduce((a, b) => a + b) / poorSleepEntries.length;
      
      final difference = goodSleepMood - poorSleepMood;
      
      if (difference > 1.0) {
        _insights.add(MoodInsight(
          title: 'النوم مفتاح السعادة! 😴',
          description: 'النوم الجيد يحسن مزاجك بـ ${difference.toStringAsFixed(1)} نقطة',
          icon: Icons.bedtime,
          color: Colors.indigo,
          type: InsightType.positive,
          importance: 7,
        ));
      }
    }
  }

  void _analyzeEnergyCorrelation() {
    if (widget.moodEntries.length < 5) return;
    
    final highEnergyEntries = widget.moodEntries.where((e) => e.energy >= 4).toList();
    final lowEnergyEntries = widget.moodEntries.where((e) => e.energy <= 2).toList();
    
    if (highEnergyEntries.length >= 3 && lowEnergyEntries.length >= 3) {
      final highEnergyMood = highEnergyEntries.map((e) => e.mood).reduce((a, b) => a + b) / highEnergyEntries.length;
      final lowEnergyMood = lowEnergyEntries.map((e) => e.mood).reduce((a, b) => a + b) / lowEnergyEntries.length;
      
      final difference = highEnergyMood - lowEnergyMood;
      
      if (difference > 1.0) {
        _insights.add(MoodInsight(
          title: 'الطاقة = السعادة! ⚡',
          description: 'الطاقة العالية ترفع مزاجك بـ ${difference.toStringAsFixed(1)} نقطة',
          icon: Icons.bolt,
          color: Colors.yellow[700]!,
          type: InsightType.positive,
          importance: 6,
        ));
      }
    }
  }

  void _analyzeStress() {
    if (widget.moodEntries.length < 5) return;
    
    final highStressEntries = widget.moodEntries.where((e) => e.stress >= 4).toList();
    final lowStressEntries = widget.moodEntries.where((e) => e.stress <= 2).toList();
    
    if (highStressEntries.length >= 3) {
      final stressPercentage = (highStressEntries.length / widget.moodEntries.length * 100).round();
      
      if (stressPercentage > 40) {
        _insights.add(MoodInsight(
          title: 'مستوى توتر عالي! 😰',
          description: 'أنت متوتر في $stressPercentage% من الوقت. حان وقت الاسترخاء',
          icon: Icons.psychology,
          color: Colors.red,
          type: InsightType.warning,
          importance: 9,
        ));
      }
    }
    
    if (lowStressEntries.length >= 5) {
      final calmPercentage = (lowStressEntries.length / widget.moodEntries.length * 100).round();
      
      if (calmPercentage > 60) {
        _insights.add(MoodInsight(
          title: 'هدوء رائع! 🧘‍♀️',
          description: 'أنت هادئ في $calmPercentage% من الوقت. استمر هكذا!',
          icon: Icons.self_improvement,
          color: Colors.teal,
          type: InsightType.positive,
          importance: 6,
        ));
      }
    }
  }

  void _analyzeWeeklyPatterns() {
    if (widget.moodEntries.length < 7) return;
    
    final weekdayMoods = <int, List<double>>{};
    
    for (var entry in widget.moodEntries) {
      final weekday = entry.timestamp.weekday;
      weekdayMoods[weekday] = (weekdayMoods[weekday] ?? [])..add(entry.mood.toDouble());
    }
    
    int? bestDay;
    int? worstDay;
    double bestAverage = 0;
    double worstAverage = 5;
    
    weekdayMoods.forEach((day, moods) {
      if (moods.length >= 2) {
        final average = moods.reduce((a, b) => a + b) / moods.length;
        if (average > bestAverage) {
          bestAverage = average;
          bestDay = day;
        }
        if (average < worstAverage) {
          worstAverage = average;
          worstDay = day;
        }
      }
    });
    
    if (bestDay != null && worstDay != null && bestDay != worstDay) {
      final bestDayName = _getDayName(bestDay!);
      final worstDayName = _getDayName(worstDay!);
      
      _insights.add(MoodInsight(
        title: 'نمط أسبوعي 📅',
        description: 'أفضل أيامك: $bestDayName (${bestAverage.toStringAsFixed(1)})\nأصعب أيامك: $worstDayName (${worstAverage.toStringAsFixed(1)})',
        icon: Icons.calendar_view_week,
        color: Colors.purple,
        type: InsightType.neutral,
        importance: 5,
      ));
    }
  }

  void _analyzeConsistency() {
    if (widget.moodEntries.length < 7) return;
    
    final recent7Days = DateTime.now().subtract(const Duration(days: 7));
    final recentEntries = widget.moodEntries
        .where((e) => e.timestamp.isAfter(recent7Days))
        .length;
    
    final consistencyPercentage = (recentEntries / 7 * 100).round();
    
    if (consistencyPercentage >= 80) {
      _insights.add(MoodInsight(
        title: 'انتظام ممتاز! 🎯',
        description: 'سجلت مزاجك $consistencyPercentage% من الأسبوع الماضي',
        icon: Icons.check_circle,
        color: Colors.green,
        type: InsightType.positive,
        importance: 6,
      ));
    } else if (consistencyPercentage < 50) {
      _insights.add(MoodInsight(
        title: 'حاول الانتظام أكثر 📝',
        description: 'سجلت مزاجك $consistencyPercentage% فقط من الأسبوع الماضي',
        icon: Icons.schedule,
        color: Colors.orange,
        type: InsightType.motivational,
        importance: 4,
      ));
    }
  }

  void _generateRecommendations() {
    final recentEntries = widget.moodEntries.take(7).toList();
    
    if (recentEntries.isEmpty) return;
    
    final averageMood = recentEntries.map((e) => e.mood).reduce((a, b) => a + b) / recentEntries.length;
    final averageStress = recentEntries.map((e) => e.stress).reduce((a, b) => a + b) / recentEntries.length;
    final averageSleep = recentEntries.map((e) => e.sleep).reduce((a, b) => a + b) / recentEntries.length;
    
    if (averageMood < 3) {
      _insights.add(const MoodInsight(
        title: 'اقتراح للتحسين 💡',
        description: 'جرب ممارسة الرياضة أو التأمل لمدة 10 دقائق يومياً',
        icon: Icons.lightbulb,
        color: Colors.cyan,
        type: InsightType.recommendation,
        importance: 7,
      ));
    }
    
    if (averageStress > 3.5) {
      _insights.add(const MoodInsight(
        title: 'تقليل التوتر 🌱',
        description: 'جرب تقنيات التنفس العميق أو اليوغا',
        icon: Icons.spa,
        color: Colors.green,
        type: InsightType.recommendation,
        importance: 8,
      ));
    }
    
    if (averageSleep < 3) {
      _insights.add(const MoodInsight(
        title: 'تحسين النوم 🌙',
        description: 'حاول النوم والاستيقاظ في أوقات ثابتة',
        icon: Icons.bedtime,
        color: Colors.indigo,
        type: InsightType.recommendation,
        importance: 7,
      ));
    }
  }

  String _getDayName(int weekday) {
    const days = {
      1: 'الاثنين',
      2: 'الثلاثاء',
      3: 'الأربعاء',
      4: 'الخميس',
      5: 'الجمعة',
      6: 'السبت',
      7: 'الأحد',
    };
    return days[weekday] ?? 'غير معروف';
  }

  @override
  void didUpdateWidget(MoodInsightsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.moodEntries != widget.moodEntries) {
      _generateInsights();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildInsightCards(),
            if (_insights.length > 1) ...[
              const SizedBox(height: 16),
              _buildPageIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.psychology,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        const Text(
          'رؤى ذكية',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (_insights.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_insights.length} رؤية',
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInsightCards() {
    if (_insights.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insights,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'سجل المزيد من البيانات\nللحصول على رؤى شخصية',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedInsightIndex = index;
          });
        },
        itemCount: _insights.length,
        itemBuilder: (context, index) {
          return _buildInsightCard(_insights[index]);
        },
      ),
    );
  }

  Widget _buildInsightCard(MoodInsight insight) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            insight.color.withOpacity(0.1),
            insight.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: insight.color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: insight.color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: insight.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  insight.icon,
                  color: insight.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  insight.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: insight.color,
                  ),
                ),
              ),
              _buildInsightTypeBadge(insight.type),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              insight.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
          
          // Importance indicator
          Row(
            children: [
              ...List.generate(5, (index) {
                return Container(
                  margin: const EdgeInsets.only(right: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index < (insight.importance / 2).round()
                        ? insight.color
                        : insight.color.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text(
                'أهمية: ${insight.importance}/10',
                style: TextStyle(
                  fontSize: 10,
                  color: insight.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightTypeBadge(InsightType type) {
    String text;
    Color color;
    
    switch (type) {
      case InsightType.positive:
        text = 'إيجابي';
        color = Colors.green;
        break;
      case InsightType.warning:
        text = 'تحذير';
        color = Colors.orange;
        break;
      case InsightType.neutral:
        text = 'معلومة';
        color = Colors.blue;
        break;
      case InsightType.recommendation:
        text = 'اقتراح';
        color = Colors.purple;
        break;
      case InsightType.motivational:
        text = 'تحفيز';
        color = Colors.cyan;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_insights.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _selectedInsightIndex == index ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _selectedInsightIndex == index
                ? AppTheme.primaryColor
                : AppTheme.primaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class MoodInsight {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final InsightType type;
  final int importance;

  const MoodInsight({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    this.importance = 5,
  });
}

enum InsightType {
  positive,
  warning,
  neutral,
  recommendation,
  motivational,
}