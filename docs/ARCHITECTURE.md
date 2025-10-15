# UniCheck - Architektúra Dokumentáció

## Áttekintés

Ez a dokumentum részletesen bemutatja a UniCheck alkalmazás architektúráját, tervezési mintáit és technikai döntéseit.

## Architektúrális Rétegek

### 1. Prezentációs Réteg (UI Layer)

A felhasználói felület Flutter widgetek segítségével épül fel, következetes Material Design elveket követve.

#### Komponens Hierarchia

```
MaterialApp (GetMaterialApp)
└── LoginOrRegister (Router)
    ├── LoginPage
    │   ├── CustomLoginRegisterContainer
    │   ├── NeptunCodeField
    │   ├── PasswordTextField
    │   └── CustomButton
    └── RegisterPage
        ├── CustomLoginRegisterContainer
        ├── NameTextField
        ├── NeptunCodeField
        ├── PasswordTextField
        ├── PasswordVerificationTextField
        └── CustomButton
```

#### Widget Típusok

**Stateless Widgets:**
- `CustomButton`: Általános gomb komponens
- `CustomLoginRegisterContainer`: Login/Register form konténer
- `Mainscreen`: Főképernyő
- `AdminPage`: Admin felület

**Stateful Widgets:**
- `LoginPage`: Bejelentkezési képernyő
- `RegisterPage`: Regisztrációs képernyő
- `NfcStatusPage`: NFC státusz ellenőrző
- `Methodchannel`: NFC Method Channel példa

### 2. Üzleti Logika Réteg (Business Logic Layer)

A GetX framework Controller mintáját használja az állapotkezelésre és üzleti logikára.

#### Controller Pattern

```dart
class LoginController extends GetxController {
  // Reaktív állapot
  RxBool _isLoading = false.obs;
  
  // Getter/Setter
  bool get isLoading => _isLoading.value;
  set setLoading(bool newState) => _isLoading.value = newState;
  
  // Üzleti logika metódusok
  void loginFunction(String data) async {
    setLoading = true;
    try {
      // API hívás
      var response = await http.post(url, headers: headers, body: data);
      // Válasz feldolgozása
      // Navigáció
    } finally {
      setLoading = false;
    }
  }
}
```

#### Controller Felelősségek

| Controller | Felelősség |
|------------|------------|
| `LoginController` | Bejelentkezés, token mentés, navigáció |
| `RegisterController` | Regisztráció, validáció |
| `PasswordController` | Jelszó láthatóság kezelése |

### 3. Adat Réteg (Data Layer)

#### Model Classes

Minden API entitáshoz van egy megfelelő Dart model:

```dart
class LoginModel {
  final String neptunCode;
  final String password;
  final String cardId;
  
  LoginModel({
    required this.neptunCode,
    required this.password,
    required this.cardId,
  });
  
  Map<String, dynamic> toJson() => {
    "neptunCode": neptunCode,
    "password": password,
    "cardId": cardId,
  };
}
```

#### Data Flow

```
User Input
    ↓
Controller (validates & transforms)
    ↓
Model (serializes to JSON)
    ↓
HTTP Client (sends request)
    ↓
API Response
    ↓
Model (deserializes from JSON)
    ↓
Controller (updates state)
    ↓
UI (rebuilds via Obx)
```

### 4. Hálózati Réteg (Network Layer)

#### HTTP Client Configuration

```dart
Map<String, String> headers = {
  'Content-type': 'application/json',
  'Authorization': 'Bearer ${box.read("token")}'
};

var response = await http.post(
  Uri.parse('$baseURL/api/Auth/login'),
  headers: headers,
  body: data
);
```

#### Response Handling

```dart
if (response.statusCode == 200) {
  // Sikeres válasz
  LoginResponseModel data = loginResponseModelFromJson(response.body);
  box.write("userData", jsonEncode(data));
  box.write("token", data.token);
  Get.offAll(() => Mainscreen());
} else {
  // Hiba kezelés
  var error = apiErrorFromJson(response.body);
  Get.snackbar("Hiba", error.details);
}
```

### 5. Perzisztencia Réteg (Persistence Layer)

#### GetStorage

A helyi adattároláshoz GetStorage-t használ:

```dart
final box = GetStorage();

// Írás
box.write("token", tokenValue);
box.write("userData", userDataJson);

// Olvasás
String? token = box.read("token");
String? userData = box.read("userData");

// Törlés
box.remove("token");
box.erase(); // Összes törlése
```

#### Android SharedPreferences (Natív)

NFC HCE Service esetén:

