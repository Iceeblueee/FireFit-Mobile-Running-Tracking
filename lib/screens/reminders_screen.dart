import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initSystem();
  }

  // --- 1. INISIALISASI SISTEM NOTIFIKASI ---
  Future<void> _initSystem() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    await _notificationsPlugin.initialize(
      const InitializationSettings(android: androidSettings),
    );

    // Minta izin Android 13+ & Alarm Presisi
    await [
      Permission.notification,
      Permission.audio,
      Permission.scheduleExactAlarm,
    ].request();
  }

  // --- 2. LOGIKA JADWAL NOTIFIKASI (FIXED) ---
  Future<void> _scheduleNotification(
    String id,
    String desc,
    String timeStr,
    bool enabled,
  ) async {
    if (!enabled) {
      await _notificationsPlugin.cancel(id.hashCode);
      return;
    }

    try {
      final timeParts = timeStr.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      DateTime now = DateTime.now();
      DateTime scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      ).subtract(const Duration(minutes: 5));

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        id.hashCode,
        'FireFit: Get Ready!',
        'Aktivitas "$desc" dimulai dalam 5 menit.',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'firefit_running_v5', // Channel ID baru untuk reset setting
            'Running Reminders',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint("Gagal menjadwalkan notifikasi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String uid = _auth.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(uid)
            .collection('reminders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Your Reminders',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                _buildEmptyState()
              else
                ...snapshot.data!.docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  _scheduleNotification(
                    doc.id,
                    data['description'],
                    data['time'],
                    data['enabled'],
                  );
                  return _buildReminderItem(doc.id, data, uid);
                }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.notification_add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 150),
        child: Column(
          children: [
            Icon(
              Icons.notification_important_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            const Text(
              "No Reminders Yet",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Set your new running schedule.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderItem(String id, Map<String, dynamic> data, String uid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.withOpacity(0.1),
            ),
            child: const Icon(Icons.alarm, color: Colors.orange),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['description'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${data['day']} • ${data['time']}",
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
          Switch(
            value: data['enabled'],
            onChanged: (val) => _firestore
                .collection('users')
                .doc(uid)
                .collection('reminders')
                .doc(id)
                .update({'enabled': val}),
            activeColor: Colors.orange,
          ),
          IconButton(
            icon: const Icon(Icons.edit_note, color: Colors.blue),
            onPressed: () =>
                _showFormDialog(context, docId: id, existingData: data),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _firestore
                .collection('users')
                .doc(uid)
                .collection('reminders')
                .doc(id)
                .delete(),
          ),
        ],
      ),
    );
  }

  void _showFormDialog(
    BuildContext context, {
    String? docId,
    Map<String, dynamic>? existingData,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => _ReminderFormSheet(
        uid: _auth.currentUser?.uid ?? "",
        docId: docId,
        existingData: existingData,
      ),
    );
  }
}

// --- FORM MODAL (FIXED ALIGNMENT) ---
class _ReminderFormSheet extends StatefulWidget {
  final String uid;
  final String? docId;
  final Map<String, dynamic>? existingData;

  const _ReminderFormSheet({required this.uid, this.docId, this.existingData});

  @override
  State<_ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends State<_ReminderFormSheet> {
  final _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedDay = 'Monday';
  TimeOfDay selectedTime = const TimeOfDay(hour: 07, minute: 00);
  String? selectedSoundName;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _controller.text = widget.existingData!['description'] ?? "";
      selectedDay = widget.existingData!['day'] ?? "Monday";
      final timeParts = (widget.existingData!['time'] as String).split(':');
      selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }
  }

  Future<void> _pickSound() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (result != null)
        setState(() => selectedSoundName = result.files.single.name);
    } catch (e) {
      debugPrint("File Picker Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.docId != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 25,
        right: 25,
        top: 25,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEdit ? "Edit Reminder" : "Add Reminder",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "e.g. Morning Cardio",
              filled: true,
              fillColor: Colors.grey[50],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.orange, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // TATA LETAK DAY & SOUND (SEJAJAR & RAPI)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInputWrapper(
                  label: "Day",
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDay,
                      isExpanded: true,
                      items:
                          [
                                'Monday',
                                'Tuesday',
                                'Wednesday',
                                'Thursday',
                                'Friday',
                                'Saturday',
                                'Sunday',
                              ]
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => selectedDay = v!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: InkWell(
                  onTap: _pickSound,
                  child: _buildInputWrapper(
                    label: "Sound",
                    child: Row(
                      children: [
                        const Icon(
                          Icons.music_note,
                          size: 18,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedSoundName ?? "Select Tone",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          InkWell(
            onTap: () async {
              final p = await showTimePicker(
                context: context,
                initialTime: selectedTime,
              );
              if (p != null) setState(() => selectedTime = p);
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.orange),
                      const SizedBox(width: 10),
                      const Text(
                        "Start Time",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    selectedTime.format(context),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  final data = {
                    'description': _controller.text,
                    'day': selectedDay,
                    'time':
                        "${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}",
                    'enabled': isEdit ? widget.existingData!['enabled'] : true,
                    'createdAt': isEdit
                        ? widget.existingData!['createdAt']
                        : FieldValue.serverTimestamp(),
                  };
                  if (isEdit) {
                    _firestore
                        .collection('users')
                        .doc(widget.uid)
                        .collection('reminders')
                        .doc(widget.docId)
                        .update(data);
                  } else {
                    _firestore
                        .collection('users')
                        .doc(widget.uid)
                        .collection('reminders')
                        .add(data);
                  }
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isEdit ? Colors.blue : Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEdit ? "Update Schedule" : "Save Schedule",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // HELPER UNTUK WRAPPING INPUT AGAR SEJAJAR
  Widget _buildInputWrapper({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 5),
        Container(
          height: 55, // Tinggi statis agar sejajar
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          alignment: Alignment.centerLeft,
          child: child,
        ),
      ],
    );
  }
}
