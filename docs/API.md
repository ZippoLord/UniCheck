# UniCheck API Documentation

This document provides detailed information about the API endpoints used by the UniCheck mobile application.

## Base Configuration

### Backend URL
Configure in `lib/constants.dart`:
```dart
String baseURL = "http://localhost:5188";
```

### Authentication
Most endpoints require JWT authentication. Include the token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

## Endpoints

### Authentication Endpoints

#### 1. User Registration

**Endpoint:** `POST /Auth/register`

**Description:** Creates a new user account in the system.

**Headers:**
```http
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "John Doe",
  "neptunCode": "ABC123",
  "password": "securePassword123",
  "cardId": "3"
}
```

**Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | Yes | Full name of the user |
| neptunCode | string | Yes | University Neptun identification code |
| password | string | Yes | User's password (minimum 6 characters) |
| cardId | string | Yes | Physical card ID for NFC |

**Success Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "name": "John Doe",
  "role": 2
}
```

**Error Response (400 Bad Request):**
```json
{
  "error": "ValidationError",
  "details": "Neptun code already exists",
  "stackTrace": "..."
}
```

**Example Usage (Dart):**
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

#### 2. User Login

**Endpoint:** `POST /api/Auth/login`

**Description:** Authenticates a user and returns a JWT token.

**Headers:**
```http
Content-Type: application/json
Authorization: Bearer <optional_existing_token>
```

**Request Body:**
```json
{
  "neptunCode": "ABC123",
  "password": "securePassword123",
  "cardId": "2"
}
```

**Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| neptunCode | string | Yes | University Neptun identification code |
| password | string | Yes | User's password |
| cardId | string | Yes | Physical card ID for validation |

**Success Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiI5IiwidW5pcXVlX25hbWUiOiJiZW4iLCJuZXB0dW4iOiJ0ZXN0MTIzIiwicm9sZSI6IlN0dWRlbnQiLCJuYmYiOjE3NjA0NDg3MTcsImV4cCI6MTc2MDQ3NzUxNywiaWF0IjoxNzYwNDQ4NzE3fQ.zW_TqEyleqsr-3au01yzSufzFpijeuDE0z-sOxTlxEs",
  "name": "ben",
  "role": 2
}
```

**Response Fields:**
| Field | Type | Description |
|-------|------|-------------|
| token | string | JWT authentication token |
| name | string | User's name |
| role | integer | User role (0=Admin, 1=Instructor, 2=Student) |

**Error Response (401 Unauthorized):**
```json
{
  "error": "AuthenticationError",
  "details": "Invalid neptun code or password",
  "stackTrace": "..."
}
```

**Example Usage (Dart):**
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
  // Store token and user data
  box.write("userData", jsonEncode(data));
  box.write("token", data.token);
}
```

---

## User Roles

The system supports three user roles with different access levels:

| Role | Value | Description | Access |
|------|-------|-------------|--------|
| Admin | 0 | System Administrator | Full system access, user management |
| Instructor | 1 | Teacher/Professor | Class management, attendance tracking |
| Student | 2 | Student | Attendance check-in, view own records |

### Role-Based Routing

After successful login, users are routed based on their role:

```dart
if (data.role == 2) {
  Get.offAll(() => Mainscreen());  // Student
} else if (data.role == 0) {
  Get.offAll(() => AdminPage());   // Admin
} else {
  Get.offAll(() => InstructorPage());  // Instructor
}
```

---

## Data Models

### LoginModel

**Purpose:** Represents user credentials for authentication

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

**Purpose:** Represents the server response after successful login

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

**Purpose:** Represents new user registration data

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

**Purpose:** Standardized error response structure

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

## Error Handling

### Error Response Structure

All API errors follow this consistent structure:

```json
{
  "error": "ErrorType",
  "details": "Human-readable error message",
  "stackTrace": "Technical stack trace (for debugging)"
}
```

### Common Error Codes

| HTTP Code | Error Type | Description |
|-----------|------------|-------------|
| 400 | ValidationError | Invalid request data |
| 401 | AuthenticationError | Invalid credentials or token |
| 403 | AuthorizationError | Insufficient permissions |
| 404 | NotFoundError | Resource not found |
| 500 | ServerError | Internal server error |

### Error Handling Example

```dart
try {
  var response = await http.post(url, headers: headers, body: data);
  
  if (response.statusCode == 200) {
    // Success
    LoginResponseModel data = loginResponseModelFromJson(response.body);
    // Process data
  } else {
    // Error
    var error = apiErrorFromJson(response.body);
    Get.snackbar(
      "Error",
      error.details,
      colorText: Colors.white,
      backgroundColor: Colors.redAccent,
    );
  }
} catch (e) {
  // Network or parsing error
  print('Exception: $e');
}
```

---

## JWT Token Management

### Token Storage

Tokens are stored locally using GetStorage:

```dart
// Save token
box.write("token", data.token);

