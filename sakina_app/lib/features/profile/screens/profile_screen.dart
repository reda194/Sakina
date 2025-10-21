import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'ض',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'ضيف',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'guest@sakina.com',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Profile Options
            _buildProfileOption(
              context,
              icon: Icons.person_outline,
              title: 'معلومات الحساب',
              onTap: () {
                // Navigate to account info
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.notifications_outlined,
              title: 'الإشعارات',
              onTap: () {
                // Navigate to notifications settings
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.security_outlined,
              title: 'الخصوصية والأمان',
              onTap: () {
                // Navigate to privacy settings
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.language_outlined,
              title: 'اللغة',
              subtitle: 'العربية',
              onTap: () {
                // Navigate to language settings
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.dark_mode_outlined,
              title: 'المظهر',
              subtitle: 'فاتح',
              onTap: () {
                // Navigate to theme settings
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.help_outline,
              title: 'المساعدة والدعم',
              onTap: () {
                // Navigate to help
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.info_outline,
              title: 'عن التطبيق',
              onTap: () {
                // Navigate to about
              },
            ),
            const SizedBox(height: 20),
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                label: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.errorColor),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
