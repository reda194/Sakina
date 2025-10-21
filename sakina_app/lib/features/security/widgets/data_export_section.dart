import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../core/themes/app_theme.dart';
import '../providers/security_provider.dart';
import 'security_option_tile.dart';

class DataExportSection extends StatelessWidget {
  const DataExportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityProvider>(
      builder: (context, securityProvider, child) {
        return Column(
          children: [
            // Export Data
            SecurityActionTile(
              title: 'تصدير البيانات',
              subtitle: 'تحميل نسخة من جميع بياناتك',
              icon: Icons.download,
              onTap: () => _exportData(context, securityProvider),
              iconColor: AppTheme.infoColor,
            ),
            
            // Share Data
            SecurityActionTile(
              title: 'مشاركة البيانات',
              subtitle: 'مشاركة بياناتك مع تطبيق آخر أو خدمة',
              icon: Icons.share,
              onTap: () => _shareData(context, securityProvider),
              iconColor: AppTheme.primaryColor,
            ),
            
            // Backup Settings
            SecurityActionTile(
              title: 'نسخ احتياطي للإعدادات',
              subtitle: 'حفظ إعدادات التطبيق والأمان',
              icon: Icons.backup,
              onTap: () => _backupSettings(context, securityProvider),
              iconColor: AppTheme.successColor,
            ),
            
            const SizedBox(height: 16),
            
            // Danger Zone
            _buildDangerZone(context, securityProvider),
          ],
        );
      },
    );
  }

  Widget _buildDangerZone(BuildContext context, SecurityProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning,
                color: AppTheme.errorColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'منطقة الخطر',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          const Text(
            'العمليات التالية لا يمكن التراجع عنها. تأكد من إنشاء نسخة احتياطية قبل المتابعة.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          
          // Clear Cache
          SecurityActionTile(
            title: 'مسح التخزين المؤقت',
            subtitle: 'حذف الملفات المؤقتة والصور المحفوظة',
            icon: Icons.cleaning_services,
            onTap: () => _clearCache(context),
            iconColor: AppTheme.warningColor,
          ),
          
          // Reset Settings
          SecurityActionTile(
            title: 'إعادة تعيين الإعدادات',
            subtitle: 'إعادة جميع الإعدادات إلى القيم الافتراضية',
            icon: Icons.settings_backup_restore,
            onTap: () => _resetSettings(context, provider),
            isDestructive: true,
          ),
          
          // Delete All Data
          SecurityActionTile(
            title: 'حذف جميع البيانات',
            subtitle: 'حذف جميع بياناتك نهائياً من التطبيق',
            icon: Icons.delete_forever,
            onTap: () => _deleteAllData(context, provider),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, SecurityProvider provider) async {
    try {
      _showLoadingDialog(context, 'جاري تصدير البيانات...');
      
      final userData = await provider.exportUserData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(userData);
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/sakina_data_export.json');
      await file.writeAsString(jsonString);
      
      Navigator.pop(context); // Close loading dialog
      
      _showSuccessDialog(
        context,
        'تم التصدير بنجاح',
        'تم حفظ بياناتك في: ${file.path}',
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog(context, 'فشل في تصدير البيانات: $e');
    }
  }

  Future<void> _shareData(BuildContext context, SecurityProvider provider) async {
    try {
      _showLoadingDialog(context, 'جاري تحضير البيانات للمشاركة...');
      
      final userData = await provider.exportUserData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(userData);
      
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/sakina_data_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);
      
      Navigator.pop(context); // Close loading dialog
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'بيانات تطبيق سكينة',
        subject: 'تصدير بيانات سكينة',
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog(context, 'فشل في مشاركة البيانات: $e');
    }
  }

  Future<void> _backupSettings(BuildContext context, SecurityProvider provider) async {
    try {
      _showLoadingDialog(context, 'جاري إنشاء نسخة احتياطية...');
      
      final settings = provider.exportSecuritySettings();
      final jsonString = const JsonEncoder.withIndent('  ').convert({
        'backup_date': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
        'settings': settings,
      });
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/sakina_settings_backup.json');
      await file.writeAsString(jsonString);
      
      Navigator.pop(context); // Close loading dialog
      
      _showSuccessDialog(
        context,
        'تم إنشاء النسخة الاحتياطية',
        'تم حفظ إعداداتك في: ${file.path}',
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog(context, 'فشل في إنشاء النسخة الاحتياطية: $e');
    }
  }

  Future<void> _clearCache(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      'مسح التخزين المؤقت',
      'هل أنت متأكد من رغبتك في مسح جميع الملفات المؤقتة؟ هذا سيحرر مساحة تخزين ولكن قد يبطئ التطبيق مؤقتاً.',
    );
    
    if (confirmed) {
      try {
        _showLoadingDialog(context, 'جاري مسح التخزين المؤقت...');
        
        final tempDir = await getTemporaryDirectory();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
        
        Navigator.pop(context); // Close loading dialog
        
        _showSuccessDialog(
          context,
          'تم المسح بنجاح',
          'تم مسح جميع الملفات المؤقتة.',
        );
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        _showErrorDialog(context, 'فشل في مسح التخزين المؤقت: $e');
      }
    }
  }

  Future<void> _resetSettings(BuildContext context, SecurityProvider provider) async {
    final confirmed = await _showConfirmationDialog(
      context,
      'إعادة تعيين الإعدادات',
      'هل أنت متأكد من رغبتك في إعادة تعيين جميع الإعدادات؟ سيتم فقدان جميع التخصيصات الحالية.',
    );
    
    if (confirmed) {
      try {
        _showLoadingDialog(context, 'جاري إعادة تعيين الإعدادات...');
        
        await provider.resetSecuritySettings();
        
        Navigator.pop(context); // Close loading dialog
        
        _showSuccessDialog(
          context,
          'تم إعادة التعيين',
          'تم إعادة تعيين جميع الإعدادات إلى القيم الافتراضية.',
        );
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        _showErrorDialog(context, 'فشل في إعادة تعيين الإعدادات: $e');
      }
    }
  }

  Future<void> _deleteAllData(BuildContext context, SecurityProvider provider) async {
    final confirmed = await _showConfirmationDialog(
      context,
      'حذف جميع البيانات',
      'تحذير: هذا سيحذف جميع بياناتك نهائياً ولا يمكن التراجع عن هذا الإجراء. هل أنت متأكد؟',
      isDestructive: true,
    );
    
    if (confirmed) {
      final doubleConfirmed = await _showConfirmationDialog(
        context,
        'تأكيد نهائي',
        'هذا هو التأكيد الأخير. سيتم حذف جميع بياناتك نهائياً. هل تريد المتابعة؟',
        isDestructive: true,
      );
      
      if (doubleConfirmed) {
        try {
          _showLoadingDialog(context, 'جاري حذف البيانات...');
          
          await provider.deleteAllUserData();
          
          Navigator.pop(context); // Close loading dialog
          
          _showSuccessDialog(
            context,
            'تم الحذف',
            'تم حذف جميع بياناتك بنجاح.',
          );
        } catch (e) {
          Navigator.pop(context); // Close loading dialog
          _showErrorDialog(context, 'فشل في حذف البيانات: $e');
        }
      }
    }
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.successColor),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: AppTheme.errorColor),
            SizedBox(width: 8),
            Text('خطأ'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context,
    String title,
    String message, {
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isDestructive ? Icons.warning : Icons.help,
              color: isDestructive ? AppTheme.errorColor : AppTheme.warningColor,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: AppTheme.errorColor)
                : null,
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}