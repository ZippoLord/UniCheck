# UniCheck Gyors Referencia

Gyors referencia útmutató a gyakori feladatokhoz és parancsokhoz a UniCheck fejlesztésében.

## Gyors Linkek

- [Fő README](../README.md)
- [Telepítési Útmutató](SETUP.md)
- [API Dokumentáció](API.md)
- [NFC/HCE Útmutató](NFC_HCE.md)
- [Architektúra](ARCHITECTURE.md)
- [Közreműködés](CONTRIBUTING.md)

## Gyakori Parancsok

### Flutter Parancsok

```bash
# Függőségek letöltése
flutter pub get

# Alkalmazás futtatása (debug mód)
flutter run

# Futtatás hot reload-dal
flutter run --debug

# Release APK build
flutter build apk --release

# App bundle build
flutter build appbundle --release

# Build fájlok tisztítása
flutter clean

# Kód elemzése
flutter analyze

# Kód formázása
flutter format lib/

# Tesztek futtatása
flutter test

# Flutter beállítás ellenőrzése
flutter doctor

# Eszközök listázása
flutter devices

# Logok megtekintése
flutter logs
```

### Git Parancsok

```bash
# Repository klónozása
git clone https://github.com/ZippoLord/UniCheck.git

# Új branch létrehozása
git checkout -b feature/feature-name

# Státusz ellenőrzése
git status

# Változtatások hozzáadása
git add .

# Commit készítése
git commit -m "feat: add feature"

# Push a remote-ba
git push origin feature/feature-name

# Legújabb változtatások húzása
git pull origin main

# Szinkronizálás upstream-mel
git fetch upstream
git merge upstream/main
```

### Android Debug Bridge (ADB)

```bash
# Csatlakoztatott eszközök listázása
adb devices

# APK telepítése
adb install app-release.apk

# Alkalmazás eltávolítása
adb uninstall com.example.prog24

# Logok megtekintése
adb logcat

# Logok szűrése
adb logcat | grep "flutter"

# Alkalmazás adatainak törlése
adb shell pm clear com.example.prog24

# Képernyőkép készítése
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png

# NFC státusz ellenőrzése
adb shell dumpsys nfc
```

## Fájl Struktúra Gyors Referencia

```
UniCheck/
├── lib/
│   ├── main.dart                    # Alkalmazás belépési pont
│   ├── constants.dart               # API URL konfiguráció
│   │
│   ├── controllers/                 # Üzleti logika
│   │   ├── login_controller.dart
│   │   ├── register_controller.dart
│   │   └── password_controller.dart
│   │
│   ├── models/                      # Adat modellek
│   │   ├── login_model.dart
│   │   ├── login_response.dart
│   │   ├── register_model.dart
│   │   └── api_error.dart
│   │
│   ├── components/                  # Űrlap bevitelek
│   │   ├── neptunCodeField.dart
│   │   ├── nametextField.dart
│   │   ├── passwordTextField.dart
│   │   └── passwordVerField.dart
│   │
│   ├── widgets/                     # Újrafelhasználható widgetek
│   │   ├── customButton.dart
│   │   └── customLoginRegister..dart
│   │
│   ├── login.dart                   # Bejelentkezési képernyő
│   ├── register.dart                # Regisztrációs képernyő
│   ├── login_or_register.dart       # Auth váltó
│   ├── mainScreen.dart              # Hallgatói műszerfal
│   ├── adminPage.dart               # Admin műszerfal
│   ├── instructorPage.dart          # Oktatói műszerfal
│   ├── nfc.dart                     # NFC státusz oldal
│   └── methodChannel.dart           # HCE teszt oldal
│
├── android/
│   └── app/src/main/kotlin/com/example/prog24/
│       ├── MainActivity.kt          # Method channel handler
│       └── HceService.kt            # NFC HCE szolgáltatás
│
├── docs/                            # Dokumentáció
│   ├── API.md
│   ├── ARCHITECTURE.md
│   ├── NFC_HCE.md
│   ├── SETUP.md
│   ├── CONTRIBUTING.md
│   └── QUICK_REFERENCE.md
│
└── test/                            # Tesztek
    └── widget_test.dart
```

## Konfiguráció

### Backend URL

**Fájl:** `lib/constants.dart`
```dart
String baseURL = "http://localhost:5188";  // Változtassa meg ezt
```

**Helyi fejlesztés:**
```dart
String baseURL = "http://localhost:5188";
```

