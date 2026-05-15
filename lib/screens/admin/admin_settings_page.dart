import 'package:flutter/material.dart';
import '../../services/constants.dart';
import '../../services/firestore_service.dart';
import '../../auth/auth_service.dart';
import '../../models/user_model.dart';

class AdminSettingsPage extends StatefulWidget {
  final UserModel user;

  const AdminSettingsPage({super.key, required this.user});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _updatingProfile = false;
  bool _updatingPassword = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
                const SizedBox(height: 24),
                const Text(
                  'Account Settings',
                  style: AppConstants.subHeadingStyle,
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            hintText: widget.user.email,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updatingProfile ? null : _saveProfile,
                            child: _updatingProfile
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrent,
                          decoration: InputDecoration(
                            labelText: 'Current Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureCurrent
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureCurrent = !_obscureCurrent;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: _obscureNew,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: const Icon(Icons.lock_reset),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNew
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNew = !_obscureNew;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            labelText: 'Confirm New Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirm = !_obscureConfirm;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updatingPassword
                                ? null
                                : _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.warningColor,
                              foregroundColor: Colors.white,
                            ),
                            child: _updatingPassword
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Update Password'),
                          ),
                        ),
                      ],
                    ),
                  ),
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

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppConstants.showSnackBar(context, 'Name cannot be empty.', isError: true);
      return;
    }

    setState(() => _updatingProfile = true);
    try {
      await _firestoreService.updateUserProfile(uid: widget.user.uid, name: name);
      await _authService.updateDisplayName(name);
      if (mounted) {
        AppConstants.showSnackBar(context, 'Profile updated successfully.');
      }
    } catch (e) {
      if (!mounted) return;
      AppConstants.showSnackBar(
        context,
        'Failed to update profile: ${AppConstants.formatError(e)}',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _updatingProfile = false);
    }
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      AppConstants.showSnackBar(
        context,
        'Please fill in all password fields.',
        isError: true,
      );
      return;
    }
    if (newPassword.length < 6) {
      AppConstants.showSnackBar(
        context,
        'Password must be at least 6 characters.',
        isError: true,
      );
      return;
    }
    if (newPassword != confirmPassword) {
      AppConstants.showSnackBar(
        context,
        'New passwords do not match.',
        isError: true,
      );
      return;
    }

    setState(() => _updatingPassword = true);
    try {
      await _authService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      if (mounted) {
        AppConstants.showSnackBar(context, 'Password updated successfully.');
      }
    } catch (e) {
      if (!mounted) return;
      AppConstants.showSnackBar(
        context,
        'Failed to update password: ${AppConstants.formatError(e)}',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _updatingPassword = false);
    }
  }
}
