# UniCheck - API Referencia Dokumentáció

## Áttekintés

Ez a dokumentum részletes referenciát nyújt a UniCheck backend API-járól. Az API RESTful elveket követ és JSON formátumot használ a kommunikációhoz.

## Alap Információk

### Base URL

```
http://localhost:5188/api
```

**Production URL:** `https://api.unichez.edu/api` (példa)

### Autentikáció

Az API JWT (JSON Web Token) alapú autentikációt használ. A legtöbb endpoint megköveteli, hogy a kérés fejlécében szerepeljen egy érvényes token.

#### Token Használata

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Content Type

Minden kérés és válasz JSON formátumú:

```http
Content-Type: application/json
```

### Válasz Formátumok

#### Sikeres Válasz

```json
{
  "success": true,
  "data": { /* ... */ },
  "message": "Művelet sikeres"
}
```

#### Hiba Válasz

```json
{
  "error": "Error Type",
  "details": "Részletes hibaüzenet",
  "statusCode": 400
}
```

## Autentikációs Endpointok

### POST /api/Auth/register

Új felhasználó regisztrálása a rendszerben.

#### Request

```http
POST /api/Auth/register
Content-Type: application/json
```

**Body:**
```json
{
  "name": "Kovács János",
  "neptunCode": "ABC123",
  "password": "SecurePassword123!",
  "cardId": "3"
}
```

**Paraméterek:**

| Mező | Típus | Kötelező | Leírás |
|------|-------|----------|---------|
| name | string | Igen | Felhasználó teljes neve (min. 3 karakter) |
| neptunCode | string | Igen | Neptun kód (6 karakter, alfanumerikus) |
| password | string | Igen | Jelszó (min. 8 karakter, 1 nagybetű, 1 szám) |
| cardId | string | Nem | Kártya azonosító |

#### Response

**Sikeres (200 OK):**
```json
{
  "success": true,
  "userId": 12345,
  "message": "Sikeres regisztráció",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Hiba válaszok:**

| Kód | Leírás | Példa Válasz |
|-----|--------|--------------|
| 400 | Hibás input | `{"error": "ValidationError", "details": "Neptun kód formátuma hibás"}` |
| 409 | Már létezik | `{"error": "Conflict", "details": "A Neptun kód már használatban van"}` |
| 500 | Szerver hiba | `{"error": "InternalError", "details": "Adatbázis hiba"}` |

#### Példa Használat (Dart)

```dart
Future<void> register() async {
  RegisterModel model = RegisterModel(
    name: nameController.text,
    neptunCode: neptunController.text,
    password: passwordController.text,
    cardId: "3"
  );
  
  Uri url = Uri.parse('$baseURL/api/Auth/register');
  Map<String, String> headers = {'Content-type': 'application/json'};
  
  var response = await http.post(
    url, 
    headers: headers, 
    body: jsonEncode(model.toJson())
  );
  
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    print('Regisztráció sikeres: ${data['userId']}');
  }
}
```

---

### POST /api/Auth/login

Felhasználó bejelentkeztetése.

#### Request

```http
POST /api/Auth/login
Content-Type: application/json
```

**Body:**
```json
{
  "neptunCode": "ABC123",
  "password": "SecurePassword123!",
  "cardId": "2"
}
```

**Paraméterek:**

| Mező | Típus | Kötelező | Leírás |
|------|-------|----------|---------|
| neptunCode | string | Igen | Neptun kód |
| password | string | Igen | Jelszó |
| cardId | string | Nem | Kártya azonosító |

#### Response

**Sikeres (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiI5IiwidW5pcXVlX25hbWUiOiJiZW4iLCJuZXB0dW4iOiJ0ZXN0MTIzIiwicm9sZSI6IlN0dWRlbnQiLCJuYmYiOjE3NjA0NDg3MTcsImV4cCI6MTc2MDQ3NzUxNywiaWF0IjoxNzYwNDQ4NzE3fQ.zW_TqEyleqsr-3au01yzSufzFpijeuDE0z-sOxTlxEs",
  "name": "Kovács János",
  "role": 2,
  "expiresAt": "2024-01-15T18:25:17Z"
}
```