**Tesztelés eszközön (használja a számítógép helyi IP-címét):**
```dart
String baseURL = "http://192.168.1.100:5188";
```

**Produkció:**
```dart
String baseURL = "https://api.yourdomain.com";
```

### NFC AID

**Fájl:** `android/app/src/main/res/xml/apduservice.xml`
```xml
<aid-filter android:name="F0010203040506"/>
```

## API Végpontok

### Hitelesítés

**Bejelentkezés:**
```http
POST /api/Auth/login
Content-Type: application/json

{
  "neptunCode": "ABC123",
  "password": "password123",
  "cardId": "2"
}
```

**Regisztráció:**
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

## Felhasználói Szerepkörök

| Szerepkör | Érték | Leírás |
|------|-------|-------------|
| Admin | 0 | Teljes rendszer hozzáférés |
| Oktató | 1 | Óra kezelés |
| Hallgató | 2 | Jelenléti bejelentkezés |

## Kód Részletek

### Új Kontroller Létrehozása

```dart
import 'package:get/get.dart';

class MyController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  
  Future<void> fetchData() async {
    _isLoading.value = true;
    try {
      // Az Ön logikája itt
    } finally {
      _isLoading.value = false;
    }
  }
}
```

### Kontroller Használata Widgetben

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

### API Hívás Hibakezeléssel

```dart
Future<void> apiCall() async {
  try {
    final response = await http.post(
      Uri.parse('$baseURL/api/endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    
    if (response.statusCode == 200) {
      // Sikeres
      final data = jsonDecode(response.body);
    } else {
      // Hiba
      final error = apiErrorFromJson(response.body);
      Get.snackbar('Hiba', error.details);
    }
  } catch (e) {
    Get.snackbar('Hiba', 'Hálózati hiba: $e');
  }
}
```

### Snackbar Megjelenítése

```dart
// Siker üzenet
Get.snackbar(
  'Sikeres',
  'Művelet befejezve',
  backgroundColor: Colors.green,
  colorText: Colors.white,
);

// Hiba üzenet
Get.snackbar(
  'Hiba',
  'Valami hiba történt',
  backgroundColor: Colors.red,
  colorText: Colors.white,
);
```

### Navigálás Oldalak Között

```dart
// Új oldal megnyitása
Get.to(() => NewPage());

// Jelenlegi oldal cseréje
Get.off(() => NewPage());

// Stack törlése és navigálás
Get.offAll(() => HomePage());

// Vissza navigálás
Get.back();
```

### Adatok Helyi Tárolása

```dart
import 'package:get_storage/get_storage.dart';

final box = GetStorage();

// Adat írása
box.write('key', 'value');
box.write('token', userToken);

// Adat olvasása
String? value = box.read('key');
String? token = box.read('token');

// Adat eltávolítása
box.remove('key');

// Minden adat törlése
box.erase();
```

## NFC/HCE Gyors Referencia

### APDU Parancsok

**SELECT Parancs:**
```
00 A4 04 00 07 F0 01 02 03 04 05 06
```

**GET_CHUNK Parancs:**
```
00 10 00 00 03 [offset_hi] [offset_lo] [length]
```

### Státusz Szavak

| Kód | Hex | Jelentés |
|------|-----|---------|
| Sikeres | 90 00 | Parancs sikeresen végrehajtva |
| Fájl nem található | 6A 82 | Érvénytelen offset vagy nincs adat |
| Rossz hossz | 67 00 | Érvénytelen Lc mező |
| Ismeretlen | 6F 00 | Parancs nem felismerhető |

### Method Channel

**JSON küldése HCE-be:**
```dart
const platform = MethodChannel('com.example.prog24/hce');

await platform.invokeMethod('setEmulatedJson', {
  'json': jsonData
});
```

## Hibaelhárítás

### Gyakori Problémák

| Probléma | Megoldás |
|-------|----------|
| Flutter nem található | Adja hozzá a Flutter-t a PATH-hoz |
| Android licencek | Futtassa a `flutter doctor --android-licenses` parancsot |
| Gradle build sikertelen | Futtassa a `flutter clean && flutter pub get` parancsot |
| Eszköz nem észlelhető | Engedélyezze az USB hibakeresést |
| NFC nem működik | Ellenőrizze, hogy az NFC engedélyezve van-e a beállításokban |
| API kapcsolat sikertelen | Ellenőrizze a backend URL-t és a tűzfalat |

