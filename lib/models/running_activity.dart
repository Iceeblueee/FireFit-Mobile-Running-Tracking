// models/running_activity.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RunningActivity {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final double distance; // km
  final int steps;
  final Duration duration;
  final List<LatLng> path;
  final List<String> mediaUrls;

  RunningActivity({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.steps,
    required this.duration,
    required this.path,
    this.mediaUrls = const [],
  });

  String get movingTime =>
      '${duration.inMinutes} min ${duration.inSeconds % 60} sec';

  String get formattedDate {
    final now = DateTime.now();
    if (startTime.day == now.day &&
        startTime.month == now.month &&
        startTime.year == now.year) {
      return 'Today, ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
    } else if (startTime.day == now.subtract(const Duration(days: 1)).day) {
      return 'Yesterday, ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${startTime.day} ${_getMonthName(startTime.month)} ${startTime.year}, ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _getMonthName(int month) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'distance': distance,
      'steps': steps,
      'duration': duration.inSeconds,
      'path': path.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'mediaUrls': mediaUrls,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory RunningActivity.fromFirestore(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Perbaikan: Gunakan .toDouble() dan casting num agar aman dari error tipe data
    return RunningActivity(
      id: doc.id,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      distance: (data['distance'] ?? 0.0).toDouble(),
      steps: (data['steps'] ?? 0) as int,
      duration: Duration(seconds: (data['duration'] ?? 0) as int),
      path:
          (data['path'] as List?)
              ?.map(
                (e) => LatLng(
                  (e['lat'] as num).toDouble(),
                  (e['lng'] as num).toDouble(),
                ),
              )
              .toList() ??
          [],
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
    );
  }
}
