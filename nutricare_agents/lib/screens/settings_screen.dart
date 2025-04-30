import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutricare_agents/utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  String _language = 'Tiếng Việt';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settingsBox = Hive.box('userPreferences');
    setState(() {
      _darkMode = settingsBox.get('darkMode', defaultValue: false);
      _notifications = settingsBox.get('notifications', defaultValue: true);
      _language = settingsBox.get('language', defaultValue: 'Tiếng Việt');
    });
  }

  Future<void> _saveSettings() async {
    final settingsBox = Hive.box('userPreferences');
    await settingsBox.put('darkMode', _darkMode);
    await settingsBox.put('notifications', _notifications);
    await settingsBox.put('language', _language);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme settings
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giao diện',
                    style: AppTextStyles.heading2,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Chế độ tối'),
                    subtitle: const Text('Bật chế độ tối cho ứng dụng'),
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                      _saveSettings();
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Notification settings
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông báo',
                    style: AppTextStyles.heading2,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Nhận thông báo'),
                    subtitle: const Text('Bật thông báo từ ứng dụng'),
                    value: _notifications,
                    onChanged: (value) {
                      setState(() {
                        _notifications = value;
                      });
                      _saveSettings();
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Language settings
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ngôn ngữ',
                    style: AppTextStyles.heading2,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Ngôn ngữ hiện tại'),
                    subtitle: Text(_language),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Show language selection dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Chọn ngôn ngữ'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text('Tiếng Việt'),
                                onTap: () {
                                  setState(() {
                                    _language = 'Tiếng Việt';
                                  });
                                  _saveSettings();
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text('English'),
                                onTap: () {
                                  setState(() {
                                    _language = 'English';
                                  });
                                  _saveSettings();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // About section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin',
                    style: AppTextStyles.heading2,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Phiên bản'),
                    subtitle: const Text('1.0.0'),
                  ),
                  ListTile(
                    title: const Text('Điều khoản sử dụng'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to terms of service
                    },
                  ),
                  ListTile(
                    title: const Text('Chính sách bảo mật'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to privacy policy
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}