```kotlin
val prefs = getSharedPreferences("hce_prefs", Context.MODE_PRIVATE)
prefs.edit().putString("emulated_json", json).apply()
```

## Platform Natív Integráció

### Android NFC HCE Architektúra

#### Komponensek

1. **MainActivity.kt**
   - Flutter Activity
   - Method Channel host
   - SharedPreferences kezelés

2. **HceService.kt**
   - HostApduService kiterjesztése
   - APDU parancsok feldolgozása
   - JSON token emulálás

3. **Method Channel**
   - Flutter ↔ Kotlin híd
   - JSON adatok átadása

#### Szekvencia Diagram: NFC Token Emulálás

```
Flutter App          MainActivity          SharedPrefs          HceService          NFC Reader
    |                     |                     |                    |                   |
    |--setEmulatedJson--->|                     |                    |                   |
    |                     |----put(json)------->|                    |                   |
    |<---success----------|                     |                    |                   |
    |                     |                     |                    |                   |
    |                     |                     |                    |<---SELECT---------|
    |                     |                     |                    |                   |
    |                     |                     |<----get(json)------|                   |
    |                     |                     |----json----------->|                   |
    |                     |                     |                    |---SW_OK---------->|
    |                     |                     |                    |                   |
    |                     |                     |                    |<--GET_CHUNK-------|
    |                     |                     |                    |---chunk+SW_OK---->|
```

### APDU Command Structure

#### SELECT Command
```
CLA  INS  P1   P2   Lc   Data...        Le
00   A4   04   00   07   F0010203040506  00

Response: 90 00 (SW_OK)
```

#### GET_CHUNK Command
```
CLA  INS  P1   P2   Lc   Off_Hi  Off_Lo  Length
00   10   00   00   03   00      00      FF

Response: [chunk data] 90 00
```

## State Management: GetX

### Reaktív Programozás

#### Rx Variables

```dart
// Reaktív változó deklarálása
RxBool _isLoading = false.obs;
RxString _userName = ''.obs;
RxList<Course> _courses = <Course>[].obs;

// Érték módosítása
_isLoading.value = true;
_userName.value = "János";
_courses.add(newCourse);
```

#### Obx Widget

A UI automatikusan újraépül, amikor a megfigyelt változók változnak:

```dart
Obx(() {
  if (controller.isLoading) {
    return CircularProgressIndicator();
  }
  return Text(controller.userName);
})
```

### Dependency Injection

```dart
// Controller regisztráció
Get.put(LoginController());
Get.lazyPut(() => RegisterController());

// Controller használat
final controller = Get.find<LoginController>();

// Controller törlés
Get.delete<LoginController>();
```

### Navigation

```dart
// Push új oldal
Get.to(() => NewPage());

// Replace jelenlegi oldal
Get.off(() => NewPage());

// Replace összes oldal (nincs back)
Get.offAll(() => HomePage());

// Named routes
Get.toNamed('/profile');

// Paraméterek átadása
Get.to(() => DetailPage(), arguments: {'id': 123});
```

## Design Patterns

### 1. MVC (Model-View-Controller)

```
Model (models/)
  ├── Adatstruktúrák
  ├── JSON serialization
  └── Validáció

View (pages/, components/, widgets/)
  ├── UI komponensek
  ├── Layout
  └── Felhasználói interakció

Controller (controllers/)
  ├── Üzleti logika
  ├── API hívások
  └── State management
```

### 2. Repository Pattern (Implicit)

Bár nincs külön repository réteg, a controllerek működnek repository-ként:

```dart
class LoginController extends GetxController {
  // Repository-szerű metódusok
  Future<LoginResponseModel> login(LoginModel model) async {
    // API hívás
  }
  
  void saveUserData(LoginResponseModel data) {
    // Adatmentés
  }
  
  LoginResponseModel? getUserData() {
    // Adat lekérés
  }
}
```

### 3. Singleton Pattern

GetX automatikusan singleton-t hoz létre a controllerekből:

```dart
Get.put(LoginController()); // Singleton létrehozás
final controller = Get.find<LoginController>(); // Ugyanaz az instance
```

### 4. Observer Pattern

Obx widgetek figyelik a reaktív változókat:

```dart
// Observable
RxBool _isVisible = false.obs;

// Observer
Obx(() => Visibility(
  visible: _isVisible.value,
  child: Widget(),
))
```

## Biztonsági Architektúra

### Authentication Flow

```
1. User enters credentials
         ↓
2. Controller validates input
         ↓
3. HTTP POST to /api/Auth/login
         ↓
4. Backend validates & generates JWT
         ↓
5. Response with token
         ↓
6. Save token to GetStorage
         ↓
7. Navigate to Home
         ↓
8. All subsequent requests include token in header
```

