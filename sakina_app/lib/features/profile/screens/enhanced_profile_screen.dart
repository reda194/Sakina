import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../widgets/responsive_widget.dart';
import '../../../widgets/mental_health_widgets.dart';

class EnhancedProfileScreen extends StatefulWidget {
  const EnhancedProfileScreen({super.key});

  @override
  State<EnhancedProfileScreen> createState() => _EnhancedProfileScreenState();
}

class _EnhancedProfileScreenState extends State<EnhancedProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
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
      body: ResponsiveWidget(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverPadding(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveSpacing(context, 16.0),
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildProfileHeader(),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
                  _buildStatsSection(),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
                  _buildMenuSection(),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
                  _buildSettingsSection(),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 100.0)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveSpacing(context, 32.0),
                vertical: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildProfileHeader(),
                            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
                            _buildStatsSection(),
                          ],
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildMenuSection(),
                            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
                            _buildSettingsSection(),
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
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveSpacing(context, 64.0),
                vertical: ResponsiveUtils.getResponsiveSpacing(context, 32.0),
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildProfileHeader(),
                            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
                            _buildStatsSection(),
                          ],
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 32.0)),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildMenuSection(),
                            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
                            _buildSettingsSection(),
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
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: ResponsiveUtils.getAppBarHeight(context) * 2,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40.0)),
                const ResponsiveText(
                  'الملف الشخصي',
                  baseFontSize: 28.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8.0)),
                ResponsiveText(
                  'إدارة معلوماتك الشخصية',
                  baseFontSize: 16.0,
                  color: Colors.white.withOpacity(0.9),
                ),
              ],
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.edit,
            color: Colors.white,
            size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
          ),
          onPressed: () => _showEditProfileDialog(),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return ResponsiveCard(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: ResponsiveUtils.getResponsiveIconSize(context, 120.0),
                height: ResponsiveUtils.getResponsiveIconSize(context, 120.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 20.0,
                      spreadRadius: 5.0,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 60.0),
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: ResponsiveUtils.getResponsiveIconSize(context, 36.0),
                  height: ResponsiveUtils.getResponsiveIconSize(context, 36.0),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3.0,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 18.0),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
          const ResponsiveText(
            'سارة أحمد',
            baseFontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4.0)),
          const ResponsiveText(
            'sara.ahmed@example.com',
            baseFontSize: 16.0,
            color: AppTheme.textLight,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8.0)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
              vertical: ResponsiveUtils.getResponsiveSpacing(context, 6.0),
            ),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 20.0),
            ),
            child: const ResponsiveText(
              'عضو مميز',
              baseFontSize: 12.0,
              color: AppTheme.successColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveText(
          'إحصائياتي',
          baseFontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
        Row(
          children: [
            const Expanded(
              child: StatCard(
                title: 'أيام متتالية',
                value: '15',
                icon: Icons.local_fire_department,
                color: AppTheme.warningColor,
              ),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12.0)),
            const Expanded(
              child: StatCard(
                title: 'جلسات مكتملة',
                value: '42',
                icon: Icons.check_circle,
                color: AppTheme.successColor,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12.0)),
        Row(
          children: [
            const Expanded(
              child: StatCard(
                title: 'ساعات التأمل',
                value: '28',
                icon: Icons.self_improvement,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12.0)),
            const Expanded(
              child: StatCard(
                title: 'مستوى السعادة',
                value: '85%',
                icon: Icons.sentiment_very_satisfied,
                color: AppTheme.moodHappy,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveText(
          'الحساب',
          baseFontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
        _buildMenuItem(
          icon: Icons.person_outline,
          title: 'المعلومات الشخصية',
          subtitle: 'تحديث بياناتك الشخصية',
          onTap: () => _showEditProfileDialog(),
        ),
        _buildMenuItem(
          icon: Icons.security,
          title: 'الأمان والخصوصية',
          subtitle: 'إدارة كلمة المرور والخصوصية',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.notifications_outlined,
          title: 'الإشعارات',
          subtitle: 'إعدادات التنبيهات والإشعارات',
          onTap: () {},
          trailing: Switch(
            value: true,
            onChanged: (value) {},
            activeThumbColor: AppTheme.primaryColor,
          ),
        ),
        _buildMenuItem(
          icon: Icons.language,
          title: 'اللغة',
          subtitle: 'العربية',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.dark_mode_outlined,
          title: 'المظهر',
          subtitle: 'فاتح / داكن',
          onTap: () {},
          trailing: Switch(
            value: false,
            onChanged: (value) {},
            activeThumbColor: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveText(
          'الدعم',
          baseFontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'مركز المساعدة',
          subtitle: 'الأسئلة الشائعة والدعم',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.feedback_outlined,
          title: 'إرسال ملاحظات',
          subtitle: 'شاركنا رأيك لتحسين التطبيق',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.star_outline,
          title: 'قيم التطبيق',
          subtitle: 'ساعدنا بتقييمك في المتجر',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.info_outline,
          title: 'حول التطبيق',
          subtitle: 'الإصدار 1.0.0',
          onTap: () {},
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
        _buildMenuItem(
          icon: Icons.logout,
          title: 'تسجيل الخروج',
          subtitle: 'الخروج من حسابك',
          onTap: () => _showLogoutDialog(),
          titleColor: AppTheme.errorColor,
          iconColor: AppTheme.errorColor,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? titleColor,
    Color? iconColor,
  }) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 8.0),
      ),
      child: ResponsiveCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: ResponsiveUtils.getResponsiveIconSize(context, 48.0),
              height: ResponsiveUtils.getResponsiveIconSize(context, 48.0),
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppTheme.primaryColor,
                size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
              ),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText(
                    title,
                    baseFontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: titleColor ?? AppTheme.textDark,
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 2.0)),
                  ResponsiveText(
                    subtitle,
                    baseFontSize: 14.0,
                    color: AppTheme.textLight,
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textLight,
                size: ResponsiveUtils.getResponsiveIconSize(context, 16.0),
              ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحديث الملف الشخصي'),
        content: const Text('هذه الميزة قيد التطوير'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Add logout logic here
            },
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}