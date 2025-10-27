import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:walktrack/services/walk_tracker.dart';
import 'package:walktrack/services/image_processor.dart';
import 'package:walktrack/services/storage_service.dart';
import 'package:walktrack/models/walk_image.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  WalkTracker? _tracker;
  final StorageService _storageService = StorageService();
  bool _isInitialized = false;
  bool _isTracking = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeTracker();
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _showError('Camera permission denied');
        return;
      }

      // Get cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showError('No cameras available');
        return;
      }

      // Initialize controller
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      _showError('Error initializing camera: $e');
    }
  }

  void _initializeTracker() {
    _tracker = WalkTracker(
      onUpdate: (distance, speed) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Future<void> _startTracking() async {
    try {
      await _tracker?.startTracking();
      setState(() {
        _isTracking = true;
      });
    } catch (e) {
      _showError('Error starting tracking: $e');
    }
  }

  void _stopTracking() {
    _tracker?.stopTracking();
    setState(() {
      _isTracking = false;
    });
  }

  Future<void> _takePicture() async {
    if (!_isInitialized || _controller == null || !_controller!.value.isInitialized) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Take picture
      final image = await _controller!.takePicture();
      
      // Get distance and speed
      final distance = _tracker?.totalDistanceKm ?? 0.0;
      final speed = _tracker?.currentSpeedKmh ?? 0.0;

      // Process image (add border and text)
      final processedBytes = await ImageProcessor.processImage(
        File(image.path),
        distance,
        speed,
      );

      // Save processed image
      final timestamp = DateTime.now();
      final filename = 'walk_${timestamp.millisecondsSinceEpoch}.png';
      final imagePath = await _storageService.getImagePath(filename);
      
      final file = File(imagePath);
      await file.writeAsBytes(processedBytes);

      // Save metadata
      final walkImage = WalkImage(
        id: timestamp.millisecondsSinceEpoch.toString(),
        imagePath: imagePath,
        distance: distance,
        speed: speed,
        timestamp: timestamp,
      );

      await _storageService.saveImage(walkImage);

      // Delete temporary camera file
      await File(image.path).delete();

      // Navigate back
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError('Error taking picture: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _tracker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          CameraPreview(_controller!),
          
          // Overlay stats
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: _buildStatsOverlay(),
          ),
          
          // Control buttons
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: _buildControls(),
          ),
          
          // Back button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverlay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat(
            'Distance',
            '${(_tracker?.totalDistanceKm ?? 0.0).toStringAsFixed(2)} km',
            Icons.straighten,
          ),
          _buildStat(
            'Speed',
            '${(_tracker?.currentSpeedKmh ?? 0.0).toStringAsFixed(1)} km/h',
            Icons.speed,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        // Tracking toggle
        Container(
          margin: const EdgeInsets.only(bottom: 30),
          child: ElevatedButton(
            onPressed: _isProcessing ? null : () {
              if (_isTracking) {
                _stopTracking();
              } else {
                _startTracking();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isTracking ? Colors.green : Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isTracking ? Icons.location_on : Icons.location_off,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _isTracking ? 'Tracking...' : 'Start Tracking',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Capture button
        GestureDetector(
          onTap: _isProcessing ? null : _takePicture,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.3),
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: _isProcessing
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Center(
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 35),
                  ),
          ),
        ),
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
