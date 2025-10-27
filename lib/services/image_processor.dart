import 'dart:io';
import 'dart:ui' as ui_dart;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class ImageProcessor {
  // Add white border and text overlay to image
  static Future<Uint8List> processImage(
    File imageFile,
    double distance,
    double speed,
  ) async {
    // Read original image
    img.Image originalImage = img.decodeImage(await imageFile.readAsBytes())!;
    
    // Calculate border size (10% of image width)
    int borderSize = (originalImage.width * 0.1).round();
    
    // Create new image with border
    int newWidth = originalImage.width + (borderSize * 2);
    int newHeight = originalImage.height + (borderSize * 2);
    
    // Start with a white canvas
    img.Image borderedImage = img.Image(width: newWidth, height: newHeight);
    img.fill(borderedImage, color: img.ColorRgb8(255, 255, 255));
    
    // Copy original image onto white canvas (centered)
    img.compositeImage(
      borderedImage,
      originalImage,
      dstX: borderSize,
      dstY: borderSize,
    );
    
    // Convert to Uint8List for Flutter
    Uint8List imageData = Uint8List.fromList(img.encodePng(borderedImage));
    
    // Now add text overlay using Flutter's image capabilities
    ui_dart.Codec codec = await ui_dart.instantiateImageCodec(imageData);
    ui_dart.FrameInfo frameInfo = await codec.getNextFrame();
    ui_dart.Image image = frameInfo.image;
    
    // Create a picture recorder
    ui_dart.PictureRecorder recorder = ui_dart.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Draw the image
    canvas.drawImage(image, Offset.zero, Paint());
    
    // Prepare text
    String distanceText = "${distance.toStringAsFixed(2)} km";
    String speedText = "${speed.toStringAsFixed(1)} km/h";
    
    // Calculate text position (bottom of image with some padding)
    double textY = image.height - 100; // 100px from bottom
    double textX = 30; // 30px from left
    
    // Style for distance
    final distancePainter = TextPainter(
      text: TextSpan(
        text: distanceText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 4.0,
              color: Colors.black54,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    distancePainter.layout();
    distancePainter.paint(canvas, Offset(textX, textY));
    
    // Style for speed
    final speedPainter = TextPainter(
      text: TextSpan(
        text: speedText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 4.0,
              color: Colors.black54,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    speedPainter.layout();
    speedPainter.paint(canvas, Offset(textX, textY + 40));
    
    // Convert back to image bytes
    final picture = recorder.endRecording();
    final finalImage = await picture.toImage(image.width, image.height);
    final byteData = await finalImage.toByteData(format: ui_dart.ImageByteFormat.png);
    final finalBytes = byteData!.buffer.asUint8List();
    
    // Dispose resources
    image.dispose();
    finalImage.dispose();
    
    return finalBytes;
  }
}
