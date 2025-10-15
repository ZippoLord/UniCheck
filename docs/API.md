# UniCheck API Dokumentáció

Ez a dokumentum részletes információkat nyújt a UniCheck mobilalkalmazás által használt API végpontokról.

## Alap Konfiguráció

### Backend URL
Konfigurálja a `lib/constants.dart` fájlban:
```dart
String baseURL = "http://localhost:5188";
```

### Hitelesítés
A legtöbb végpont JWT hitelesítést igényel. Tegye hozzá a tokent az Authorization fejlécbe:
```
Authorization: Bearer <your_jwt_token>
```

## Végpontok

### Hitelesítési Végpontok

#### 1. Felhasználó Regisztráció

**Végpont:** `POST /Auth/register`

**Leírás:** Új felhasználói fiókot hoz létre a rendszerben.

**Fejlécek:**
```http
Content-Type: application/json
```

**Kérés Törzs:**
```json
{
  "name": "John Doe",
  "neptunCode": "ABC123",
  "password": "securePassword123",
  "cardId": "3"
}
```

**Paraméterek:**
| Mező | Típus | Kötelező | Leírás |
|-------|------|----------|-------------|
| name | string | Igen | A felhasználó teljes neve |
| neptunCode | string | Igen | Egyetemi Neptun azonosító kód |
| password | string | Igen | Felhasználó jelszava (minimum 6 karakter) |
| cardId | string | Igen | Fizikai kártya azonosító NFC-hez |

**Sikeres Válasz (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "name": "John Doe",
  "role": 2
}
```

**Hiba Válasz (400 Bad Request):**
```json
{
  "error": "ValidationError",
  "details": "Neptun kód már létezik",
  "stackTrace": "..."
}
```

**Használati Példa (Dart):**
```dart
final model = RegisterModel(
  name: "John Doe",
  neptunCode: "ABC123",
  password: "securePassword123",
  cardId: "3"
);