**Token Payload (JWT dekódolva):**
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

**Szerepkörök:**

| Érték | Szerepkör | Leírás |
|-------|-----------|---------|
| 0 | Admin | Teljes rendszer hozzáférés |
| 1 | Instructor | Oktató, órák kezelése |
| 2 | Student | Hallgató, jelenlét rögzítés |

**Hiba válaszok:**

| Kód | Leírás | Példa Válasz |
|-----|--------|--------------|
| 400 | Hibás input | `{"error": "ValidationError", "details": "Neptun kód vagy jelszó hiányzik"}` |
| 401 | Hibás hitelesítő adatok | `{"error": "Unauthorized", "details": "Érvénytelen Neptun kód vagy jelszó"}` |
| 423 | Zárolva | `{"error": "Locked", "details": "Fiók ideiglenesen zárolva"}` |

#### Példa Használat (Dart)

```dart
Future<void> login() async {
  LoginModel model = LoginModel(
    neptunCode: neptunCodeController.text,
    password: passwordController.text,
    cardId: "2"
  );
  
  Uri url = Uri.parse('$baseURL/api/Auth/login');
  Map<String, String> headers = {'Content-type': 'application/json'};
  
  var response = await http.post(
    url,
    headers: headers,
    body: loginModelToJson(model)
  );
  
  if (response.statusCode == 200) {
    LoginResponseModel data = loginResponseModelFromJson(response.body);
    box.write("token", data.token);
    box.write("userData", jsonEncode(data));
    
    // Navigáció szerepkör alapján
    if (data.role == 2) {
      Get.offAll(() => Mainscreen());
    } else if (data.role == 0) {
      Get.offAll(() => AdminPage());
    } else {
      Get.offAll(() => InstructorPage());
    }
  }
}
```

---

### POST /api/Auth/logout

Felhasználó kijelentkeztetése (token invalidálás).

#### Request

```http
POST /api/Auth/logout
Authorization: Bearer {token}
```

#### Response

**Sikeres (200 OK):**
```json
{
  "success": true,
  "message": "Sikeres kijelentkezés"
}
```

---

### POST /api/Auth/refresh

JWT token frissítése.

#### Request

```http
POST /api/Auth/refresh
Content-Type: application/json
Authorization: Bearer {old_token}
```

**Body:**
```json
{
  "refreshToken": "refresh_token_here"
}
```

#### Response

**Sikeres (200 OK):**
```json
{
  "token": "new_jwt_token",
  "refreshToken": "new_refresh_token",
  "expiresAt": "2024-01-15T20:00:00Z"
}
```

## Felhasználói Endpointok

### GET /api/Users/profile

Bejelentkezett felhasználó profiljának lekérdezése.

#### Request

```http
GET /api/Users/profile
Authorization: Bearer {token}
```

#### Response

**Sikeres (200 OK):**
```json
{
  "userId": 12345,
  "name": "Kovács János",
  "neptunCode": "ABC123",
  "email": "kovacs.janos@edu.hu",
  "role": 2,
  "roleString": "Student",
  "registeredAt": "2024-01-01T10:00:00Z",
  "lastLogin": "2024-01-15T08:00:00Z",
  "profilePicture": "https://...",
  "stats": {
    "totalCourses": 5,
    "attendanceRate": 87.5,
    "missedClasses": 3
  }
}
```

---

### PUT /api/Users/profile

Felhasználó profil adatok frissítése.

#### Request

```http
PUT /api/Users/profile
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "name": "Kovács János Péter",
  "email": "janos.kovacs@email.com",
  "profilePicture": "base64_encoded_image"
}
```

#### Response