### Debug Parancsok

```bash
# Flutter verzió megtekintése
flutter --version

# Problémák ellenőrzése
flutter doctor -v

# Build tisztítása
flutter clean
flutter pub get

# Alkalmazás újraépítése
flutter run --debug

# Részletes logok megtekintése
flutter logs -v
```

## Tesztelés

### Tesztek Futtatása

```bash
# Minden teszt
flutter test

# Konkrét teszt
flutter test test/widget_test.dart

# Lefedettséggel
flutter test --coverage

# Watch mód (automatikus futtatás változtatáskor)
flutter test --watch
```

### Widget Teszt Írása

```dart
testWidgets('Gomb kattintás teszt', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  
  expect(find.text('Sikeres'), findsOneWidget);
});
```

## Teljesítmény

### Alkalmazás Profilozása

```bash
# Futtatás profile módban
flutter run --profile

# DevTools megnyitása
flutter pub global activate devtools
flutter pub global run devtools
```

### Optimalizálási Tippek

- Használjon `const` konstruktorokat
- Kerülje el a teljes fa újraépítését
- Dispose-olja a kontrollereket
- Használjon `ListView.builder`-t hosszú listákhoz
- Optimalizálja a képeket
- Profilozzon optimalizálás előtt

## Billentyű Parancsikonok

### VS Code

| Parancsikon | Művelet |
|----------|--------|
| `Ctrl+Space` | Auto-complete |
| `Ctrl+.` | Gyors javítások |
| `F5` | Debug indítása |
| `Shift+F5` | Debug leállítása |
| `Ctrl+Shift+P` | Parancs paletta |
| `Ctrl+/` | Komment kapcsoló |
| `Alt+Shift+F` | Dokumentum formázása |

### Android Studio

| Parancsikon | Művelet |
|----------|--------|
| `Ctrl+Space` | Auto-complete |
| `Alt+Enter` | Gyors javítások |
| `Shift+F10` | Futtatás |
| `Shift+F9` | Debug |
| `Ctrl+Alt+L` | Kód formázása |
| `Ctrl+/` | Sor kommentelése |

## Build Változatok

```bash
# Debug (fejlesztés)
flutter build apk --debug

# Profile (teljesítmény tesztelés)
flutter build apk --profile

# Release (produkció)
flutter build apk --release

# Egyedi konfigurációval
flutter build apk --release --dart-define=API_URL=https://api.prod.com
```

## Hasznos Csomagok

| Csomag | Cél |
|---------|---------|
| get | Állapotkezelés és navigáció |
| get_storage | Helyi tárolás |
| http | HTTP kliens |
| lottie | Animációk |
| nfc_manager | NFC funkcionalitás |
| encrypt | Titkosítás |
| permission_handler | Futásidejű engedélyek |
| app_settings | Rendszerbeállítások megnyitása |

## Források

### Hivatalos Dokumentáció
- [Flutter Dokumentáció](https://docs.flutter.dev/)
- [Dart API](https://api.dart.dev/)
- [Android Fejlesztők](https://developer.android.com/)

### Csomagok
- [pub.dev](https://pub.dev/) - Dart & Flutter csomagok
- [GetX](https://pub.dev/packages/get) - Állapotkezelés

### Eszközök
- [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools/overview)
- [Android Studio](https://developer.android.com/studio)
- [VS Code](https://code.visualstudio.com/)

### Közösség
- [Flutter Közösség](https://flutter.dev/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Reddit r/FlutterDev](https://reddit.com/r/FlutterDev)

## Környezeti Változók

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

## Gyors Indítás Ellenőrző Lista

- [ ] Flutter SDK telepítve
- [ ] Android Studio konfigurálva
- [ ] Repository klónozva
- [ ] Függőségek telepítve (`flutter pub get`)
- [ ] Backend URL konfigurálva
- [ ] Eszköz csatlakoztatva vagy emulátor fut
- [ ] Alkalmazás sikeresen épül
- [ ] Tesztek átmennek
- [ ] Dokumentáció elolvasva

## Segítségre van szüksége?

1. Nézze meg a [Telepítési Útmutatót](SETUP.md)
2. Olvassa el az [Architektúra Dokumentációt](ARCHITECTURE.md)
3. Keressen a meglévő issue-k között
4. Kérdezzen a megbeszélésekben
5. Hozzon létre új issue-t

---

**Utoljára frissítve:** 2025. Október
**Verzió:** 1.0.0
