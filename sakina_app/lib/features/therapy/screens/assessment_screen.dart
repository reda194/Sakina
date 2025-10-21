import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/therapy_program_model.dart';
import '../providers/therapy_provider.dart';
import '../../../widgets/loading_button.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  final Map<String, dynamic> _answers = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقييم الأولي'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildWelcomePage(),
                _buildQuestionPage(
                  'كيف تشعر بشكل عام؟',
                  'mood_general',
                  [
                    {'value': 'excellent', 'text': 'ممتاز'},
                    {'value': 'good', 'text': 'جيد'},
                    {'value': 'fair', 'text': 'متوسط'},
                    {'value': 'poor', 'text': 'سيء'},
                    {'value': 'very_poor', 'text': 'سيء جداً'},
                  ],
                ),
                _buildQuestionPage(
                  'ما مستوى التوتر الذي تشعر به؟',
                  'stress_level',
                  [
                    {'value': 'none', 'text': 'لا يوجد توتر'},
                    {'value': 'mild', 'text': 'توتر خفيف'},
                    {'value': 'moderate', 'text': 'توتر متوسط'},
                    {'value': 'high', 'text': 'توتر عالي'},
                    {'value': 'severe', 'text': 'توتر شديد'},
                  ],
                ),
                _buildQuestionPage(
                  'هل تواجه صعوبة في النوم؟',
                  'sleep_issues',
                  [
                    {'value': 'never', 'text': 'أبداً'},
                    {'value': 'rarely', 'text': 'نادراً'},
                    {'value': 'sometimes', 'text': 'أحياناً'},
                    {'value': 'often', 'text': 'غالباً'},
                    {'value': 'always', 'text': 'دائماً'},
                  ],
                ),
                _buildQuestionPage(
                  'كيف تقيم علاقاتك الاجتماعية؟',
                  'social_relationships',
                  [
                    {'value': 'excellent', 'text': 'ممتازة'},
                    {'value': 'good', 'text': 'جيدة'},
                    {'value': 'fair', 'text': 'متوسطة'},
                    {'value': 'poor', 'text': 'ضعيفة'},
                    {'value': 'very_poor', 'text': 'ضعيفة جداً'},
                  ],
                ),
                _buildQuestionPage(
                  'ما مستوى ثقتك بنفسك؟',
                  'self_confidence',
                  [
                    {'value': 'very_high', 'text': 'عالية جداً'},
                    {'value': 'high', 'text': 'عالية'},
                    {'value': 'moderate', 'text': 'متوسطة'},
                    {'value': 'low', 'text': 'منخفضة'},
                    {'value': 'very_low', 'text': 'منخفضة جداً'},
                  ],
                ),
                _buildQuestionPage(
                  'هل تشعر بالقلق بشكل متكرر؟',
                  'anxiety_frequency',
                  [
                    {'value': 'never', 'text': 'أبداً'},
                    {'value': 'rarely', 'text': 'نادراً'},
                    {'value': 'sometimes', 'text': 'أحياناً'},
                    {'value': 'often', 'text': 'غالباً'},
                    {'value': 'always', 'text': 'دائماً'},
                  ],
                ),
                _buildQuestionPage(
                  'ما هو هدفك الأساسي من العلاج؟',
                  'therapy_goal',
                  [
                    {'value': 'reduce_stress', 'text': 'تقليل التوتر'},
                    {'value': 'improve_mood', 'text': 'تحسين المزاج'},
                    {'value': 'better_sleep', 'text': 'تحسين النوم'},
                    {'value': 'social_skills', 'text': 'تطوير المهارات الاجتماعية'},
                    {'value': 'self_esteem', 'text': 'زيادة الثقة بالنفس'},
                    {'value': 'anxiety_management', 'text': 'إدارة القلق'},
                  ],
                ),
                _buildResultsPage(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    const totalPages = 8; // Welcome + 6 questions + Results
    final progress = _currentPage / (totalPages - 1);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السؤال ${_currentPage == 0 || _currentPage == totalPages - 1 ? '' : '$_currentPage من ${totalPages - 2}'}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.backgroundColor,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.assessment,
              color: AppTheme.primaryColor,
              size: 60,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'مرحباً بك في التقييم الأولي',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'سنطرح عليك بعض الأسئلة البسيطة لفهم احتياجاتك وتوصية البرامج العلاجية الأنسب لك.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.infoColor.withOpacity(0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.infoColor,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'جميع إجاباتك محمية ومشفرة ولن تُشارك مع أي طرف ثالث',
                    style: TextStyle(
                      color: AppTheme.infoColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(
    String question,
    String key,
    List<Map<String, String>> options,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            question,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = _answers[key] == option['value'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _answers[key] = option['value'];
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.backgroundColor,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.textSecondary,
                                width: 2,
                              ),
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 12,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option['text']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsPage() {
    return Consumer<TherapyProvider>(
      builder: (context, provider, child) {
        final recommendations = _getRecommendations();

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'تم إكمال التقييم بنجاح!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'بناءً على إجاباتك، إليك البرامج الموصى بها لك:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    final program = recommendations[index];
                    return _buildRecommendationCard(program);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecommendationCard(TherapyProgramModel program) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getProgramIcon(program.type),
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        program.description,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(
                  Icons.schedule,
                  '${program.durationWeeks} أسبوع',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.star,
                  program.rating.toString(),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'موصى به',
                    style: TextStyle(
                      color: AppTheme.successColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isLastPage = _currentPage == 7; // Results page
    final isFirstPage = _currentPage == 0;
    final canProceed = isFirstPage || _answers.containsKey(_getQuestionKey(_currentPage));

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (!isFirstPage)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('السابق'),
              ),
            ),
          if (!isFirstPage) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: LoadingButton(
              onPressed: canProceed
                  ? () async {
                      if (isLastPage) {
                        await _submitAssessment();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    }
                  : null,
              isLoading: _isLoading,
              child: Text(
                isLastPage ? 'إنهاء التقييم' : (isFirstPage ? 'بدء التقييم' : 'التالي'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _getQuestionKey(int page) {
    switch (page) {
      case 1:
        return 'mood_general';
      case 2:
        return 'stress_level';
      case 3:
        return 'sleep_issues';
      case 4:
        return 'social_relationships';
      case 5:
        return 'self_confidence';
      case 6:
        return 'anxiety_frequency';
      case 7:
        return 'therapy_goal';
      default:
        return null;
    }
  }

  List<TherapyProgramModel> _getRecommendations() {
    final provider = Provider.of<TherapyProvider>(context, listen: false);
    final allPrograms = provider.programs;

    // Simple recommendation logic based on answers
    List<TherapyProgramModel> recommendations = [];

    final stressLevel = _answers['stress_level'];
    final anxietyFreq = _answers['anxiety_frequency'];
    final sleepIssues = _answers['sleep_issues'];
    final therapyGoal = _answers['therapy_goal'];
    final selfConfidence = _answers['self_confidence'];

    // Recommend based on primary goal
    switch (therapyGoal) {
      case 'reduce_stress':
        recommendations.addAll(
          allPrograms.where((p) => p.type == TherapyProgramType.stress),
        );
        break;
      case 'anxiety_management':
        recommendations.addAll(
          allPrograms.where((p) => p.type == TherapyProgramType.anxiety),
        );
        break;
      case 'better_sleep':
        recommendations.addAll(
          allPrograms.where((p) => p.type == TherapyProgramType.sleep),
        );
        break;
      case 'self_esteem':
        recommendations.addAll(
          allPrograms.where((p) => p.type == TherapyProgramType.selfEsteem),
        );
        break;
      case 'social_skills':
        recommendations.addAll(
          allPrograms.where((p) => p.type == TherapyProgramType.relationships),
        );
        break;
      case 'improve_mood':
        recommendations.addAll(
          allPrograms.where((p) => p.type == TherapyProgramType.depression),
        );
        break;
    }

    // Add CBT if high stress or anxiety
    if ((stressLevel == 'high' || stressLevel == 'severe') ||
        (anxietyFreq == 'often' || anxietyFreq == 'always')) {
      final cbtPrograms = allPrograms.where((p) => p.type == TherapyProgramType.cbt);
      for (final program in cbtPrograms) {
        if (!recommendations.contains(program)) {
          recommendations.add(program);
        }
      }
    }

    // Add mindfulness for general wellness
    final mindfulnessPrograms = allPrograms.where((p) => p.type == TherapyProgramType.mindfulness);
    for (final program in mindfulnessPrograms) {
      if (!recommendations.contains(program)) {
        recommendations.add(program);
      }
    }

    // Limit to top 3 recommendations
    return recommendations.take(3).toList();
  }

  Future<void> _submitAssessment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<TherapyProvider>(context, listen: false);
      await provider.submitAssessment(_answers);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التقييم بنجاح'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Navigate back to therapy screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _getProgramIcon(TherapyProgramType type) {
    switch (type) {
      case TherapyProgramType.cbt:
        return Icons.psychology;
      case TherapyProgramType.mindfulness:
        return Icons.self_improvement;
      case TherapyProgramType.anxiety:
        return Icons.healing;
      case TherapyProgramType.depression:
        return Icons.mood;
      case TherapyProgramType.stress:
        return Icons.spa;
      case TherapyProgramType.relationships:
        return Icons.people;
      case TherapyProgramType.selfEsteem:
        return Icons.favorite;
      case TherapyProgramType.sleep:
        return Icons.bedtime;
      case TherapyProgramType.addiction:
        return Icons.block;
      case TherapyProgramType.trauma:
        return Icons.shield;
    }
  }
}