**Sikeres (200 OK):**
```json
{
  "success": true,
  "message": "Profil sikeresen frissítve",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

---

### GET /api/Users/{userId}

Felhasználó adatainak lekérdezése (admin/oktató jogosultság szükséges).

#### Request

```http
GET /api/Users/12345
Authorization: Bearer {token}
```

#### Response

**Sikeres (200 OK):**
```json
{
  "userId": 12345,
  "name": "Kovács János",
  "neptunCode": "ABC123",
  "role": 2,
  "email": "kovacs.janos@edu.hu"
}
```

**Hiba válaszok:**

| Kód | Leírás |
|-----|--------|
| 403 | Nincs jogosultság |
| 404 | Felhasználó nem található |

## Jelenléti Endpointok

### POST /api/Attendance/check-in

Hallgatói jelenlét rögzítése.

#### Request

```http
POST /api/Attendance/check-in
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "courseId": "CS101",
  "sessionId": "CS101-2024-01-15-08",
  "timestamp": "2024-01-15T08:00:00Z",
  "location": "A épület 101",
  "nfcData": "encrypted_nfc_payload"
}
```

**Paraméterek:**

| Mező | Típus | Kötelező | Leírás |
|------|-------|----------|---------|
| courseId | string | Igen | Kurzus azonosító |
| sessionId | string | Igen | Óra session azonosító |
| timestamp | string (ISO 8601) | Igen | Jelenlét időpontja |
| location | string | Nem | Helyszín |
| nfcData | string | Nem | NFC payload |

#### Response

**Sikeres (200 OK):**
```json
{
  "success": true,
  "attendanceId": 56789,
  "message": "Jelenlét sikeresen rögzítve",
  "recordedAt": "2024-01-15T08:00:15Z"
}
```

**Hiba válaszok:**

| Kód | Leírás | Példa |
|-----|--------|-------|
| 400 | Érvénytelen kérés | `{"error": "ValidationError", "details": "CourseId szükséges"}` |
| 404 | Session nem található | `{"error": "NotFound", "details": "Az óra nem létezik"}` |
| 409 | Már rögzítve | `{"error": "Conflict", "details": "Jelenléted már rögzítve volt"}` |
| 410 | Session lejárt | `{"error": "Gone", "details": "Az óra már véget ért"}` |

---

### GET /api/Attendance/my-attendance

Bejelentkezett hallgató jelenléti adatai.

#### Request

```http
GET /api/Attendance/my-attendance?courseId=CS101&from=2024-01-01&to=2024-01-31
Authorization: Bearer {token}
```

**Query Paraméterek:**

| Paraméter | Típus | Kötelező | Leírás |
|-----------|-------|----------|---------|
| courseId | string | Nem | Szűrés kurzus szerint |
| from | string (ISO 8601) | Nem | Kezdő dátum |
| to | string (ISO 8601) | Nem | Záró dátum |
| page | integer | Nem | Oldal szám (alapértelmezett: 1) |
| pageSize | integer | Nem | Oldal méret (alapértelmezett: 20) |

#### Response

**Sikeres (200 OK):**
```json
{
  "total": 45,
  "page": 1,
  "pageSize": 20,
  "totalPages": 3,
  "attendance": [
    {
      "attendanceId": 56789,
      "courseId": "CS101",
      "courseName": "Programozás Alapjai",
      "sessionId": "CS101-2024-01-15-08",
      "timestamp": "2024-01-15T08:00:00Z",
      "location": "A épület 101",
      "status": "present"
    },
    {
      "attendanceId": 56788,
      "courseId": "CS101",
      "courseName": "Programozás Alapjai",
      "sessionId": "CS101-2024-01-12-08",
      "timestamp": "2024-01-12T08:05:00Z",
      "location": "A épület 101",
      "status": "late"
    }
  ],
  "summary": {
    "totalSessions": 50,
    "attended": 45,
    "missed": 5,
    "late": 3,
    "attendanceRate": 90.0
  }
}
```

**Státuszok:**

| Státusz | Leírás |
|---------|--------|
| present | Időben jelen volt |
| late | Késve érkezett |
| absent | Hiányzott |
| excused | Igazolt hiányzás |

## Kurzus Endpointok

### GET /api/Courses

Elérhető kurzusok listája.

#### Request

```http
GET /api/Courses?semester=2024-spring&department=CS
Authorization: Bearer {token}
```

**Query Paraméterek:**

| Paraméter | Típus | Kötelező | Leírás |
|-----------|-------|----------|---------|
| semester | string | Nem | Félév szűrő |
| department | string | Nem | Tanszék szűrő |
| enrolled | boolean | Nem | Csak a felvett kurzusok (hallgatóknál) |

#### Response

**Sikeres (200 OK):**
```json
{
  "courses": [
    {
      "courseId": "CS101",
      "courseName": "Programozás Alapjai",
      "courseCode": "PROG101",
      "instructor": "Dr. Nagy Péter",
      "semester": "2024-spring",
      "department": "Computer Science",
      "credits": 5,
      "enrolled": true,
      "schedule": [
        {
          "day": "Monday",
          "startTime": "08:00",
          "endTime": "10:00",
          "location": "A épület 101"
        }
      ]
    }
  ]
}
```

---

### GET /api/Courses/{courseId}

Kurzus részletes adatai.

#### Request

```http
GET /api/Courses/CS101
Authorization: Bearer {token}
```

#### Response

**Sikeres (200 OK):**
```json
{
  "courseId": "CS101",
  "courseName": "Programozás Alapjai",
  "courseCode": "PROG101",
  "description": "Bevezetés a programozásba...",
  "instructor": {
    "userId": 567,
    "name": "Dr. Nagy Péter",
    "email": "nagy.peter@edu.hu"
  },
  "semester": "2024-spring",
  "department": "Computer Science",
  "credits": 5,
  "maxStudents": 100,
  "enrolledStudents": 87,
  "schedule": [
    {
      "day": "Monday",
      "startTime": "08:00",
      "endTime": "10:00",
      "location": "A épület 101",
      "type": "lecture"
    }
  ],
  "requirements": {
    "minimumAttendance": 70,
    "midtermExam": true,
    "finalExam": true
  }
}
```

---

### POST /api/Courses/{courseId}/enroll

Kurzusra feljelentkezés (hallgató).

#### Request

```http
POST /api/Courses/CS101/enroll
Authorization: Bearer {token}
```

#### Response

**Sikeres (200 OK):**
```json
{
  "success": true,
  "message": "Sikeres feljelentkezés a CS101 kurzusra",
  "enrolledAt": "2024-01-15T10:00:00Z"
}
```

## Oktatói Endpointok

### POST /api/Instructor/sessions/create

Új óra session létrehozása (oktató).

#### Request

```http
POST /api/Instructor/sessions/create
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "courseId": "CS101",
  "sessionDate": "2024-01-15",
  "startTime": "08:00",
  "endTime": "10:00",
  "location": "A épület 101",
  "description": "Első előadás",
  "attendanceRequired": true,
  "lateThreshold": 10
}
```

#### Response

**Sikeres (201 Created):**
```json
{
  "sessionId": "CS101-2024-01-15-08",
  "qrCode": "base64_encoded_qr",
  "nfcEnabled": true,
  "message": "Session sikeresen létrehozva"
}
```

---

### GET /api/Instructor/sessions/{sessionId}/attendance

Session jelenléti lista (oktató).

#### Request

```http
GET /api/Instructor/sessions/CS101-2024-01-15-08/attendance
Authorization: Bearer {token}
```

#### Response

**Sikeres (200 OK):**
```json
{
  "sessionId": "CS101-2024-01-15-08",
  "courseId": "CS101",
  "courseName": "Programozás Alapjai",
  "date": "2024-01-15",
  "startTime": "08:00",
  "endTime": "10:00",
  "totalEnrolled": 87,
  "attendees": [
    {
      "userId": 12345,
      "name": "Kovács János",
      "neptunCode": "ABC123",
      "checkInTime": "2024-01-15T08:00:15Z",
      "status": "present"
    },
    {
      "userId": 12346,
      "name": "Nagy Anna",
      "neptunCode": "DEF456",
      "checkInTime": "2024-01-15T08:12:00Z",
      "status": "late"
    }
  ],
  "absentees": [
    {
      "userId": 12347,
      "name": "Szabó Péter",
      "neptunCode": "GHI789"
    }
  ],
  "summary": {
    "present": 75,
    "late": 10,
    "absent": 2,
    "attendanceRate": 97.7
  }
}
```

## Admin Endpointok

### GET /api/Admin/users

Összes felhasználó listázása (admin).

#### Request

```http
GET /api/Admin/users?role=2&page=1&pageSize=50
Authorization: Bearer {token}
```

**Query Paraméterek:**

| Paraméter | Típus | Kötelező | Leírás |
|-----------|-------|----------|---------|
| role | integer | Nem | Szerepkör szűrő (0=Admin, 1=Instructor, 2=Student) |
| search | string | Nem | Keresés név vagy neptun szerint |
| page | integer | Nem | Oldal szám |
| pageSize | integer | Nem | Oldal méret |

#### Response

**Sikeres (200 OK):**
```json
{
  "total": 1543,
  "page": 1,
  "pageSize": 50,
  "users": [
    {
      "userId": 12345,
      "name": "Kovács János",
      "neptunCode": "ABC123",
      "email": "kovacs.janos@edu.hu",
      "role": 2,
      "roleString": "Student",
      "active": true,
      "registeredAt": "2024-01-01T10:00:00Z"
    }
  ]
}
```

---

### PUT /api/Admin/users/{userId}/role

Felhasználó szerepkörének módosítása (admin).

#### Request

```http
PUT /api/Admin/users/12345/role
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "newRole": 1
}
```

#### Response

**Sikeres (200 OK):**
```json
{
  "success": true,
  "message": "Szerepkör sikeresen módosítva",
  "userId": 12345,
  "newRole": 1
}
```

## Státusz Kódok Összefoglalása

| Kód | Jelentés | Használat |
|-----|----------|-----------|
| 200 | OK | Sikeres kérés |
| 201 | Created | Erőforrás létrehozva |
| 204 | No Content | Sikeres, nincs visszatérési érték |
| 400 | Bad Request | Hibás kérés formátum/validáció |
| 401 | Unauthorized | Hiányzó/érvénytelen token |
| 403 | Forbidden | Nincs jogosultság |
| 404 | Not Found | Erőforrás nem található |
| 409 | Conflict | Ütközés (pl. már létezik) |
| 410 | Gone | Erőforrás már nem elérhető |
| 423 | Locked | Fiók zárolva |
| 429 | Too Many Requests | Rate limit túllépve |
| 500 | Internal Server Error | Szerver hiba |
| 503 | Service Unavailable | Szolgáltatás nem elérhető |

## Rate Limiting

Az API rate limitinget alkalmaz a visszaélések megakadályozására:

- **Autentikálatlan kérések:** 100/óra IP címenként
- **Autentikált kérések:** 1000/óra felhasználónként
- **Admin műveletek:** 5000/óra

**Rate limit túllépés válasza:**
```json
{
  "error": "RateLimitExceeded",
  "details": "Túl sok kérés. Próbáld újra 1 óra múlva.",
  "retryAfter": 3600
}
```

## Webhook Események

Az API webhook értesítéseket küldhet bizonyos eseményekről (ha konfigurálva):

### Attendance Webhook

```json
{
  "event": "attendance.checked_in",
  "timestamp": "2024-01-15T08:00:15Z",
  "data": {
    "userId": 12345,
    "courseId": "CS101",
    "sessionId": "CS101-2024-01-15-08",
    "status": "present"
  }
}
```

## Változások és Verziózás

Az API verziózást használ a visszafelé kompatibilitás biztosítására:

```
/api/v1/Auth/login  (current)
/api/v2/Auth/login  (future)
```

---

**API Verzió:** 1.0  
**Utolsó Frissítés:** 2024-01-15  
**Support:** api-support@unichez.edu
