# UniCheck

A UniCheck egy Flutter-alapú mobilalkalmazás, amely egyetemi jelenléti nyilvántartás kezelésére lett tervezve NFC (Near Field Communication) technológiával és Host Card Emulation (HCE) használatával. Az alkalmazás lehetővé teszi a hallgatók, oktatók és adminisztrátorok számára a jelenlét kezelését NFC-képes eszközökön keresztül.

## Tartalomjegyzék

- [Funkciók](#funkciók)
- [Architektúra](#architektúra)
- [Előfeltételek](#előfeltételek)
- [Telepítés](#telepítés)
- [Konfiguráció](#konfiguráció)
- [Használat](#használat)
- [Projekt Struktúra](#projekt-struktúra)
- [API Dokumentáció](#api-dokumentáció)
- [NFC/HCE Implementáció](#nfchce-implementáció)
- [Felhasználói Szerepkörök](#felhasználói-szerepkörök)
- [Használt Technológiák](#használt-technológiák)
- [Fejlesztés](#fejlesztés)
- [Közreműködés](#közreműködés)

## Funkciók

### Alapvető Funkciók
- **Felhasználói Hitelesítés**: Bejelentkezés és regisztráció Neptun kóddal
- **Szerepkör-alapú Hozzáférés**: Támogatás hallgatók, oktatók és adminisztrátorok számára
- **NFC Integráció**: Jelenlét rögzítése NFC technológia használatával
- **Host Card Emulation (HCE)**: NFC kártyák emulálása jelenléti követéshez
- **JWT Hitelesítés**: Biztonságos token-alapú hitelesítés
- **Valós idejű Státusz**: NFC elérhetőség ellenőrzése az eszközön

### Felhasználó-specifikus Funkciók
- **Hallgatók**: Bejelentkezés NFC-vel, jelenléti rekordok megtekintése
- **Oktatók**: Órák kezelése és jelenlét követése
- **Adminisztrátorok**: Teljes rendszerkezelési képességek

## Architektúra

A UniCheck tiszta architektúra mintát követ egyértelmű feladatok szétválasztásával:

```
lib/
├── controllers/       # Üzleti logika és állapotkezelés (GetX)
├── models/           # Adatmodellek és szerializáció
├── components/       # Újrafelhasználható UI komponensek
├── widgets/          # Egyedi widgetek
├── *.dart            # Fő alkalmazás képernyők (login, register, stb.)
└── constants.dart    # Konfigurációs konstansok
```

### Fő Architektúra Minták
- **Állapotkezelés**: GetX reaktív állapotkezeléshez
- **Perzisztens Tárolás**: GetStorage helyi adatmegőrzéshez
- **HTTP Kliens**: Standard http csomag API kommunikációhoz
- **Platform Csatornák**: Method channels Android natív kommunikációhoz

## Előfeltételek

- **Flutter SDK**: 3.9.2 vagy újabb verzió
- **Dart SDK**: A Flutterrel együtt érkezik
- **Android Studio** vagy **VS Code** Flutter bővítményekkel
- **Android Eszköz/Emulátor**: NFC támogatással (API level 19+)
- **Backend API**: A UniCheck backend szerver futó példánya

## Telepítés

### 1. Repository Klónozása

```bash
git clone https://github.com/ZippoLord/UniCheck.git
cd UniCheck
```

### 2. Függőségek Telepítése

```bash
flutter pub get
```

### 3. Backend URL Konfigurálása

Szerkessze a `lib/constants.dart` fájlt, hogy a backend szerverre mutasson:

```dart
String baseURL = "http://your-backend-url:port";
```

### 4. Build és Futtatás

#### Androidra
```bash
flutter run
```

#### Release Build-hez
```bash
flutter build apk --release
```

## Konfiguráció

### Android Engedélyek

Az alkalmazás a következő engedélyeket igényli (már konfigurálva az `AndroidManifest.xml`-ben):

```xml
<uses-permission android:name="android.permission.NFC" />
<uses-permission android:name="android.permission.INTERNET"/>
<uses-feature android:name="android.hardware.nfc" android:required="false"/>
```

### NFC AID Konfiguráció

A HCE szolgáltatás az AID (Application ID) használja: `F0010203040506`

Ez az `android/app/src/main/res/xml/apduservice.xml` fájlban van konfigurálva

## Használat

### Első Beállítás

1. **Alkalmazás Indítása**: Nyissa meg a UniCheck-et az NFC-képes Android eszközön
2. **Regisztráció**: Hozzon létre fiókot a következőkkel:
   - Teljes név
   - Neptun kód (egyetemi azonosító)
   - Jelszó
   - Kártya azonosító
3. **Bejelentkezés**: Használja Neptun kódját és jelszavát az alkalmazás eléréséhez

### Jelenlét Rögzítése (Hallgató)

1. Navigáljon a főképernyőre bejelentkezés után
2. Kapcsolja be az NFC-t az eszközön
3. Tartsa az eszközét az oktató NFC olvasója közelébe
4. Az alkalmazás automatikusan emulálja az Ön hitelesítő adatait
5. Várja meg a megerősítést

### Órák Kezelése (Oktató)

1. Jelentkezzen be oktató hitelesítő adatokkal
2. Nyissa meg az oktató műszerfalat
3. Kapcsolja be az NFC olvasó módot
4. A hallgatók bejelentkezhetnek az eszközük közelítésével

### Rendszeradminisztráció

1. Jelentkezzen be admin hitelesítő adatokkal
2. Nyissa meg az admin panelt
3. Kezelje a felhasználókat, órákat és rendszerbeállításokat

## Projekt Struktúra

### Fő Képernyők

- **LoginPage** (`lib/login.dart`): Felhasználói hitelesítési képernyő
- **RegisterPage** (`lib/register.dart`): Új felhasználó regisztráció
- **MainScreen** (`lib/mainScreen.dart`): Hallgatói műszerfal
- **InstructorPage** (`lib/instructorPage.dart`): Oktatói műszerfal
- **AdminPage** (`lib/adminPage.dart`): Adminisztrátori műszerfal
- **NfcStatusPage** (`lib/nfc.dart`): NFC elérhetőség ellenőrző

### Kontrollerek (GetX)

- **LoginController** (`lib/controllers/login_controller.dart`)
  - Kezeli a felhasználói hitelesítést
  - Kezeli a JWT tokeneket
  - Irányítja a felhasználókat szerepkörök alapján

- **RegisterController** (`lib/controllers/register_controller.dart`)
  - Kezeli az új felhasználói regisztrációt
  - Validálja a felhasználói inputot
  - Létrehozza az új fiókokat

- **PasswordController** (`lib/controllers/password_controller.dart`)
  - Kezeli a jelszó láthatóságot
  - Kezeli a jelszó validációt

### Modellek

- **LoginModel**: Felhasználói hitelesítő adatok a hitelesítéshez
- **LoginResponseModel**: Szerver válasz sikeres bejelentkezés után
- **RegisterModel**: Új felhasználói regisztrációs adatok
- **ApiError**: Szabványosított hibaválaszok

### Komponensek

- **NeptunCodeField**: Beviteli mező Neptun kódhoz
- **NameTextField**: Beviteli mező felhasználó nevéhez
- **PasswordTextField**: Biztonságos jelszó bevitel
- **PasswordVerificationTextField**: Jelszó megerősítés bevitel
- **CustomButton**: Újrafelhasználható gomb komponens
- **CustomLoginRegisterContainer**: Konténer auth képernyőkhöz

## API Dokumentáció

### Alap URL
```
http://localhost:5188
```

### Végpontok

#### Hitelesítés

**Bejelentkezés**
```http
POST /api/Auth/login
Content-Type: application/json

{
  "neptunCode": "ABC123",
  "password": "password123",
  "cardId": "2"
}

Válasz:
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "name": "John Doe",
  "role": 2
}
```

**Regisztráció**
```http
POST /Auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "neptunCode": "ABC123",
  "password": "password123",
  "cardId": "3"
}

Válasz: 200 OK
```

### Felhasználói Szerepkörök

- **0**: Adminisztrátor (Teljes rendszer hozzáférés)
- **1**: Oktató (Óra kezelés)
- **2**: Hallgató (Jelenléti bejelentkezés)

### Hibakezelés

Minden API hiba ezt a struktúrát követi:
```json
{
  "error": "Hiba típus",
  "details": "Részletes hibaüzenet",
  "stackTrace": "Stack trace információ"
}
```

## NFC/HCE Implementáció

### Áttekintés

A UniCheck Host Card Emulation (HCE) technológiát használ, hogy az Android eszközöket virtuális NFC kártyákká alakítsa. Ez lehetővé teszi, hogy a hallgatók telefonjait NFC olvasók olvashassák a jelenléti követéshez.

### Architektúra

```
Flutter App (Dart)
    ↓ MethodChannel
Android MainActivity (Kotlin)
    ↓ SharedPreferences
HCE Service (Kotlin)
    ↓ APDU Commands
NFC Reader
```

### Komponensek

#### 1. Flutter Réteg (`lib/methodChannel.dart`)

```dart
const platform = MethodChannel('com.example.prog24/hce');
```

JSON adatokat küld, amely tartalmazza a felhasználói hitelesítő adatokat a natív Android réteghez.

#### 2. MainActivity (`android/app/src/main/kotlin/com/example/prog24/MainActivity.kt`)

JSON-t fogad a Fluttertől és SharedPreferences-ben tárolja:
- Csatorna: `com.example.prog24/hce`
- Metódus: `setEmulatedJson`
- Tárolás: Alapértelmezett SharedPreferences `emulated_json` kulccsal

#### 3. HCE Service (`android/app/src/main/kotlin/com/example/prog24/HceService.kt`)

Az NFC kártya emulációt implementálja:

**Fő Funkciók:**
- **AID**: `F0010203040506`
- **APDU Parancsok**:
  - `SELECT (INS=0xA4)`: Kártya kiválasztás
  - `GET_CHUNK (INS=0x10)`: JSON adat lekérése darabokban

**Adat Formátum:**
```kotlin
// Parancs Struktúra
CLA | INS | P1 | P2 | Lc | Data | Le
00  | 10  | 00 | 00 | 03 | offset_hi, offset_lo, length

// Válasz
[data_chunk] | SW1 | SW2
[...] | 90 | 00  // Sikeres
```

**Státusz Szavak:**
- `90 00`: Sikeres
- `6A 82`: Fájl nem található
- `67 00`: Rossz hossz
- `6F 00`: Ismeretlen hiba

### JSON Adat Struktúra

Az emulált adat felhasználói hitelesítési információkat tartalmaz:
```json
{
  "token": "JWT_TOKEN_HERE",
  "name": "username",
  "role": 2
}
```

### NFC Folyamat

1. A felhasználó bejelentkezik és a hitelesítő adatok tárolódnak
2. A `setEmulatedJson` meghívásra kerül a felhasználói adatok tárolásához
3. A felhasználó közelíti az NFC olvasót
4. A HCE Service APDU parancsokat fogad
5. A Service felhasználói adatokkal válaszol darabokban
6. Az olvasó validálja és rögzíti a jelenlétet

### NFC Tesztelés

Használja az NFC Státusz oldalt a következőkre:
- Ellenőrizze, hogy az NFC elérhető-e
- NFC engedélyezése/letiltása
- Eszköz NFC beállítások megnyitása

## Használt Technológiák

### Framework & Programozási Nyelv
- **Flutter**: 3.9.2+ - Többplatformos UI framework
- **Dart**: Programozási nyelv
- **Kotlin**: Android natív kód

### Állapotkezelés
- **GetX** (^4.7.2): Reaktív állapotkezelés és dependency injection

### Tárolás
- **GetStorage** (^2.1.1): Gyors helyi kulcs-érték tárolás

### Hálózatkezelés
- **http** (^1.5.0): HTTP kliens API kommunikációhoz

### NFC
- **nfc_manager** (^4.1.1): NFC funkcionalitás
- **Android HCE**: Natív Host Card Emulation

### Biztonság
- **encrypt** (^5.0.3): Adat titkosítási segédprogramok
- **JWT**: Token-alapú hitelesítés

### UI/UX
- **Lottie** (^3.3.2): Animációk
- **Cupertino Icons** (^1.0.8): iOS-stílusú ikonok

### Engedélyek
- **permission_handler** (^12.0.1): Futásidejű engedélykezelés
- **app_settings** (^6.1.1): Rendszerbeállítások megnyitása

## Fejlesztés

### Futtatás Fejlesztői Módban

```bash
flutter run --debug
```

### Hot Reload

Nyomja meg az `r` gombot a terminálban a hot reload-hoz, vagy az `R` gombot a hot restart-hoz.

### Kódminőség Ellenőrzése

```bash
flutter analyze
```

### Tesztek Futtatása

```bash
flutter test
```

### Build Produkciós Környezethez

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

### Debug Logok

Az alkalmazás print utasításokat használ a debuggoláshoz. Nézze meg a logokat:

```bash
flutter logs
```

Vagy Android Studioban a Logcat ablakon keresztül.

## Közreműködés

1. Forkoljaarepository-t
2. Hozzon létre egy feature branchet (`git checkout -b feature/amazing-feature`)
3. Commitolja a változtatásokat (`git commit -m 'Add amazing feature'`)
4. Pusholja a branchbe (`git push origin feature/amazing-feature`)
5. Nyisson Pull Request-et

## Licenc

Ez a projekt egy akadémiai projekt része. Kérjük, vegye fel a kapcsolatot a repository tulajdonosával licencelési információkért.

## Támogatás

Problémák és kérdések esetén:
- Nyisson issue-t a GitHubon
- Vegye fel a kapcsolatot a fejlesztői csapattal

## Köszönetnyilvánítás

- A Flutter és Dart csapatoknak a kiváló frameworkért
- A GetX közösségnek az állapotkezelési megoldásokért
- Az NFC közösségnek a HCE dokumentációért és példákért
