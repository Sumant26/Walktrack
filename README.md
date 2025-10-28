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

### Google Maps API Key Setup

The app uses Google Maps to display your walking route. You need to get a free API key:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Maps SDK for Android and iOS
4. Create credentials (API Key)
5. Restrict the key to Maps SDK only for security

**For Android**, add your API key to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

**For iOS**, add your API key to `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

### Android Setup

Permissions are automatically configured in `android/app/src/main/AndroidManifest.xml`.

### iOS Setup

Permissions are configured in `ios/Runner/Info.plist`.

## Usage

1. **Start Walk Session**: Tap the walking icon to start a new walk session
2. **View Map Tracking**: See your route on the interactive map as you walk
3. **Stop Walking**: Tap "Stop Walk" when your session is complete
4. **Take Photo**: Capture a photo after your walk finishes
5. **View Results**: The photo will be saved with distance/speed overlay and white border
6. **Share**: View your photo in the gallery and share it on social media platforms
7. **Download**: Save the processed image directly to your device gallery

## Architecture

### Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── walk_image.dart         # Data model for walk images
├── screens/
│   ├── home_screen.dart        # Main gallery screen
│   ├── camera_screen.dart      # Legacy camera with tracking
│   └── walk_session_screen.dart # New walk session with map & photo
├── services/
│   ├── walk_tracker.dart       # GPS tracking service
│   ├── image_processor.dart   # Image processing with borders and text
│   └── storage_service.dart    # Local storage management
└── widgets/
    └── image_detail_sheet.dart # Image detail bottom sheet
```

### Key Technologies

- **Camera**: `camera` package for capturing photos
- **Location**: `geolocator` package for GPS tracking
- **Maps**: `google_maps_flutter` for route visualization
- **Image Processing**: `image` package for adding borders and overlays
- **Storage**: `shared_preferences` and `path_provider` for local data
- **Sharing**: `share_plus` for social media integration

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
