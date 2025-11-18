// screens/reminders_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Fungsi helper untuk parsing string ke TimeOfDay
TimeOfDay _timeOfDayFromString(String timeString) {
  final parts = timeString.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final reminderList = prefs.getStringList('reminders') ?? [];
    setState(() {
      _reminders = reminderList.map((json) => _parseJson(json)).toList();
    });
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final reminderList = _reminders.map((map) => _toJson(map)).toList();
    await prefs.setStringList('reminders', reminderList);
  }

  String _toJson(Map<String, dynamic> map) {
    return "${map['description']},${map['day']},${map['time']},${map['enabled']}";
  }

  Map<String, dynamic> _parseJson(String json) {
    final parts = json.split(',');
    return {
      'description': parts[0],
      'day': parts[1],
      'time': parts[2],
      'enabled': parts[3] == 'true',
    };
  }

  Future<void> _toggleReminder(int index) async {
    setState(() {
      _reminders[index]['enabled'] = !_reminders[index]['enabled'];
    });
    await _saveReminders();
  }

  Future<void> _deleteReminder(int index) async {
    setState(() {
      _reminders.removeAt(index);
    });
    await _saveReminders();
  }

  void _addReminder(String description, String day, String time) {
    setState(() {
      _reminders.add({
        'description': description,
        'day': day,
        'time': time,
        'enabled': true,
      });
    });
    _saveReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Reminders',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _reminders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_off,
                            size: 50,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          const Text('No reminders set'),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showAddReminderDialog(context);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Reminder'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = _reminders[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.orange.withOpacity(0.1),
                                ),
                                child: const Icon(
                                  Icons.notifications,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reminder['description'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      reminder['day'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      reminder['time'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: reminder['enabled'],
                                onChanged: (value) {
                                  _toggleReminder(index);
                                },
                                activeColor: Colors.orange,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _deleteReminder(index);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddReminderDialog(context);
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddReminderDialog(
        onAdd: (description, day, time) {
          _addReminder(description, day, time);
          Navigator.pop(context); // Tutup dialog setelah save
        },
      ),
    );
  }
}

// ✅ Buat dialog sebagai StatefulWidget agar bisa update UI
class AddReminderDialog extends StatefulWidget {
  final Function(String, String, String) onAdd;

  const AddReminderDialog({super.key, required this.onAdd});

  @override
  State<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  String description = '';
  String day = 'Monday';
  String time = '07:00'; // Default

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Reminder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Description'),
            onChanged: (value) => setState(() {
              description = value;
            }),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: day,
            decoration: const InputDecoration(labelText: 'Day'),
            items:
                [
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                  'Sunday',
                ].map((day) {
                  return DropdownMenuItem(value: day, child: Text(day));
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  day = value;
                });
              }
            },
          ),
          const SizedBox(height: 10),
          // ✅ Ganti TextFormField dengan controller agar bisa update dinamis
          TextField(
            decoration: InputDecoration(
              labelText: 'Time',
              suffixIcon: IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () async {
                  final timeOfDay = await showTimePicker(
                    context: context,
                    initialTime: _timeOfDayFromString(time),
                  );
                  if (timeOfDay != null) {
                    setState(() {
                      time = timeOfDay.format(context);
                    });
                  }
                },
              ),
            ),
            controller: TextEditingController(
              text: time,
            ), // ✅ Gunakan controller
            readOnly: true,
            onTap: () async {
              final timeOfDay = await showTimePicker(
                context: context,
                initialTime: _timeOfDayFromString(time),
              );
              if (timeOfDay != null) {
                setState(() {
                  time = timeOfDay.format(context);
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (description.isNotEmpty) {
              widget.onAdd(description, day, time);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
