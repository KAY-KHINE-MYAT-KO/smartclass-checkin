# Firebase Configuration Guide

## Setup Required

To complete the Firebase integration, follow these steps:

### 1. Create Firebase Project
- Go to [Firebase Console](https://console.firebase.google.com)
- Create a new project named `smart-class-checkin`
- Enable Firestore Database in the project

### 2. Set Firebase Config

Update `lib/firebase_options.dart` with your actual Firebase credentials:

For **Web**:
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: 'YOUR_WEB_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  databaseURL: 'https://YOUR_PROJECT_ID.firebaseio.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);
```

Do the same for Android, iOS, macOS, Windows, and Linux configurations.

### 3. For Android
- Download `google-services.json` from Firebase Console
- Place it in: `android/app/`

### 4. For iOS
- Download `GoogleService-Info.plist` from Firebase Console
- Add it to Xcode project

### 5. Firestore Security Rules

Set these rules in Firestore Security Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /checkins/{document=**} {
      allow read, write: if request.auth != null || true;  // Allow all for now, restrict as needed
    }
    match /completions/{document=**} {
      allow read, write: if request.auth != null || true;  // Allow all for now, restrict as needed
    }
  }
}
```

## Data Structure

### Checkins Collection
- `studentId`: Student identifier
- `classId`: Class session ID from QR scan
- `checkinTimestamp`: Check-in time
- `checkinGps`: GeoPoint with latitude/longitude
- `previousTopic`: Previous class topic notes
- `expectedTopic`: Expected topic for today
- `mood`: 1-5 mood scale
- `createdAt`: Server timestamp

### Completions Collection
- `studentId`: Student identifier
- `classId`: Class session ID from QR scan
- `completionTimestamp`: Completion time
- `completionGps`: GeoPoint with latitude/longitude
- `learnedToday`: Summary of what was learned
- `feedback`: Feedback for instructor
- `createdAt`: Server timestamp

## Testing

1. Run the app in debug mode
2. Fill out the check-in form and tap "Save Check-in"
3. Data will be saved to both local storage and Firestore
4. Check the Firestore console to verify data is being stored
