# UniCheck Quick Reference

A quick reference guide for common tasks and commands in UniCheck development.

## Quick Links

- [Main README](../README.md)
- [Setup Guide](SETUP.md)
- [API Documentation](API.md)
- [NFC/HCE Guide](NFC_HCE.md)
- [Architecture](ARCHITECTURE.md)
- [Contributing](CONTRIBUTING.md)

## Common Commands

### Flutter Commands

```bash
# Get dependencies
flutter pub get

# Run app (debug mode)
flutter run

# Run with hot reload
flutter run --debug

# Build release APK
flutter build apk --release

# Build app bundle
flutter build appbundle --release

# Clean build files
flutter clean

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Run tests
flutter test

# Check Flutter setup
flutter doctor

# List devices
flutter devices

# View logs
flutter logs
```

### Git Commands

```bash
# Clone repository
git clone https://github.com/ZippoLord/UniCheck.git

# Create new branch
git checkout -b feature/feature-name

# Check status
git status

# Stage changes
git add .

# Commit changes
git commit -m "feat: add feature"

# Push to remote
git push origin feature/feature-name

# Pull latest changes
git pull origin main

# Sync with upstream
git fetch upstream
git merge upstream/main
```

### Android Debug Bridge (ADB)

```bash
# List connected devices
adb devices

# Install APK
adb install app-release.apk

# Uninstall app
adb uninstall com.example.prog24

# View logs
adb logcat

# Filter logs
adb logcat | grep "flutter"

# Clear app data
adb shell pm clear com.example.prog24

# Take screenshot
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png

# Check NFC status
adb shell dumpsys nfc
```

## File Structure Quick Reference

```
UniCheck/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── constants.dart               # API URL configuration
│   │
│   ├── controllers/                 # Business logic
│   │   ├── login_controller.dart
│   │   ├── register_controller.dart
│   │   └── password_controller.dart
│   │
│   ├── models/                      # Data models
│   │   ├── login_model.dart
│   │   ├── login_response.dart
│   │   ├── register_model.dart
│   │   └── api_error.dart
│   │
│   ├── components/                  # Form inputs
│   │   ├── neptunCodeField.dart
│   │   ├── nametextField.dart
│   │   ├── passwordTextField.dart
│   │   └── passwordVerField.dart
│   │
│   ├── widgets/                     # Reusable widgets
│   │   ├── customButton.dart
│   │   └── customLoginRegister..dart
│   │
│   ├── login.dart                   # Login screen
│   ├── register.dart                # Registration screen
│   ├── login_or_register.dart       # Auth switcher
│   ├── mainScreen.dart              # Student dashboard
│   ├── adminPage.dart               # Admin dashboard
│   ├── instructorPage.dart          # Instructor dashboard
│   ├── nfc.dart                     # NFC status page
│   └── methodChannel.dart           # HCE test page
│
├── android/
│   └── app/src/main/kotlin/com/example/prog24/
│       ├── MainActivity.kt          # Method channel handler
│       └── HceService.kt            # NFC HCE service
│
├── docs/                            # Documentation
│   ├── API.md
│   ├── ARCHITECTURE.md
│   ├── NFC_HCE.md
│   ├── SETUP.md
│   ├── CONTRIBUTING.md
│   └── QUICK_REFERENCE.md
│
└── test/                            # Tests
    └── widget_test.dart
```

## Configuration

### Backend URL

**File:** `lib/constants.dart`
```dart
String baseURL = "http://localhost:5188";  // Change this
```

**Local development:**
```dart
String baseURL = "http://localhost:5188";
```

