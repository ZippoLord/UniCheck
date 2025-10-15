# UniCheck Setup and Installation Guide

This comprehensive guide will help you set up, configure, and run the UniCheck mobile application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Building the App](#building-the-app)
- [Running the App](#running-the-app)
- [Troubleshooting](#troubleshooting)
- [Development Environment](#development-environment)

## Prerequisites

### Required Software

1. **Flutter SDK** (3.9.2 or higher)
2. **Android Studio** or **VS Code**
3. **Git**
4. **Java Development Kit (JDK)** 8 or higher
5. **Android SDK** (API level 19+)
6. **Physical Android Device with NFC** (recommended for full testing)

### Optional Software

- **Android Emulator** (for basic testing without NFC)
- **Postman** or **cURL** (for API testing)
- **VS Code Flutter Extensions**

## System Requirements

### Development Machine

**Windows:**
- Windows 10 (64-bit) or later
- 8 GB RAM minimum (16 GB recommended)
- 10 GB free disk space

**macOS:**
- macOS 10.14 (Mojave) or later
- 8 GB RAM minimum (16 GB recommended)
- 10 GB free disk space

**Linux:**
- 64-bit Ubuntu 18.04+ (or equivalent)
- 8 GB RAM minimum (16 GB recommended)
- 10 GB free disk space

### Target Device

**Android Device:**
- Android 4.4 (API 19) or higher
- NFC hardware (for full functionality)
- Minimum 2 GB RAM
- 100 MB free storage

## Installation

### Step 1: Install Flutter

#### Windows

1. Download Flutter SDK from [flutter.dev](https://docs.flutter.dev/get-started/install/windows)
2. Extract to desired location (e.g., `C:\src\flutter`)
3. Add Flutter to PATH:
   ```
   C:\src\flutter\bin
   ```
4. Verify installation:
   ```bash
   flutter --version
   ```

#### macOS

1. Download Flutter SDK:
   ```bash
   cd ~/development
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.9.2-stable.zip
   unzip flutter_macos_3.9.2-stable.zip
   ```

2. Add to PATH (in `~/.zshrc` or `~/.bash_profile`):
   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

3. Verify installation:
   ```bash
   flutter --version
   ```

#### Linux

1. Download and extract Flutter:
   ```bash
   cd ~/development
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.9.2-stable.tar.xz
   tar xf flutter_linux_3.9.2-stable.tar.xz
   ```

2. Add to PATH (in `~/.bashrc` or `~/.zshrc`):
   ```bash
   export PATH="$PATH:$HOME/development/flutter/bin"
   ```

3. Verify installation:
   ```bash
   flutter --version
   ```

### Step 2: Run Flutter Doctor

Check for any missing dependencies:

```bash
flutter doctor
```

This will check for:
- Flutter SDK
- Android toolchain
- IDE setup (Android Studio/VS Code)
- Connected devices

Fix any issues reported by `flutter doctor`.

### Step 3: Install Android Studio

1. Download from [developer.android.com](https://developer.android.com/studio)
2. Install with default settings
3. Open Android Studio
4. Install required SDK components:
   - Android SDK Platform (API 33 or latest)
   - Android SDK Command-line Tools
   - Android SDK Build-Tools
   - Android Emulator

### Step 4: Install Flutter Plugins

#### For Android Studio

1. Open Android Studio
2. Go to File → Settings → Plugins (Windows/Linux) or Android Studio → Preferences → Plugins (macOS)
3. Search and install:
   - Flutter plugin
   - Dart plugin
4. Restart Android Studio

#### For VS Code

1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search and install:
   - Flutter
   - Dart
   - Flutter Widget Snippets (optional)

### Step 5: Clone the Repository

```bash
git clone https://github.com/ZippoLord/UniCheck.git
cd UniCheck
```

### Step 6: Install Dependencies

```bash
flutter pub get
```

This will download all required packages listed in `pubspec.yaml`.

## Configuration

### 1. Backend URL Configuration

Edit `lib/constants.dart` to set your backend server URL:

```dart
String baseURL = "http://YOUR_SERVER_IP:5188";
```

**Examples:**

For local development:
```dart
String baseURL = "http://localhost:5188";
```

For testing on physical device (using your computer's local IP):
```dart
String baseURL = "http://192.168.1.100:5188";
```

For production:
```dart
String baseURL = "https://api.yourdomain.com";
```

> **Note:** If testing on a physical device, ensure your device and development machine are on the same network, and use your computer's local IP address.

### 2. Android Configuration

The app is pre-configured, but verify these settings:

#### AndroidManifest.xml

Check permissions in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.NFC" />
<uses-permission android:name="android.permission.INTERNET"/>
<uses-feature android:name="android.hardware.nfc" android:required="false"/>
```

#### Build Configuration

Check `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        minSdkVersion 19
        targetSdkVersion 33
    }
}
```

### 3. Package Name (Optional)

If you want to change the package name from `com.example.prog24`:

1. Update `android/app/build.gradle`:
   ```gradle
   defaultConfig {
       applicationId "com.yourcompany.unicheck"
   }
   ```

2. Rename package directories in `android/app/src/main/kotlin/`

3. Update package declarations in Kotlin files

### 4. App Name and Icon (Optional)

**Change App Name:**

Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="UniCheck"
    ...>
```

**Change App Icon:**

Replace icons in `android/app/src/main/res/mipmap-*/ic_launcher.png`

Or use a tool:
```bash
flutter pub global activate flutter_launcher_icons
flutter pub run flutter_launcher_icons:main
```

## Building the App

### Debug Build (Development)

For testing and debugging:

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release Build (Production)

For distribution:

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle (For Google Play)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Build with Custom Configuration

```bash
flutter build apk --release --dart-define=API_URL=https://api.production.com
```

## Running the App

### Option 1: Run on Physical Device

1. Enable Developer Options on your Android device:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings → Developer Options
   - Enable "USB Debugging"

2. Connect device via USB

3. Verify device is connected:
   ```bash
   flutter devices
   ```

4. Run the app:
   ```bash
   flutter run
   ```

### Option 2: Run on Emulator

1. Create Android Emulator in Android Studio:
   - Tools → Device Manager
   - Create Device
   - Select hardware (e.g., Pixel 6)
   - Select system image (API 33+)
   - Finish

2. Start the emulator:
   ```bash
   flutter emulators --launch <emulator_id>
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Option 3: Run with Hot Reload (Development)

```bash
flutter run --debug
```

Then:
- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Option 4: Run Specific Build Mode

```bash
# Debug mode
flutter run --debug

# Profile mode (performance testing)
flutter run --profile

# Release mode
flutter run --release
```

## Troubleshooting

### Common Issues

#### Issue 1: "Flutter SDK not found"

**Solution:**
```bash
# Verify Flutter is in PATH
echo $PATH  # macOS/Linux
echo %PATH%  # Windows

# Add Flutter to PATH if missing
export PATH="$PATH:/path/to/flutter/bin"
```

#### Issue 2: "Android licenses not accepted"

**Solution:**
```bash
flutter doctor --android-licenses
```
Press `y` to accept all licenses.

#### Issue 3: "Unable to locate Android SDK"

**Solution:**

Set Android SDK path:

```bash
# Linux/macOS
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Windows (Command Prompt)
set ANDROID_HOME=C:\Users\YourUsername\AppData\Local\Android\Sdk
```

Or in Android Studio:
- File → Project Structure → SDK Location
- Set Android SDK location

#### Issue 4: "Gradle build failed"

**Solutions:**

1. Clean build files:
   ```bash
   flutter clean
   flutter pub get
   ```

2. Check Gradle version in `android/gradle/wrapper/gradle-wrapper.properties`:
   ```properties
   distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
   ```

3. Invalidate caches in Android Studio:
   - File → Invalidate Caches / Restart

#### Issue 5: "Plugin not found" errors

**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### Issue 6: "NFC not available"

**Cause:** Testing on emulator or device without NFC

**Solutions:**
- Use a physical device with NFC hardware
- Enable NFC in device settings
- For testing without NFC, comment out NFC-related code

#### Issue 7: "Connection refused" when calling API

**Solutions:**

1. Check backend is running:
   ```bash
   curl http://localhost:5188/api/health
   ```

2. For physical device, use computer's local IP:
   ```bash
   # Find your local IP
   # Windows
   ipconfig
   
   # macOS/Linux
   ifconfig
   
   # Update constants.dart
   String baseURL = "http://192.168.1.100:5188";
   ```

3. Check firewall settings allow the port

#### Issue 8: "Cannot install app" on device

**Solutions:**

1. Enable "Install via USB" in developer options
2. Uninstall old version:
   ```bash
   adb uninstall com.example.prog24
   ```
3. Try different USB cable/port
4. Restart device and computer

### Performance Issues

#### App is slow or laggy

**Solutions:**

1. Build release version:
   ```bash
   flutter build apk --release
   ```

2. Analyze performance:
   ```bash
   flutter run --profile
   ```
   Then use DevTools for profiling

3. Check for memory leaks:
   - Dispose controllers properly
   - Clear large data structures
   - Use const constructors

#### Build takes too long

**Solutions:**

1. Use Gradle daemon:
   ```bash
   # Add to gradle.properties
   org.gradle.daemon=true
   org.gradle.parallel=true
   org.gradle.configureondemand=true
   ```

2. Increase Gradle memory:
   ```bash
   # Add to gradle.properties
   org.gradle.jvmargs=-Xmx4096m
   ```

### Debugging

#### View Logs

```bash
# All logs
flutter logs

# Filtered logs
flutter logs | grep "Error"

# Android logcat
adb logcat

# Filtered logcat
adb logcat | grep "flutter"
```

#### Debug Mode

```bash
# Run with verbose output
flutter run -v

# Run with specific device
flutter run -d <device_id>
```

#### Analyze Code

```bash
# Check for issues
flutter analyze

# Format code
flutter format lib/
```

## Development Environment

### Recommended IDE Setup

#### VS Code

**Extensions:**
- Flutter
- Dart
- Dart Data Class Generator
- Flutter Widget Snippets
- Error Lens
- GitLens

**Settings (settings.json):**
```json
{
  "dart.lineLength": 120,
  "editor.formatOnSave": true,
  "dart.previewFlutterUiGuides": true,
  "[dart]": {
    "editor.rulers": [80, 120]
  }
}
```

#### Android Studio

**Plugins:**
- Flutter
- Dart
- Flutter Enhancement Suite
- Rainbow Brackets
- Key Promoter X

**Settings:**
- Enable auto-import
- Set line length to 120
- Enable format on save

### Git Configuration

**Ignore build files:**

`.gitignore` is pre-configured, but verify:

```gitignore
# Build artifacts
build/
*.apk
*.aab

# Dependencies
.packages
pubspec.lock

# IDE
.idea/
.vscode/
*.iml

# Platform
android/.gradle
android/captures/
ios/Flutter/.last_build_id
```

### Environment Variables

**Create `.env` file (optional):**

```env
API_URL=http://localhost:5188
API_KEY=your_api_key_here
```

**Load in code:**
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();
String apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:5188';
```

## Next Steps

After successful setup:

1. **Read Documentation:**
   - [API Documentation](API.md)
   - [NFC/HCE Guide](NFC_HCE.md)
   - [Architecture Overview](ARCHITECTURE.md)

2. **Test the App:**
   - Register a new account
   - Login with credentials
   - Test NFC functionality
   - Check different user roles

3. **Development:**
   - Set up backend server
   - Configure database
   - Test API endpoints
   - Implement additional features

4. **Deployment:**
   - Build release APK
   - Sign the app
   - Upload to Play Store (optional)
   - Set up CI/CD pipeline

## Additional Resources

### Official Documentation

- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Android Developers](https://developer.android.com/)
- [GetX Documentation](https://pub.dev/packages/get)

### Tutorials

- [Flutter Codelabs](https://docs.flutter.dev/codelabs)
- [Flutter Widget of the Week](https://www.youtube.com/playlist?list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG)
- [Android HCE Tutorial](https://developer.android.com/guide/topics/connectivity/nfc/hce)

### Community

- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)
- [Reddit - r/FlutterDev](https://reddit.com/r/FlutterDev)

## Support

If you encounter issues not covered in this guide:

1. Check existing GitHub issues
2. Run `flutter doctor` and fix any issues
3. Clean and rebuild the project
4. Check log files for error messages
5. Create a new issue with:
   - Flutter version (`flutter --version`)
   - Device/emulator details
   - Error messages and logs
   - Steps to reproduce

## Conclusion

You should now have:
- ✅ Flutter SDK installed
- ✅ Development environment configured
- ✅ UniCheck app cloned and configured
- ✅ App running on device/emulator

You're ready to start developing! 🚀

For questions or contributions, please refer to the project's GitHub repository.
