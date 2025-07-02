import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../models/settings.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Section
                _buildUserProfileSection(context, viewModel),
                
                SizedBox(height: 24),
                
                // UI Mode Section
                _buildUIModeSection(context, viewModel),
                
                SizedBox(height: 24),
                
                // Security Section
                _buildSecuritySection(context, viewModel),
                
                SizedBox(height: 24),
                
                // Notifications Section
                _buildNotificationsSection(context, viewModel),
                
                SizedBox(height: 24),
                
                // Data & Backup Section
                _buildDataBackupSection(context, viewModel),
                
                SizedBox(height: 24),
                
                // App Preferences Section
                _buildAppPreferencesSection(context, viewModel),
                
                SizedBox(height: 24),
                
                // About Section
                _buildAboutSection(context, viewModel),
                
                SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserProfileSection(BuildContext context, SettingsViewModel viewModel) {
    return _buildSection(
      'Profile',
      [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  'D',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daud Raza',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Self-taught Entrepreneur',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'U.S. Dispatch Hours',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit,
                color: Colors.white.withOpacity(0.8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUIModeSection(BuildContext context, SettingsViewModel viewModel) {
    return _buildSection(
      'UI Mode',
      [
        _buildUIModeCard(
          'Warrior Mode',
          'High-energy interface for peak performance',
          Icons.flash_on,
          Colors.red,
          UIMode.warrior,
          viewModel,
        ),
        SizedBox(height: 12),
        _buildUIModeCard(
          'Clarity Mode',
          'Clean, minimal interface for focus',
          Icons.visibility,
          Colors.blue,
          UIMode.clarity,
          viewModel,
        ),
        SizedBox(height: 12),
        _buildUIModeCard(
          'Dark Mode',
          'Easy on the eyes for night work',
          Icons.dark_mode,
          Colors.grey[800]!,
          UIMode.dark,
          viewModel,
        ),
        SizedBox(height: 12),
        _buildUIModeCard(
          'Light Mode',
          'Bright and energetic for day use',
          Icons.light_mode,
          Colors.orange,
          UIMode.light,
          viewModel,
        ),
      ],
    );
  }

  Widget _buildUIModeCard(
    String title,
    String description,
    IconData icon,
    Color color,
    UIMode mode,
    SettingsViewModel viewModel,
  ) {
    final isSelected = viewModel.settings?.uiMode == mode;
    
    return GestureDetector(
      onTap: () => viewModel.updateUIMode(mode),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection(BuildContext context, SettingsViewModel viewModel) {
    return _buildSection(
      'Security',
      [
        _buildSettingsTile(
          'App Lock',
          'Secure your app with PIN or biometric',
          Icons.lock,
          trailing: Switch(
            value: viewModel.settings?.appLockEnabled ?? false,
            onChanged: (value) => viewModel.toggleAppLock(value),
          ),
        ),
        if (viewModel.settings?.appLockEnabled == true) ...[
          SizedBox(height: 8),
          _buildSettingsTile(
            'Biometric Authentication',
            'Use fingerprint or face unlock',
            Icons.fingerprint,
            trailing: Switch(
              value: viewModel.settings?.biometricEnabled ?? false,
              onChanged: (value) => viewModel.toggleBiometric(value),
            ),
          ),
          SizedBox(height: 8),
          _buildSettingsTile(
            'Change PIN',
            'Update your security PIN',
            Icons.pin,
            onTap: () => _showChangePinDialog(context, viewModel),
          ),
        ],
      ],
    );
  }

  Widget _buildNotificationsSection(BuildContext context, SettingsViewModel viewModel) {
    return _buildSection(
      'Notifications',
      [
        _buildSettingsTile(
          'Push Notifications',
          'Receive app notifications',
          Icons.notifications,
          trailing: Switch(
            value: viewModel.settings?.notificationsEnabled ?? true,
            onChanged: (value) => viewModel.toggleNotifications(value),
          ),
        ),
        SizedBox(height: 8),
        _buildSettingsTile(
          'Habit Reminders',
          'Get reminded about your habits',
          Icons.alarm,
          trailing: Switch(
            value: viewModel.settings?.habitRemindersEnabled ?? true,
            onChanged: (value) => viewModel.toggleHabitReminders(value),
          ),
        ),
        SizedBox(height: 8),
        _buildSettingsTile(
          'Motivational Quotes',
          'Daily inspiration notifications',
          Icons.format_quote,
          trailing: Switch(
            value: viewModel.settings?.motivationalQuotesEnabled ?? true,
            onChanged: (value) => viewModel.toggleMotivationalQuotes(value),
          ),
        ),
      ],
    );
  }

  Widget _buildDataBackupSection(BuildContext context, SettingsViewModel viewModel) {
    return _buildSection(
      'Data & Backup',
      [
        _buildSettingsTile(
          'Firebase Backup',
          'Sync data to cloud automatically',
          Icons.cloud_upload,
          trailing: Switch(
            value: viewModel.settings?.firebaseBackupEnabled ?? false,
            onChanged: (value) => viewModel.toggleFirebaseBackup(value),
          ),
        ),
        SizedBox(height: 8),
        _buildSettingsTile(
          'Auto Sync',
          'Sync data when connected to WiFi',
          Icons.sync,
          trailing: Switch(
            value: viewModel.settings?.autoSyncEnabled ?? true,
            onChanged: (value) => viewModel.toggleAutoSync(value),
          ),
        ),
        SizedBox(height: 8),
        _buildSettingsTile(
          'Manual Backup',
          'Backup your data now',
          Icons.backup,
          onTap: () => viewModel.performManualBackup(),
          trailing: viewModel.isBackingUp
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.arrow_forward_ios, size: 16),
        ),
        SizedBox(height: 8),
        _buildSettingsTile(
          'Export Data',
          'Download your data as JSON',
          Icons.download,
          onTap: () => viewModel.exportData(),
        ),
      ],
    );
  }

  Widget _buildAppPreferencesSection(BuildContext context, SettingsViewModel viewModel) {
    return _buildSection(
      'App Preferences',
      [
        _buildSettingsTile(
          'Language',
          'English',
          Icons.language,
          onTap: () => _showLanguageDialog(context, viewModel),
        ),
        SizedBox(height: 8),
        _buildSettingsTile(
          'Time Zone',
          'Pakistan Standard Time (PKT)',
          Icons.schedule,
          onTap: () => _showTimezoneDialog(context, viewModel),
        ),
        SizedBox(height: 8),
        _buildSettingsTile(
          'Work Schedule',
          '6 PM - 6 AM (U.S. Dispatch)',
          Icons.work,
          onTap: () => _showWorkScheduleDialog(context, viewModel),
        ),
        SizedBox(height: 8),
        _buildSettingsTile(
          'Reset App',
          'Clear all data and start fresh',
          Icons.refresh,
          onTap: () => _showResetDialog(context, viewModel),
          textColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, SettingsViewModel viewModel) {
    return _buildSection(
      'About',
      [
        _buildSettingsTile(
          'Version',
          '1.0.0 (Build 1)',
          Icons.info,
        ),
        SizedBox(height: 8),
        _buildSettingsTile(
          'Privacy Policy',
          'Read our privacy policy',
          Icons.privacy_tip,
          onTap: () => _showPrivacyPolicy(context),
        ),
        SizedBox(height: 8),
        _buildSettingsTile(
          'Terms of Service',
          'Read our terms of service',
          Icons.description,
          onTap: () => _showTermsOfService(context),
        ),
        SizedBox(height: 8),
        _buildSettingsTile(
          'Contact Support',
          'Get help with the app',
          Icons.support,
          onTap: () => _showContactSupport(context),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: textColor ?? Colors.grey[700]),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: trailing ?? (onTap != null ? Icon(Icons.arrow_forward_ios, size: 16) : null),
      onTap: onTap,
    );
  }

  void _showChangePinDialog(BuildContext context, SettingsViewModel viewModel) {
    // Implementation for changing PIN
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change PIN'),
        content: Text('PIN change functionality would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsViewModel viewModel) {
    // Implementation for language selection
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language'),
        content: Text('Language selection would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showTimezoneDialog(BuildContext context, SettingsViewModel viewModel) {
    // Implementation for timezone selection
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Time Zone'),
        content: Text('Timezone selection would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showWorkScheduleDialog(BuildContext context, SettingsViewModel viewModel) {
    // Implementation for work schedule configuration
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Work Schedule'),
        content: Text('Work schedule configuration would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset App'),
        content: Text('This will delete all your data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.resetApp();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    // Implementation for privacy policy
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: Text('Privacy policy content would be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    // Implementation for terms of service
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms of Service'),
        content: Text('Terms of service content would be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showContactSupport(BuildContext context) {
    // Implementation for contact support
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact Support'),
        content: Text('Support contact information would be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

