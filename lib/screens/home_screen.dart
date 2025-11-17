// screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Tambahkan ini
import 'package:geolocator/geolocator.dart'; // Tambahkan ini
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Tambahkan import ini
import 'login_screen.dart'; // ✅ Tambahkan import ini

import '../models/navigation_model.dart';
import '../models/tracking_model.dart';
import '../widgets/custom_bottom_nav.dart';
import 'activity_screen.dart';
import 'alerts_screen.dart';
import 'settings_screen.dart';

// ✅ Tambahkan GlobalKey untuk mengakses Scaffold
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final navModel = Provider.of<NavigationModel>(context);

    final List<Widget> pages = [
      const HomeContent(), // Index 0
      const ActivityScreen(), // Index 1
      const AlertsScreen(), // Index 2
      const SettingsScreen(), // Index 3
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            SvgPicture.asset('assets/images/logo.svg', width: 30, height: 30),
            const SizedBox(width: 8),
            Text(
              'FIREFIT',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
        elevation: 4,
      ),
      endDrawer: Drawer(
        child: Container(
          color: Colors.white, // Warna latar belakang drawer
          child: ListView(
            padding: EdgeInsets.zero, // Hilangkan padding default
            children: [
              // === HEADER DENGAN LOGO ===
              Container(
                padding: const EdgeInsets.only(
                  top: 50,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3), // Biru solid seperti gambar
                ),
                child: Column(
                  children: [
                    // Logo FireFit (gunakan SVG jika tersedia)
                    SvgPicture.asset(
                      'assets/images/logo.svg', // Pastikan file ini ada
                      width: 60,
                      height: 60,
                      color: Colors.orange, // Ubah warna logo menjadi putih
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'FIREFIT MENU',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // === PROFIL PENGGUNA ===
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    // Ikon Profil
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                    const SizedBox(width: 15),
                    // Nama dan Email
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Doe',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'johndoe@example.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // === GARIS PEMISAH ===
              const Divider(
                height: 1,
                thickness: 1,
                indent: 0,
                endIndent: 0,
                color: Colors.blueGrey,
              ),
              // === MENU ITEMS ===
              // Gunakan ListTile tanpa divider dan dengan padding disesuaikan
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: const Icon(Icons.home, size: 20, color: Colors.black),
                ),
                title: const Text(
                  'Home',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                onTap: () {
                  Navigator.pop(context);
                  navModel.setIndex(
                    0,
                  ); // ✅ Aman karena sudah divalidasi di model
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: const Icon(Icons.timer, size: 20, color: Colors.black),
                ),
                title: const Text(
                  'Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                onTap: () {
                  Navigator.pop(context);
                  navModel.setIndex(1);
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: const Icon(
                    Icons.notifications,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
                title: const Text(
                  'Alerts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                onTap: () {
                  Navigator.pop(context);
                  navModel.setIndex(2);
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: const Icon(
                    Icons.settings,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
                title: const Text(
                  'Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                onTap: () {
                  Navigator.pop(context);
                  navModel.setIndex(3);
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: const Icon(
                    Icons.privacy_tip,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
                title: const Text(
                  'Privacy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Tambahkan navigasi ke halaman Privacy jika ada
                  // navModel.setIndex(?);
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
                title: const Text(
                  'Help & Support',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Tambahkan navigasi ke halaman Help & Support jika ada
                  // navModel.setIndex(?);
                },
              ),
              // === LOGOUT BUTTON ===
              const SizedBox(height: 180), // Jarak dari menu terakhir
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // ✅ Tambahkan async
                    // ✅ Logout dari Firebase
                    await FirebaseAuth.instance.signOut();

                    // ✅ Arahkan ke halaman login
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Jarak dari tombol logout ke bawah
            ],
          ),
        ),
      ),
      // ✅ Perbaikan: Gunakan index yang aman
      body:
          pages.elementAtOrNull(navModel.selectedIndex) ??
          const Center(child: Text('Page not found')),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: navModel.selectedIndex,
        onItemTapped: (index) {
          navModel.setIndex(index); // ✅ Aman karena validasi ada di model
        },
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _formattedDate = '';
  String _currentTime = '';
  double _todayDistance = 0.0; // Tambahkan variabel

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDateTime();
    });

    // ✅ Ambil jarak hari ini saat halaman dimuat
    _loadTodayDistance();

    // ✅ Simulasi login untuk testing (hapus jika pakai auth real)
    Future.delayed(Duration.zero, () {
      final trackingModel = Provider.of<TrackingModel>(context, listen: false);
      trackingModel.simulateLogin('user_1'); // Ganti dengan UID nyata nanti
    });
  }

  Future<void> _loadTodayDistance() async {
    final trackingModel = Provider.of<TrackingModel>(context, listen: false);
    final distance = await trackingModel.getTodayDistance();
    setState(() {
      _todayDistance = distance;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final days = [
      'Sunday', // 0
      'Monday', // 1
      'Tuesday', // 2
      'Wednesday', // 3
      'Thursday', // 4
      'Friday', // 5
      'Saturday', // 6
    ]; // <= 7 elemen (indeks 0-6)
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

    setState(() {
      // ✅ Perbaikan: gunakan now.weekday - 1
      _formattedDate =
          '${days[now.weekday - 1]} ${now.day} ${months[now.month - 1]} ${now.year}';
      _currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final trackingModel = Provider.of<TrackingModel>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === HEADER: Hello, John Doe + Hari, Tanggal, Jam ===
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                // ✅ Gunakan RichText untuk menyambungkan "Hello," dan "John Doe"
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Hello, ',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'John Doe',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C47FF), // Ungu seperti gambar
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formattedDate.split(' ')[0], // Hanya hari (e.g., Thursday)
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formattedDate.substring(_formattedDate.indexOf(' ') + 1)} | $_currentTime', // Tanggal & Jam
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Today's Run + Runner Illustration
          Row(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.1),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.directions_run, size: 60, color: Colors.blue),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today you run for',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${_todayDistance.toStringAsFixed(2)} km', // ✅ Gunakan _todayDistance
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final navModel = Provider.of<NavigationModel>(
                          context,
                          listen: false,
                        );
                        navModel.setIndex(
                          1,
                        ); // Arahkan ke ActivityScreen melalui bottom nav
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Details',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Live Tracking Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF5C6BC0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.whatshot, color: Colors.white),
                        Text(
                          '${trackingModel.steps}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const Text(
                          'steps',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white),
                        Text(
                          trackingModel.distance.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const Text(
                          'km',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.timer, color: Colors.white),
                        Text(
                          '${(trackingModel.timerSeconds ~/ 60).toString().padLeft(2, '0')}:${(trackingModel.timerSeconds % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const Text(
                          'min',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // === BOX ABU-ABU UNTUK MAPS ===
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        IgnorePointer(
                          ignoring: true,
                          child: const GoogleMapWidget(),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const FullscreenMapScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.3),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.fullscreen,
                                size: 20,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Live tracking',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),

                // === Tombol Start/Finish di Dalam Card ===
                const SizedBox(height: 15),
                Consumer<TrackingModel>(
                  builder: (context, trackingModel, child) {
                    return _buildSliderButton(trackingModel);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSliderButton(TrackingModel trackingModel) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (trackingModel.isTracking) {
          // Geser ke kiri untuk finish
          if (details.delta.dx < -5) {
            trackingModel.stopTracking();
            trackingModel
                .saveCurrentActivity(); // ✅ Simpan aktivitas ke Firestore
          }
        } else {
          // Geser ke kanan untuk start
          if (details.delta.dx > 5) {
            trackingModel.startTracking();
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: trackingModel.isTracking
              ? Colors.orangeAccent
              : Colors.blue[50],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Ikon lari
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: trackingModel.isTracking ? Colors.white : Colors.blue,
                ),
                child: Icon(
                  trackingModel.isTracking ? Icons.stop : Icons.directions_run,
                  color: trackingModel.isTracking
                      ? Colors.orangeAccent
                      : Colors.white,
                  size: 20,
                ),
              ),
            ),
            // Teks "Start" atau "Finish"
            Center(
              child: Text(
                trackingModel.isTracking ? 'Finish' : 'Start',
                style: TextStyle(
                  color: trackingModel.isTracking ? Colors.white : Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Panah
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  2,
                  (index) => Icon(
                    trackingModel.isTracking
                        ? Icons.arrow_back_ios
                        : Icons.arrow_forward_ios,
                    color: trackingModel.isTracking
                        ? Colors.white
                        : Colors.blue,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget untuk menampilkan peta kecil di card
class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({super.key});

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Jika layanan tidak aktif, tampilkan pesan
      print('Layanan lokasi tidak aktif.');
      setState(() {
        _isLoadingLocation = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Izin lokasi ditolak.');
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Izin lokasi ditolak selamanya. Aktifkan di pengaturan.');
      setState(() {
        _isLoadingLocation = false;
      });
      return;
    }

    // Ambil lokasi terbaru
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
      _isLoadingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentPosition == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(child: Text('Tidak dapat mengakses lokasi')),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 15,
      ),
      mapType: MapType.normal,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      zoomControlsEnabled: false,
      zoomGesturesEnabled: false,
      scrollGesturesEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

// Widget untuk fullscreen map
class FullscreenMapScreen extends StatefulWidget {
  const FullscreenMapScreen({super.key});

  @override
  State<FullscreenMapScreen> createState() => _FullscreenMapScreenState();
}

class _FullscreenMapScreenState extends State<FullscreenMapScreen> {
  late GoogleMapController _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Layanan lokasi tidak aktif.');
      setState(() {
        _isLoadingLocation = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Izin lokasi ditolak.');
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Izin lokasi ditolak selamanya. Aktifkan di pengaturan.');
      setState(() {
        _isLoadingLocation = false;
      });
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
      _isLoadingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_isLoadingLocation)
            Container(
              color: Colors.white,
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (_currentPosition == null)
            Container(
              color: Colors.white,
              child: const Center(child: Text('Tidak dapat mengakses lokasi')),
            )
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  _mapController.dispose();
                  Navigator.pop(context);
                },
              ),
            ),
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
