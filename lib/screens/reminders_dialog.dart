// screens/reminders_dialog.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemindersDialog extends StatefulWidget {
  const RemindersDialog({super.key});

  @override
  State<RemindersDialog> createState() => _RemindersDialogState();
}

class _RemindersDialogState extends State<RemindersDialog> {
  bool morningRunEnabled = false;
  bool eveningWalkEnabled = false;
  bool weekendHikeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      morningRunEnabled = prefs.getBool('morning_run_enabled') ?? false;
      eveningWalkEnabled = prefs.getBool('evening_walk_enabled') ?? false;
      weekendHikeEnabled = prefs.getBool('weekend_hike_enabled') ?? false;
    });
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('morning_run_enabled', morningRunEnabled);
    await prefs.setBool('evening_walk_enabled', eveningWalkEnabled);
    await prefs.setBool('weekend_hike_enabled', weekendHikeEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Workout Reminders'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildReminderItem('Morning Run', '7:00 AM', morningRunEnabled, (
            value,
          ) {
            setState(() {
              morningRunEnabled = value!;
            });
            _saveReminders();
          }),
          const SizedBox(height: 10),
          _buildReminderItem('Evening Walk', '6:00 PM', eveningWalkEnabled, (
            value,
          ) {
            setState(() {
              eveningWalkEnabled = value!;
            });
            _saveReminders();
          }),
          const SizedBox(height: 10),
          _buildReminderItem('Weekend Hike', '9:00 AM', weekendHikeEnabled, (
            value,
          ) {
            setState(() {
              weekendHikeEnabled = value!;
            });
            _saveReminders();
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildReminderItem(
    String title,
    String time,
    bool enabled,
    ValueChanged<bool?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onChanged,
            activeColor: Colors.orange,
          ),
        ],
      ),
    );
  }
}
