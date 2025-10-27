class WalkImage {
  final String id;
  final String imagePath;
  final double distance;
  final double speed;
  final DateTime timestamp;

  WalkImage({
    required this.id,
    required this.imagePath,
    required this.distance,
    required this.speed,
    required this.timestamp,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'distance': distance,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from JSON
  factory WalkImage.fromJson(Map<String, dynamic> json) {
    return WalkImage(
      id: json['id'],
      imagePath: json['imagePath'],
      distance: json['distance']?.toDouble() ?? 0.0,
      speed: json['speed']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

