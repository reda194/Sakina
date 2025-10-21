import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/themes/app_theme.dart';
import '../providers/analytics_provider.dart';
import '../widgets/mood_trend_chart.dart';
import '../widgets/weekly_summary_card.dart';
import '../widgets/insights_card.dart';
import '../widgets/progress_indicators.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadAnalytics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'لوحة التحليلات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
              context.read<AnalyticsProvider>().changePeriod(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'week',
                child: Text('هذا الأسبوع'),
              ),
              const PopupMenuItem(
                value: 'month',
                child: Text('هذا الشهر'),
              ),
              const PopupMenuItem(
                value: 'quarter',
                child: Text('آخر 3 أشهر'),
              ),
              const PopupMenuItem(
                value: 'year',
                child: Text('هذا العام'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'نظرة عامة'),
            Tab(text: 'المزاج'),
            Tab(text: 'التقدم'),
            Tab(text: 'التقارير'),
          ],
        ),
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, analytics, child) {
          if (analytics.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(analytics),
              _buildMoodTab(analytics),
              _buildProgressTab(analytics),
              _buildReportsTab(analytics),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(AnalyticsProvider analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'متوسط المزاج',
                  analytics.averageMood.toStringAsFixed(1),
                  Icons.mood,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'أيام التتبع',
                  analytics.trackingDays.toString(),
                  Icons.calendar_today,
                  AppTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'مستوى الطاقة',
                  analytics.averageEnergy.toStringAsFixed(1),
                  Icons.battery_charging_full,
                  AppTheme.warningColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'جودة النوم',
                  analytics.averageSleep.toStringAsFixed(1),
                  Icons.bedtime,
                  AppTheme.infoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Weekly Summary
          WeeklySummaryCard(analytics: analytics),
          const SizedBox(height: 24),
          
          // Insights
          InsightsCard(analytics: analytics),
        ],
      ),
    );
  }

  Widget _buildMoodTab(AnalyticsProvider analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mood Trend Chart
          MoodTrendChart(analytics: analytics),
          const SizedBox(height: 24),
          
          // Mood Distribution
          _buildMoodDistribution(analytics),
          const SizedBox(height: 24),
          
          // Triggers Analysis
          _buildTriggersAnalysis(analytics),
        ],
      ),
    );
  }

  Widget _buildProgressTab(AnalyticsProvider analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProgressIndicators(analytics: analytics),
          const SizedBox(height: 24),
          
          // Goals Progress
          _buildGoalsProgress(analytics),
          const SizedBox(height: 24),
          
          // Achievements
          _buildAchievements(analytics),
        ],
      ),
    );
  }

  Widget _buildReportsTab(AnalyticsProvider analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export Options
          _buildExportOptions(),
          const SizedBox(height: 24),
          
          // Detailed Report
          _buildDetailedReport(analytics),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodDistribution(AnalyticsProvider analytics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'توزيع المزاج',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: analytics.moodDistribution.entries.map((entry) {
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    title: '${entry.value}%',
                    color: _getMoodColor(entry.key),
                    radius: 60,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggersAnalysis(AnalyticsProvider analytics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'أكثر المحفزات تأثيراً',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...analytics.topTriggers.map((trigger) => 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(trigger['name']),
                  ),
                  Text(
                    '${trigger['count']} مرة',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsProgress(AnalyticsProvider analytics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تقدم الأهداف',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...analytics.goals.map((goal) => 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(goal['title']),
                      ),
                      Text(
                        '${goal['progress']}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: goal['progress'] / 100.0,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(AnalyticsProvider analytics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الإنجازات الأخيرة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...analytics.achievements.map((achievement) => 
            ListTile(
              leading: Icon(
                achievement['icon'],
                color: AppTheme.primaryColor,
              ),
              title: Text(achievement['title']),
              subtitle: Text(achievement['description']),
              trailing: Text(
                achievement['date'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تصدير التقارير',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Export as PDF
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Export as Excel
                  },
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedReport(AnalyticsProvider analytics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'التقرير التفصيلي',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'فترة التقرير: ${_getPeriodText()}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildReportSection('ملخص المزاج', analytics.moodSummary),
          _buildReportSection('التحسينات', analytics.improvements),
          _buildReportSection('التوصيات', analytics.recommendations),
        ],
      ),
    );
  }

  Widget _buildReportSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(child: Text(item)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'ممتاز':
        return Colors.green;
      case 'جيد':
        return Colors.lightGreen;
      case 'عادي':
        return Colors.yellow;
      case 'سيء':
        return Colors.orange;
      case 'سيء جداً':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPeriodText() {
    switch (_selectedPeriod) {
      case 'week':
        return 'هذا الأسبوع';
      case 'month':
        return 'هذا الشهر';
      case 'quarter':
        return 'آخر 3 أشهر';
      case 'year':
        return 'هذا العام';
      default:
        return 'هذا الأسبوع';
    }
  }
}