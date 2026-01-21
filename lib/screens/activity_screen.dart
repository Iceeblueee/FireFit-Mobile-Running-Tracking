// screens/activity_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tracking_model.dart';
import '../models/running_activity.dart';
import 'running_detail_screen.dart';
import 'home_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late Future<List<RunningActivity>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  // Fungsi untuk memicu pengambilan data (digunakan saat init dan refresh)
  void _loadActivities() {
    final trackingModel = Provider.of<TrackingModel>(context, listen: false);
    final userId = trackingModel.currentUserId;

    setState(() {
      _activitiesFuture = _fetchActivities(userId);
    });
  }

  // Mengambil data dari Firestore secara manual (bukan stream)
  Future<List<RunningActivity>> _fetchActivities(String? userId) async {
    if (userId == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('activities')
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => RunningActivity.fromFirestore(doc))
        .toList();
  }

  Future<void> _handleRefresh() async {
    _loadActivities();
    await _activitiesFuture;
  }

  // --- LOGIKA HAPUS DATA ---
  Future<void> _deleteActivity(String activityId) async {
    final trackingModel = Provider.of<TrackingModel>(context, listen: false);
    final userId = trackingModel.currentUserId;

    if (userId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('activities')
          .doc(activityId)
          .delete();

      _loadActivities();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Activity deleted successfully")),
        );
      }
    } catch (e) {
      debugPrint("Error deleting activity: $e");
    }
  }

  void _confirmDelete(String activityId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Record"),
        content: const Text("Are you sure you want to delete this activity?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteActivity(activityId);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trackingModel = Provider.of<TrackingModel>(context);
    final userId = trackingModel.currentUserId;

    if (userId == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: _buildMessageUI(
          context,
          icon: Icons.lock_outline,
          title: 'Access Denied',
          message: 'Please login to view your activities.',
          buttonLabel: 'Go to Home',
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.orange,
        child: FutureBuilder<List<RunningActivity>>(
          future: _activitiesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Tampilan Dasar ListView agar Pull-to-Refresh bekerja pada layar kosong/error
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                // 2. Judul di dalam Body (Sama seperti halaman Remainders)
                const Text(
                  'Your Activities',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Penanganan Error
                if (snapshot.hasError)
                  _buildMessageUI(
                    context,
                    icon: Icons.error_outline,
                    title: 'Something went wrong',
                    message: 'Unable to load activities.',
                  )
                // Penanganan Data Kosong
                else if (!snapshot.hasData || snapshot.data!.isEmpty)
                  _buildMessageUI(
                    context,
                    icon: Icons.directions_run,
                    title: 'No Activities Yet',
                    message: 'Pull down to refresh or start a new run.',
                  )
                // Penanganan List Data
                else
                  ...snapshot.data!.map(
                    (activity) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildActivityItem(context, activity),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, RunningActivity activity) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RunningDetailScreen(activity: activity),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
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
                color: Colors.blue.withOpacity(0.1),
              ),
              child: const Icon(Icons.directions_run, color: Colors.blue),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Running Session',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${activity.distance.toStringAsFixed(2)} km • ${activity.movingTime}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.formattedDate,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Tombol Delete ditempatkan di sebelah kiri icon
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _confirmDelete(activity.id),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageUI(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    String? buttonLabel,
    VoidCallback? onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 150),
        child: Column(
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            if (buttonLabel != null) ...[
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(buttonLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
