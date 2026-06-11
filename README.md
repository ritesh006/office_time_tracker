# Office Time Tracker

A Flutter application to help employees track office working hours and maintain a required daily average of 9 hours 15 minutes.

## Features (v1.3)

- **Real-time Clock**: Current time displayed at the top.
- **Enhanced Status Card**: View today's goal, remaining time, and weekly average at a glance.
- **Weekly Average Tracker**: Calculates rolling average of the last 5 working days, including live updates for the current day.
- **Goal Status Indicators**: Clear ✅/❌ indicators for daily target and weekly average policy.
- **Overtime & Deficit Tracking**: Live monitoring of extra hours worked or time needed to meet the average.
- **Statistics Screen**: Detailed summary of total days worked, total overtime, best day, and worst day.
- **Dynamic Progress Bar**: Color-coded progress (Red < 50%, Orange < 90%, Green 100%).
- **Leave Status**: Instant "Can I Leave Now?" feedback.
- **Expected Leave Time**: Automatically calculated upon Check In.
- **Check-Out Protection**: Prevents accidental overwriting of data.
- **Local Storage**: Data persistence using `shared_preferences`.

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider
- **Storage**: SharedPreferences (Local)
- **UI**: Material Design 3

![CI](https://github.com/<username>/<repo>/actions/workflows/flutter-ci.yml/badge.svg)

## Folder Structure

```text
lib/
├── main.dart
├── models/
│   └── attendance.dart
├── providers/
│   └── attendance_provider.dart
├── screens/
│   ├── history_screen.dart
│   └── home_screen.dart
├── services/
│   └── storage_service.dart
└── widgets/
```

## Setup Instructions

1.  **Prerequisites**:
    - Ensure you have [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
    - Set up an Android emulator or connect a physical device.

2.  **Clone/Open Project**:
    - Open the project folder in VS Code or Android Studio.

3.  **Install Dependencies**:
    - Run the following command in your terminal:
      ```bash
      flutter pub get
      ```

4.  **Run the App**:
    - Run the app using:
      ```bash
      flutter run
      ```

## Usage

- Tap **Check In** when you arrive at the office.
- The dashboard will show your worked hours and the time remaining until your 9h 15m goal.
- The **Expected Leave Time** helps you plan your departure.
- Tap **Check Out** before leaving.
- Navigate to the **History** screen (icon in the top right) to view past logs.

## Future Enhancements

- GPS-based auto check-in/out (Geofencing).
- Weekly and monthly statistics.
- Push notifications for target completion.
- SQLite/Hive migration for complex data handling.
