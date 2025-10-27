# WalkTrack - Walking Photo Tracker

WalkTrack is an elegant Flutter application that allows users to track their walks, take photos, and automatically overlay walking statistics (distance and speed) on the images with a beautiful white border.

## Features

- 📸 **Camera Integration** - Take photos during your walks
- 🗺️ **Real-time Tracking** - Track distance and speed in real-time
- 🖼️ **Auto Overlay** - Automatically adds white border and walking stats to photos
- 📊 **Gallery View** - Beautiful grid layout showing all your walking photos
- 📤 **Social Sharing** - Share your walks on Instagram and other platforms
- 💾 **Save to Gallery** - Download processed images to your device
- 🎨 **Modern UI** - Elegant dark theme with smooth animations

## Screenshots

The app features:
- **Home Screen**: Gallery view of all walking photos with distance and speed overlays
- **Camera Screen**: Live camera preview with real-time stats overlay
- **Detail View**: Full-screen image view with share, download, and delete options

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / Xcode for platform-specific development
- Physical device with camera and location services (simulator may have limitations)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd walktrack
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Required Permissions

The app requires the following permissions:
- **Camera**: To take photos during walks
- **Location**: To track distance and speed
- **Storage**: To save images to the gallery
- **Internet**: For sharing functionality

### Android Setup

Permissions are automatically configured in `android/app/src/main/AndroidManifest.xml`.

### iOS Setup

Permissions are configured in `ios/Runner/Info.plist`.

For iOS, you may need to add the following to `Info.plist` for location tracking in the background (if required).

## Usage

1. **Start Tracking**: Open the camera view and tap "Start Tracking" to begin monitoring your walk
2. **Take Photo**: Position your shot and tap the capture button
3. **View Results**: The photo will be saved with distance and speed overlay, plus a white border
4. **Share**: View your photo in the gallery and share it on social media platforms
5. **Download**: Save the processed image directly to your device gallery

## Architecture

### Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── walk_image.dart         # Data model for walk images
├── screens/
│   ├── home_screen.dart        # Main gallery screen
│   └── camera_screen.dart     # Camera with tracking
├── services/
│   ├── walk_tracker.dart      # GPS tracking service
│   ├── image_processor.dart   # Image processing with borders and text
│   └── storage_service.dart   # Local storage management
└── widgets/
    └── image_detail_sheet.dart # Image detail bottom sheet
```

### Key Technologies

- **Camera**: `camera` package for capturing photos
- **Location**: `geolocator` package for GPS tracking
- **Image Processing**: `image` package for adding borders and overlays
- **Storage**: `shared_preferences` and `path_provider` for local data
- **Sharing**: `share_plus` and `image_gallery_saver` for social media integration

## Building

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is open source and available for free use.
