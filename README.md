# Hello World Flutter App

A simple Flutter app displaying **Hello World** in the center of the screen.

## Run on Android

1. Install Flutter and add its `bin` folder to PATH.
2. Install Android Studio and its Android SDK, command-line tools, and emulator.
3. Review Android licenses with `flutter doctor --android-licenses`.
4. Create and start a virtual phone in Android Studio Device Manager.
5. In this project directory, run:

```sh
flutter pub get
flutter doctor
flutter devices
flutter run -d <android-device-id>
```

Replace `<android-device-id>` with the Android ID printed by `flutter devices`.
The project includes iOS source; running an iOS simulator requires macOS and Xcode.

## Verification

- Flutter 3.47.5 / Dart 3.13.4 detected on Windows.
- `flutter analyze`: no issues found.
- `flutter test`: the Hello World widget test passed.
- Mobile execution and screenshots are pending: no Android SDK or emulator was installed at verification time.

## Submission

The source ZIP and two-paragraph PDF description are in `submission/`.
Before submitting, run on an Android emulator or device, capture the actual app screen,
and update the description to record the successful mobile test. Upload the source ZIP,
PDF, and genuine screenshots to the course platform.

## Official guidance

- https://docs.flutter.dev/learn/pathway
- https://docs.flutter.dev/platform-integration/android/setup
