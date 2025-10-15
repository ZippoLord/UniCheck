# UniCheck Architektúra Dokumentáció

Ez a dokumentum leírja az UniCheck mobilalkalmazás architektúráját, tervezési mintáit és technikai döntéseit.

## Rendszer Áttekintés

A UniCheck egy Flutter-alapú többplatformos mobilalkalmazás egyetemi jelenléti nyilvántartás kezelésére NFC technológia használatával. Az alkalmazás tiszta architektúra elveket követ egyértelmű feladatok szétválasztásával.

## Technológiai Stack

### Frontend (Mobilalkalmazás)
- **Framework:** Flutter 3.9.2+
- **Nyelv:** Dart
- **Állapotkezelés:** GetX
- **Tárolás:** GetStorage
- **HTTP Kliens:** http csomag
- **Animációk:** Lottie

### Backend Integráció
- **Hitelesítés:** JWT (JSON Web Tokens)
- **API Kommunikáció:** REST
- **Adat Formátum:** JSON

### Natív Integráció
- **Platform:** Android (Kotlin)
- **NFC:** Host Card Emulation (HCE)
- **Kommunikáció:** Platform Csatornák

## Architektúra Minták

### 1. Tiszta Architektúra

Az alkalmazás tiszta architektúra elveket követ egyértelmű réteg szétválasztással:

```
┌─────────────────────────────────────────────────────────┐
│                  Prezentációs Réteg                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Képernyők   │  │   Widgetek   │  │  Komponensek │  │
│  │  (UI/Pages)  │  │   (Egyedi)   │  │(Újrahaszn.)  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│                 Üzleti Logika Réteg                      │
│  ┌──────────────────────────────────────────────────┐  │
│  │            Kontrollerek (GetX)                    │  │
│  │  - LoginController                                │  │
│  │  - RegisterController                             │  │
│  │  - PasswordController                             │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│                      Adat Réteg                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Modellek   │  │  API Kliens  │  │   Tárolás    │  │
│  │   (DTOk)     │  │    (HTTP)    │  │ (GetStorage) │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│             Platform-Specifikus Réteg                    │
│  ┌──────────────────────────────────────────────────┐  │
│  │        Android Natív (Kotlin)                     │  │
│  │  - MainActivity (Method Channel Handler)          │  │
│  │  - HCE Service (NFC Emuláció)                     │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 2. Állapotkezelés (GetX)

A UniCheck GetX-et használ reaktív állapotkezeléshez, amely biztosítja:
- **Dependency Injection:** Egyszerű kontroller példányosítás
- **Reaktív Programozás:** Automatikus UI frissítések
- **Útvonal Kezelés:** Egyszerű navigáció
- **Állapot Perzisztencia:** Helyi tárolás integráció

**Kontroller Minta:**

```dart
class LoginController extends GetxController {
  // Megfigyelhető állapot
  RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  
  // Üzleti logika
  void loginFunction(String data) async {
    _isLoading.value = true;
    try {
      // API hívás és feldolgozás
    } finally {
      _isLoading.value = false;
    }
  }
}
```

### 3. Repository Minta

Az API kommunikáció követi a repository mintát (implicit módon):

```
Kontroller → HTTP Kliens → API Végpont
     ↓
   Model (DTO)
     ↓
   Tárolás (Cache)
```

## Projekt Struktúra

### Könyvtár Szervezés

```
lib/
├── main.dart                    # Alkalmazás belépési pont
├── constants.dart               # Globális konstansok (API URL-ek)
├── login_or_register.dart       # Auth váltó oldal
│
├── controllers/                 # Üzleti logika (GetX)
│   ├── login_controller.dart
│   ├── register_controller.dart
│   └── password_controller.dart
│
├── models/                      # Adat modellek (DTOk)
│   ├── login_model.dart
│   ├── login_response.dart
│   ├── register_model.dart
│   ├── register_response_model.dart
│   └── api_error.dart
│
├── components/                  # Űrlap komponensek
│   ├── neptunCodeField.dart
│   ├── nametextField.dart
│   ├── passwordTextField.dart
│   └── passwordVerField.dart
│
├── widgets/                     # Újrafelhasználható widgetek
│   ├── customButton.dart
│   └── customLoginRegister..dart
│
├── login.dart                   # Bejelentkezési képernyő
├── register.dart                # Regisztrációs képernyő
├── login_or_register.dart       # Auth váltó
├── mainScreen.dart              # Hallgatói műszerfal
├── adminPage.dart               # Admin műszerfal
├── instructorPage.dart          # Oktatói műszerfal
├── nfc.dart                     # NFC státusz oldal
└── methodChannel.dart           # HCE teszt oldal

