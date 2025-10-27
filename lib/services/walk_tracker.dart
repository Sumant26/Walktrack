import 'dart:async';
import 'package:geolocator/geolocator.dart';

class WalkTracker {
  Timer? _timer;
  Position? _lastPosition;
  double _totalDistance = 0.0; // in meters
  double _currentSpeed = 0.0; // in m/s
  
  // Getters
  double get totalDistance => _totalDistance;
  double get totalDistanceKm => _totalDistance / 1000.0;
  double get currentSpeed => _currentSpeed;
  double get currentSpeedKmh => _currentSpeed * 3.6;
  bool get isTracking => _timer != null && _timer!.isActive;
  
  // Callbacks
  final Function(double distance, double speed)? onUpdate;
  
  WalkTracker({this.onUpdate});
  
  Future<bool> requestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }
  
  Future<void> startTracking() async {
    if (!await requestPermissions()) {
      throw Exception('Location permissions not granted');
    }
    
    // Get initial position
    _lastPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    
    // Start timer to update position every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        Position newPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        
        if (_lastPosition != null) {
          // Calculate distance
          double distance = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            newPosition.latitude,
            newPosition.longitude,
          );
          
          _totalDistance += distance;
          
          // Calculate speed (m/s)
          double timeElapsed = 1.0; // 1 second
          _currentSpeed = distance / timeElapsed;
        }
        
        _lastPosition = newPosition;
        
        // Notify listeners
        onUpdate?.call(_totalDistance, _currentSpeed);
      } catch (e) {
        // Handle error silently or log it
      }
    });
  }
  
  void stopTracking() {
    _timer?.cancel();
    _timer = null;
  }
  
  void reset() {
    stopTracking();
    _totalDistance = 0.0;
    _currentSpeed = 0.0;
    _lastPosition = null;
  }
  
  void dispose() {
    stopTracking();
  }
}