### Token Management

```dart
class TokenManager {
  static final box = GetStorage();
  
  static void saveToken(String token) {
    box.write("token", token);
  }
  
  static String? getToken() {
    return box.read("token");
  }
  
  static void clearToken() {
    box.remove("token");
  }
  
  static bool isTokenValid() {
    String? token = getToken();
    if (token == null) return false;
    // JWT decode és lejárat ellenőrzés
    return true;
  }
}
```

## Teljesítmény Optimalizálás

### 1. Lazy Loading

```dart
// Controller lazy betöltése
Get.lazyPut(() => HeavyController());

// Csak akkor jön létre, amikor először használjuk
final controller = Get.find<HeavyController>();
```

### 2. Image Caching

```dart
// Cached network image használata (javaslat)
CachedNetworkImage(
  imageUrl: "https://...",
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### 3. List Optimization

```dart
// ListView.builder nagy listák számára
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
)
```

## Skálázhatósági Megfontolások

### Backend Kommunikáció

A jelenlegi architektúra támogatja:
- ✅ Több API endpoint
- ✅ Token-based auth
- ✅ Hiba kezelés
- ⚠️ Retry mechanizmus (hiányzik)
- ⚠️ Request caching (hiányzik)

### Javaslatok Nagy Felhasználói Bázishoz

1. **API Client Service**
```dart
class ApiService {
  static final http.Client client = http.Client();
  
  static Future<Response> post(String endpoint, dynamic body) async {
    // Retry logika
    // Timeout kezelés
    // Error handling
  }
}
```

2. **Offline Support**
```dart
class OfflineManager {
  static void saveForLater(AttendanceModel data) {
    // Lokális mentés
  }
  
  static void syncWhenOnline() {
    // Szinkronizálás
  }
}
```

3. **Pagination**
```dart
class CourseController extends GetxController {
  RxList<Course> courses = <Course>[].obs;
  int page = 1;
  
  void loadMore() async {
    page++;
    final newCourses = await fetchCourses(page);
    courses.addAll(newCourses);
  }
}
```

## Tesztelhetőség

### Unit Test Struktúra

```dart
// test/controllers/login_controller_test.dart
void main() {
  group('LoginController Tests', () {
    late LoginController controller;
    
    setUp(() {
      controller = LoginController();
    });
    
    test('Initial state', () {
      expect(controller.isLoading, false);
    });
    
    test('Login success updates state', () async {
      // Mock HTTP response
      // Test login
      // Assert state changes
    });
  });
}
```

### Widget Test Példa

```dart
// test/widgets/custom_button_test.dart
void main() {
  testWidgets('CustomButton shows text and responds to tap', 
    (WidgetTester tester) async {
    
    bool tapped = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'Test',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    
    expect(find.text('Test'), findsOneWidget);
    
    await tester.tap(find.byType(CustomButton));
    await tester.pump();
    
    expect(tapped, true);
  });
}
```

## Deployment Architektúra

### CI/CD Pipeline (Javasolt)

```yaml
# .github/workflows/flutter.yml
name: Flutter CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk --release
```

### Build Variants

```gradle
// android/app/build.gradle
android {
    buildTypes {
        debug {
            applicationIdSuffix ".debug"
            manifestPlaceholders = [appName: "UniCheck Debug"]
        }
        release {
            manifestPlaceholders = [appName: "UniCheck"]
            signingConfig signingConfigs.release
        }
    }
    
    flavorDimensions "environment"
    productFlavors {
        dev {
            dimension "environment"
            applicationIdSuffix ".dev"
            buildConfigField "String", "API_URL", '"http://dev.api.com"'
        }
        prod {
            dimension "environment"
            buildConfigField "String", "API_URL", '"http://api.com"'
        }
    }
}
```

## Konklúzió

A UniCheck alkalmazás egy jól strukturált, skálázható Flutter alkalmazás, amely modern fejlesztési gyakorlatokat követ. A GetX framework használata egyszerűsíti az állapotkezelést és navigációt, míg a tiszta architektúra megkönnyíti a karbantartást és bővítést.

### Erősségek
- ✅ Tiszta MVC struktúra
- ✅ Reaktív state management
- ✅ Platform natív integráció (NFC)
- ✅ Token-based authentication

### Fejlesztési Lehetőségek
- 🔄 Repository pattern explicit implementálása
- 🔄 Dependency injection konténer
- 🔄 Error handling centralizálása
- 🔄 Offline support
- 🔄 Comprehensive testing

---

**Verzió:** 1.0.0  
**Utolsó Frissítés:** 2024-01-15
