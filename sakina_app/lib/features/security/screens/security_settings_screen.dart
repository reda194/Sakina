import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/themes/app_theme.dart';
import '../providers/security_provider.dart';
import '../widgets/security_option_tile.dart';
import '../widgets/privacy_settings_section.dart';
import '../widgets/data_export_section.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() {
        _isBiometricAvailable = isAvailable && isDeviceSupported;
      });
    } catch (e) {
      setState(() {
        _isBiometricAvailable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('الأمان والخصوصية'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<SecurityProvider>(
        builder: (context, securityProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Security Header
                _buildSectionHeader(
                  'إعدادات الأمان',
                  'حماية بياناتك الشخصية',
                  Icons.security,
                ),
                const SizedBox(height: 16),
                
                // Biometric Authentication
                if (_isBiometricAvailable)
                  SecurityOptionTile(
                    title: 'المصادقة البيومترية',
                    subtitle: 'استخدم بصمة الإصبع أو التعرف على الوجه',
                    icon: Icons.fingerprint,
                    value: securityProvider.isBiometricEnabled,
                    onChanged: (value) => _toggleBiometric(securityProvider, value),
                  ),
                
                // PIN Lock
                SecurityOptionTile(
                  title: 'قفل برقم سري',
                  subtitle: 'حماية التطبيق برقم سري',
                  icon: Icons.lock,
                  value: securityProvider.isPinEnabled,
                  onChanged: (value) => _togglePin(securityProvider, value),
                ),
                
                // Auto Lock
                SecurityOptionTile(
                  title: 'القفل التلقائي',
                  subtitle: 'قفل التطبيق تلقائياً بعد فترة عدم النشاط',
                  icon: Icons.timer,
                  value: securityProvider.isAutoLockEnabled,
                  onChanged: (value) => securityProvider.setAutoLock(value),
                  trailing: securityProvider.isAutoLockEnabled
                      ? _buildAutoLockTimer(securityProvider)
                      : null,
                ),
                
                const SizedBox(height: 24),
                
                // Privacy Settings
                _buildSectionHeader(
                  'إعدادات الخصوصية',
                  'التحكم في مشاركة البيانات',
                  Icons.privacy_tip,
                ),
                const SizedBox(height: 16),
                
                const PrivacySettingsSection(),
                
                const SizedBox(height: 24),
                
                // Data Management
                _buildSectionHeader(
                  'إدارة البيانات',
                  'تصدير أو حذف بياناتك',
                  Icons.storage,
                ),
                const SizedBox(height: 16),
                
                const DataExportSection(),
                
                const SizedBox(height: 24),
                
                // Security Status
                _buildSecurityStatus(securityProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoLockTimer(SecurityProvider provider) {
    return GestureDetector(
      onTap: () => _showAutoLockOptions(provider),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          _getAutoLockText(provider.autoLockDuration),
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityStatus(SecurityProvider provider) {
    final securityLevel = _calculateSecurityLevel(provider);
    final color = _getSecurityColor(securityLevel);
    
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
              Icon(
                Icons.shield,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'مستوى الأمان',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Security Level Progress
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: securityLevel / 100,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${securityLevel.toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            _getSecurityLevelText(securityLevel),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          
          if (securityLevel < 80) ...[
            const SizedBox(height: 12),
            _buildSecurityRecommendations(provider),
          ],
        ],
      ),
    );
  }

  Widget _buildSecurityRecommendations(SecurityProvider provider) {
    final recommendations = <String>[];
    
    if (!provider.isBiometricEnabled && _isBiometricAvailable) {
      recommendations.add('تفعيل المصادقة البيومترية');
    }
    if (!provider.isPinEnabled) {
      recommendations.add('تفعيل القفل برقم سري');
    }
    if (!provider.isAutoLockEnabled) {
      recommendations.add('تفعيل القفل التلقائي');
    }
    
    if (recommendations.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.warningColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: AppTheme.warningColor,
              ),
              SizedBox(width: 8),
              Text(
                'توصيات لتحسين الأمان:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...recommendations.map(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.circle,
                    size: 6,
                    color: AppTheme.warningColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    rec,
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBiometric(SecurityProvider provider, bool value) async {
    if (value) {
      try {
        final isAuthenticated = await _localAuth.authenticate(
          localizedReason: 'تأكيد الهوية لتفعيل المصادقة البيومترية',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        
        if (isAuthenticated) {
          provider.setBiometric(true);
        }
      } catch (e) {
        _showErrorDialog('فشل في تفعيل المصادقة البيومترية');
      }
    } else {
      provider.setBiometric(false);
    }
  }

  Future<void> _togglePin(SecurityProvider provider, bool value) async {
    if (value) {
      final pin = await _showPinSetupDialog();
      if (pin != null && pin.length >= 4) {
        provider.setPin(pin);
      }
    } else {
      provider.removePin();
    }
  }

  Future<String?> _showPinSetupDialog() async {
    String pin = '';
    String confirmPin = '';
    bool isConfirming = false;
    
    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isConfirming ? 'تأكيد الرقم السري' : 'إنشاء رقم سري'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isConfirming 
                    ? 'أعد إدخال الرقم السري للتأكيد'
                    : 'أدخل رقم سري مكون من 4 أرقام على الأقل',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (value) {
                  if (isConfirming) {
                    confirmPin = value;
                  } else {
                    pin = value;
                  }
                },
                decoration: const InputDecoration(
                  hintText: '****',
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (isConfirming) {
                  if (pin == confirmPin) {
                    Navigator.pop(context, pin);
                  } else {
                    _showErrorDialog('الرقم السري غير متطابق');
                  }
                } else {
                  if (pin.length >= 4) {
                    setState(() {
                      isConfirming = true;
                    });
                  } else {
                    _showErrorDialog('الرقم السري يجب أن يكون 4 أرقام على الأقل');
                  }
                }
              },
              child: Text(isConfirming ? 'تأكيد' : 'التالي'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAutoLockOptions(SecurityProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'مدة القفل التلقائي',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...[30, 60, 300, 600, 1800].map(
              (seconds) => ListTile(
                title: Text(_getAutoLockText(seconds)),
                trailing: provider.autoLockDuration == seconds
                    ? const Icon(Icons.check, color: AppTheme.primaryColor)
                    : null,
                onTap: () {
                  provider.setAutoLockDuration(seconds);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ'),
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

  double _calculateSecurityLevel(SecurityProvider provider) {
    double level = 0;
    
    if (provider.isBiometricEnabled) level += 40;
    if (provider.isPinEnabled) level += 30;
    if (provider.isAutoLockEnabled) level += 20;
    if (provider.isDataEncrypted) level += 10;
    
    return level;
  }

  Color _getSecurityColor(double level) {
    if (level >= 80) return Colors.green;
    if (level >= 60) return Colors.lightGreen;
    if (level >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getSecurityLevelText(double level) {
    if (level >= 80) return 'مستوى أمان ممتاز - بياناتك محمية بشكل جيد';
    if (level >= 60) return 'مستوى أمان جيد - يمكن تحسينه';
    if (level >= 40) return 'مستوى أمان متوسط - يحتاج تحسين';
    return 'مستوى أمان ضعيف - يحتاج تحسين عاجل';
  }

  String _getAutoLockText(int seconds) {
    if (seconds < 60) return '$seconds ثانية';
    if (seconds < 3600) return '${seconds ~/ 60} دقيقة';
    return '${seconds ~/ 3600} ساعة';
  }
}