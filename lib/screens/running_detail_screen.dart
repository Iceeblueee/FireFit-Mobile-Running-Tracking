// screens/running_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/running_activity.dart';
import '../screens/fullscreen_media_screen.dart';

class RunningDetailScreen extends StatefulWidget {
  final RunningActivity activity;

  const RunningDetailScreen({super.key, required this.activity});

  @override
  State<RunningDetailScreen> createState() => _RunningDetailScreenState();
}

class _RunningDetailScreenState extends State<RunningDetailScreen> {
  late GoogleMapController _mapController;
  final ImagePicker _picker = ImagePicker();
  final List<String> _uploadedMediaUrls = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Running Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/100',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.activity.formattedDate,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Peta Jalur
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.activity.path.isNotEmpty
                      ? widget.activity.path.first
                      : LatLng(-7.7956, 110.3691),
                  zoom: 13,
                ),
                mapType: MapType.normal,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('running_path'),
                    points: widget.activity.path,
                    color: Colors.orange,
                    width: 5,
                    startCap: Cap.roundCap,
                    endCap: Cap.roundCap,
                  ),
                },
                markers: {
                  if (widget.activity.path.isNotEmpty)
                    Marker(
                      markerId: const MarkerId('start'),
                      position: widget.activity.path.first,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                    ),
                  if (widget.activity.path.isNotEmpty)
                    Marker(
                      markerId: const MarkerId('end'),
                      position: widget.activity.path.last,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                    ),
                },
              ),
            ),
            const SizedBox(height: 20),

            // Statistik
            GridView.count(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Agar tidak scroll sendiri
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildStatCard('Distance', '${widget.activity.distance} km'),
                _buildStatCard('Steps', '${widget.activity.steps}'),
                _buildStatCard('Moving Time', widget.activity.movingTime),
                _buildStatCard(
                  'Calories',
                  '${(widget.activity.distance * 80).toInt()} Cal',
                ),
                _buildStatCard(
                  'Carbon Saved',
                  '${(widget.activity.distance * 0.22).toStringAsFixed(2)} kg CO2',
                ),
                _buildStatCard('Avg Heart Rate', '114 bpm'),
              ],
            ),
            const SizedBox(height: 20),

            // Media Preview (Jika ada)
            if (widget.activity.mediaUrls.isNotEmpty ||
                _uploadedMediaUrls.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Moments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: [
                        ...widget.activity.mediaUrls,
                        ..._uploadedMediaUrls,
                      ].length,
                      itemBuilder: (context, index) {
                        final url = index < widget.activity.mediaUrls.length
                            ? widget.activity.mediaUrls[index]
                            : _uploadedMediaUrls[index -
                                  widget.activity.mediaUrls.length];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FullscreenMediaScreen(mediaUrl: url),
                                ),
                              );
                            },
                            child: Container(
                              width: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(url),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // Button View Analysis
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('View Analysis'),
            ),

            // ✅ Tombol Add Moment di sini
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final pickedFile = await _picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        setState(() {
                          _uploadedMediaUrls.add(pickedFile.path);
                        });
                      }
                    },
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Add Moment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
