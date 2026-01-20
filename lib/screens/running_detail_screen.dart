import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'dart:typed_data';
import 'dart:math' as math;
import '../models/running_activity.dart';
import '../screens/fullscreen_media_screen.dart';

class RunningDetailScreen extends StatefulWidget {
  final RunningActivity activity;

  const RunningDetailScreen({super.key, required this.activity});

  @override
  State<RunningDetailScreen> createState() => _RunningDetailScreenState();
}

class _RunningDetailScreenState extends State<RunningDetailScreen> {
  GoogleMapController? _mapController;
  final ImagePicker _picker = ImagePicker();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  bool _isUploading = false;
  String _fullName = "Loading...";
  final GlobalKey _shareWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // SINKRONISASI NAMA DARI FIRESTORE (Tabel fullName)
  Future<void> _fetchUserData() async {
    if (currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _fullName = doc.data()?['fullName'] ?? "Runner";
        });
      }
    } catch (e) {
      if (mounted) setState(() => _fullName = "User");
    }
  }

  // LOGIKA DOWNLOAD GAMBAR SHARE (RASIO 9:16)
  Future<void> _downloadShareImage() async {
    try {
      // Tunggu render frame stabil agar logo & rute ter-capture sempurna
      await Future.delayed(const Duration(milliseconds: 500));

      final boundary =
          _shareWidgetKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) throw Exception("Sistem belum siap.");

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) throw Exception("Gagal memproses gambar.");

      Uint8List pngBytes = byteData.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final tempPath =
          '${directory.path}/firefit_share_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(tempPath);
      await file.writeAsBytes(pngBytes);

      // Simpan ke Galeri Publik
      await Gal.putImage(tempPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Foto berhasil disimpan ke galeri!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menghasilkan gambar share.")),
        );
      }
    }
  }

  void _showEnhancedAnalysis() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Performance Analysis",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 2),
                        FlSpot(1, 4),
                        FlSpot(2, 3),
                        FlSpot(3, 5),
                        FlSpot(4, 4),
                      ],
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 5,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.orange.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Running Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.orange),
            onPressed: _downloadShareImage,
          ),
        ],
      ),
      body: Stack(
        children: [
          // SHARE LAYOUT TERSEMBUNYI (RASIO 9:16)
          Positioned(
            left: -1500, // Tetap painted tapi di luar layar
            child: RepaintBoundary(
              key: _shareWidgetKey,
              child: _buildShareLayout(),
            ),
          ),

          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[100],
                            backgroundImage: currentUser?.photoURL != null
                                ? NetworkImage(currentUser!.photoURL!)
                                : null,
                            child: currentUser?.photoURL == null
                                ? const Icon(Icons.person, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.activity.formattedDate,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // MAP PREVIEW DENGAN TOMBOL FULLSCREEN
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: widget.activity.path.isNotEmpty
                                    ? widget.activity.path.first
                                    : const LatLng(0, 0),
                                zoom: 17.5,
                              ),
                              polylines: {
                                Polyline(
                                  polylineId: const PolylineId('p'),
                                  points: widget.activity.path,
                                  color: Colors.orange,
                                  width: 6,
                                ),
                              },
                              zoomControlsEnabled: false,
                              scrollGesturesEnabled: false,
                              onMapCreated: (controller) =>
                                  _mapController = controller,
                            ),
                            // ADAKAN KEMBALI TOMBOL FULLSCREEN
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: GestureDetector(
                                onTap: _openFullscreenMap,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.fullscreen,
                                    color: Colors.orange,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 6 ITEM DATA KESEHATAN
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildStatBox(
                            "Distance",
                            "${widget.activity.distance.toStringAsFixed(2)} km",
                          ),
                          _buildStatBox("Avg Pace", "${_calculatePace()} /km"),
                          _buildStatBox("Duration", widget.activity.movingTime),
                          _buildStatBox(
                            "Calories",
                            "${(widget.activity.distance * 65).toInt()} kcal",
                          ),
                          _buildStatBox(
                            "Carbon Saved",
                            "${(widget.activity.distance * 0.21).toStringAsFixed(2)} kg",
                          ),
                          _buildStatBox("Steps", "${widget.activity.steps}"),
                        ],
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _showEnhancedAnalysis,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[50],
                            foregroundColor: Colors.blue,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "View Performance Analysis",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // MOMENTS SECTION (TINGGI 100 & RAPAT)
                      const Text(
                        'Moments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height:
                            100, // Menghilangkan ruang kosong vertikal berlebih
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          children: [
                            GestureDetector(
                              onTap: _isUploading ? null : _uploadMoment,
                              child: Container(
                                width: 80,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: _isUploading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.add_a_photo,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                            ...widget.activity.mediaUrls.map(
                              (url) => _buildMomentItem(url),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- LAYOUT SHARE STORY 9:16 ---
  Widget _buildShareLayout() {
    return Container(
      width: 450,
      height: 800,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
      color: Colors.transparent, // Background Transparan
      child: Column(
        children: [
          const Spacer(flex: 1),
          // LOGO FIREFIT
          Image.asset(
            'assets/images/app_logo.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.flash_on, color: Colors.orange, size: 50),
          ),
          const SizedBox(height: 20),
          const Text(
            "FIREFIT ACTIVITY",
            style: TextStyle(
              color: Colors.orange,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(flex: 2),
          // RUTE DINAMIS (HALUS/ROUNDED)
          SizedBox(
            height: 300,
            width: double.infinity,
            child: CustomPaint(
              painter: _RoutePainter(
                path: widget.activity.path,
                color: Colors.orange,
                strokeWidth: 6.0,
              ),
            ),
          ),
          const Spacer(flex: 3),
          // STATISTIK DENGAN BG SEMI-TRANSPARAN
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.orange.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareStat(
                  "Distance",
                  "${widget.activity.distance.toStringAsFixed(2)} km",
                ),
                _buildShareStat("Steps", "${widget.activity.steps}"),
                _buildShareStat("Time", widget.activity.movingTime),
              ],
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildShareStat(String l, String v) => Column(
    children: [
      Text(l, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      Text(
        v,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    ],
  );

  Widget _buildStatBox(String label, String value) {
    double width = (MediaQuery.of(context).size.width - 52) / 2;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildMomentItem(String url) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullscreenMediaScreen(mediaUrl: url),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                url,
                width: 80,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 17,
          child: GestureDetector(
            onTap: () => _deleteMoment(url),
            child: const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _openFullscreenMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.activity.path.first,
                  zoom: 16,
                ),
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('fs'),
                    points: widget.activity.path,
                    color: Colors.orange,
                    width: 6,
                  ),
                },
              ),
              Positioned(
                top: 50,
                left: 20,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculatePace() {
    if (widget.activity.distance == 0) return "0:00";
    double minutes = widget.activity.duration.inSeconds / 60;
    double paceDecimal = minutes / widget.activity.distance;
    int paceMin = paceDecimal.toInt();
    int paceSec = ((paceDecimal - paceMin) * 60).toInt();
    return "$paceMin:${paceSec.toString().padLeft(2, '0')}";
  }

  Future<void> _uploadMoment() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image == null) return;
    setState(() => _isUploading = true);
    try {
      String path =
          'moments/${currentUser?.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(File(image.path));
      String url = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .collection('activities')
          .doc(widget.activity.id)
          .update({
            'mediaUrls': FieldValue.arrayUnion([url]),
          });
      setState(() {
        widget.activity.mediaUrls.add(url);
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteMoment(String url) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .collection('activities')
          .doc(widget.activity.id)
          .update({
            'mediaUrls': FieldValue.arrayRemove([url]),
          });
      setState(() => widget.activity.mediaUrls.remove(url));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

// PAINTER UNTUK MENGGAMBAR RUTE HALUS (ROUNDED)
class _RoutePainter extends CustomPainter {
  final List<LatLng> path;
  final Color color;
  final double strokeWidth;

  _RoutePainter({
    required this.path,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (path.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    double minLat = path.first.latitude,
        maxLat = path.first.latitude,
        minLng = path.first.longitude,
        maxLng = path.first.longitude;
    for (var point in path) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }
    final latPad = (maxLat - minLat) * 0.15, lngPad = (maxLng - minLng) * 0.15;
    minLat -= latPad;
    maxLat += latPad;
    minLng -= lngPad;
    maxLng += lngPad;
    final latSpan = maxLat - minLat, lngSpan = maxLng - minLng;
    if (latSpan == 0 || lngSpan == 0) return;
    final viewPath = Path();
    for (int i = 0; i < path.length; i++) {
      final x = ((path[i].longitude - minLng) / lngSpan) * size.width;
      final y = (1.0 - (path[i].latitude - minLat) / latSpan) * size.height;
      if (i == 0)
        viewPath.moveTo(x, y);
      else
        viewPath.lineTo(x, y);
    }
    canvas.drawPath(viewPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
