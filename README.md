# Smart Class Check-in & Learning Reflection App

A comprehensive Flutter application for intelligent classroom management. Students check in at the beginning of class, scan QR codes for session identification, and complete structured reflection forms before and after class. All data is geo-tagged, timestamped, and persisted to Firebase Firestore.

## Features

### Pre-Class Check-in
- **QR Code Scanning**: Scan class session QR codes for automatic class identification
- **GPS Location Capture**: Automatic geo-tagging with high precision GPS coordinates
- **Timestamp Recording**: Precise check-in time recording
- **Mood Assessment**: 5-point emotional state scale (Very Negative to Very Positive)
- **Topic Planning**: Input for previous class topic and expected topics

### Post-Class Reflection
- **Learning Summary**: Document key concepts and skills learned
- **Feedback Collection**: Structured feedback on class effectiveness and improvements
- **QR Code Scanning**: Re-scan for session verification
- **GPS Location Capture**: Completion location geo-tagging
- **Timestamp Recording**: Precise completion time

### Data Management
- **Firebase Firestore Integration**: Cloud-based data persistence
- **Local Storage Backup**: SharedPreferences backup for offline access
- **Automatic Synchronization**: Data synced to Firestore when available
- **Server-side Timestamps**: Firestore server timestamps for data integrity

### Cross-Platform Support
- **Web**: Responsive design with fallback manual QR input
- **Android**: Native app with full camera and location permissions
- **iOS**: Native app with location access
- **Windows, macOS, Linux**: Desktop support
- **Material Design 3**: Modern, consistent UI across all platforms

## Requirements

- **Flutter**: 3.0.0 or higher
- **Dart**: 3.0.0 or higher
- **Firebase**: Active Firebase project with Firestore
- **Permissions** (Android/iOS):
  - Camera access (QR scanning)
  - Location services (GPS capture)

## Installation & Setup

### 1. Prerequisities
```bash
flutter --version  # Ensure Flutter 3.0+
dart --version     # Ensure Dart 3.0+
```

### 2. Clone & Install Dependencies
```bash
git clone <repository-url>
cd lab_6731503058
flutter pub get
```

### 3. Firebase Configuration

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing one
3. Enable Firestore Database
4. Set Firestore location and security rules

#### Configure Firebase Credentials
Edit `lib/firebase_options.dart` and replace placeholder API keys with your Firebase project credentials:

**For Web:**
```dart
const webOptions = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  authDomain: 'your-project.firebaseapp.com',
  projectId: 'your-project-id',
  storageBucket: 'your-project.appspot.com',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  appId: 'YOUR_APP_ID',
);
```

Replace all platform-specific options similarly.

#### Android Setup
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/`
3. Ensure `android/app/build.gradle.kts` includes:
```gradle
id("com.google.gms.google-services")
```

#### iOS Setup
1. Download `GoogleService-Info.plist` from Firebase Console
2. Add to Xcode (Runner.xcworkspace)
3. Ensure iOS Runner app references the plist

### 4. Run the App

**Web:**
```bash
flutter run -d chrome
```

**Android Emulator:**
```bash
flutter run -d emulator-5554
```

**Physical Device:**
```bash
flutter run
```

**macOS:**
```bash
flutter run -d macos
```

## Project Structure

```
lib/
├── main.dart                 # App entry point, home screen
├── theme.dart               # Material Design 3 theme & components
├── models.dart              # Firestore data models
├── firebase_options.dart    # Firebase configuration
├── check_in_screen.dart     # Pre-class check-in form
├── finish_class_screen.dart # Post-class reflection form
└── qr_scanner_screen.dart   # QR code scanning with web fallback

android/                      # Android native configuration
ios/                          # iOS native configuration
web/                          # Web build assets
```

## Key Dependencies

- **firebase_core** (^2.24.0): Firebase SDK initialization
- **cloud_firestore** (^4.14.0): Firestore database
- **geolocator** (^12.0.0): GPS location services
- **mobile_scanner** (^4.0.0): Cross-platform QR scanning
- **shared_preferences** (^2.3.2): Local data backup
- **flutter**: Core Flutter framework

## Firestore Collections

### `checkins` Collection
Stores pre-class check-in data:
```
{
  studentId: string,
  classId: string (from QR scan),
  checkinTimestamp: timestamp,
  checkinGps: geopoint,
  previousTopic: string,
  expectedTopic: string,
  mood: number (1-5),
  createdAt: timestamp
}
```

### `completions` Collection
Stores post-class reflection data:
```
{
  studentId: string,
  classId: string,
  completionTimestamp: timestamp,
  completionGps: geopoint,
  learnedToday: string,
  feedback: string,
  createdAt: timestamp
}
```

## Usage

1. **Launch App**
   - Home screen shows welcome message with two options
   - "Check-in" button → Pre-class check-in form
   - "Finish Class" button → Post-class reflection form

2. **Check-in Flow**
   - Scan class QR code
   - Tap to capture current GPS location
   - Tap to record check-in timestamp
   - Enter previous topic and expected topics
   - Select mood (5-point scale)
   - Tap "Save Check-in" → Success confirmation + auto-clear

3. **Reflection Flow**
   - Scan class QR code (verification)
   - Tap to capture current GPS location
   - Tap to record completion timestamp
   - Enter what you learned today
   - Enter feedback and suggestions
   - Tap "Save Reflection" → Success confirmation + auto-clear

## API & Permissions

### Android Permissions (`AndroidManifest.xml`)
- `CAMERA` - QR code scanning
- `ACCESS_FINE_LOCATION` - High-precision GPS
- `ACCESS_COARSE_LOCATION` - Network-based location

### iOS Permissions (`Info.plist`)
- `NSCameraUsageDescription` - QR code scanning
- `NSLocationWhenInUseUsageDescription` - GPS location

## Offline Mode

Data is automatically saved to SharedPreferences as a backup:
- Check-in data: `checkin_*` keys
- Completion data: `finish_*` keys
- When connectivity is restored, manual sync to Firestore is recommended

## Material Design 3 Theme

The app uses a custom Material Design 3 theme with:
- **Primary Color**: Deep Purple
- **Success Color**: Green
- **Warning Color**: Orange
- **Error Color**: Red
- **Text Colors**: Primary (dark) and Secondary (gray)
- **Card Styling**: Rounded corners, subtle shadows
- **Typography**: Consistent font sizing and weights

## Troubleshooting

### Firebase Not Connecting
- Verify Firebase credentials in `firebase_options.dart`
- Check Firestore security rules allow writes
- Ensure Firebase project has Firestore enabled

### QR Scanner Not Working
- Android: Check camera permission in app settings
- iOS: Check camera permission in iOS Settings
- Web: Manual input fallback should work (copy/paste class ID)

### GPS Not Accurate
- Ensure location services are enabled on device
- Wait for GPS to acquire signal (5-30 seconds)
- Use device with GPS hardware (web platform uses browser geolocation)

### Build Failures
- Run `flutter clean && flutter pub get`
- Verify all platform-specific configurations are in place
- Check Dart SDK version matches requirements

## Future Enhancements

- Admin dashboard for reviewing collected data
- Student ID management and SSO integration
- Data export to CSV/Excel
- Analytics and insights
- Push notifications for attendance reminders
- Biometric authentication

## License

This project is private and confidential.

## Support

For issues or questions, contact the development team.