android/
├── app/
│   └── src/
│       └── main/
│           ├── AndroidManifest.xml
│           ├── kotlin/com/example/prog24/
│           │   ├── MainActivity.kt       # Platform channel handler
│           │   └── HceService.kt         # NFC HCE implementáció
│           └── res/
│               └── xml/
│                   └── apduservice.xml   # HCE konfiguráció

assets/
└── lotties/                     # Animációs fájlok
    └── Education.json

docs/                            # Dokumentáció
├── API.md                       # API dokumentáció
├── NFC_HCE.md                   # NFC implementáció
└── ARCHITECTURE.md              # Ez a fájl
```

## Komponens Részletek

### 1. Kontrollerek

A kontrollerek üzleti logikát és állapotkezelést kezelnek:

#### LoginController

**Felelősségek:**
- Felhasználó hitelesítés
- Token tárolás
- Szerepkör-alapú irányítás
- Hibakezelés

**Fő Metódusok:**
- `loginFunction(String data)` - Felhasználó hitelesítés
- `setLoading(bool state)` - Betöltési állapot frissítése

**Állapot:**
- `_isLoading: RxBool` - Betöltési indikátor

#### RegisterController

**Felelősségek:**
- Új felhasználó regisztráció
- Input validáció
- Success/error feedback

**Key Methods:**
- `registerFunction(String data)` - Create new account
- `setLoading(bool state)` - Update loading state

**State:**
- `_isLoading: RxBool` - Loading indicator

#### PasswordController

**Responsibilities:**
- Password visibility toggle
- Password validation

**State:**
- `_obscurePassword: RxBool` - Password visibility state

### 2. Models

Models represent data structures used throughout the app:

#### Data Flow

```
User Input → Model.toJson() → JSON String → HTTP Request
                                                  ↓
HTTP Response → JSON String → Model.fromJson() → Model Object
```

#### Key Models

**LoginModel**
- Input model for authentication
- Fields: neptunCode, password, cardId

**LoginResponseModel**
- Response from successful login
- Fields: token, name, role

**RegisterModel**
- Input model for registration
- Fields: name, neptunCode, password, cardId

**ApiError**
- Standard error response
- Fields: error, details, stackTrace

### 3. Screens

Screens represent complete pages in the application:

#### Authentication Flow

```
App Start
    ↓
LoginOrRegister (State: showLoginPage)
    ↓
    ├─→ LoginPage (showLoginPage = true)
    │       ↓
    │   Login Success
    │       ↓
    │   Role Check
    │       ├─→ role == 2 → MainScreen (Student)
    │       ├─→ role == 0 → AdminPage (Admin)
    │       └─→ role == 1 → InstructorPage (Instructor)
    │
    └─→ RegisterPage (showLoginPage = false)
            ↓
        Registration Success
            ↓
        Redirect to LoginPage
```

### 4. Native Integration

#### Platform Channel Architecture

```
┌────────────────────────────────────────┐
│         Flutter (Dart)                  │
│                                         │
│  platform.invokeMethod(                 │
│    'setEmulatedJson',                   │
│    {'json': jsonData}                   │
│  )                                      │
└───────────────┬────────────────────────┘
                │
        MethodChannel
  ('com.example.prog24/hce')
                │
