import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../widgets/responsive_widget.dart';
import '../../../widgets/mental_health_widgets.dart';
import '../providers/mood_provider.dart';
import '../models/mood_entry.dart';

class EnhancedMoodScreen extends StatefulWidget {
  const EnhancedMoodScreen({super.key});

  @override
  State<EnhancedMoodScreen> createState() => _EnhancedMoodScreenState();
}

class _EnhancedMoodScreenState extends State<EnhancedMoodScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _chartController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _chartAnimation;
  
  int _selectedPeriod = 0; // 0: Week, 1: Month, 2: Year
  final List<String> _periods = ['أسبوع', 'شهر', 'سنة'];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadMoodData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.elasticOut,
    ));
    
    _fadeController.forward();
    _chartController.forward();
  }

  void _loadMoodData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodProvider>().loadMoodHistory();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ResponsiveWidget(
          mobile: _buildMobileLayout(),
          tablet: _buildTabletLayout(),
          desktop: _buildDesktopLayout(),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const ResponsiveText(
        'تتبع المزاج',
        baseFontSize: 20.0,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showMoodInsights,
          icon: Icon(
            Icons.insights,
            color: Colors.white,
            size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
          ),
        ),
        IconButton(
          onPressed: _exportMoodData,
          icon: Icon(
            Icons.download,
            color: Colors.white,
            size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickMoodEntry(),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
          _buildPeriodSelector(),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
          _buildMoodChart(),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
          _buildMoodStats(),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
          _buildMoodHistory(),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 100.0)),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        children: [
          _buildQuickMoodEntry(),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32.0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildPeriodSelector(),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
                    _buildMoodChart(),
                  ],
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildMoodStats(),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
                    _buildMoodHistory(),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 100.0)),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 48.0),
        vertical: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
      ),
      child: Column(
        children: [
          _buildQuickMoodEntry(),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40.0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildPeriodSelector(),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
                    _buildMoodChart(),
                  ],
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 32.0)),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildMoodStats(),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32.0)),
                    _buildMoodHistory(),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 100.0)),
        ],
      ),
    );
  }

  Widget _buildQuickMoodEntry() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        return ResponsiveCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
                    ),
                    child: Icon(
                      Icons.mood,
                      color: Colors.white,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ResponsiveText(
                          'كيف تشعر الآن؟',
                          baseFontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        ResponsiveText(
                          'سجل مزاجك الحالي',
                          baseFontSize: 14.0,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
              EnhancedMoodSelector(
                selectedMood: moodProvider.currentMood,
                onMoodSelected: (mood) {
                  moodProvider.updateMood(mood);
                  _showMoodEntryDialog(mood);
                },
                showLabels: true,
                size: 70.0,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.getResponsiveSpacing(context, 4.0),
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
        border: Border.all(
          color: AppTheme.dividerColor,
          width: 1.0,
        ),
      ),
      child: Row(
        children: List.generate(_periods.length, (index) {
          final isSelected = _selectedPeriod == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = index;
                });
                _chartController.reset();
                _chartController.forward();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 8.0),
                ),
                child: ResponsiveText(
                  _periods[index],
                  baseFontSize: 14.0,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMoodChart() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        return ResponsiveCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.show_chart,
                    color: AppTheme.primaryColor,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12.0)),
                  const ResponsiveText(
                    'رسم بياني للمزاج',
                    baseFontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getResponsiveSpacing(context, 8.0),
                      vertical: ResponsiveUtils.getResponsiveSpacing(context, 4.0),
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 6.0),
                    ),
                    child: ResponsiveText(
                      _periods[_selectedPeriod],
                      baseFontSize: 12.0,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
              AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  return SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 250.0),
                    child: LineChart(
                      _buildLineChartData(moodProvider.moodHistory),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  LineChartData _buildLineChartData(List<MoodEntry> moodHistory) {
    final spots = moodHistory.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.mood.toDouble());
    }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppTheme.dividerColor.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < moodHistory.length) {
                final date = moodHistory[value.toInt()].date;
                return ResponsiveText(
                  '${date.day}/${date.month}',
                  baseFontSize: 10.0,
                  color: AppTheme.textSecondary,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              switch (value.toInt()) {
                case 1:
                  return const ResponsiveText('😢', baseFontSize: 16.0);
                case 2:
                  return const ResponsiveText('😕', baseFontSize: 16.0);
                case 3:
                  return const ResponsiveText('😐', baseFontSize: 16.0);
                case 4:
                  return const ResponsiveText('😊', baseFontSize: 16.0);
                case 5:
                  return const ResponsiveText('😄', baseFontSize: 16.0);
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: AppTheme.dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      minX: 0,
      maxX: (moodHistory.length - 1).toDouble(),
      minY: 1,
      maxY: 5,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: AppTheme.primaryGradient,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppTheme.primaryColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.3),
                AppTheme.primaryColor.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: AppTheme.surfaceColor,
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final moodEmoji = _getMoodEmoji(spot.y.toInt());
              return LineTooltipItem(
                '$moodEmoji\n${spot.y.toStringAsFixed(0)}',
                TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12.0),
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildMoodStats() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ResponsiveText(
              'إحصائيات المزاج',
              baseFontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
            ResponsiveGridView(
              crossAxisCount: context.isMobile ? 2 : 1,
              crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
              mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
              children: [
                StatCard(
                  title: 'متوسط المزاج',
                  value: moodProvider.averageMood.toStringAsFixed(1),
                  icon: Icons.trending_up,
                  color: _getMoodColor(moodProvider.averageMood.round()),
                  trend: '+0.3',
                  isPositiveTrend: true,
                ),
                StatCard(
                  title: 'أفضل مزاج',
                  value: _getMoodEmoji(moodProvider.bestMood),
                  icon: Icons.star,
                  color: AppTheme.moodExcellent,
                  subtitle: 'هذا الأسبوع',
                ),
                StatCard(
                  title: 'أسوأ مزاج',
                  value: _getMoodEmoji(moodProvider.worstMood),
                  icon: Icons.trending_down,
                  color: AppTheme.moodTerrible,
                  subtitle: 'هذا الأسبوع',
                ),
                StatCard(
                  title: 'أيام التتبع',
                  value: '${moodProvider.trackingDays}',
                  icon: Icons.calendar_today,
                  color: AppTheme.secondaryColor,
                  trend: '${moodProvider.trackingStreak} متتالية',
                  isPositiveTrend: true,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMoodHistory() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
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
                    'السجل الأخير',
                    baseFontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
              ...moodProvider.recentMoodEntries.take(5).map((entry) {
                return _buildMoodHistoryItem(entry);
              }).toList(),
              if (moodProvider.recentMoodEntries.length > 5) ...[
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8.0)),
                Center(
                  child: TextButton(
                    onPressed: _showFullHistory,
                    child: ResponsiveText(
                      'عرض المزيد',
                      baseFontSize: 14.0,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoodHistoryItem(MoodEntry entry) {
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
              color: _getMoodColor(entry.mood).withOpacity(0.1),
              borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 8.0),
            ),
            child: ResponsiveText(
              _getMoodEmoji(entry.mood),
              baseFontSize: 20.0,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  _getMoodLabel(entry.mood),
                  baseFontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
                ResponsiveText(
                  _formatDate(entry.date),
                  baseFontSize: 12.0,
                  color: AppTheme.textSecondary,
                ),
                if (entry.note != null && entry.note!.isNotEmpty) ...[
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4.0)),
                  ResponsiveText(
                    entry.note!,
                    baseFontSize: 12.0,
                    color: AppTheme.textLight,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
        _showMoodEntryDialog();
      },
      child: Icon(
        Icons.add_reaction,
        color: Colors.white,
        size: ResponsiveUtils.getResponsiveIconSize(context, 28.0),
      ),
    );
  }

  void _showMoodEntryDialog([int? selectedMood]) {
    showDialog(
      context: context,
      builder: (context) => MoodEntryDialog(
        initialMood: selectedMood,
        onMoodSaved: (mood, note) {
          context.read<MoodProvider>().addMoodEntry(mood, note);
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
        },
      ),
    );
  }

  void _showMoodInsights() {
    // Navigate to mood insights screen
  }

  void _exportMoodData() {
    // Export mood data functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم تصدير البيانات بنجاح'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 8.0),
        ),
      ),
    );
  }

  void _showFullHistory() {
    // Navigate to full mood history screen
  }

  Color _getMoodColor(int mood) {
    switch (mood) {
      case 1:
        return AppTheme.moodTerrible;
      case 2:
        return AppTheme.moodBad;
      case 3:
        return AppTheme.moodNeutral;
      case 4:
        return AppTheme.moodGood;
      case 5:
        return AppTheme.moodExcellent;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 1:
        return '😢';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'سيء جداً';
      case 2:
        return 'سيء';
      case 3:
        return 'عادي';
      case 4:
        return 'جيد';
      case 5:
        return 'ممتاز';
      default:
        return 'غير محدد';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'اليوم';
    } else if (difference == 1) {
      return 'أمس';
    } else if (difference < 7) {
      return 'منذ $difference أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Mood Entry Dialog Widget
class MoodEntryDialog extends StatefulWidget {
  final int? initialMood;
  final Function(int mood, String? note) onMoodSaved;

  const MoodEntryDialog({
    super.key,
    this.initialMood,
    required this.onMoodSaved,
  });

  @override
  State<MoodEntryDialog> createState() => _MoodEntryDialogState();
}

class _MoodEntryDialogState extends State<MoodEntryDialog> {
  int _selectedMood = 3;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialMood != null) {
      _selectedMood = widget.initialMood!;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveUtils.getCardWidth(context),
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 20.0),
        ),
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                    'كيف تشعر؟',
                    baseFontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 20.0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
              EnhancedMoodSelector(
                selectedMood: _selectedMood,
                onMoodSelected: (mood) {
                  setState(() {
                    _selectedMood = mood;
                  });
                },
                showLabels: true,
                size: 60.0,
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'أضف ملاحظة (اختياري)',
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
                    borderSide: const BorderSide(
                      color: AppTheme.dividerColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                        ),
                        side: const BorderSide(
                          color: AppTheme.dividerColor,
                          width: 1.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
                        ),
                      ),
                      child: const ResponsiveText(
                        'إلغاء',
                        baseFontSize: 14.0,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12.0)),
                  Expanded(
                    child: ResponsiveButton(
                      onPressed: () {
                        widget.onMoodSaved(_selectedMood, _noteController.text.trim());
                        Navigator.of(context).pop();
                      },
                      child: const ResponsiveText(
                        'حفظ',
                        baseFontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}