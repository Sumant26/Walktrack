import 'dart:io';
import 'package:flutter/material.dart';
import 'package:walktrack/models/walk_image.dart';
import 'package:walktrack/services/storage_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class ImageDetailSheet extends StatelessWidget {
  final WalkImage walkImage;
  final VoidCallback onDeleted;

  const ImageDetailSheet({
    super.key,
    required this.walkImage,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          
          // Image
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  File(walkImage.imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          
          // Stats
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  context,
                  'Distance',
                  '${walkImage.distance.toStringAsFixed(2)} km',
                  Icons.straighten,
                ),
                _buildStatCard(
                  context,
                  'Speed',
                  '${walkImage.speed.toStringAsFixed(1)} km/h',
                  Icons.speed,
                ),
              ],
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  'Share',
                  Icons.share,
                  () => _shareImage(context),
                  Colors.blue,
                ),
                _buildActionButton(
                  context,
                  'Download',
                  Icons.download,
                  () => _downloadImage(context),
                  Colors.green,
                ),
                _buildActionButton(
                  context,
                  'Delete',
                  Icons.delete,
                  () => _deleteImage(context),
                  Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
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
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareImage(BuildContext context) async {
    try {
      final file = File(walkImage.imagePath);
      if (!await file.exists()) {
        if (context.mounted) {
          _showSnackBar(context, 'Image file not found', isError: true);
        }
        return;
      }

      final xFile = XFile(walkImage.imagePath);
      await Share.shareXFiles(
        [xFile],
        text: 'My walk: ${walkImage.distance.toStringAsFixed(2)} km at ${walkImage.speed.toStringAsFixed(1)} km/h',
      );
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error sharing image', isError: true);
      }
    }
  }

  Future<void> _downloadImage(BuildContext context) async {
    try {
      // Request storage permission for Android
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (context.mounted) {
          _showSnackBar(context, 'Storage permission denied', isError: true);
        }
        return;
      }

      final sourceFile = File(walkImage.imagePath);
      if (!await sourceFile.exists()) {
        if (context.mounted) {
          _showSnackBar(context, 'Image file not found', isError: true);
        }
        return;
      }

      // For Android, save to Downloads folder
      final directory = Directory('/storage/emulated/0/Download');
      if (await directory.exists()) {
        final fileName = walkImage.imagePath.split('/').last;
        final destFile = File('${directory.path}/$fileName');
        await sourceFile.copy(destFile.path);
        
        if (context.mounted) {
          _showSnackBar(context, 'Image saved to Downloads', isError: false);
        }
      } else {
        // Fallback: save to app documents
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = walkImage.imagePath.split('/').last;
        final destFile = File('${appDir.path}/$fileName');
        await sourceFile.copy(destFile.path);
        
        if (context.mounted) {
          _showSnackBar(context, 'Image saved successfully', isError: false);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _deleteImage(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final storageService = StorageService();
        await storageService.deleteImage(walkImage.id);
        if (context.mounted) {
          Navigator.pop(context);
          onDeleted();
          _showSnackBar(context, 'Image deleted', isError: false);
        }
      } catch (e) {
        if (context.mounted) {
          _showSnackBar(context, 'Error deleting image', isError: true);
        }
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

