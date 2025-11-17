// models/tracking_model.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'running_activity.dart';

typedef RunningActivityCallback = void Function(RunningActivity activity);

class TrackingModel extends ChangeNotifier {
  bool _isTracking = false;
  int _steps = 0;
  double _distance = 0.0; // dalam meter
  int _timerSeconds = 0;
  Timer? _trackingTimer;
  Timer? _locationUpdateTimer;

  Position? _lastKnownPosition;
  Position? _currentPosition;

  List<LatLng> _recordedPositions = [];
  double _sliderDragOffset = 0.0;

  static const double _averageStepLengthMeters = 0.75;

  RunningActivityCallback? onActivitySaved;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId;

  String? get currentUserId => _currentUserId;

  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  void simulateLogin(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  bool get isTracking => _isTracking;
  int get steps => _steps;
  double get distance => _distance;
  int get timerSeconds => _timerSeconds;

  Position? get lastKnownPosition => _lastKnownPosition;
  Position? get currentPosition => _currentPosition;

  List<LatLng> get recordedPositions => _recordedPositions;
  double get sliderDragOffset => _sliderDragOffset;

  void setSliderDragOffset(double offset) {
    _sliderDragOffset = offset;
    notifyListeners();
  }

  // Helper untuk rentang waktu hari ini
  DateTime get startOfDay {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get endOfDay {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  }

  // Method untuk menghitung total jarak hari ini dari Firestore
  Future<double> getTodayDistance() async {
    if (_currentUserId == null) return 0.0;

    final todayStart = startOfDay;
    final todayEnd = endOfDay;

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('activities')
          .where('startTime', isGreaterThanOrEqualTo: todayStart)
          .where('endTime', isLessThanOrEqualTo: todayEnd)
          .get();

      double totalDistance = 0.0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['distance'] is double) {
          totalDistance += data['distance'] as double;
        }
      }

      return totalDistance;
    } catch (e) {
      debugPrint("Error fetching today's distance: $e");
      return 0.0;
    }
  }

  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Izin lokasi ditolak');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Izin lokasi ditolak selamanya, arahkan ke pengaturan.');
      return false;
    }
    return true;
  }

  void startTracking() async {
    if (_isTracking) return;

    bool hasPermission = await _requestLocationPermission();
    if (!hasPermission) {
      debugPrint("Tracking tidak dapat dimulai: Izin lokasi tidak diberikan.");
      return;
    }

    debugPrint("Memulai tracking GPS...");

    _isTracking = true;
    _steps = 0;
    _distance = 0.0;
    _timerSeconds = 0;
    _lastKnownPosition = null;
    _currentPosition = null;
    _recordedPositions = [];

    _trackingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTracking) {
        _timerSeconds++;
        notifyListeners();
      }
    });

    const Duration locationUpdateInterval = Duration(seconds: 5);
    _locationUpdateTimer = Timer.periodic(locationUpdateInterval, (
      timer,
    ) async {
      if (_isTracking) {
        await _updateLocation();
      }
    });

    notifyListeners();
  }

  Future<void> _updateLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("Layanan lokasi dinonaktifkan.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint("Izin lokasi hilang selama tracking.");
        return;
      }

      Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (_lastKnownPosition != null) {
        double distanceTraveled = Geolocator.distanceBetween(
          _lastKnownPosition!.latitude,
          _lastKnownPosition!.longitude,
          newPosition.latitude,
          newPosition.longitude,
        );

        if (distanceTraveled > 1.0) {
          _distance += distanceTraveled;
          _steps = (_distance / _averageStepLengthMeters).round();
          _recordedPositions.add(
            LatLng(newPosition.latitude, newPosition.longitude),
          );
        }
      } else {
        _recordedPositions.add(
          LatLng(newPosition.latitude, newPosition.longitude),
        );
        _steps = 0;
      }

      _lastKnownPosition = newPosition;
      _currentPosition = newPosition;

      notifyListeners();
    } catch (e) {
      debugPrint("Error saat memperbarui lokasi: $e");
    }
  }

  void stopTracking() {
    if (!_isTracking) return;

    debugPrint("Menghentikan tracking GPS...");
    _isTracking = false;

    _trackingTimer?.cancel();
    _trackingTimer = null;

    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;

    notifyListeners();
  }

  // ✅ Method untuk menyimpan aktivitas saat tracking selesai
  Future<void> saveCurrentActivity() async {
    if (_isTracking) {
      stopTracking();
    }

    // ✅ Pastikan ada data yang bisa disimpan
    if (_recordedPositions.isNotEmpty && _currentUserId != null) {
      final now = DateTime.now();
      final activity = RunningActivity(
        id: '', // Akan diisi oleh Firestore
        startTime: now.subtract(Duration(seconds: _timerSeconds)),
        endTime: now,
        distance: _distance / 1000, // Konversi meter ke km
        steps: _steps,
        duration: Duration(seconds: _timerSeconds),
        path: [..._recordedPositions], // Simpan salinan rute
        mediaUrls: [], // Kosong dulu, nanti bisa ditambahkan
      );

      try {
        // ✅ Simpan ke Firestore di koleksi: users/{userId}/activities
        await _firestore
            .collection('users')
            .doc(_currentUserId)
            .collection('activities')
            .add(activity.toMap());

        debugPrint("Activity saved to Firestore");

        // ✅ Reset statistik setelah simpan
        reset();

        notifyListeners();

        onActivitySaved?.call(activity);
      } catch (e) {
        debugPrint("Error saving activity to Firestore: $e");
      }
    } else {
      debugPrint("Tidak ada data untuk disimpan atau user belum login.");
    }
  }

  void startNewTracking() {
    reset();
    startTracking();
  }

  void reset() {
    stopTracking();
    _isTracking = false;
    _steps = 0;
    _distance = 0.0;
    _timerSeconds = 0;
    _lastKnownPosition = null;
    _currentPosition = null;
    _recordedPositions = [];
    _sliderDragOffset = 0.0;
    notifyListeners();
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }
}
