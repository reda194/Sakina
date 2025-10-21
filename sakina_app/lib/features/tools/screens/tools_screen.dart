import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../widgets/feature_card.dart';
import 'mood_tracker_screen.dart';
import '../../ai_assistant/screens/ai_assistant_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأدوات'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أدوات الصحة النفسية',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                FeatureCard(
                  title: 'المساعد الذكي',
                  description: 'تحدث مع سكينة الذكية',
                  icon: Icons.psychology,
                  color: AppTheme.primaryColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AIAssistantScreen(),
                      ),
                    );
                  },
                ),
                FeatureCard(
                  title: 'تتبع المزاج',
                  description: 'سجل مشاعرك يومياً',
                  icon: Icons.mood,
                  color: AppTheme.successColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MoodTrackerScreen(),
                      ),
                    );
                  },
                ),
                FeatureCard(
                  title: 'تمارين التنفس',
                  description: 'تقنيات الاسترخاء',
                  icon: Icons.air,
                  color: AppTheme.infoColor,
                  onTap: () {
                    // TODO: Navigate to breathing exercises
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('قريباً...')),
                    );
                  },
                ),
                FeatureCard(
                  title: 'التأمل الموجه',
                  description: 'جلسات تأمل يومية',
                  icon: Icons.self_improvement,
                  color: AppTheme.accentColor,
                  onTap: () {
                    // TODO: Navigate to meditation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('قريباً...')),
                    );
                  },
                ),
                FeatureCard(
                  title: 'مذكرة الامتنان',
                  description: 'اكتب ما تشعر بالامتنان له',
                  icon: Icons.favorite,
                  color: Colors.pink,
                  onTap: () {
                    // TODO: Navigate to gratitude journal
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('قريباً...')),
                    );
                  },
                ),
                FeatureCard(
                  title: 'تحليل النوم',
                  description: 'تتبع جودة نومك',
                  icon: Icons.bedtime,
                  color: AppTheme.secondaryColor,
                  onTap: () {
                    // TODO: Navigate to sleep tracker
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('قريباً...')),
                    );
                  },
                ),
                FeatureCard(
                  title: 'تمارين الذهن',
                  description: 'تدريبات اليقظة الذهنية',
                  icon: Icons.spa,
                  color: AppTheme.warningColor,
                  onTap: () {
                    // TODO: Navigate to mindfulness exercises
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('قريباً...')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.primaryLight.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'نصائح للاستخدام الأمثل',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• استخدم تتبع المزاج يومياً لفهم أنماط مشاعرك\n'
                    '• مارس تمارين التنفس عند الشعور بالتوتر\n'
                    '• اكتب في مذكرة الامتنان قبل النوم\n'
                    '• حافظ على روتين يومي صحي',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