┌───────────────▼────────────────────────┐
│      Android Native (Kotlin)           │
│                                         │
│  MethodChannel.setMethodCallHandler {  │
│    when (call.method) {                │
│      "setEmulatedJson" -> {            │
│        // Store JSON                   │
│      }                                 │
│    }                                   │
│  }                                     │
└────────────────────────────────────────┘
```

## Data Flow Diagrams

### 1. User Login Flow

```
┌──────┐    ┌──────────┐    ┌────────────┐    ┌────────┐
│ User │    │   UI     │    │ Controller │    │  API   │
└──┬───┘    └────┬─────┘    └─────┬──────┘    └───┬────┘
   │             │                 │                │
   │ 1. Enter    │                 │                │
   │ credentials │                 │                │
   ├────────────>│                 │                │
   │             │ 2. Tap Login    │                │
   │             │                 │                │
   │             │ 3. Create       │                │
   │             │    LoginModel   │                │
   │             ├────────────────>│                │
   │             │                 │                │
   │             │                 │ 4. POST        │
   │             │                 │    /login      │
   │             │                 ├───────────────>│
   │             │                 │                │
   │             │                 │ 5. JWT Token   │
   │             │                 │<───────────────┤
   │             │                 │                │
   │             │                 │ 6. Store Token │
   │             │                 │    in Storage  │
   │             │                 │                │
   │             │ 7. Navigate     │                │
   │             │    by Role      │                │
   │             │<────────────────┤                │
   │             │                 │                │
   │ 8. Show     │                 │                │
   │ Dashboard   │                 │                │
   │<────────────┤                 │                │
```

### 2. NFC Emulation Setup Flow

```
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│  Login   │  │ Flutter  │  │ Android  │  │   HCE    │
│ Success  │  │  Layer   │  │ Native   │  │ Service  │
└────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘
     │             │              │              │
     │ 1. Token    │              │              │
     │    Received │              │              │
     ├────────────>│              │              │
     │             │              │              │
     │             │ 2. Create    │              │
     │             │    JSON      │              │
     │             │    Payload   │              │
     │             │              │              │
     │             │ 3. Method    │              │
     │             │    Channel   │              │
     │             │    Call      │              │
     │             ├─────────────>│              │
     │             │              │              │
     │             │              │ 4. Store in  │
     │             │              │    SharedPref│
     │             │              ├─────────────>│
     │             │              │              │
     │             │              │              │
     │             │ 5. Success   │              │
     │             │<─────────────┤              │
     │             │              │              │
     │ 6. Ready    │              │              │
     │    for NFC  │              │              │
     │<────────────┤              │              │
     │             │              │              │
     │         NFC Reader Approaches             │
     │             │              │              │
     │             │              │  7. APDU     │
     │             │              │     Commands │
     │             │              │<─────────────┤
     │             │              │              │
     │             │              │  8. Read     │
     │             │              │     JSON     │
     │             │              │     from     │
     │             │              │     Storage  │
     │             │              │              │
     │             │              │  9. Return   │
     │             │              │     Data     │
     │             │              │─────────────>│
```

### 3. Registration Flow

```
┌──────┐    ┌──────────┐    ┌────────────┐    ┌────────┐
│ User │    │   UI     │    │ Controller │    │  API   │
└──┬───┘    └────┬─────┘    └─────┬──────┘    └───┬────┘
   │             │                 │                │
   │ 1. Fill     │                 │                │
   │ Form        │                 │                │
   ├────────────>│                 │                │
   │             │ 2. Tap Register │                │
   │             │                 │                │
   │             │ 3. Create       │                │
   │             │ RegisterModel   │                │
   │             ├────────────────>│                │
   │             │                 │                │
   │             │                 │ 4. POST        │
   │             │                 │ /register      │
   │             │                 ├───────────────>│
   │             │                 │                │
   │             │                 │ 5. Success     │
   │             │                 │    Response    │
   │             │                 │<───────────────┤
   │             │                 │                │
   │             │ 6. Show Success │                │
   │             │    Message      │                │
   │             │<────────────────┤                │
   │             │                 │                │
   │             │ 7. Navigate to  │                │
   │             │    Login        │                │
   │             │                 │                │
   │ 8. Login    │                 │                │
   │ Page Shown  │                 │                │
   │<────────────┤                 │                │
```

## Design Patterns

### 1. Observer Pattern (GetX)

Used for reactive state management:

```dart
// Observable state
RxBool _isLoading = false.obs;

// UI automatically updates when state changes
Obx(() {
  if (controller.isLoading) {
    return CircularProgressIndicator();
  }
  return LoginForm();
})
```

### 2. Singleton Pattern (GetStorage)

Used for persistent storage:

```dart
final box = GetStorage();

// Single instance accessed throughout app
box.write("token", token);
String? token = box.read("token");
```

### 3. Factory Pattern (Model Parsing)

Used for JSON deserialization:

```dart
factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
  LoginResponseModel(
    token: json["token"],
    name: json["name"],
    role: json["role"],
  );