// Retrieve token
String? token = box.read("token");

// Use in API calls
Map<String, String> headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer ${box.read("token")}'
};
```

### Token Structure

The JWT token contains:
- User ID (`nameid`)
- Username (`unique_name`)
- Neptun code (`neptun`)
- Role (`role`)
- Expiration (`exp`)
- Issued at (`iat`)

Example decoded payload:
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

### Token Expiration

- Tokens expire after a set period (configured on backend)
- Always check token validity before critical operations
- Implement token refresh mechanism if needed

---

## Best Practices

### 1. Secure Storage
- Never store passwords in plain text
- Use secure storage for tokens
- Clear sensitive data on logout

### 2. Network Error Handling
```dart
try {
  var response = await http.post(url, headers: headers, body: data);
  // Process response
} catch (e) {
  // Handle network errors
  if (e is SocketException) {
    // No internet connection
  } else if (e is TimeoutException) {
    // Request timeout
  }
}
```

### 3. Loading States
```dart
class LoginController extends GetxController {
  RxBool _isLoading = false.obs;
  
  void loginFunction(String data) async {
    _isLoading.value = true;  // Show loading
    
    try {
      // API call
    } finally {
      _isLoading.value = false;  // Hide loading
    }
  }
}
```

### 4. User Feedback
```dart
// Success message
Get.snackbar(
  "Success",
  "Login successful!",
  colorText: Colors.white,
  backgroundColor: Colors.blue,
);

// Error message
Get.snackbar(
  "Error",
  "Invalid credentials",
  colorText: Colors.white,
  backgroundColor: Colors.redAccent,
);
```

---

## Testing API Endpoints

### Using cURL

**Login:**
```bash
curl -X POST http://localhost:5188/api/Auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "neptunCode": "ABC123",
    "password": "password123",
    "cardId": "2"
  }'
```

**Register:**
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

### Using Postman

1. Set request type to POST
2. Enter the endpoint URL
3. Add headers:
   - `Content-Type: application/json`
   - `Authorization: Bearer <token>` (if needed)
4. Add JSON body
5. Send request

---

## Rate Limiting

(To be implemented)

Consider implementing rate limiting on the backend:
- Max 5 login attempts per minute per IP
- Max 3 registration attempts per hour per IP
- Token refresh rate limiting

---

## Future API Endpoints (Planned)

### Attendance Management
- `POST /api/Attendance/checkin` - Student check-in
- `GET /api/Attendance/history` - View attendance history
- `GET /api/Attendance/class/{classId}` - Class attendance report

### Class Management
- `GET /api/Classes` - List all classes
- `POST /api/Classes` - Create new class
- `GET /api/Classes/{id}` - Get class details
- `PUT /api/Classes/{id}` - Update class
- `DELETE /api/Classes/{id}` - Delete class

### User Management (Admin)
- `GET /api/Users` - List all users
- `GET /api/Users/{id}` - Get user details
- `PUT /api/Users/{id}` - Update user
- `DELETE /api/Users/{id}` - Delete user
- `POST /api/Users/{id}/reset-password` - Reset user password

---

## Contact & Support

For API-related questions or issues:
- Check the backend server logs
- Verify network connectivity
- Ensure correct API endpoint URLs
- Validate request/response data formats
