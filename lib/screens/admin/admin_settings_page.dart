import 'package:flutter/material.dart';
import '../../services/constants.dart';
import '../../services/firestore_service.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppConstants.warningColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _firestoreService.getAdminSettings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  AppConstants.formatError(snapshot.error!),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final settings = snapshot.data ?? {};
          final bool emailAlerts = settings['emailAlerts'] ?? true;
          final bool autoApprove = settings['autoApproveBookings'] ?? false;
          final bool maintenanceMode = settings['maintenanceMode'] ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Preferences',
                  style: AppConstants.subHeadingStyle,
                ),
                const SizedBox(height: 12),
                _buildSwitchTile(
                  title: 'Email alerts',
                  subtitle: 'Receive daily summaries and system alerts.',
                  value: emailAlerts,
                  onChanged: (value) => _updateSetting('emailAlerts', value),
                ),
                _buildSwitchTile(
                  title: 'Auto-approve bookings',
                  subtitle:
                      'Approve bookings instantly when seats are available.',
                  value: autoApprove,
                  onChanged: (value) =>
                      _updateSetting('autoApproveBookings', value),
                ),
                _buildSwitchTile(
                  title: 'Maintenance mode',
                  subtitle: 'Temporarily disable new bookings during updates.',
                  value: maintenanceMode,
                  onChanged: (value) =>
                      _updateSetting('maintenanceMode', value),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }

  Future<void> _updateSetting(String key, bool value) async {
    try {
      await _firestoreService.updateAdminSettings({key: value});
    } catch (e) {
      if (!mounted) return;
      AppConstants.showSnackBar(
        context,
        'Failed to update settings: ${AppConstants.formatError(e)}',
        isError: true,
      );
    }
  }
}