```

### 4. Strategy Pattern (Role-Based Navigation)

Used for different user type handling:

```dart
if (data.role == 2) {
  Get.offAll(() => Mainscreen());
} else if (data.role == 0) {
  Get.offAll(() => AdminPage());
} else {
  Get.offAll(() => InstructorPage());
}
```

## Security Architecture

### 1. Authentication Security

```
┌─────────────────────────────────────────┐
│         Client (Mobile App)              │
│                                          │
│  1. User credentials                     │
│     ↓                                    │
│  2. HTTPS POST /login                    │
│     ↓                                    │
│  3. Receive JWT Token                    │
│     ↓                                    │
│  4. Store in GetStorage                  │
│     (device-local, encrypted OS storage) │
│     ↓                                    │
│  5. Include in Authorization header      │
│     for subsequent requests              │
└─────────────────────────────────────────┘
```

### 2. Data Storage Security

**Sensitive Data:**
- JWT tokens stored in GetStorage (uses native encrypted storage)
- No passwords stored locally
- Token cleared on logout

**Non-Sensitive Data:**
- User preferences
- UI state
- Cached responses

### 3. Network Security

**Current Implementation:**
- HTTP-based communication
- JWT authentication
- HTTPS should be used in production

**Recommendations:**
- Implement certificate pinning
- Use HTTPS exclusively
- Implement request signing
- Add request throttling

### 4. NFC Security

**Current Implementation:**
- Short-range communication (< 4cm)
- JWT token transmitted
- APDU protocol

**Security Measures:**
- Proximity requirement
- Token expiration
- Server-side validation

**Recommendations:**
- Encrypt NFC payload
- Implement replay protection
- Add nonce/timestamp
- Use challenge-response

## Performance Considerations

### 1. State Management Optimization

**GetX Benefits:**
- Minimal rebuilds (only affected widgets)
- Lazy loading of controllers
- Automatic memory management

**Best Practices:**
```dart
// ✅ Good: Only rebuild when needed
Obx(() => Text(controller.username))

// ❌ Bad: Rebuild entire widget tree
GetBuilder<LoginController>(
  builder: (controller) => EntireScreen()
)
```

### 2. Image and Asset Optimization

**Lottie Animations:**
- JSON-based (small file size)
- Hardware accelerated
- Cached by framework

**Asset Management:**
```yaml
assets:
  - assets/lotties/  # Only load when needed
```

### 3. Network Optimization

**Current Implementation:**
- Synchronous HTTP requests
- No caching
- No retry mechanism

**Recommendations:**
- Implement request caching
- Add retry logic with exponential backoff
- Use connection pooling
- Implement request debouncing

### 4. Memory Management

**GetX Controller Lifecycle:**
```dart
// Controllers automatically disposed when not needed
Get.delete<LoginController>(force: true);
Get.put(LoginController());  // Create new instance
```

**Best Practices:**
- Dispose controllers when not needed
- Clear large data structures
- Use const constructors where possible

## Testing Strategy

### 1. Unit Tests

**Target:** Business logic in controllers

```dart
test('Login controller sets loading state', () {
  final controller = LoginController();
  controller.setLoading = true;
  expect(controller.isLoading, true);
});
```

### 2. Widget Tests

**Target:** UI components

```dart
testWidgets('Login button triggers login', (tester) async {
  await tester.pumpWidget(LoginPage());
  await tester.tap(find.text('Bejelentkezés'));
  await tester.pump();
  // Verify expected behavior
});
```

### 3. Integration Tests

**Target:** Complete user flows

```dart
testWidgets('Complete login flow', (tester) async {
  // 1. Launch app
  // 2. Enter credentials
  // 3. Tap login
  // 4. Verify navigation
});
```

### 4. Platform Tests

**Target:** Native integration

- Test Method Channel communication
- Test HCE service responses
- Test NFC transactions

## Deployment Architecture

### 1. Build Process

```bash
# Development build
flutter run --debug

