# UniCheck

UniCheck is a Flutter-based mobile application designed for university attendance management using NFC (Near Field Communication) technology with Host Card Emulation (HCE). The app allows students, instructors, and administrators to manage attendance through NFC-enabled devices.

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [API Documentation](#api-documentation)
- [NFC/HCE Implementation](#nfchce-implementation)
- [User Roles](#user-roles)
- [Technologies Used](#technologies-used)
- [Development](#development)
- [Contributing](#contributing)

## Features

### Core Features
- **User Authentication**: Login and registration with Neptun code
- **Role-Based Access**: Support for Students, Instructors, and Administrators
- **NFC Integration**: Check attendance using NFC technology
- **Host Card Emulation (HCE)**: Emulate NFC cards for attendance tracking
- **JWT Authentication**: Secure token-based authentication
- **Real-time Status**: Check NFC availability on device

### User-Specific Features
- **Students**: Check in using NFC, view attendance records
- **Instructors**: Manage classes and track attendance
- **Administrators**: Full system management capabilities

## Architecture

UniCheck follows a clean architecture pattern with clear separation of concerns:

```
lib/
├── controllers/       # Business logic and state management (GetX)
├── models/           # Data models and serialization
├── components/       # Reusable UI components
├── widgets/          # Custom widgets
├── *.dart            # Main application screens (login, register, etc.)
└── constants.dart    # Configuration constants
```

### Key Architectural Patterns
- **State Management**: GetX for reactive state management
- **Persistent Storage**: GetStorage for local data persistence
- **HTTP Client**: Standard http package for API communication
- **Platform Channels**: Method channels for Android native communication

## Prerequisites

- **Flutter SDK**: Version 3.9.2 or higher
- **Dart SDK**: Included with Flutter
- **Android Studio** or **VS Code** with Flutter extensions
- **Android Device/Emulator**: With NFC support (API level 19+)
- **Backend API**: Running instance of the UniCheck backend server

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/ZippoLord/UniCheck.git
cd UniCheck
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Backend URL

Edit `lib/constants.dart` to point to your backend server:

```dart
String baseURL = "http://your-backend-url:port";
```

### 4. Build and Run

#### For Android
```bash
flutter run
```

#### For Release Build
```bash
flutter build apk --release
```

## Configuration

### Android Permissions

The app requires the following permissions (already configured in `AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.NFC" />
<uses-permission android:name="android.permission.INTERNET"/>
<uses-feature android:name="android.hardware.nfc" android:required="false"/>
```

### NFC AID Configuration

The HCE service uses AID (Application ID): `F0010203040506`

This is configured in `android/app/src/main/res/xml/apduservice.xml`

## Usage

### First Time Setup

1. **Launch the App**: Open UniCheck on your NFC-enabled Android device
2. **Register**: Create an account with:
   - Full name
   - Neptun code (university ID)
   - Password
   - Card ID
3. **Login**: Use your Neptun code and password to access the app

### Checking Attendance (Student)

1. Navigate to the main screen after login
2. Enable NFC on your device
3. Hold your device near the instructor's NFC reader
4. The app will automatically emulate your credentials
5. Wait for confirmation

### Managing Classes (Instructor)

1. Login with instructor credentials
2. Access the instructor dashboard
3. Enable NFC reader mode
4. Students can check in by holding their devices nearby

### System Administration

1. Login with admin credentials
2. Access the admin panel
3. Manage users, classes, and system settings

## Project Structure

### Main Screens

- **LoginPage** (`lib/login.dart`): User authentication screen
- **RegisterPage** (`lib/register.dart`): New user registration
- **MainScreen** (`lib/mainScreen.dart`): Student dashboard
- **InstructorPage** (`lib/instructorPage.dart`): Instructor dashboard
- **AdminPage** (`lib/adminPage.dart`): Administrator dashboard
- **NfcStatusPage** (`lib/nfc.dart`): NFC availability checker

### Controllers (GetX)

- **LoginController** (`lib/controllers/login_controller.dart`)
  - Handles user authentication
  - Manages JWT tokens
  - Routes users based on roles

- **RegisterController** (`lib/controllers/register_controller.dart`)
  - Handles new user registration
  - Validates user input
  - Creates new accounts

- **PasswordController** (`lib/controllers/password_controller.dart`)
  - Manages password visibility
  - Handles password validation

### Models

- **LoginModel**: User credentials for authentication
- **LoginResponseModel**: Server response with token and user info
- **RegisterModel**: New user registration data
- **ApiError**: Standardized error responses

### Components

- **NeptunCodeField**: Input field for Neptun code
- **NameTextField**: Input field for user's name
- **PasswordTextField**: Secure password input
- **PasswordVerificationTextField**: Password confirmation input
- **CustomButton**: Reusable button component
- **CustomLoginRegisterContainer**: Container for auth screens

## API Documentation

### Base URL
```
http://localhost:5188
```

### Endpoints

#### Authentication

**Login**
```http
POST /api/Auth/login
Content-Type: application/json

{
  "neptunCode": "ABC123",
  "password": "password123",
  "cardId": "2"
}

Response:
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "name": "John Doe",
  "role": 2
}
```

**Register**
```http
POST /Auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "neptunCode": "ABC123",
  "password": "password123",
  "cardId": "3"
}

Response: 200 OK
```

### User Roles

- **0**: Administrator (Full system access)
- **1**: Instructor (Class management)
- **2**: Student (Attendance check-in)

### Error Handling

All API errors follow this structure:
```json
{
  "error": "Error type",
  "details": "Detailed error message",
  "stackTrace": "Stack trace information"
}
```

## NFC/HCE Implementation

### Overview

UniCheck uses Host Card Emulation (HCE) to turn Android devices into virtual NFC cards. This allows students' phones to be read by NFC readers for attendance tracking.

### Architecture

```
Flutter App (Dart)
    ↓ MethodChannel
Android MainActivity (Kotlin)
    ↓ SharedPreferences
HCE Service (Kotlin)
    ↓ APDU Commands
NFC Reader
```

### Components

#### 1. Flutter Layer (`lib/methodChannel.dart`)

```dart
const platform = MethodChannel('com.example.prog24/hce');
```

Sends JSON data containing user credentials to the native Android layer.

#### 2. MainActivity (`android/app/src/main/kotlin/com/example/prog24/MainActivity.kt`)

Receives JSON from Flutter and stores it in SharedPreferences:
- Channel: `com.example.prog24/hce`
- Method: `setEmulatedJson`
- Storage: Default SharedPreferences with key `emulated_json`

#### 3. HCE Service (`android/app/src/main/kotlin/com/example/prog24/HceService.kt`)

Implements the NFC card emulation:

**Key Features:**
- **AID**: `F0010203040506`
- **APDU Commands**:
  - `SELECT (INS=0xA4)`: Card selection
  - `GET_CHUNK (INS=0x10)`: Retrieve JSON data in chunks

**Data Format:**
```kotlin
// Command Structure
CLA | INS | P1 | P2 | Lc | Data | Le
00  | 10  | 00 | 00 | 03 | offset_hi, offset_lo, length

// Response
[data_chunk] | SW1 | SW2
[...] | 90 | 00  // Success
```

**Status Words:**
- `90 00`: Success
- `6A 82`: File not found
- `67 00`: Wrong length
- `6F 00`: Unknown error

### JSON Data Structure

The emulated data contains user authentication information:
```json
{
  "token": "JWT_TOKEN_HERE",
  "name": "username",
  "role": 2
}
```

### NFC Flow

1. User logs in and credentials are stored
2. `setEmulatedJson` is called to store user data
3. User approaches NFC reader
4. HCE Service receives APDU commands
5. Service responds with user data in chunks
6. Reader validates and records attendance

### Testing NFC

Use the NFC Status page to:
- Check if NFC is available
- Enable/disable NFC
- Open device NFC settings

## Technologies Used

### Framework & Language
- **Flutter**: 3.9.2+ - Cross-platform UI framework
- **Dart**: Programming language
- **Kotlin**: Android native code

### State Management
- **GetX** (^4.7.2): Reactive state management and dependency injection

### Storage
- **GetStorage** (^2.1.1): Fast local key-value storage

### Networking
- **http** (^1.5.0): HTTP client for API communication

### NFC
- **nfc_manager** (^4.1.1): NFC functionality
- **Android HCE**: Native Host Card Emulation

### Security
- **encrypt** (^5.0.3): Data encryption utilities
- **JWT**: Token-based authentication

### UI/UX
- **Lottie** (^3.3.2): Animations
- **Cupertino Icons** (^1.0.8): iOS-style icons

### Permissions
- **permission_handler** (^12.0.1): Runtime permission management
- **app_settings** (^6.1.1): Open system settings

## Development

### Running in Development Mode

```bash
flutter run --debug
```

### Hot Reload

Press `r` in the terminal to hot reload, or `R` for hot restart.

### Checking Code Quality

```bash
flutter analyze
```

### Running Tests

```bash
flutter test
```

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

### Debug Logs

The app uses print statements for debugging. View logs with:

```bash
flutter logs
```

Or in Android Studio via the Logcat window.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is part of an academic project. Please contact the repository owner for licensing information.

## Support

For issues and questions:
- Open an issue on GitHub
- Contact the development team

## Acknowledgments

- Flutter and Dart teams for the excellent framework
- GetX community for state management solutions
- NFC community for HCE documentation and examples
