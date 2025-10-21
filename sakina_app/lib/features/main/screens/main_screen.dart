import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../widgets/enhanced_bottom_navigation.dart';
import '../../home/screens/enhanced_home_screen.dart';
import '../../mood/screens/enhanced_mood_screen.dart';
import '../../tools/screens/enhanced_tools_screen.dart';
import '../../profile/screens/enhanced_profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  final List<Widget> _screens = [
    const EnhancedHomeScreen(),
    const EnhancedMoodScreen(),
    const EnhancedToolsScreen(),
    const EnhancedProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _initFabAnimation();
  }

  void _initFabAnimation() {
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));
    
    _fabController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    // Animate FAB
    _fabController.reset();
    _fabController.forward();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: EnhancedBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          const EnhancedBottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'الرئيسية',
          ),
          EnhancedBottomNavItem(
            icon: Icons.mood_outlined,
            activeIcon: Icons.mood,
            label: 'المزاج',
            badge: _getMoodBadge(),
          ),
          const EnhancedBottomNavItem(
            icon: Icons.psychology_outlined,
            activeIcon: Icons.psychology,
            label: 'الأدوات',
          ),
          EnhancedBottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'الملف الشخصي',
            badge: _getProfileBadge(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget? _buildFloatingActionButton() {
    // Show FAB only on home screen
    if (_currentIndex != 0) return null;
    
    return ScaleTransition(
      scale: _fabAnimation,
      child: Container(
        width: ResponsiveUtils.getResponsiveIconSize(context, 64.0),
        height: ResponsiveUtils.getResponsiveIconSize(context, 64.0),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.4),
              blurRadius: 16.0,
              spreadRadius: 4.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(32.0),
            onTap: _onFabPressed,
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: ResponsiveUtils.getResponsiveIconSize(context, 28.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _getMoodBadge() {
    // Show notification badge if user hasn't logged mood today
    final shouldShowBadge = _shouldShowMoodReminder();
    if (!shouldShowBadge) return null;
    
    return const DotBadge(
      color: AppTheme.warningColor,
    );
  }

  Widget? _getProfileBadge() {
    // Show badge for profile updates or notifications
    final notificationCount = _getProfileNotificationCount();
    if (notificationCount <= 0) return null;
    
    return NotificationBadge(
      count: notificationCount,
      color: AppTheme.errorColor,
    );
  }

  bool _shouldShowMoodReminder() {
    // TODO: Check if user has logged mood today
    // This is a placeholder - implement actual logic
    return true;
  }

  int _getProfileNotificationCount() {
    // TODO: Get actual notification count from user data
    // This is a placeholder - implement actual logic
    return 2;
  }

  void _onFabPressed() {
    HapticFeedback.mediumImpact();
    
    _showQuickActionSheet();
  }

  void _showQuickActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuickActionSheet(),
    );
  }

  Widget _buildQuickActionSheet() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: ResponsiveUtils.getResponsiveBorderRadius(context, 24.0).topLeft,
          topRight: ResponsiveUtils.getResponsiveBorderRadius(context, 24.0).topRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: ResponsiveUtils.getResponsiveSpacing(context, 40.0),
              height: ResponsiveUtils.getResponsiveSpacing(context, 4.0),
              margin: EdgeInsets.symmetric(
                vertical: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
              ),
              decoration: BoxDecoration(
                color: AppTheme.textLight.withOpacity(0.3),
                borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 2.0),
              ),
            ),
            
            // Title
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
                vertical: ResponsiveUtils.getResponsiveSpacing(context, 8.0),
              ),
              child: Text(
                'إجراءات سريعة',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20.0),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            
            // Quick actions
            Padding(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveSpacing(context, 24.0),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionItem(
                          icon: Icons.mood,
                          title: 'تسجيل المزاج',
                          color: AppTheme.moodHappy,
                          onTap: () {
                            Navigator.pop(context);
                            _onTabTapped(1); // Navigate to mood screen
                          },
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
                      Expanded(
                        child: _buildQuickActionItem(
                          icon: Icons.self_improvement,
                          title: 'تأمل سريع',
                          color: AppTheme.primaryColor,
                          onTap: () {
                            Navigator.pop(context);
                            _onTabTapped(2); // Navigate to tools screen
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionItem(
                          icon: Icons.air,
                          title: 'تمرين تنفس',
                          color: AppTheme.successColor,
                          onTap: () {
                            Navigator.pop(context);
                            _startBreathingExercise();
                          },
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
                      Expanded(
                        child: _buildQuickActionItem(
                          icon: Icons.chat_bubble_outline,
                          title: 'دردشة سريعة',
                          color: AppTheme.infoColor,
                          onTap: () {
                            Navigator.pop(context);
                            _startQuickChat();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(
          ResponsiveUtils.getResponsiveSpacing(context, 16.0),
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: ResponsiveUtils.getResponsiveIconSize(context, 48.0),
              height: ResponsiveUtils.getResponsiveIconSize(context, 48.0),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8.0)),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12.0),
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _startBreathingExercise() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تمرين التنفس'),
        content: const Text('سيتم إطلاق تمرين التنفس قريباً'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _startQuickChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الدردشة السريعة'),
        content: const Text('ميزة الدردشة مع المساعد الذكي قيد التطوير'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}