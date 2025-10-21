import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../widgets/responsive_widget.dart';

class EnhancedToolsScreen extends StatefulWidget {
  const EnhancedToolsScreen({super.key});

  @override
  State<EnhancedToolsScreen> createState() => _EnhancedToolsScreenState();
}

class _EnhancedToolsScreenState extends State<EnhancedToolsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _selectedCategory = 'الكل';
  final List<String> _categories = ['الكل', 'التأمل', 'التنفس', 'النوم', 'التركيز', 'الاسترخاء'];

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
                  _buildCategoryFilter(),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
                  _buildFeaturedTools(),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
                  _buildToolsGrid(),
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
                  _buildCategoryFilter(),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32.0)),
                  _buildFeaturedTools(),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32.0)),
                  _buildToolsGrid(),
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
                  _buildCategoryFilter(),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40.0)),
                  _buildFeaturedTools(),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40.0)),
                  _buildToolsGrid(),
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.secondaryColor,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40.0)),
                Icon(
                  Icons.psychology,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 48.0),
                  color: Colors.white,
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
                const ResponsiveText(
                  'أدوات الصحة النفسية',
                  baseFontSize: 28.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8.0)),
                ResponsiveText(
                  'اكتشف أدوات متنوعة لتحسين صحتك النفسية',
                  baseFontSize: 16.0,
                  color: Colors.white.withOpacity(0.9),
                  textAlign: TextAlign.center,
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
            Icons.search,
            color: Colors.white,
            size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
          ),
          onPressed: () => _showSearchDialog(),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveText(
          'الفئات',
          baseFontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(context, 50.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              
              return Container(
                margin: EdgeInsets.only(
                  right: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                ),
                child: FilterChip(
                  label: ResponsiveText(
                    category,
                    baseFontSize: 14.0,
                    color: isSelected ? Colors.white : AppTheme.textDark,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                    HapticFeedback.lightImpact();
                  },
                  backgroundColor: AppTheme.surfaceColor,
                  selectedColor: AppTheme.primaryColor,
                  checkmarkColor: Colors.white,
                  elevation: isSelected ? 4.0 : 0.0,
                  shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 25.0),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveText(
          'الأدوات المميزة',
          baseFontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(context, 200.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _getFeaturedTools().length,
            itemBuilder: (context, index) {
              final tool = _getFeaturedTools()[index];
              return Container(
                width: ResponsiveUtils.getResponsiveSpacing(context, 280.0),
                margin: EdgeInsets.only(
                  right: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
                ),
                child: _buildFeaturedToolCard(tool),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedToolCard(ToolItem tool) {
    return ResponsiveCard(
      onTap: () => _openTool(tool),
      child: Container(
        decoration: BoxDecoration(
          gradient: tool.gradient,
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
        ),
        padding: EdgeInsets.all(
          ResponsiveUtils.getResponsiveSpacing(context, 20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: ResponsiveUtils.getResponsiveIconSize(context, 48.0),
                  height: ResponsiveUtils.getResponsiveIconSize(context, 48.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
                  ),
                  child: Icon(
                    tool.icon,
                    color: Colors.white,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
                  ),
                ),
                const Spacer(),
                if (tool.isPremium)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getResponsiveSpacing(context, 8.0),
                      vertical: ResponsiveUtils.getResponsiveSpacing(context, 4.0),
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor,
                      borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
                    ),
                    child: const ResponsiveText(
                      'مميز',
                      baseFontSize: 10.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
            ResponsiveText(
              tool.title,
              baseFontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8.0)),
            ResponsiveText(
              tool.description,
              baseFontSize: 14.0,
              color: Colors.white.withOpacity(0.9),
              maxLines: 2,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.white.withOpacity(0.8),
                  size: ResponsiveUtils.getResponsiveIconSize(context, 16.0),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 4.0)),
                ResponsiveText(
                  tool.duration,
                  baseFontSize: 12.0,
                  color: Colors.white.withOpacity(0.8),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 16.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsGrid() {
    final tools = _getFilteredTools();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveText(
          'جميع الأدوات',
          baseFontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
        ResponsiveGridView(
          children: tools.map((tool) => _buildToolCard(tool)).toList(),
        ),
      ],
    );
  }

  Widget _buildToolCard(ToolItem tool) {
    return ResponsiveCard(
      onTap: () => _openTool(tool),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: ResponsiveUtils.getResponsiveSpacing(context, 80.0),
            decoration: BoxDecoration(
              gradient: tool.gradient,
              borderRadius: BorderRadius.only(
                topLeft: ResponsiveUtils.getResponsiveBorderRadius(context, 16.0).topLeft,
                topRight: ResponsiveUtils.getResponsiveBorderRadius(context, 16.0).topRight,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    tool.icon,
                    color: Colors.white,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 32.0),
                  ),
                ),
                if (tool.isPremium)
                  Positioned(
                    top: ResponsiveUtils.getResponsiveSpacing(context, 8.0),
                    right: ResponsiveUtils.getResponsiveSpacing(context, 8.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 6.0),
                        vertical: ResponsiveUtils.getResponsiveSpacing(context, 2.0),
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor,
                        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 8.0),
                      ),
                      child: const ResponsiveText(
                        'مميز',
                        baseFontSize: 8.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveSpacing(context, 16.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText(
                    tool.title,
                    baseFontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    maxLines: 1,
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4.0)),
                  ResponsiveText(
                    tool.description,
                    baseFontSize: 12.0,
                    color: AppTheme.textLight,
                    maxLines: 2,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppTheme.textLight,
                        size: ResponsiveUtils.getResponsiveIconSize(context, 14.0),
                      ),
                      SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 4.0)),
                      ResponsiveText(
                        tool.duration,
                        baseFontSize: 12.0,
                        color: AppTheme.textLight,
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.getResponsiveSpacing(context, 8.0),
                          vertical: ResponsiveUtils.getResponsiveSpacing(context, 4.0),
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(tool.category).withOpacity(0.1),
                          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 8.0),
                        ),
                        child: ResponsiveText(
                          tool.category,
                          baseFontSize: 10.0,
                          color: _getCategoryColor(tool.category),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<ToolItem> _getFeaturedTools() {
    return [
      const ToolItem(
        title: 'تأمل الصباح',
        description: 'ابدأ يومك بطاقة إيجابية مع جلسة تأمل مهدئة',
        icon: Icons.wb_sunny,
        category: 'التأمل',
        duration: '10 دقائق',
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
        isPremium: false,
      ),
      const ToolItem(
        title: 'تنفس عميق',
        description: 'تقنيات التنفس للتخلص من التوتر والقلق',
        icon: Icons.air,
        category: 'التنفس',
        duration: '5 دقائق',
        gradient: LinearGradient(
          colors: [AppTheme.successColor, Color(0xFF4CAF50)],
        ),
        isPremium: false,
      ),
      const ToolItem(
        title: 'نوم هادئ',
        description: 'أصوات طبيعية مهدئة لنوم عميق ومريح',
        icon: Icons.bedtime,
        category: 'النوم',
        duration: '30 دقيقة',
        gradient: LinearGradient(
          colors: [AppTheme.moodCalm, Color(0xFF673AB7)],
        ),
        isPremium: true,
      ),
    ];
  }

  List<ToolItem> _getAllTools() {
    return [
      ..._getFeaturedTools(),
      const ToolItem(
        title: 'تركيز عميق',
        description: 'موسيقى وأصوات لتحسين التركيز والإنتاجية',
        icon: Icons.psychology,
        category: 'التركيز',
        duration: '25 دقيقة',
        gradient: LinearGradient(
          colors: [AppTheme.warningColor, Color(0xFFFF9800)],
        ),
        isPremium: false,
      ),
      const ToolItem(
        title: 'استرخاء العضلات',
        description: 'تمارين لاسترخاء العضلات وتخفيف التوتر',
        icon: Icons.self_improvement,
        category: 'الاسترخاء',
        duration: '15 دقيقة',
        gradient: LinearGradient(
          colors: [AppTheme.moodHappy, Color(0xFFE91E63)],
        ),
        isPremium: false,
      ),
      const ToolItem(
        title: 'تأمل المشي',
        description: 'تأمل أثناء المشي لتحسين الوعي والحضور',
        icon: Icons.directions_walk,
        category: 'التأمل',
        duration: '20 دقيقة',
        gradient: LinearGradient(
          colors: [AppTheme.infoColor, Color(0xFF2196F3)],
        ),
        isPremium: true,
      ),
    ];
  }

  List<ToolItem> _getFilteredTools() {
    final allTools = _getAllTools();
    if (_selectedCategory == 'الكل') {
      return allTools;
    }
    return allTools.where((tool) => tool.category == _selectedCategory).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'التأمل':
        return AppTheme.primaryColor;
      case 'التنفس':
        return AppTheme.successColor;
      case 'النوم':
        return AppTheme.moodCalm;
      case 'التركيز':
        return AppTheme.warningColor;
      case 'الاسترخاء':
        return AppTheme.moodHappy;
      default:
        return AppTheme.textLight;
    }
  }

  void _openTool(ToolItem tool) {
    HapticFeedback.lightImpact();
    
    if (tool.isPremium) {
      _showPremiumDialog(tool);
    } else {
      _showToolDialog(tool);
    }
  }

  void _showToolDialog(ToolItem tool) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tool.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tool.description),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppTheme.textLight),
                const SizedBox(width: 4),
                Text(
                  tool.duration,
                  style: const TextStyle(color: AppTheme.textLight),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Start tool session
            },
            child: const Text('ابدأ الآن'),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog(ToolItem tool) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.star, color: AppTheme.warningColor),
            SizedBox(width: 8),
            Text('محتوى مميز'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${tool.title} متاح للأعضاء المميزين فقط'),
            const SizedBox(height: 16),
            const Text('اشترك الآن للوصول إلى جميع الأدوات المميزة'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to subscription
            },
            child: const Text('اشترك الآن'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('البحث'),
        content: const Text('ميزة البحث قيد التطوير'),
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

class ToolItem {
  final String title;
  final String description;
  final IconData icon;
  final String category;
  final String duration;
  final LinearGradient gradient;
  final bool isPremium;

  const ToolItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.duration,
    required this.gradient,
    this.isPremium = false,
  });
}