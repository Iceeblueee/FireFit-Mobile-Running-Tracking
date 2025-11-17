// models/running_activity.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RunningActivity {
  final String id; // Firestore document ID
  final DateTime startTime;
  final DateTime endTime;
  final double distance; // km
  final int steps;
  final Duration duration;
  final List<LatLng> path; // Track GPS
  final List<String> mediaUrls; // Foto & Video

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

  // Helper untuk menghitung moving time
  String get movingTime =>
      '${duration.inMinutes} min ${duration.inSeconds % 60} sec';

  // Helper untuk format tanggal
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

  // Method untuk konversi ke Map (untuk Firestore)
  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'distance': distance,
      'steps': steps,
      'duration': duration.inSeconds,
      'path': path.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'mediaUrls': mediaUrls,
      'createdAt': FieldValue.serverTimestamp(), // Tambahkan timestamp server
    };
  }

  // Factory constructor dari Firestore
  factory RunningActivity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return RunningActivity(
      id: snapshot.id,
      startTime: (data?['startTime'] as Timestamp).toDate(),
      endTime: (data?['endTime'] as Timestamp).toDate(),
      distance: data?['distance'] as double,
      steps: data?['steps'] as int,
      duration: Duration(seconds: data?['duration'] as int),
      path: (data?['path'] as List)
          .map((e) => LatLng(e['lat'] as double, e['lng'] as double))
          .toList(),
      mediaUrls: List<String>.from(data?['mediaUrls'] ?? []),
    );
  }
}
