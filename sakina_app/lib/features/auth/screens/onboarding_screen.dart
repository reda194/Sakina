import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../widgets/loading_button.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: 'مرحباً بك في سكينة',
      description: 'رفيقك الموثوق في رحلة الصحة النفسية',
      image: Icons.psychology,
      color: AppTheme.primaryColor,
    ),
    OnboardingItem(
      title: 'دعم متخصص',
      description: 'تواصل مع أفضل المختصين النفسيين المعتمدين',
      image: Icons.support_agent,
      color: AppTheme.secondaryColor,
    ),
    OnboardingItem(
      title: 'خصوصية تامة',
      description: 'بياناتك آمنة ومحمية بأعلى معايير التشفير',
      image: Icons.lock,
      color: AppTheme.primaryDark,
    ),
    OnboardingItem(
      title: 'مجتمع داعم',
      description: 'انضم لمجتمع يفهمك ويدعمك في رحلتك',
      image: Icons.people,
      color: AppTheme.successColor,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.storageService.setOnboardingCompleted(true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topLeft,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text(
                  'تخطي',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingItems.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingItems[index]);
                },
              ),
            ),
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingItems.length,
                (index) => _buildPageIndicator(index),
              ),
            ),
            const SizedBox(height: 30),
            // Action button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LoadingButton(
                text: _currentPage == _onboardingItems.length - 1
                    ? 'ابدأ الآن'
                    : 'التالي',
                isLoading: false,
                onPressed: _nextPage,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.image,
              size: 80,
              color: item.color,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            item.title,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppTheme.primaryColor
            : AppTheme.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData image;
  final Color color;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
  });
}
