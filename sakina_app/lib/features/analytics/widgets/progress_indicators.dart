import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/themes/app_theme.dart';
import '../providers/analytics_provider.dart';

class ProgressIndicators extends StatelessWidget {
  final AnalyticsProvider analytics;

  const ProgressIndicators({super.key, required this.analytics});

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
          const Text(
            'مؤشرات التقدم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Overall progress circle
          _buildOverallProgress(),
          const SizedBox(height: 24),
          
          // Individual metrics
          _buildMetricProgress('تحسن المزاج', analytics.averageMood / 5, AppTheme.primaryColor, Icons.mood),
          const SizedBox(height: 12),
          _buildMetricProgress('مستوى الطاقة', analytics.averageEnergy / 5, AppTheme.successColor, Icons.battery_charging_full),
          const SizedBox(height: 12),
          _buildMetricProgress('جودة النوم', analytics.averageSleep / 5, AppTheme.infoColor, Icons.bedtime),
          const SizedBox(height: 12),
          _buildMetricProgress('الاستمرارية', analytics.trackingDays / 30, AppTheme.warningColor, Icons.calendar_today),
          const SizedBox(height: 24),
          
          // Weekly progress comparison
          _buildWeeklyProgress(),
        ],
      ),
    );
  }

  Widget _buildOverallProgress() {
    final overallScore = _calculateOverallScore();
    
    return Center(
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          children: [
            PieChart(
              PieChartData(
                startDegreeOffset: -90,
                sectionsSpace: 2,
                centerSpaceRadius: 35,
                sections: [
                  PieChartSectionData(
                    value: overallScore,
                    color: _getProgressColor(overallScore),
                    radius: 15,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 100 - overallScore,
                    color: Colors.grey.withOpacity(0.2),
                    radius: 15,
                    showTitle: false,
                  ),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${overallScore.toInt()}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getProgressColor(overallScore),
                    ),
                  ),
                  const Text(
                    'التقدم العام',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricProgress(String title, double progress, Color color, IconData icon) {
    final percentage = (progress * 100).clamp(0, 100);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${percentage.toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'التقدم الأسبوعي',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildWeeklyProgressItem(
                'هذا الأسبوع',
                analytics.averageMood,
                AppTheme.primaryColor,
                true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildWeeklyProgressItem(
                'الأسبوع الماضي',
                analytics.averageMood - 0.3, // Mock previous week data
                Colors.grey,
                false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildProgressTrend(),
      ],
    );
  }

  Widget _buildWeeklyProgressItem(String title, double value, Color color, bool isCurrent) {
    final progress = value / 5.0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: isCurrent ? Border.all(color: color.withOpacity(0.3)) : null,
      ),
      child: Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Center(
                  child: Text(
                    value.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTrend() {
    const improvement = 0.3; // Mock improvement data
    const isPositive = improvement > 0;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isPositive 
            ? AppTheme.successColor.withOpacity(0.1)
            : AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 16,
            color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isPositive 
                  ? 'تحسن بنسبة ${(improvement * 100).toInt()}% مقارنة بالأسبوع الماضي'
                  : 'انخفاض بنسبة ${(improvement.abs() * 100).toInt()}% مقارنة بالأسبوع الماضي',
              style: const TextStyle(
                fontSize: 11,
                color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateOverallScore() {
    double score = 0.0;
    int factors = 0;
    
    // Mood score (40% weight)
    score += (analytics.averageMood / 5.0) * 40;
    factors++;
    
    // Energy score (25% weight)
    if (analytics.averageEnergy > 0) {
      score += (analytics.averageEnergy / 5.0) * 25;
      factors++;
    }
    
    // Sleep score (25% weight)
    if (analytics.averageSleep > 0) {
      score += (analytics.averageSleep / 5.0) * 25;
      factors++;
    }
    
    // Consistency score (10% weight)
    final consistencyScore = (analytics.trackingDays / 30.0).clamp(0.0, 1.0);
    score += consistencyScore * 10;
    
    return score.clamp(0.0, 100.0);
  }

  Color _getProgressColor(double progress) {
    if (progress >= 80) {
      return Colors.green;
    } else if (progress >= 60) {
      return Colors.lightGreen;
    } else if (progress >= 40) {
      return Colors.orange;
    } else if (progress >= 20) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }
}