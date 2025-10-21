import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../providers/analytics_provider.dart';

class WeeklySummaryCard extends StatelessWidget {
  final AnalyticsProvider analytics;

  const WeeklySummaryCard({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'ملخص الأسبوع',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildTrendIndicator(),
            ],
          ),
          const SizedBox(height: 16),
          
          // Weekly comparison
          _buildWeeklyComparison(),
          const SizedBox(height: 16),
          
          // Daily breakdown
          _buildDailyBreakdown(),
          const SizedBox(height: 16),
          
          // Key insights
          _buildKeyInsights(),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final comparison = analytics.getWeeklyComparison();
    final change = comparison['change'] ?? 0.0;
    final isPositive = change >= 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPositive 
            ? AppTheme.successColor.withOpacity(0.1)
            : AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 16,
            color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
          ),
          const SizedBox(width: 4),
          Text(
            '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyComparison() {
    final comparison = analytics.getWeeklyComparison();
    final thisWeek = comparison['thisWeek'] ?? 0.0;
    final lastWeek = comparison['lastWeek'] ?? 0.0;
    
    return Row(
      children: [
        Expanded(
          child: _buildComparisonItem(
            'هذا الأسبوع',
            thisWeek.toStringAsFixed(1),
            AppTheme.primaryColor,
            true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildComparisonItem(
            'الأسبوع الماضي',
            lastWeek.toStringAsFixed(1),
            Colors.grey,
            false,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonItem(String label, String value, Color color, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: isCurrent ? Border.all(color: color.withOpacity(0.3)) : null,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'التفصيل اليومي',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: Row(
            children: _buildDailyBars(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDailyBars() {
    final days = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];
    final values = [3.5, 4.0, 3.2, 4.5, 3.8, 4.2, 3.9]; // Mock data
    
    return List.generate(7, (index) {
      final value = values[index];
      final height = (value / 5.0) * 40; // Scale to 40px max height
      
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: height,
                decoration: BoxDecoration(
                  color: _getMoodColor(value),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                days[index],
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildKeyInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نقاط مهمة',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        _buildInsightItem(
          Icons.trending_up,
          'تحسن في المزاج خلال نهاية الأسبوع',
          AppTheme.successColor,
        ),
        _buildInsightItem(
          Icons.schedule,
          'أفضل أوقاتك: الصباح الباكر',
          AppTheme.infoColor,
        ),
        _buildInsightItem(
          Icons.warning_amber,
          'انتبه لمستوى التوتر يوم الثلاثاء',
          AppTheme.warningColor,
        ),
      ],
    );
  }

  Widget _buildInsightItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(double value) {
    if (value >= 4.5) {
      return Colors.green;
    } else if (value >= 3.5) {
      return Colors.lightGreen;
    } else if (value >= 2.5) {
      return Colors.yellow;
    } else if (value >= 1.5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}