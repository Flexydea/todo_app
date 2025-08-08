import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late final Box _settings;
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _settings = Hive.box('settingsBox'); // make sure it's opened in main.dart
    _enabled = _settings.get('notif_enabled', defaultValue: true);
  }

  Future<void> _toggle(bool v) async {
    setState(() => _enabled = v);
    await _settings.put('notif_enabled', v);
    // optional: toast
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(v ? 'Notifications enabled' : 'Notifications disabled')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Notification Settings'),
          backgroundColor: Colors.green),
      body: SwitchListTile.adaptive(
        title: const Text('Enable notifications'),
        value: _enabled,
        onChanged: _toggle,
      ),
    );
  }
}