# Release build
flutter build apk --release
flutter build appbundle --release
```

### 2. Configuration Management

**Environment-Specific Configuration:**

```dart
// constants.dart
String baseURL = const String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:5188'
);
```

**Build with configuration:**
```bash
flutter build apk --dart-define=API_URL=https://api.production.com
```

### 3. Version Management

**pubspec.yaml:**
```yaml
version: 1.0.0+1
#        │ │ │  └─ Build number
#        │ │ └──── Patch version
#        │ └────── Minor version
#        └──────── Major version
```

## Scalability Considerations

### 1. Current Limitations

- Single backend URL
- No request caching
- No offline mode
- Limited error recovery

### 2. Scalability Improvements

**Backend:**
- Implement load balancing
- Add CDN for static assets
- Database read replicas
- API rate limiting

**Mobile App:**
- Implement offline-first architecture
- Add request queue
- Implement background sync
- Add local database (SQLite)

### 3. Future Architecture

```
┌────────────────────────────────────────┐
│         Mobile App (Flutter)            │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │     Offline-First Layer          │  │
│  │  - Local SQLite DB               │  │
│  │  - Request Queue                 │  │
│  │  - Background Sync               │  │
│  └──────────────────────────────────┘  │
│                 ↓                       │
│  ┌──────────────────────────────────┐  │
│  │     API Layer                    │  │
│  │  - Caching                       │  │
│  │  - Retry Logic                   │  │
│  │  - Request Signing               │  │
│  └──────────────────────────────────┘  │
└─────────────────┬───────────────────────┘
                  │
        ┌─────────▼─────────┐
        │   Load Balancer   │
        └─────────┬─────────┘
                  │
        ┌─────────▼─────────┐
        │   API Gateway     │
        │  - Rate Limiting  │
        │  - Auth           │
        └─────────┬─────────┘
                  │
     ┌────────────┼────────────┐
     │            │            │
┌────▼────┐  ┌───▼────┐  ┌───▼────┐
│ API     │  │ API    │  │ API    │
│ Server  │  │ Server │  │ Server │
│   #1    │  │   #2   │  │   #3   │
└────┬────┘  └───┬────┘  └───┬────┘
     └───────────┼────────────┘
                 │
        ┌────────▼─────────┐
        │    Database      │
        │  - Primary       │
        │  - Replicas      │
        └──────────────────┘
```

## Maintenance and Monitoring

### 1. Logging

**Current Implementation:**
```dart
print('Login successful');
print('Error: $e');
```

**Recommended:**
```dart
import 'package:logger/logger.dart';

final logger = Logger();

logger.i('Login successful');
logger.e('Error occurred', error: e, stackTrace: trace);
```

### 2. Error Tracking

**Recommended Tools:**
- Firebase Crashlytics
- Sentry
- Custom error reporting

### 3. Analytics

**Track:**
- User flows
- Feature usage
- Error rates
- Performance metrics

**Recommended Tools:**
- Firebase Analytics
- Google Analytics
- Mixpanel

### 4. App Updates

**Strategy:**
- Semantic versioning
- Staged rollouts
- A/B testing
- Feature flags

## Documentation Maintenance

### 1. Code Documentation

**Standard:**
```dart
/// Authenticates a user with the provided credentials.
///
/// [data] - JSON string containing neptunCode, password, and cardId
///
/// Throws [Exception] if network request fails
///
/// Returns void, but updates internal state and navigates on success
void loginFunction(String data) async {
  // Implementation
}
```

### 2. Architecture Decision Records (ADRs)

Document major technical decisions:
- Why GetX for state management?
- Why HCE instead of NDEF?
- Why REST instead of GraphQL?

### 3. API Documentation

Maintain up-to-date API documentation:
- Endpoint specifications
- Request/response examples
- Error codes
- Authentication requirements

## Conclusion

UniCheck follows modern Flutter development practices with:
- Clean architecture
- Reactive state management
- Platform-specific integration
- Security-conscious design

The architecture is designed to be:
- **Maintainable:** Clear separation of concerns
- **Testable:** Isolated business logic
- **Scalable:** Room for growth
- **Secure:** Authentication and authorization

Future improvements should focus on:
- Offline-first architecture
- Enhanced security
- Performance optimization
- Comprehensive testing
- Better error handling

## References

- [Flutter Documentation](https://docs.flutter.dev/)
- [GetX Documentation](https://pub.dev/packages/get)
- [Android HCE Guide](https://developer.android.com/guide/topics/connectivity/nfc/hce)
- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
