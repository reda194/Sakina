import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../providers/analytics_provider.dart';

class InsightsCard extends StatelessWidget {
  final AnalyticsProvider analytics;

  const InsightsCard({super.key, required this.analytics});

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
              const Icon(
                Icons.psychology,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'رؤى ذكية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildInsightScore(),
            ],
          ),
          const SizedBox(height: 16),
          
          // Mood patterns
          _buildMoodPatterns(),
          const SizedBox(height: 16),
          
          // Correlations
          _buildCorrelations(),
          const SizedBox(height: 16),
          
          // Recommendations
          _buildRecommendations(),
        ],
      ),
    );
  }

  Widget _buildInsightScore() {
    final score = _calculateInsightScore();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getScoreColor(score).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 16,
            color: _getScoreColor(score),
          ),
          const SizedBox(width: 4),
          Text(
            '${score.toStringAsFixed(1)}/5',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getScoreColor(score),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodPatterns() {
    final patterns = analytics.getMoodPatterns();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أنماط المزاج المكتشفة',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...patterns.map((pattern) => _buildPatternItem(pattern)),
      ],
    );
  }

  Widget _buildPatternItem(Map<String, dynamic> pattern) {
    final confidence = pattern['confidence'] as int;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pattern['pattern'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(confidence),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$confidence%',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            pattern['description'],
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelations() {
    final correlations = analytics.getCorrelations();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'العلاقات بين العوامل',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        _buildCorrelationItem(
          'المزاج والطاقة',
          correlations['mood_energy'] ?? 0.0,
          Icons.battery_charging_full,
        ),
        _buildCorrelationItem(
          'المزاج والنوم',
          correlations['mood_sleep'] ?? 0.0,
          Icons.bedtime,
        ),
        _buildCorrelationItem(
          'الطاقة والنوم',
          correlations['energy_sleep'] ?? 0.0,
          Icons.hotel,
        ),
      ],
    );
  }

  Widget _buildCorrelationItem(String title, double correlation, IconData icon) {
    final strength = _getCorrelationStrength(correlation);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: correlation.abs(),
              child: Container(
                decoration: BoxDecoration(
                  color: _getCorrelationColor(correlation),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            strength,
            style: TextStyle(
              fontSize: 10,
              color: _getCorrelationColor(correlation),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'توصيات مخصصة',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...analytics.recommendations.take(3).map((recommendation) => 
          _buildRecommendationItem(recommendation),
        ),
      ],
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.successColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 14,
            color: AppTheme.successColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              recommendation,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateInsightScore() {
    double score = 0.0;
    
    // Base score from mood average
    score += analytics.averageMood;
    
    // Bonus for tracking consistency
    if (analytics.trackingDays >= 7) score += 0.5;
    if (analytics.trackingDays >= 30) score += 0.5;
    
    // Bonus for balanced metrics
    if (analytics.averageEnergy >= 3.5) score += 0.3;
    if (analytics.averageSleep >= 3.5) score += 0.3;
    
    return score.clamp(0.0, 5.0);
  }

  Color _getScoreColor(double score) {
    if (score >= 4.0) {
      return Colors.green;
    } else if (score >= 3.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80) {
      return Colors.green;
    } else if (confidence >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getCorrelationStrength(double correlation) {
    final abs = correlation.abs();
    if (abs >= 0.8) {
      return 'قوية';
    } else if (abs >= 0.6) {
      return 'متوسطة';
    } else if (abs >= 0.3) {
      return 'ضعيفة';
    } else {
      return 'لا توجد';
    }
  }

  Color _getCorrelationColor(double correlation) {
    final abs = correlation.abs();
    if (abs >= 0.8) {
      return Colors.green;
    } else if (abs >= 0.6) {
      return Colors.blue;
    } else if (abs >= 0.3) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }
}