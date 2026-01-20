import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'running_activity.dart';

class TrackingModel extends ChangeNotifier {
  bool _isTracking = false;
  int _steps = 0;
  double _distance = 0.0; // Meter
  int _timerSeconds = 0;

  int _lastStepCountForDistance = 0;
  double _accelMagnitudePrevious = 0.0;
  final double _stepThreshold = 12.0;

  Timer? _trackingTimer;
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<UserAccelerometerEvent>? _accelStream;

  Position? _lastPosition;
  List<LatLng> _recordedPositions = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId;

  TrackingModel() {
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  // --- GETTERS ---
  bool get isTracking => _isTracking;
  int get steps => _steps;
  double get distance => _distance / 1000;
  int get timerSeconds => _timerSeconds;
  String? get currentUserId => _currentUserId;
  List<LatLng> get recordedPositions => _recordedPositions;

  void updateUserId() {
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    notifyListeners();
  }

  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  Future<double> getTodayDistance() async {
    if (_currentUserId == null) return 0.0;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('activities')
          .where('startTime', isGreaterThanOrEqualTo: todayStart)
          .get();

      double totalDistance = 0.0;
      for (final doc in querySnapshot.docs) {
        totalDistance += (doc.data()['distance'] as num).toDouble();
      }
      return totalDistance;
    } catch (e) {
      return 0.0;
    }
  }

  void startTracking() async {
    if (_isTracking) return;

    _stopAllStreams();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    updateUserId();
    _isTracking = true;
    _steps = 0;
    _distance = 0.0;
    _timerSeconds = 0;
    _lastStepCountForDistance = 0;
    _recordedPositions = [];
    _lastPosition = null;

    _trackingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTracking) {
        _timerSeconds++;
        notifyListeners();
      }
    });

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 8,
      ),
    ).listen(_processLocation);

    _accelStream = userAccelerometerEvents.listen(_processSteps);

    notifyListeners();
  }

  void _processSteps(UserAccelerometerEvent event) {
    if (!_isTracking) return;
    double magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    double delta = magnitude - _accelMagnitudePrevious;
    _accelMagnitudePrevious = magnitude;

    if (delta > _stepThreshold) {
      _steps++;
      notifyListeners();
    }
  }

  void _processLocation(Position position) {
    if (!_isTracking || position.accuracy > 15) return;

    if (_lastPosition != null) {
      double diff = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      bool hasMovedSteps = _steps > _lastStepCountForDistance;

      if (hasMovedSteps && diff > 5.0 && diff < 40.0) {
        _distance += diff;
        _lastStepCountForDistance = _steps;
        _recordedPositions.add(LatLng(position.latitude, position.longitude));
        _lastPosition = position;
        notifyListeners();
      }
    } else {
      _lastPosition = position;
      _lastStepCountForDistance = _steps;
      _recordedPositions.add(LatLng(position.latitude, position.longitude));
    }
  }

  void _stopAllStreams() {
    _trackingTimer?.cancel();
    _positionStream?.cancel();
    _accelStream?.cancel();
    _trackingTimer = null;
    _positionStream = null;
    _accelStream = null;
  }

  void stopTracking() {
    _isTracking = false;
    _stopAllStreams();
    notifyListeners();
  }

  // --- LOGIKA PENYIMPANAN DENGAN VALIDASI 5 DETIK ---
  Future<void> saveCurrentActivity() async {
    stopTracking();

    // VALIDASI: Minimal 5 detik rekaman agar bisa disimpan
    if (_currentUserId == null || _timerSeconds < 5) {
      debugPrint("Gagal simpan: Durasi terlalu singkat (kurang dari 5 detik).");
      reset(); // Reset tampilan ke 0 tanpa menyimpan ke Firebase
      return;
    }

    final now = DateTime.now();
    final activity = RunningActivity(
      id: '',
      startTime: now.subtract(Duration(seconds: _timerSeconds)),
      endTime: now,
      distance: _distance / 1000,
      steps: _steps,
      duration: Duration(seconds: _timerSeconds),
      path: [..._recordedPositions],
    );

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('activities')
          .add(activity.toMap());
      debugPrint("Aktivitas berhasil disimpan.");
    } catch (e) {
      debugPrint("Gagal simpan: $e");
    } finally {
      reset();
    }
  }

  void reset() {
    _isTracking = false;
    _stopAllStreams();
    _steps = 0;
    _distance = 0.0;
    _timerSeconds = 0;
    _lastStepCountForDistance = 0;
    _recordedPositions = [];
    _lastPosition = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopAllStreams();
    super.dispose();
  }
}