final response = await http.post(
  Uri.parse('$baseURL/Auth/register'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(model.toJson())
);
```

---

#### 2. Felhasználó Bejelentkezés

**Végpont:** `POST /api/Auth/login`

**Leírás:** Hitelesíti a felhasználót és JWT tokent ad vissza.

**Fejlécek:**
```http
Content-Type: application/json
Authorization: Bearer <optional_existing_token>
```

**Kérés Törzs:**
```json
{
  "neptunCode": "ABC123",
  "password": "securePassword123",
  "cardId": "2"
}
```

**Paraméterek:**
| Mező | Típus | Kötelező | Leírás |
|-------|------|----------|-------------|
| neptunCode | string | Igen | Egyetemi Neptun azonosító kód |
| password | string | Igen | Felhasználó jelszava |
| cardId | string | Igen | Fizikai kártya azonosító validáláshoz |

**Sikeres Válasz (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiI5IiwidW5pcXVlX25hbWUiOiJiZW4iLCJuZXB0dW4iOiJ0ZXN0MTIzIiwicm9sZSI6IlN0dWRlbnQiLCJuYmYiOjE3NjA0NDg3MTcsImV4cCI6MTc2MDQ3NzUxNywiaWF0IjoxNzYwNDQ4NzE3fQ.zW_TqEyleqsr-3au01yzSufzFpijeuDE0z-sOxTlxEs",
  "name": "ben",
  "role": 2
}
```

**Válasz Mezők:**
| Mező | Típus | Leírás |
|-------|------|-------------|
| token | string | JWT hitelesítési token |
| name | string | Felhasználó neve |
| role | integer | Felhasználói szerepkör (0=Admin, 1=Oktató, 2=Hallgató) |

**Hiba Válasz (401 Unauthorized):**
```json
{
  "error": "AuthenticationError",
  "details": "Érvénytelen neptun kód vagy jelszó",
  "stackTrace": "..."
}
```

**Használati Példa (Dart):**
```dart
final model = LoginModel(
  neptunCode: "ABC123",
  password: "securePassword123",
  cardId: "2"
);

final response = await http.post(
  Uri.parse('$baseURL/api/Auth/login'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${box.read("token")}'
  },
  body: loginModelToJson(model)
);

if (response.statusCode == 200) {
  LoginResponseModel data = loginResponseModelFromJson(response.body);
  // Token és felhasználói adatok tárolása
  box.write("userData", jsonEncode(data));
  box.write("token", data.token);
}
```

---

## Felhasználói Szerepkörök

A rendszer három felhasználói szerepkört támogat különböző hozzáférési szintekkel:

| Szerepkör | Érték | Leírás | Hozzáférés |
|------|-------|-------------|--------|
| Admin | 0 | Rendszer Adminisztrátor | Teljes rendszer hozzáférés, felhasználó kezelés |
| Oktató | 1 | Tanár/Professzor | Óra kezelés, jelenléti követés |
| Hallgató | 2 | Diák | Jelenléti bejelentkezés, saját rekordok megtekintése |

### Szerepkör-alapú Irányítás

Sikeres bejelentkezés után a felhasználók szerepkörük alapján irányítódnak:

```dart
if (data.role == 2) {
  Get.offAll(() => Mainscreen());  // Hallgató
} else if (data.role == 0) {
  Get.offAll(() => AdminPage());   // Admin
} else {
  Get.offAll(() => InstructorPage());  // Oktató
}
```

---

## Adat Modellek

### LoginModel

**Cél:** Felhasználói hitelesítő adatokat reprezentál a hitelesítéshez

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

### LoginResponseModel

**Cél:** A szerver válaszát reprezentálja sikeres bejelentkezés után

```dart
class LoginResponseModel {
  final String token;
  final String name;
  final int role;

  LoginResponseModel({
    required this.token,
    required this.name,
    required this.role,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
    LoginResponseModel(
      token: json["token"],
      name: json["name"],
      role: json["role"],
    );
}
```

### RegisterModel

**Cél:** Új felhasználói regisztrációs adatokat reprezentál

```dart
class RegisterModel {
  final String name;
  final String neptunCode;
  final String password;
  final String cardId;

  RegisterModel({
    required this.name,
    required this.neptunCode,
    required this.password,
    required this.cardId,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "neptunCode": neptunCode,
    "password": password,
    "cardId": cardId,
  };
}
```

### ApiError

**Cél:** Szabványosított hibaválasz struktúra

```dart
class ApiError {
  final String error;
  final String details;
  final String stackTrace;

  ApiError({
    required this.error,
    required this.details,
    required this.stackTrace,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) =>
    ApiError(
      error: json["error"],
      details: json["details"],
      stackTrace: json["stackTrace"],
    );
}
```

---

## Hibakezelés

### Hibaválasz Struktúra

Minden API hiba ezt a következetes struktúrát követi:

```json
{
  "error": "ErrorType",
  "details": "Ember által olvasható hibaüzenet",
  "stackTrace": "Technikai stack trace (debuggoláshoz)"
}
```

### Gyakori Hibakódok

| HTTP Kód | Hiba Típus | Leírás |
|-----------|------------|-------------|
| 400 | ValidationError | Érvénytelen kérés adat |
| 401 | AuthenticationError | Érvénytelen hitelesítő adatok vagy token |
| 403 | AuthorizationError | Nincs elegendő jogosultság |
| 404 | NotFoundError | Erőforrás nem található |
| 500 | ServerError | Belső szerver hiba |

### Hibakezelési Példa

```dart
try {
  var response = await http.post(url, headers: headers, body: data);
  
  if (response.statusCode == 200) {
    // Sikeres
    LoginResponseModel data = loginResponseModelFromJson(response.body);
    // Adat feldolgozása
  } else {
    // Hiba
    var error = apiErrorFromJson(response.body);
    Get.snackbar(
      "Hiba",
      error.details,
      colorText: Colors.white,
      backgroundColor: Colors.redAccent,
    );
  }
} catch (e) {
  // Hálózati vagy elemzési hiba
  print('Kivétel: $e');
}
```

---

## JWT Token Kezelés

### Token Tárolás

A tokenek helyben tárolódnak GetStorage használatával:

```dart
// Token mentése
box.write("token", data.token);

// Token lekérése
String? token = box.read("token");

// Használat API hívásokban
Map<String, String> headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer ${box.read("token")}'
};
```

### Token Struktúra

A JWT token tartalmazza:
- Felhasználó ID (`nameid`)
- Felhasználónév (`unique_name`)
- Neptun kód (`neptun`)
- Szerepkör (`role`)
- Lejárat (`exp`)
- Kibocsátva (`iat`)

Példa dekódolt payload:
```json
{
  "nameid": "9",
  "unique_name": "ben",
  "neptun": "test123",
  "role": "Student",
  "nbf": 1760448717,
  "exp": 1760477517,
  "iat": 1760448717
}
```

### Token Lejárat

- A tokenek egy beállított időszak után lejárnak (backend-en konfigurálva)
- Mindig ellenőrizze a token érvényességét kritikus műveletek előtt
- Implementáljon token frissítési mechanizmust ha szükséges

---

## Legjobb Gyakorlatok

### 1. Biztonságos Tárolás
- Soha ne tárolja a jelszavakat egyszerű szövegként
- Használjon biztonságos tárolást a tokenekhez
- Törölje az érzékeny adatokat kijelentkezéskor

### 2. Hálózati Hibakezelés
```dart
try {
  var response = await http.post(url, headers: headers, body: data);
  // Válasz feldolgozása
} catch (e) {
  // Hálózati hibák kezelése
  if (e is SocketException) {
    // Nincs internet kapcsolat
  } else if (e is TimeoutException) {
    // Kérés timeout
  }
}
```

### 3. Betöltési Állapotok
```dart
class LoginController extends GetxController {
  RxBool _isLoading = false.obs;
  
  void loginFunction(String data) async {
    _isLoading.value = true;  // Betöltés megjelenítése
    
    try {
      // API hívás
    } finally {
      _isLoading.value = false;  // Betöltés elrejtése
    }
  }
}
```

### 4. Felhasználói Visszajelzés
```dart
// Siker üzenet
Get.snackbar(
  "Sikeres",
  "Bejelentkezés sikeres!",
  colorText: Colors.white,
  backgroundColor: Colors.blue,
);

// Hiba üzenet
Get.snackbar(
  "Hiba",
  "Érvénytelen hitelesítő adatok",
  colorText: Colors.white,
  backgroundColor: Colors.redAccent,
);
```

---

## API Végpontok Tesztelése

### cURL Használata

**Bejelentkezés:**
```bash
curl -X POST http://localhost:5188/api/Auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "neptunCode": "ABC123",
    "password": "password123",
    "cardId": "2"
  }'
```

**Regisztráció:**
```bash
curl -X POST http://localhost:5188/Auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "neptunCode": "ABC123",
    "password": "password123",
    "cardId": "3"
  }'
```

### Postman Használata

1. Állítsa a kérés típusát POST-ra
2. Írja be a végpont URL-t
3. Adja hozzá a fejléceket:
   - `Content-Type: application/json`
   - `Authorization: Bearer <token>` (ha szükséges)
4. Adja hozzá a JSON törzsöt
5. Küldje el a kérést

---

## Sebességkorlátozás

(Implementálandó)

Fontolja meg a sebességkorlátozás implementálását a backend-en:
- Maximum 5 bejelentkezési kísérlet percenként IP-nként
- Maximum 3 regisztrációs kísérlet óránként IP-nként
- Token frissítés sebességkorlátozása

---

## Jövőbeli API Végpontok (Tervezett)

### Jelenléti Kezelés
- `POST /api/Attendance/checkin` - Hallgatói bejelentkezés
- `GET /api/Attendance/history` - Jelenléti előzmények megtekintése
- `GET /api/Attendance/class/{classId}` - Órai jelenléti jelentés

### Óra Kezelés
- `GET /api/Classes` - Összes óra listázása
- `POST /api/Classes` - Új óra létrehozása
- `GET /api/Classes/{id}` - Óra részletek lekérése
- `PUT /api/Classes/{id}` - Óra frissítése
- `DELETE /api/Classes/{id}` - Óra törlése

### Felhasználó Kezelés (Admin)
- `GET /api/Users` - Összes felhasználó listázása
- `GET /api/Users/{id}` - Felhasználó részletek lekérése
- `PUT /api/Users/{id}` - Felhasználó frissítése
- `DELETE /api/Users/{id}` - Felhasználó törlése
- `POST /api/Users/{id}/reset-password` - Felhasználó jelszó visszaállítása

---

## Kapcsolat és Támogatás

API-val kapcsolatos kérdések vagy problémák esetén:
- Ellenőrizze a backend szerver logokat
- Ellenőrizze a hálózati kapcsolatot
- Győződjön meg a helyes API végpont URL-ekről
- Validálja a kérés/válasz adat formátumokat
