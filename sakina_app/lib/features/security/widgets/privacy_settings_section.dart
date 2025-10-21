import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../providers/security_provider.dart';
import 'security_option_tile.dart';

class PrivacySettingsSection extends StatelessWidget {
  const PrivacySettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityProvider>(
      builder: (context, securityProvider, child) {
        return Column(
          children: [
            // Analytics
            SecurityOptionTile(
              title: 'تحليلات الاستخدام',
              subtitle: 'مساعدتنا في تحسين التطبيق من خلال بيانات الاستخدام المجهولة',
              icon: Icons.analytics,
              value: securityProvider.isAnalyticsEnabled,
              onChanged: (value) => securityProvider.setAnalytics(value),
              iconColor: AppTheme.infoColor,
            ),
            
            // Crash Reporting
            SecurityOptionTile(
              title: 'تقارير الأخطاء',
              subtitle: 'إرسال تقارير الأخطاء تلقائياً لتحسين استقرار التطبيق',
              icon: Icons.bug_report,
              value: securityProvider.isCrashReportingEnabled,
              onChanged: (value) => securityProvider.setCrashReporting(value),
              iconColor: AppTheme.warningColor,
            ),
            
            // Data Sharing
            SecurityOptionTile(
              title: 'مشاركة البيانات',
              subtitle: 'مشاركة البيانات مع شركاء موثوقين لتحسين الخدمات',
              icon: Icons.share,
              value: securityProvider.isDataSharingEnabled,
              onChanged: (value) => _showDataSharingDialog(context, securityProvider, value),
              iconColor: AppTheme.errorColor,
            ),
            
            // Location Tracking
            SecurityOptionTile(
              title: 'تتبع الموقع',
              subtitle: 'استخدام موقعك لتقديم خدمات مخصصة حسب المنطقة',
              icon: Icons.location_on,
              value: securityProvider.isLocationTrackingEnabled,
              onChanged: (value) => _showLocationDialog(context, securityProvider, value),
              iconColor: AppTheme.warningColor,
            ),
            
            const SizedBox(height: 16),
            
            // Privacy Policy
            SecurityInfoTile(
              title: 'سياسة الخصوصية',
              subtitle: 'اطلع على كيفية حماية بياناتك',
              icon: Icons.policy,
              onTap: () => _showPrivacyPolicy(context),
              iconColor: AppTheme.primaryColor,
            ),
            
            // Terms of Service
            SecurityInfoTile(
              title: 'شروط الخدمة',
              subtitle: 'اطلع على شروط استخدام التطبيق',
              icon: Icons.description,
              onTap: () => _showTermsOfService(context),
              iconColor: AppTheme.primaryColor,
            ),
            
            const SizedBox(height: 16),
            
            // Privacy Summary
            _buildPrivacySummary(securityProvider),
          ],
        );
      },
    );
  }

  Widget _buildPrivacySummary(SecurityProvider provider) {
    final privacyScore = _calculatePrivacyScore(provider);
    final color = _getPrivacyColor(privacyScore);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
              Icon(
                Icons.privacy_tip,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'ملخص الخصوصية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Privacy Score
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: privacyScore / 100,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${privacyScore.toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Text(
            _getPrivacyScoreText(privacyScore),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Privacy Details
          _buildPrivacyDetails(provider),
        ],
      ),
    );
  }

  Widget _buildPrivacyDetails(SecurityProvider provider) {
    return Column(
      children: [
        _buildPrivacyDetailRow(
          'تحليلات الاستخدام',
          provider.isAnalyticsEnabled ? 'مفعل' : 'معطل',
          provider.isAnalyticsEnabled ? AppTheme.warningColor : AppTheme.successColor,
        ),
        _buildPrivacyDetailRow(
          'تقارير الأخطاء',
          provider.isCrashReportingEnabled ? 'مفعل' : 'معطل',
          provider.isCrashReportingEnabled ? AppTheme.warningColor : AppTheme.successColor,
        ),
        _buildPrivacyDetailRow(
          'مشاركة البيانات',
          provider.isDataSharingEnabled ? 'مفعل' : 'معطل',
          provider.isDataSharingEnabled ? AppTheme.errorColor : AppTheme.successColor,
        ),
        _buildPrivacyDetailRow(
          'تتبع الموقع',
          provider.isLocationTrackingEnabled ? 'مفعل' : 'معطل',
          provider.isLocationTrackingEnabled ? AppTheme.errorColor : AppTheme.successColor,
        ),
      ],
    );
  }

  Widget _buildPrivacyDetailRow(String title, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDataSharingDialog(BuildContext context, SecurityProvider provider, bool value) {
    if (value) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تأكيد مشاركة البيانات'),
          content: const Text(
            'هل أنت متأكد من رغبتك في مشاركة بياناتك؟ سيتم مشاركة البيانات المجهولة فقط مع شركاء موثوقين لتحسين الخدمات.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                provider.setDataSharing(true);
                Navigator.pop(context);
              },
              child: const Text('موافق'),
            ),
          ],
        ),
      );
    } else {
      provider.setDataSharing(false);
    }
  }

  void _showLocationDialog(BuildContext context, SecurityProvider provider, bool value) {
    if (value) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تأكيد تتبع الموقع'),
          content: const Text(
            'هل تريد السماح للتطبيق بالوصول إلى موقعك؟ سيتم استخدام هذه المعلومات لتقديم خدمات مخصصة حسب منطقتك.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                provider.setLocationTracking(true);
                Navigator.pop(context);
              },
              child: const Text('موافق'),
            ),
          ],
        ),
      );
    } else {
      provider.setLocationTracking(false);
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سياسة الخصوصية'),
        content: const SingleChildScrollView(
          child: Text(
            'نحن في تطبيق سكينة نلتزم بحماية خصوصيتك وبياناتك الشخصية.\n\n'
            '• نجمع البيانات الضرورية فقط لتشغيل التطبيق\n'
            '• لا نشارك بياناتك مع أطراف ثالثة بدون موافقتك\n'
            '• نستخدم التشفير لحماية بياناتك\n'
            '• يمكنك حذف بياناتك في أي وقت\n\n'
            'لمزيد من التفاصيل، يرجى زيارة موقعنا الإلكتروني.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('شروط الخدمة'),
        content: const SingleChildScrollView(
          child: Text(
            'باستخدام تطبيق سكينة، فإنك توافق على الشروط التالية:\n\n'
            '• استخدام التطبيق للأغراض المشروعة فقط\n'
            '• عدم مشاركة معلومات حساسة أو شخصية\n'
            '• احترام حقوق المستخدمين الآخرين\n'
            '• الالتزام بالقوانين المحلية والدولية\n\n'
            'نحتفظ بالحق في تعديل هذه الشروط في أي وقت.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  double _calculatePrivacyScore(SecurityProvider provider) {
    double score = 100;
    
    if (provider.isAnalyticsEnabled) score -= 15;
    if (provider.isCrashReportingEnabled) score -= 10;
    if (provider.isDataSharingEnabled) score -= 40;
    if (provider.isLocationTrackingEnabled) score -= 25;
    
    return score.clamp(0, 100);
  }

  Color _getPrivacyColor(double score) {
    if (score >= 80) return AppTheme.successColor;
    if (score >= 60) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String _getPrivacyScoreText(double score) {
    if (score >= 80) return 'مستوى خصوصية ممتاز - بياناتك محمية جيداً';
    if (score >= 60) return 'مستوى خصوصية جيد - يمكن تحسينه';
    return 'مستوى خصوصية منخفض - راجع إعداداتك';
  }
}