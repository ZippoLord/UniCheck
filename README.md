# UniCheck - Egyetemi Jelenléti Rendszer

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.9.2+-blue.svg)
![Android](https://img.shields.io/badge/Platform-Android-green.svg)
![License](https://img.shields.io/badge/License-Private-red.svg)

## 📖 Tartalomjegyzék

1. [Projekt Áttekintés](#projekt-áttekintés)
2. [Funkciók](#funkciók)
3. [Technológiai Stack](#technológiai-stack)
4. [Architektúra](#architektúra)
5. [Telepítés és Konfiguráció](#telepítés-és-konfiguráció)
6. [Használati Útmutató](#használati-útmutató)
7. [NFC Implementáció](#nfc-implementáció)
8. [API Dokumentáció](#api-dokumentáció)
9. [Fejlesztői Dokumentáció](#fejlesztői-dokumentáció)
10. [Hibaelhárítás](#hibaelhárítás)
11. [Biztonsági Megfontolások](#biztonsági-megfontolások)

## 🎯 Projekt Áttekintés

A **UniCheck** egy modern, Flutter-alapú mobil alkalmazás, amely NFC (Near Field Communication) technológiát használ az egyetemi hallgatók jelenléti nyilvántartásának egyszerűsítésére. Az alkalmazás lehetővé teszi a hallgatók számára, hogy digitális diákigazolványként használják okostelefonjukat, és a rendszer támogatja a különböző felhasználói szerepköröket (hallgató, oktató, adminisztrátor).

### Fő Célkitűzések

- **Egyszerűsítés**: A hagyományos papíralapú vagy manuális jelenléti rendszerek helyettesítése
- **Biztonság**: JWT tokenek és titkosított kommunikáció használata
- **Felhasználóbarát**: Intuitív felhasználói felület Lottie animációkkal
- **Technológiai Innováció**: NFC HCE (Host Card Emulation) implementáció
- **Skálázhatóság**: Több egyetemi kar és tanszék támogatása

## ✨ Funkciók

### Hallgatói Funkciók

- ✅ **Regisztráció és Bejelentkezés**
  - Neptun kód alapú regisztráció
  - Jelszó validáció és megerősítés
  - Biztonságos bejelentkezés JWT tokenekkel
  
- 📱 **NFC Digitális Diákigazolvány**
  - Okostelefon mint diákigazolvány
  - HCE (Host Card Emulation) technológia
  - Valós idejű token emulálás
  
- 👤 **Profil Kezelés**
  - Személyes adatok megtekintése
  - Jelenléti statisztikák
  
### Oktatói Funkciók

- 📊 **Jelenléti Nyilvántartás**
  - NFC alapú jelenlét rögzítés
  - Kurzusok kezelése
  - Statisztikák és riportok
  
### Adminisztrátori Funkciók

- ⚙️ **Rendszer Adminisztráció**
  - Felhasználók kezelése
  - Jogosultságok beállítása
  - Rendszer konfiguráció

## 🛠 Technológiai Stack

### Frontend (Flutter/Dart)

```yaml
Verzió: Flutter 3.9.2+
SDK: Dart ^3.9.2
```

#### Főbb Függőségek

| Csomag | Verzió | Funkció |
|--------|--------|---------|
| `get` | ^4.7.2 | State management és navigáció |
| `get_storage` | ^2.1.1 | Helyi adattárolás |
| `http` | ^1.5.0 | HTTP kérések kezelése |
| `lottie` | ^3.3.2 | Animációk |
| `nfc_manager` | ^4.1.1 | NFC funkcionalitás |
| `encrypt` | ^5.0.3 | Titkosítás |
| `app_settings` | ^6.1.1 | Rendszerbeállítások elérése |
| `permission_handler` | ^12.0.1 | Engedélyek kezelése |

### Backend

- **ASP.NET Core API** (feltételezett)
- **JWT Authentication**
- **RESTful API architektúra**
- Alapértelmezett endpoint: `http://localhost:5188`

### Android Natív Komponensek

- **Kotlin**: Natív Android fejlesztés
- **NFC HCE Service**: Host Card Emulation implementáció
- **SharedPreferences**: Token tárolás
- **Method Channel**: Flutter-Kotlin kommunikáció

## 🏗 Architektúra

### Alkalmazás Architektúra

A projekt **GetX** alapú MVC (Model-View-Controller) architektúrát követ:

```
lib/
├── main.dart                 # Alkalmazás belépési pont
├── constants.dart            # Globális konstansok (API URL)
├── login_or_register.dart    # Autentikációs router
│
├── models/                   # Adatmodellek
│   ├── login_model.dart
│   ├── login_response.dart
│   ├── register_model.dart
│   ├── register_response_model.dart
│   └── api_error.dart
│
├── controllers/              # Üzleti logika
│   ├── login_controller.dart
│   ├── register_controller.dart
│   └── password_controller.dart
│
├── components/               # Újrafelhasználható komponensek
│   ├── neptunCodeField.dart
│   ├── nametextField.dart
│   ├── passwordTextField.dart
│   └── passwordVerField.dart
│
├── widgets/                  # Összetett widgetek
│   ├── customButton.dart
│   └── customLoginRegister.dart
│
└── pages/                    # Képernyők
    ├── login.dart
    ├── register.dart
    ├── mainScreen.dart
    ├── adminPage.dart
    ├── instructorPage.dart
    ├── nfc.dart
    └── methodChannel.dart
```

### Android Natív Struktúra

```
android/app/src/main/
├── kotlin/com/example/prog24/
│   ├── MainActivity.kt       # Flutter Activity + Method Channel
│   └── HceService.kt         # NFC HCE Service
│
├── res/
│   └── xml/
│       └── apduservice.xml   # NFC AID konfiguráció
│
└── AndroidManifest.xml       # App konfiguráció és engedélyek
```

### Adatfolyam Diagram

```
┌─────────────┐
│   Flutter   │
│     UI      │
└──────┬──────┘
       │
       ├─── GetX Controllers ───┐
       │                        │
       ├─── HTTP Client ────────┼──► Backend API
       │                        │
       └─── Method Channel ─────┘
                │
                ▼
       ┌──────────────┐
       │   Android    │
       │ HCE Service  │
       └──────┬───────┘
              │
              ▼
         NFC Reader
```

## 📦 Telepítés és Konfiguráció

### Előfeltételek

- **Flutter SDK**: 3.9.2 vagy újabb
- **Dart SDK**: 3.9.2 vagy újabb
- **Android Studio**: Latest stable version
- **Kotlin**: 1.9+
- **Android SDK**: API 21+ (minimum), API 33+ (ajánlott)
- **NFC-képes Android eszköz**: Teszteléshez

### Lépésről Lépésre Telepítés

#### 1. Repository Klónozása

```bash
git clone https://github.com/ZippoLord/UniCheck.git
cd UniCheck
```

#### 2. Függőségek Telepítése

```bash
# Flutter függőségek letöltése
flutter pub get

# Flutter környezet ellenőrzése
flutter doctor -v
```

#### 3. Backend URL Konfigurálása

Szerkeszd a `lib/constants.dart` fájlt:

```dart
String baseURL = "http://your-backend-server:port";
// Példa: String baseURL = "https://api.unichez.edu";
```

#### 4. Android Konfiguráció

##### NFC Engedélyek (AndroidManifest.xml)

A projekt már tartalmazza a szükséges engedélyeket:

```xml
<uses-permission android:name="android.permission.NFC" />
<uses-permission android:name="android.permission.INTERNET"/>
<uses-feature android:name="android.hardware.nfc" android:required="false"/>
```

##### HCE Service Konfiguráció

Az `apduservice.xml` fájlban állítsd be az egyedi AID-t (Application ID):

```xml
<host-apdu-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:description="@string/servicedesc"
    android:requireDeviceUnlock="false">
    <aid-group android:description="@string/aiddescription"
        android:category="other">
        <aid-filter android:name="F0010203040506"/>
    </aid-group>
</host-apdu-service>
```

#### 5. Alkalmazás Build és Futtatás

```bash
# Debug build
flutter run

# Release build
flutter build apk --release

# App bundle (Play Store)
flutter build appbundle --release
```

### Környezeti Változók

Hozz létre egy `.env` fájlt (opcionális):

```env
API_BASE_URL=http://localhost:5188
API_TIMEOUT=30
DEBUG_MODE=true
```

## 📱 Használati Útmutató

### Első Indítás

1. **Alkalmazás Telepítése**
   - Telepítsd az alkalmazást Android eszközödre
   - Engedélyezd az NFC funkciót az eszköz beállításaiban

2. **Regisztráció**
   - Nyisd meg az alkalmazást
   - Kattints a "Regisztráció" gombra
   - Töltsd ki a mezőket:
     - **Név**: Teljes neved
     - **Neptun kód**: Egyetemi azonosító (pl. ABC123)
     - **Jelszó**: Minimum 8 karakter, legalább 1 nagybetű, 1 szám
     - **Jelszó megerősítés**: Ugyanaz, mint a jelszó
   - Kattints a "Regisztráció" gombra

3. **Bejelentkezés**
   - Add meg Neptun kódodat
   - Add meg jelszavadat
   - Kattints a "Bejelentkezés" gombra

### Jelenlét Rögzítése (Hallgató)

1. **NFC Aktiválása**
   - Navigálj az NFC státusz oldalra
   - Ellenőrizd, hogy az NFC engedélyezett
   - Ha nem, kattints az "NFC beállítások megnyitása" gombra

2. **Jelenlét Bejelentése**
   - Az előadásteremben/laborban közelítsd az eszközt az NFC olvasóhoz
   - Az alkalmazás automatikusan továbbítja a digitális diákigazolvány adatokat
   - Várd meg a megerősítő üzenetet

### Oktatói Funkciók

1. **Órához Készítés**
   - Jelentkezz be oktató fiókkal
   - Válaszd ki az aktuális órát/kurzust
   - Indítsd el a jelenléti rögzítést

2. **Hallgatók Rögzítése**
   - A hallgatók NFC eszközeit olvasd be
   - A rendszer automatikusan naplózza a jelenlétet
   - Tekintsd meg a valós idejű statisztikákat

## 🔐 NFC Implementáció

### Host Card Emulation (HCE) Architektúra

Az UniCheck az Android HCE technológiát használja, amely lehetővé teszi, hogy a telefon NFC kártyaként viselkedjen külső Secure Element nélkül.

#### HCE Service Működése

##### 1. Service Regisztráció

```kotlin
class MyHostApduService : HostApduService() {
    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
        // APDU parancsok feldolgozása
    }
    
    override fun onDeactivated(reason: Int) {
        // Tisztítás kapcsolat megszakadásakor
    }
}
```

##### 2. APDU Parancsok

Az alkalmazás két fő APDU parancsot kezel:

**SELECT Command (CLA=0x00, INS=0xA4)**
```kotlin
if (ins == 0xA4) {
    // Applet kiválasztása
    return SW_OK // 0x9000
}
```

**GET_CHUNK Command (CLA=0x00, INS=0x10)**
```kotlin
if (ins == 0x10) {
    val offsetHi = commandApdu[5].toInt() and 0xFF
    val offsetLo = commandApdu[6].toInt() and 0xFF
    val length = commandApdu[7].toInt() and 0xFF
    val offset = (offsetHi shl 8) or offsetLo
    
    val jsonBytes = getEmulatedJson()
    val chunk = jsonBytes.copyOfRange(offset, end)
    return chunk + SW_OK
}
```

##### 3. Token Tárolás és Emulálás

```kotlin
private fun getEmulatedJson(): ByteArray {
    val prefs = getSharedPreferences("hce_prefs", Context.MODE_PRIVATE)
    val json = prefs.getString("emulated_json", "") ?: ""
    return json.toByteArray(Charsets.UTF_8)
}
```

#### Flutter-Kotlin Kommunikáció

**Method Channel Beállítás**

```kotlin
// MainActivity.kt
private val CHANNEL = "com.example.prog24/hce"

MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
    .setMethodCallHandler { call, result ->
        when (call.method) {
            "setEmulatedJson" -> {
                val json = call.argument<String>("json") ?: ""
                // Mentés SharedPreferences-be
                result.success(null)
            }
        }
    }
```

**Flutter Oldal**

```dart
const platform = MethodChannel('com.example.prog24/hce');

Future<void> _pushJsonToHce() async {
  try {
    await platform.invokeMethod('setEmulatedJson', {
      'json': sampleJson
    });
  } on PlatformException catch (e) {
    print('Hiba: $e');
  }
}
```

#### JSON Token Formátum

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "name": "Kovács János",
  "role": 2,
  "neptunCode": "ABC123",
  "userId": 12345
}
```

### NFC Biztonsági Megfontolások

1. **Token Érvényesség**: JWT tokenek rövid lejárati idővel
2. **Titkosítás**: Kommunikáció HTTPS-en keresztül
3. **Device Unlock**: Opcionálisan beállítható, hogy csak feloldott eszközön működjön
4. **Replay Attack védelem**: Timestamp és nonce használata

## 📡 API Dokumentáció

### Base URL

```
http://localhost:5188/api
```

### Endpointok

#### Autentikáció

##### POST `/Auth/register`

Új felhasználó regisztrálása.

**Request Body:**
```json
{
  "name": "Kovács János",
  "neptunCode": "ABC123",
  "password": "SecurePass123",
  "cardId": "3"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Sikeres regisztráció",
  "userId": 12345
}
```

**Response (400 Bad Request):**
```json
{
  "error": "Validation Error",
  "details": "A Neptun kód már használatban van"
}
```

##### POST `/Auth/login`

Felhasználó bejelentkeztetése.

**Request Body:**
```json
{
  "neptunCode": "ABC123",
  "password": "SecurePass123",
  "cardId": "2"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "name": "Kovács János",
  "role": 2,
  "expiresAt": "2024-01-15T10:30:00Z"
}
```

**Szerepkörök:**
- `0`: Admin
- `1`: Oktató (Instructor)
- `2`: Hallgató (Student)

#### Jelenléti Nyilvántartás

##### POST `/Attendance/check-in`

Hallgatói jelenlét rögzítése.

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "courseId": "CS101",
  "timestamp": "2024-01-15T08:00:00Z",
  "location": "A épület 101"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "attendanceId": 56789,
  "message": "Jelenlét sikeresen rögzítve"
}
```

#### Felhasználó Adatok

##### GET `/Users/profile`

Bejelentkezett felhasználó profiljának lekérdezése.

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "userId": 12345,
  "name": "Kovács János",
  "neptunCode": "ABC123",
  "role": 2,
  "email": "kovacs.janos@edu.hu",
  "enrolledCourses": [
    {
      "courseId": "CS101",
      "courseName": "Programozás alapjai",
      "attendance": 85.5
    }
  ]
}
```

### Hibakódok

| Státusz Kód | Jelentés | Leírás |
|-------------|----------|---------|
| 200 | OK | Sikeres kérés |
| 201 | Created | Erőforrás létrehozva |
| 400 | Bad Request | Hibás kérés formátum |
| 401 | Unauthorized | Hiányzó vagy érvénytelen token |
| 403 | Forbidden | Nincs jogosultság |
| 404 | Not Found | Erőforrás nem található |
| 409 | Conflict | Ütközés (pl. már létezik) |
| 500 | Internal Server Error | Szerver hiba |

## 👨‍💻 Fejlesztői Dokumentáció

### Projekt Klónozása és Beállítása

```bash
# Repository klónozása
git clone https://github.com/ZippoLord/UniCheck.git
cd UniCheck

# Függőségek telepítése
flutter pub get

# Generált fájlok frissítése (ha szükséges)
flutter pub run build_runner build --delete-conflicting-outputs
```

### Kód Stílus és Konvenciók

A projekt a Flutter hivatalos kódstílusát követi:

```bash
# Kód formázás
flutter format .

# Linting futtatása
flutter analyze

# Tesztek futtatása
flutter test
```

### State Management - GetX

#### Controller Példa

```dart
class LoginController extends GetxController {
  RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  
  set setLoading(bool newState) {
    _isLoading.value = newState;
  }
  
  void loginFunction(String data) async {
    setLoading = true;
    
    try {
      var response = await http.post(url, headers: headers, body: data);
      if (response.statusCode == 200) {
        LoginResponseModel data = loginResponseModelFromJson(response.body);
        box.write("userData", jsonEncode(data));
        box.write("token", data.token);
        
        Get.offAll(() => Mainscreen());
      }
    } finally {
      setLoading = false;
    }
  }
}
```

#### View Használat

```dart
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController controller = LoginController();
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading) {
        return CircularProgressIndicator();
      }
      return /* UI */;
    });
  }
}
```

### Új Képernyő Hozzáadása

1. **Képernyő létrehozása**: `lib/pages/new_page.dart`
```dart
import 'package:flutter/material.dart';

class NewPage extends StatelessWidget {
  const NewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Új Oldal')),
      body: Center(child: Text('Tartalom')),
    );
  }
}
```

2. **Navigáció hozzáadása**:
```dart
Get.to(() => NewPage());
// vagy
Get.offAll(() => NewPage()); // Előzmények törlésével
```

### Modell Generálás

JSON-ból Dart modell generálása online eszközökkel:
- [quicktype.io](https://quicktype.io/)
- [json_serializable](https://pub.dev/packages/json_serializable)

### Testing

#### Unit Teszt Példa

```dart
// test/controllers/login_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:prog24/controllers/login_controller.dart';

void main() {
  group('LoginController', () {
    test('initial loading state is false', () {
      final controller = LoginController();
      expect(controller.isLoading, false);
    });
    
    test('setLoading changes state', () {
      final controller = LoginController();
      controller.setLoading = true;
      expect(controller.isLoading, true);
    });
  });
}
```

### Build Variants

```bash
# Debug build
flutter build apk --debug

# Profile build (performance testing)
flutter build apk --profile

# Release build
flutter build apk --release

# Split per ABI (csökkenti a fájlméretet)
flutter build apk --split-per-abi
```

## 🔧 Hibaelhárítás

### Gyakori Problémák

#### 1. NFC Nem Működik

**Probléma:** Az alkalmazás nem érzékeli az NFC olvasót.

**Megoldások:**
- Ellenőrizd, hogy az NFC engedélyezve van az eszköz beállításaiban
- Próbáld meg újraindítani az alkalmazást
- Ellenőrizd az AndroidManifest.xml-ben az NFC engedélyeket
- Teszteld más NFC-képes eszközzel

```bash
# NFC támogatás ellenőrzése ADB-vel
adb shell dumpsys nfc
```

#### 2. Backend Kapcsolódási Hiba

**Probléma:** `SocketException: Failed to connect`

**Megoldások:**
- Ellenőrizd a `lib/constants.dart` fájlban a backend URL-t
- Ha emulátoron futtatod, használd `10.0.2.2` az `localhost` helyett
- Ellenőrizd, hogy a backend fut-e
- Tűzfal beállítások ellenőrzése

```dart
// Emulátorhoz
String baseURL = "http://10.0.2.2:5188";

// Fizikai eszközhöz (ugyanazon a hálózaton)
String baseURL = "http://192.168.1.100:5188";
```

#### 3. JWT Token Expired

**Probléma:** 401 Unauthorized hibák bejelentkezés után.

**Megoldások:**
- Jelentkezz ki és be újra
- Ellenőrizd a token lejárati idejét
- Implementálj token refresh mechanizmust

```dart
// Token ellenőrzés
final box = GetStorage();
String? token = box.read("token");
if (token == null || isTokenExpired(token)) {
  // Újrabejelentkezés szükséges
  Get.offAll(() => LoginOrRegister());
}
```

#### 4. Build Hibák

**Probléma:** Gradle build hiba Android build során.

**Megoldások:**

```bash
# Cache tisztítás
flutter clean
flutter pub get

# Gradle cache tisztítás
cd android
./gradlew clean
cd ..

# Újraépítés
flutter build apk
```

#### 5. GetStorage Inicializálási Hiba

**Probléma:** `GetStorage not initialized`

**Megoldás:**

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}
```

### Debug Módok

#### Verbose Logging

```bash
# Flutter verbose log
flutter run -v

# Csak hibák
flutter run --verbose

# Android logcat
adb logcat | grep Flutter
```

#### Network Debugging

```dart
// HTTP kérések naplózása
print("Request URL: $url");
print("Request Body: $data");
print("Response: ${response.body}");
print("Status Code: ${response.statusCode}");
```

### Teljesítmény Optimalizálás

```bash
# Performance profiling
flutter run --profile --trace-startup

# Memory leaks ellenőrzése
flutter run --observatory

# APK méret elemzése
flutter build apk --analyze-size
```

## 🔒 Biztonsági Megfontolások

### Jelenlegi Biztonsági Intézkedések

1. **JWT Tokenek**
   - Időkorlátos tokenek
   - Token tárolás GetStorage-ben (titkosítva)
   - Bearer token autentikáció

2. **HTTPS Kommunikáció**
   - Minden API hívás titkosított csatornán (production környezetben)

3. **Jelszó Biztonság**
   - Minimum jelszó követelmények
   - Jelszó megerősítés regisztrációnál
   - Backend oldali hash-elés (feltételezett)

4. **NFC Biztonság**
   - Device unlock követelmény (opcionális)
   - Token-based azonosítás

### Javasolt Biztonsági Fejlesztések

1. **Biometrikus Autentikáció**
```dart
// local_auth csomag használata
import 'package:local_auth/local_auth.dart';

final LocalAuthentication auth = LocalAuthentication();
bool authenticated = await auth.authenticate(
  localizedReason: 'Jelenlét rögzítéséhez ujjlenyomat szükséges',
);
```

2. **Certificate Pinning**
```dart
// http_certificate_pinning csomag
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
```

3. **Token Refresh Mechanizmus**
```dart
// Automatikus token frissítés lejárat előtt
if (isTokenExpiring(token)) {
  token = await refreshToken(token);
}
```

4. **Secure Storage**
```dart
// flutter_secure_storage használata érzékeny adatokhoz
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
await storage.write(key: 'token', value: token);
```

### Adatvédelem (GDPR Megfelelés)

- Felhasználói adatok minimalizálása
- Explicit hozzájárulás adatkezeléshez
- Adatok törlésének lehetősége
- Átlátható adatkezelési tájékoztató

## 📄 Licensz

Ez a projekt privát licensz alatt áll. Minden jog fenntartva.

## 👥 Közreműködők

- **Fejlesztő Csapat**: ZippoLord
- **Projekt Típus**: Egyetemi projekt

## 📞 Kapcsolat és Támogatás

Ha problémád van vagy kérdésed, nyiss egy issue-t a GitHub repository-ban:
https://github.com/ZippoLord/UniCheck/issues

## 🗺️ Roadmap

### Rövid Távú (Q1 2024)

- [ ] Biometrikus autentikáció implementálása
- [ ] Push notification támogatás
- [ ] Offline mód jelenléti rögzítéshez
- [ ] Részletes statisztikák hallgatóknak

### Közép Távú (Q2-Q3 2024)

- [ ] iOS támogatás
- [ ] QR kód alternatíva NFC mellett
- [ ] Tantárgyi követelmények nyomon követése
- [ ] Oktatói dashboard fejlesztése

### Hosszú Távú (Q4 2024+)

- [ ] Multi-tenant támogatás (több egyetem)
- [ ] Gamification elemek
- [ ] AI-alapú jelenléti előrejelzés
- [ ] Integráció más egyetemi rendszerekkel

## 📚 További Dokumentáció

- [Flutter Dokumentáció](https://docs.flutter.dev/)
- [GetX Dokumentáció](https://pub.dev/packages/get)
- [Android NFC Guide](https://developer.android.com/guide/topics/connectivity/nfc)
- [JWT.io](https://jwt.io/)

---

**Verzió:** 1.0.0  
**Utolsó Frissítés:** 2024-01-15  
**Készítette:** UniCheck Fejlesztői Csapat