**Testing on device (use your computer's local IP):**
```dart
String baseURL = "http://192.168.1.100:5188";
```

**Production:**
```dart
String baseURL = "https://api.yourdomain.com";
```

### NFC AID

**File:** `android/app/src/main/res/xml/apduservice.xml`
```xml
<aid-filter android:name="F0010203040506"/>
```

## API Endpoints

### Authentication

**Login:**
```http
POST /api/Auth/login
Content-Type: application/json

{
  "neptunCode": "ABC123",
  "password": "password123",
  "cardId": "2"
}
```

**Register:**
```http
POST /Auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "neptunCode": "ABC123",
  "password": "password123",
  "cardId": "3"
}
```

## User Roles

| Role | Value | Description |
|------|-------|-------------|
| Admin | 0 | Full system access |
| Instructor | 1 | Class management |
| Student | 2 | Attendance check-in |

## Code Snippets

### Create a New Controller

```dart
import 'package:get/get.dart';

class MyController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  
  Future<void> fetchData() async {
    _isLoading.value = true;
    try {
      // Your logic here
    } finally {
      _isLoading.value = false;
    }
  }
}
```

### Use Controller in Widget

```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyController());
    
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading) {
          return CircularProgressIndicator();
        }
        return YourContent();
      }),
    );
  }
}
```

### API Call with Error Handling

```dart
Future<void> apiCall() async {
  try {
    final response = await http.post(
      Uri.parse('$baseURL/api/endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    
    if (response.statusCode == 200) {
      // Success
      final data = jsonDecode(response.body);
    } else {
      // Error
      final error = apiErrorFromJson(response.body);
      Get.snackbar('Error', error.details);
    }
  } catch (e) {
    Get.snackbar('Error', 'Network error: $e');
  }
}
```

### Show Snackbar

```dart
// Success message
Get.snackbar(
  'Success',
  'Operation completed',
  backgroundColor: Colors.green,
  colorText: Colors.white,
);

// Error message
Get.snackbar(
  'Error',
  'Something went wrong',
  backgroundColor: Colors.red,
  colorText: Colors.white,
);
```

### Navigate Between Pages

```dart
// Push new page
Get.to(() => NewPage());

// Replace current page
Get.off(() => NewPage());

// Clear stack and navigate
Get.offAll(() => HomePage());

// Navigate back
Get.back();
```

### Store Data Locally

```dart
import 'package:get_storage/get_storage.dart';

final box = GetStorage();

// Write data
box.write('key', 'value');
box.write('token', userToken);

// Read data
String? value = box.read('key');
String? token = box.read('token');

// Remove data
box.remove('key');

// Clear all data
box.erase();
```

## NFC/HCE Quick Reference

### APDU Commands

**SELECT Command:**
```
00 A4 04 00 07 F0 01 02 03 04 05 06
```

**GET_CHUNK Command:**
```
00 10 00 00 03 [offset_hi] [offset_lo] [length]
```

### Status Words

| Code | Hex | Meaning |
|------|-----|---------|
| Success | 90 00 | Command executed successfully |
| File not found | 6A 82 | Invalid offset or no data |
| Wrong length | 67 00 | Invalid Lc field |
| Unknown | 6F 00 | Command not recognized |

### Method Channel

**Send JSON to HCE:**
```dart
const platform = MethodChannel('com.example.prog24/hce');

await platform.invokeMethod('setEmulatedJson', {
  'json': jsonData
});
```

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Flutter not found | Add Flutter to PATH |
| Android licenses | Run `flutter doctor --android-licenses` |
| Gradle build failed | Run `flutter clean && flutter pub get` |
| Device not detected | Enable USB debugging |
| NFC not working | Check NFC enabled in settings |
| API connection failed | Check backend URL and firewall |

### Debug Commands

```bash
# View Flutter version
flutter --version

# Check for issues
flutter doctor -v

# Clean build
flutter clean
flutter pub get

# Rebuild app
flutter run --debug

# View detailed logs
flutter logs -v
```

## Testing

### Run Tests

```bash
# All tests
flutter test

# Specific test
flutter test test/widget_test.dart

# With coverage
flutter test --coverage

# Watch mode (auto-run on changes)
flutter test --watch
```

### Write Widget Test

```dart
testWidgets('Button tap test', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  
  expect(find.text('Success'), findsOneWidget);
});
```

## Performance

### Profile App

```bash
# Run in profile mode
flutter run --profile

# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Optimization Tips

- Use `const` constructors
- Avoid rebuilding entire tree
- Dispose controllers
- Use `ListView.builder` for long lists
- Optimize images
- Profile before optimizing

## Keyboard Shortcuts

### VS Code

| Shortcut | Action |
|----------|--------|
| `Ctrl+Space` | Auto-complete |
| `Ctrl+.` | Quick fixes |
| `F5` | Start debugging |
| `Shift+F5` | Stop debugging |
| `Ctrl+Shift+P` | Command palette |
| `Ctrl+/` | Toggle comment |
| `Alt+Shift+F` | Format document |

### Android Studio

| Shortcut | Action |
|----------|--------|
| `Ctrl+Space` | Auto-complete |
| `Alt+Enter` | Quick fixes |
| `Shift+F10` | Run |
| `Shift+F9` | Debug |
| `Ctrl+Alt+L` | Format code |
| `Ctrl+/` | Comment line |

## Build Variants

```bash
# Debug (development)
flutter build apk --debug

# Profile (testing performance)
flutter build apk --profile

# Release (production)
flutter build apk --release

# With custom config
flutter build apk --release --dart-define=API_URL=https://api.prod.com
```

## Useful Packages

| Package | Purpose |
|---------|---------|
| get | State management & navigation |
| get_storage | Local storage |
| http | HTTP client |
| lottie | Animations |
| nfc_manager | NFC functionality |
| encrypt | Encryption |
| permission_handler | Runtime permissions |
| app_settings | Open system settings |

## Resources

### Official Documentation
- [Flutter Docs](https://docs.flutter.dev/)
- [Dart API](https://api.dart.dev/)
- [Android Developers](https://developer.android.com/)

### Packages
- [pub.dev](https://pub.dev/) - Dart & Flutter packages
- [GetX](https://pub.dev/packages/get) - State management

### Tools
- [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools/overview)
- [Android Studio](https://developer.android.com/studio)
- [VS Code](https://code.visualstudio.com/)

### Community
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Reddit r/FlutterDev](https://reddit.com/r/FlutterDev)

## Environment Variables

```bash
# Flutter
export FLUTTER_HOME=/path/to/flutter
export PATH=$PATH:$FLUTTER_HOME/bin

# Android
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Java
export JAVA_HOME=/path/to/jdk
```

## Quick Start Checklist

- [ ] Flutter SDK installed
- [ ] Android Studio configured
- [ ] Repository cloned
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Backend URL configured
- [ ] Device connected or emulator running
- [ ] App builds successfully
- [ ] Tests pass
- [ ] Documentation read

## Need Help?

1. Check the [Setup Guide](SETUP.md)
2. Read [Architecture Documentation](ARCHITECTURE.md)
3. Search existing issues
4. Ask in discussions
5. Create a new issue

---

**Last Updated:** October 2025
**Version:** 1.0.0
