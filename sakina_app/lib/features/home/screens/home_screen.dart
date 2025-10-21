import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../widgets/feature_card.dart';
import '../../../widgets/mood_tracker_card.dart';
import '../../profile/screens/profile_screen.dart';
import '../../consultations/screens/consultations_screen.dart';
import '../../therapy/screens/therapy_screen.dart';
import '../../community/screens/community_screen.dart';
import '../../tools/screens/tools_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ConsultationsScreen(),
    const TherapyScreen(),
    const CommunityScreen(),
    const ToolsScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'الرئيسية',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.medical_services_outlined),
      activeIcon: Icon(Icons.medical_services),
      label: 'الاستشارات',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.healing_outlined),
      activeIcon: Icon(Icons.healing),
      label: 'العلاج',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.people_outline),
      activeIcon: Icon(Icons.people),
      label: 'المجتمع',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.self_improvement_outlined),
      activeIcon: Icon(Icons.self_improvement),
      label: 'الأدوات',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _navItems,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textLight,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.currentUser?.name ?? 'ضيف';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'س',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً، $userName',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'كيف حالك اليوم؟',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood Tracker Card
            const MoodTrackerCard(),
            const SizedBox(height: 24),
            
            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'الجلسات',
                    '3',
                    Icons.video_call,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'التمارين',
                    '12',
                    Icons.fitness_center,
                    AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'المجتمع',
                    '5',
                    Icons.favorite,
                    AppTheme.accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Main Features
            Text(
              'الخدمات الرئيسية',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                FeatureCard(
                  title: 'احجز استشارة',
                  description: 'تحدث مع مختص',
                  icon: Icons.psychology,
                  color: AppTheme.primaryColor,
                  onTap: () {
                    setState(() {
                      // Navigate to consultations
                    });
                  },
                ),
                FeatureCard(
                  title: 'برامج العلاج',
                  description: 'خطط مخصصة لك',
                  icon: Icons.healing,
                  color: AppTheme.secondaryColor,
                  onTap: () {
                    // Navigate to therapy
                  },
                ),
                FeatureCard(
                  title: 'المجتمع',
                  description: 'تواصل مع الآخرين',
                  icon: Icons.people,
                  color: AppTheme.successColor,
                  onTap: () {
                    // Navigate to community
                  },
                ),
                FeatureCard(
                  title: 'الأدوات',
                  description: 'تمارين وتقنيات',
                  icon: Icons.self_improvement,
                  color: AppTheme.infoColor,
                  onTap: () {
                    // Navigate to tools
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Daily Tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
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
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'نصيحة اليوم',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'خذ نفسًا عميقًا واحبس الهواء لثلاث ثوانٍ ثم أطلقه ببطء. كرر هذا التمرين 5 مرات للشعور بالهدوء.',
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

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void setState(VoidCallback fn) {
    // This is a workaround for using setState in a StatelessWidget
    // In a real app, convert HomePage to StatefulWidget
  }
} 