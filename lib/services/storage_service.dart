import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walktrack/models/walk_image.dart';

class StorageService {
  static const String _imagesKey = 'walk_images';

  // Save image metadata
  Future<void> saveImage(WalkImage walkImage) async {
    final prefs = await SharedPreferences.getInstance();
    final images = await getAllImages();
    
    // Add new image
    images.insert(0, walkImage); // Insert at beginning for newest first
    
    // Convert to JSON
    final jsonList = images.map((img) => img.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    
    await prefs.setString(_imagesKey, jsonString);
  }

  // Get all images
  Future<List<WalkImage>> getAllImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_imagesKey);
      
      if (jsonString == null) {
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => WalkImage.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Delete image
  Future<void> deleteImage(String imageId) async {
    final prefs = await SharedPreferences.getInstance();
    final images = await getAllImages();
    
    // Find the image to delete
    final imageToDelete = images.firstWhere(
      (img) => img.id == imageId,
      orElse: () => throw Exception('Image not found'),
    );
    
    // Delete the physical file
    try {
      final file = File(imageToDelete.imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Handle file deletion error
    }
    
    // Remove from list
    images.removeWhere((img) => img.id == imageId);
    
    // Update storage
    final jsonList = images.map((img) => img.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_imagesKey, jsonString);
  }

  // Get image path for saving processed images
  Future<String> getImagePath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${directory.path}/walk_images');
    
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    
    return '${imageDir.path}/$filename';
  }
}
