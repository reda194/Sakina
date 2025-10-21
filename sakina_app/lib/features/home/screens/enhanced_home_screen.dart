import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../widgets/responsive_widget.dart';
import '../../../widgets/mental_health_widgets.dart';
import '../../mood/providers/mood_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodProvider>().loadMoodHistory();
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ResponsiveWidget(
              mobile: _buildMobileLayout(),
              tablet: _buildTabletLayout(),
              desktop: _buildDesktopLayout(),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildMobileLayout() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverPadding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildWelcomeSection(),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
              _buildQuickMoodTracker(),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
              _buildStatsSection(),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
              _buildFeaturesGrid(),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
              _buildRecentActivity(),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 100.0)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverPadding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildWelcomeSection(),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32.0)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildQuickMoodTracker(),
                        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
                        _buildFeaturesGrid(),
                      ],
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildStatsSection(),
                        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
                        _buildRecentActivity(),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 100.0)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getResponsiveSpacing(context, 48.0),
            vertical: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildWelcomeSection(),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40.0)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildQuickMoodTracker(),
                        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32.0)),
                        _buildFeaturesGrid(),
                      ],
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 32.0)),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildStatsSection(),
                        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32.0)),
                        _buildRecentActivity(),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 100.0)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: ResponsiveUtils.getAppBarHeight(context) * 1.5,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12.0)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ResponsiveText(
                                  'مرحباً، ${authProvider.user?.displayName ?? 'المستخدم'}',
                                  baseFontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                ResponsiveText(
                                  'كيف تشعر اليوم؟',
                                  baseFontSize: 14.0,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Navigate to notifications
                            },
                            icon: Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 20.0),
        border: Border.all(
          color: AppTheme.secondaryColor.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                color: AppTheme.secondaryColor,
                size: ResponsiveUtils.getResponsiveIconSize(context, 28.0),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12.0)),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      'رحلتك نحو الصحة النفسية',
                      baseFontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    ResponsiveText(
                      'تذكر أن كل خطوة صغيرة تقربك من هدفك',
                      baseFontSize: 14.0,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
          const AnimatedProgressIndicator(
            progress: 0.65,
            color: AppTheme.secondaryColor,
            label: 'التقدم الأسبوعي: 65%',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMoodTracker() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        return ResponsiveCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.mood,
                    color: AppTheme.primaryColor,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12.0)),
                  const ResponsiveText(
                    'كيف تشعر الآن؟',
                    baseFontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20.0)),
              EnhancedMoodSelector(
                selectedMood: moodProvider.currentMood ?? 3,
                onMoodSelected: (mood) {
                  moodProvider.updateMood(mood);
                  _showMoodSavedSnackBar();
                },
                showLabels: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ResponsiveText(
              'إحصائياتك',
              baseFontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
            ResponsiveGridView(
              crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
              mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
              children: [
                StatCard(
                  title: 'متوسط المزاج',
                  value: '${moodProvider.averageMood.toStringAsFixed(1)}',
                  icon: Icons.trending_up,
                  color: AppTheme.primaryColor,
                  trend: '+0.5',
                  isPositiveTrend: true,
                ),
                StatCard(
                  title: 'أيام التتبع',
                  value: '${moodProvider.trackingDays}',
                  icon: Icons.calendar_today,
                  color: AppTheme.secondaryColor,
                  subtitle: 'هذا الشهر',
                ),
                StatCard(
                  title: 'أفضل يوم',
                  value: moodProvider.bestDay,
                  icon: Icons.star,
                  color: AppTheme.moodExcellent,
                ),
                const StatCard(
                  title: 'الهدف الأسبوعي',
                  value: '5/7',
                  icon: Icons.flag,
                  color: AppTheme.warningColor,
                  trend: '71%',
                  isPositiveTrend: true,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      {
        'title': 'تمارين التنفس',
        'subtitle': 'تقنيات الاسترخاء والهدوء',
        'icon': Icons.air,
        'color': AppTheme.primaryColor,
        'onTap': () => _navigateToBreathingExercises(),
      },
      {
        'title': 'التأمل الموجه',
        'subtitle': 'جلسات تأمل متنوعة',
        'icon': Icons.self_improvement,
        'color': AppTheme.secondaryColor,
        'onTap': () => _navigateToMeditation(),
      },
      {
        'title': 'يوميات المشاعر',
        'subtitle': 'اكتب أفكارك ومشاعرك',
        'icon': Icons.book,
        'color': AppTheme.accentColor,
        'onTap': () => _navigateToJournal(),
      },
      {
        'title': 'استشارة نفسية',
        'subtitle': 'تحدث مع مختص',
        'icon': Icons.psychology,
        'color': AppTheme.warningColor,
        'onTap': () => _navigateToConsultation(),
        'badge': Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getResponsiveSpacing(context, 6.0),
            vertical: ResponsiveUtils.getResponsiveSpacing(context, 2.0),
          ),
          decoration: BoxDecoration(
            color: AppTheme.errorColor,
            borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 8.0),
          ),
          child: const ResponsiveText(
            'جديد',
            baseFontSize: 8.0,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveText(
          'الأدوات والميزات',
          baseFontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
        ResponsiveGridView(
          crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
          mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
          children: features.map((feature) {
            return FeatureCard(
              title: feature['title'] as String,
              subtitle: feature['subtitle'] as String,
              icon: feature['icon'] as IconData,
              color: feature['color'] as Color,
              onTap: feature['onTap'] as VoidCallback,
              badge: feature['badge'] as Widget?,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: AppTheme.primaryColor,
                size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12.0)),
              const ResponsiveText(
                'النشاط الأخير',
                baseFontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
          ...[
            _buildActivityItem(
              'تمرين تنفس',
              'منذ ساعتين',
              Icons.air,
              AppTheme.primaryColor,
            ),
            _buildActivityItem(
              'تسجيل مزاج',
              'منذ 4 ساعات',
              Icons.mood,
              AppTheme.secondaryColor,
            ),
            _buildActivityItem(
              'جلسة تأمل',
              'أمس',
              Icons.self_improvement,
              AppTheme.accentColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsiveSpacing(context, 8.0),
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 8.0),
            ),
            child: Icon(
              icon,
              color: color,
              size: ResponsiveUtils.getResponsiveIconSize(context, 16.0),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  title,
                  baseFontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
                ResponsiveText(
                  time,
                  baseFontSize: 12.0,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return GradientFloatingActionButton(
      onPressed: () {
        _showQuickActionsBottomSheet();
      },
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: ResponsiveUtils.getResponsiveIconSize(context, 28.0),
      ),
    );
  }

  void _showMoodSavedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم حفظ مزاجك بنجاح'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 8.0),
        ),
      ),
    );
  }

  void _showQuickActionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: ResponsiveUtils.getResponsiveBorderRadius(context, 24.0).topLeft,
            topRight: ResponsiveUtils.getResponsiveBorderRadius(context, 24.0).topRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(
                top: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
              ),
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 2.0),
              ),
            ),
            Padding(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Column(
                children: [
                  const ResponsiveText(
                    'إجراءات سريعة',
                    baseFontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickAction(
                        'تسجيل مزاج',
                        Icons.mood,
                        AppTheme.primaryColor,
                        () => Navigator.pop(context),
                      ),
                      _buildQuickAction(
                        'تمرين تنفس',
                        Icons.air,
                        AppTheme.secondaryColor,
                        () => Navigator.pop(context),
                      ),
                      _buildQuickAction(
                        'كتابة يومية',
                        Icons.edit,
                        AppTheme.accentColor,
                        () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20.0)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsiveSpacing(context, 16.0),
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8.0)),
          ResponsiveText(
            title,
            baseFontSize: 12.0,
            color: AppTheme.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToBreathingExercises() {
    // Navigate to breathing exercises
  }

  void _navigateToMeditation() {
    // Navigate to meditation
  }

  void _navigateToJournal() {
    // Navigate to journal
  }

  void _navigateToConsultation() {
    // Navigate to consultation
  }
}