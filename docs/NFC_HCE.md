# NFC and Host Card Emulation (HCE) Documentation

This document explains the NFC and Host Card Emulation implementation in the UniCheck mobile application.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Components](#components)
- [APDU Protocol](#apdu-protocol)
- [Implementation Details](#implementation-details)
- [Data Flow](#data-flow)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

## Overview

### What is HCE?

Host Card Emulation (HCE) is an Android feature that allows an Android device to emulate a contactless smart card without requiring a physical Secure Element. This enables the phone to act as an NFC card that can be read by NFC readers.

### Why HCE for UniCheck?

UniCheck uses HCE to:
1. **Eliminate Physical Cards**: Students don't need to carry physical attendance cards
2. **Secure Authentication**: JWT tokens are transmitted securely via NFC
3. **Instant Updates**: User credentials can be updated instantly on the device
4. **Cost Effective**: No need for physical card infrastructure

### Requirements

- Android device with NFC capability
- Android API Level 19 (KitKat) or higher
- NFC enabled in device settings
- UniCheck app installed and user logged in

## Architecture

The HCE implementation consists of three layers:

```
┌─────────────────────────────────┐
│    Flutter App (Dart Layer)    │
│  - User Interface               │
│  - Method Channel Communication │
└────────────┬────────────────────┘
             │ MethodChannel
             │ ('com.example.prog24/hce')
┌────────────▼────────────────────┐
│   MainActivity (Kotlin Layer)   │
│  - Receives JSON from Flutter   │
│  - Stores in SharedPreferences  │
└────────────┬────────────────────┘
             │ SharedPreferences
             │ (key: 'emulated_json')
┌────────────▼────────────────────┐
│  HCE Service (Kotlin Layer)     │
│  - Processes APDU commands      │
│  - Returns JSON data in chunks  │
└────────────┬────────────────────┘
             │ NFC Communication
┌────────────▼────────────────────┐
│      NFC Reader Device          │
│  - Sends APDU commands          │
│  - Receives user credentials    │
└─────────────────────────────────┘
```

## Components

### 1. Flutter Layer

**File:** `lib/methodChannel.dart`

**Purpose:** Provides a simple interface to push user data to the native Android layer.

**Key Elements:**

```dart
// Method channel for communication with Android
const platform = MethodChannel('com.example.prog24/hce');

// Sample JSON data to emulate
final String sampleJson = '''
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "name": "ben",
  "role": 2
}
''';

// Function to push JSON to HCE service
Future<void> _pushJsonToHce() async {
  try {
    await platform.invokeMethod('setEmulatedJson', {'json': sampleJson});
    // Show success message
  } on PlatformException catch (e) {
    // Show error message
  }
}
```

**Features:**
- Simple button interface for testing
- Error handling with user feedback
- Direct communication with native code

### 2. MainActivity (Android Native)

**File:** `android/app/src/main/kotlin/com/example/prog24/MainActivity.kt`

**Purpose:** Bridge between Flutter and Android native functionality. Receives JSON data and stores it for HCE service.

**Implementation:**

```kotlin
class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.prog24/hce"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setEmulatedJson" -> {
                        val json = call.argument<String>("json") ?: ""
                        val sharedPref = PreferenceManager
                            .getDefaultSharedPreferences(this)
                        sharedPref.edit()
                            .putString("emulated_json", json)
                            .apply()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
```

**Key Functions:**
- Listen for `setEmulatedJson` method calls
- Store JSON in SharedPreferences with key `emulated_json`
- Use default SharedPreferences for data sharing

### 3. HCE Service (Android Native)

**File:** `android/app/src/main/kotlin/com/example/prog24/HceService.kt`

**Purpose:** Core HCE implementation that emulates an NFC card and responds to APDU commands from NFC readers.

**Class Structure:**

```kotlin
class MyHostApduService : HostApduService() {
    private val PREF = "hce_prefs"
    private val KEY_JSON = "emulated_json"

    // Retrieve JSON data from storage
    private fun getEmulatedJson(): ByteArray

    // Process incoming APDU commands
    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray

    // Handle deactivation
    override fun onDeactivated(reason: Int)
}
```

**Status Words:**

```kotlin
companion object {
    val SW_OK = byteArrayOf(0x90.toByte(), 0x00.toByte())
    val SW_FILE_NOT_FOUND = byteArrayOf(0x6A.toByte(), 0x82.toByte())
    val SW_WRONG_LENGTH = byteArrayOf(0x67.toByte(), 0x00.toByte())
    val UNKNOWN = byteArrayOf(0x6F.toByte(), 0x00.toByte())
}
```

### 4. Android Manifest Configuration

**File:** `android/app/src/main/AndroidManifest.xml`

**Permissions:**

```xml
<uses-permission android:name="android.permission.NFC" />
<uses-permission android:name="android.permission.INTERNET"/>
<uses-feature android:name="android.hardware.nfc" android:required="false"/>
```

**Service Declaration:**

```xml
<service android:name=".MyHostApduService"
    android:exported="true"
    android:permission="android.permission.BIND_NFC_SERVICE">
    <intent-filter>
        <action android:name="android.nfc.cardemulation.action.HOST_APDU_SERVICE"/>
    </intent-filter>
    <meta-data
        android:name="android.nfc.cardemulation.host_apdu_service"
        android:resource="@xml/apduservice" />
</service>
```

### 5. AID Configuration

**File:** `android/app/src/main/res/xml/apduservice.xml`

**Configuration:**

```xml
<host-apdu-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:description="@string/app_name"
    android:requireDeviceUnlock="false">
    <service-aids>
        <aid-filter android:name="F0010203040506"/>
    </service-aids>
</host-apdu-service>
```

**AID Details:**
- **AID Value:** `F0010203040506`
- **Length:** 7 bytes
- **Purpose:** Uniquely identifies the UniCheck HCE service
- **Device Unlock:** Not required for this implementation

## APDU Protocol

### What is APDU?

APDU (Application Protocol Data Unit) is the communication unit between a smart card and a reader. Each APDU consists of a command and a response.

### Command APDU Structure

```
┌─────┬─────┬─────┬─────┬─────┬──────────┬─────┐
│ CLA │ INS │ P1  │ P2  │ Lc  │   Data   │ Le  │
├─────┼─────┼─────┼─────┼─────┼──────────┼─────┤
│  1  │  1  │  1  │  1  │  1  │ Variable │  1  │
│byte │byte │byte │byte │byte │  bytes   │byte │
└─────┴─────┴─────┴─────┴─────┴──────────┴─────┘
```

- **CLA**: Class byte (typically `0x00`)
- **INS**: Instruction byte (command type)
- **P1, P2**: Parameter bytes
- **Lc**: Length of data field
- **Data**: Command data
- **Le**: Expected response length

### Response APDU Structure

```
┌──────────────┬──────┬──────┐
│     Data     │ SW1  │ SW2  │
├──────────────┼──────┼──────┤
│   Variable   │  1   │  1   │
│    bytes     │ byte │ byte │
└──────────────┴──────┴──────┘
```

- **Data**: Response data
- **SW1, SW2**: Status words indicating success/error

### Supported Commands

#### 1. SELECT Command

**Purpose:** Selects the HCE application using its AID.

**Command Format:**
```
CLA: 0x00
INS: 0xA4 (SELECT)
P1:  0x04 (Select by name)
P2:  0x00
Lc:  0x07 (AID length)
Data: F0010203040506 (AID)
```

**Response:**
```
SW1: 0x90
SW2: 0x00 (Success)
```

**Implementation:**
```kotlin
if (ins == 0xA4) {
    return SW_OK
}
```

#### 2. GET_CHUNK Command

**Purpose:** Retrieves a chunk of JSON data from the emulated card.

**Command Format:**
```
CLA: 0x00
INS: 0x10 (Custom GET_CHUNK)
P1:  0x00
P2:  0x00
Lc:  0x03
Data: [offset_hi, offset_lo, length]
```

**Parameters:**
- `offset_hi`: High byte of offset (for large files)
- `offset_lo`: Low byte of offset
- `length`: Number of bytes to read

**Example:**
```
Command: 00 10 00 00 03 00 00 FF
- Read 255 bytes starting at offset 0
```

**Response:**
```
Data: [JSON chunk bytes]
SW1: 0x90
SW2: 0x00
```

**Implementation:**
```kotlin
if (ins == 0x10) {
    if (commandApdu.size >= 8) {
        val offsetHi = commandApdu[5].toInt() and 0xFF
        val offsetLo = commandApdu[6].toInt() and 0xFF
        val length = commandApdu[7].toInt() and 0xFF
        val offset = (offsetHi shl 8) or offsetLo

        val jsonBytes = getEmulatedJson()
        if (offset >= jsonBytes.size) {
            return SW_FILE_NOT_FOUND
        }
        val end = minOf(jsonBytes.size, offset + length)
        val chunk = jsonBytes.copyOfRange(offset, end)
        return chunk + SW_OK
    } else {
        return SW_WRONG_LENGTH
    }
}
```

### Status Words Reference

| SW1-SW2 | Hex Value | Meaning | Usage |
|---------|-----------|---------|-------|
| 90 00 | 0x9000 | Success | Command executed successfully |
| 6A 82 | 0x6A82 | File not found | Invalid offset or no data |
| 67 00 | 0x6700 | Wrong length | Invalid Lc field |
| 6F 00 | 0x6F00 | Unknown error | Command not recognized |

## Implementation Details

### Data Storage Flow

1. **User Login:**
   ```dart
   // After successful login
   LoginResponseModel response = loginResponseModelFromJson(response.body);
   box.write("token", response.token);
   ```

2. **Prepare Emulation Data:**
   ```dart
   final jsonData = jsonEncode({
     "token": response.token,
     "name": response.name,
     "role": response.role
   });
   ```

3. **Send to Native Layer:**
   ```dart
   await platform.invokeMethod('setEmulatedJson', {'json': jsonData});
   ```

4. **Store in SharedPreferences:**
   ```kotlin
   sharedPref.edit().putString("emulated_json", json).apply()
   ```

5. **Retrieve During NFC Transaction:**
   ```kotlin
   val prefs = getSharedPreferences(PREF, Context.MODE_PRIVATE)
   val json = prefs.getString(KEY_JSON, "") ?: ""
   return json.toByteArray(Charsets.UTF_8)
   ```

### Reading JSON Data

**Chunked Reading Algorithm:**

```
1. Reader sends SELECT command → Receive SW_OK
2. Initialize offset = 0
3. While data remaining:
   a. Calculate bytes_to_read = min(255, remaining_bytes)
   b. Send GET_CHUNK(offset, bytes_to_read)
   c. Receive chunk + SW_OK
   d. Append chunk to buffer
   e. offset += bytes_read
4. Parse complete JSON
```

**Pseudocode for Reader:**

```python
def read_json_from_hce():
    # Step 1: Select application
    send_apdu([0x00, 0xA4, 0x04, 0x00, 0x07, 0xF0, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06])
    
    # Step 2: Read data in chunks
    offset = 0
    json_data = []
    
    while True:
        offset_hi = (offset >> 8) & 0xFF
        offset_lo = offset & 0xFF
        chunk_size = 255
        
        # Send GET_CHUNK command
        response = send_apdu([0x00, 0x10, 0x00, 0x00, 0x03, 
                             offset_hi, offset_lo, chunk_size])
        
        if response.sw1 == 0x90 and response.sw2 == 0x00:
            json_data.extend(response.data)
            offset += len(response.data)
            
            if len(response.data) < chunk_size:
                break  # Last chunk
        else:
            break  # Error or end of data
    
    # Step 3: Parse JSON
    json_string = ''.join(chr(b) for b in json_data)
    return json.loads(json_string)
```

## Data Flow

### Complete Attendance Check-In Flow

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│ Student  │     │ Flutter  │     │ Android  │     │   NFC    │
│   App    │     │  Layer   │     │  Native  │     │  Reader  │
└────┬─────┘     └────┬─────┘     └────┬─────┘     └────┬─────┘
     │                │                │                │
     │   1. Login     │                │                │
     ├───────────────>│                │                │
     │                │                │                │
     │   2. Store     │                │                │
     │   Token        │                │                │
     │<───────────────┤                │                │
     │                │                │                │
     │   3. Push JSON │                │                │
     │   to HCE       │                │                │
     ├───────────────>│ 4. Method     │                │
     │                │   Channel      │                │
     │                ├───────────────>│                │
     │                │                │ 5. Store in   │
     │                │                │   SharedPref  │
     │                │                │                │
     │   6. Approach NFC Reader        │                │
     │<─────────────────────────────────────────────────┤
     │                │                │                │
     │                │                │  7. SELECT    │
     │                │                │  Command      │
     │                │                │<───────────────┤
     │                │                │                │
     │                │                │  8. SW_OK     │
     │                │                │───────────────>│
     │                │                │                │
     │                │                │  9. GET_CHUNK │
     │                │                │  (offset=0)   │
     │                │                │<───────────────┤
     │                │                │                │
     │                │                │ 10. Read JSON │
     │                │                │                │
     │                │                │ 11. Data +    │
     │                │                │     SW_OK     │
     │                │                │───────────────>│
     │                │                │                │
     │                │                │ 12. Verify    │
     │                │                │     Token     │
     │                │                │                │
     │  13. Success Confirmation       │                │
     │<─────────────────────────────────────────────────┤
```

## Testing

### Testing NFC Availability

Use the built-in NFC Status page:

```dart
// Navigate to NFC status page
Navigator.push(context, 
  MaterialPageRoute(builder: (context) => NfcStatusPage())
);
```

**Features:**
- Check if NFC is available on device
- Check if NFC is currently enabled
- Open device NFC settings
- Visual status indicator

### Testing HCE Emulation

**Option 1: Using Another NFC-Enabled Phone**

1. Install an NFC reader app on a second device
2. Run UniCheck on the first device
3. Bring devices close together
4. Second device should read the emulated JSON

**Option 2: Using NFC Reader Hardware**

1. Get an ACR122U or similar USB NFC reader
2. Connect to computer
3. Use PC/SC tools to send APDU commands
4. Verify responses

**Option 3: Using Android Debug Bridge (ADB)**

```bash
# Check NFC status
adb shell dumpsys nfc

# View HCE services
adb shell dumpsys nfc | grep -A 10 "HCE"

# View app logs
adb logcat | grep "MyHostApduService"
```

### Testing APDU Commands

**Test SELECT Command:**

```bash
# Using Python and nfcpy library
import nfc

clf = nfc.ContactlessFrontend('usb')
tag = clf.connect(rdwr={'on-connect': lambda tag: False})

# SELECT command
select_cmd = bytes([0x00, 0xA4, 0x04, 0x00, 0x07, 
                   0xF0, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06])
response = tag.transceive(select_cmd)
print(f"Response: {response.hex()}")  # Should be 9000
```

**Test GET_CHUNK Command:**

```python
# GET_CHUNK command (read first 100 bytes)
get_chunk_cmd = bytes([0x00, 0x10, 0x00, 0x00, 0x03, 0x00, 0x00, 0x64])
response = tag.transceive(get_chunk_cmd)
print(f"Data: {response[:-2].decode('utf-8')}")
print(f"Status: {response[-2:].hex()}")  # Should be 9000
```

## Troubleshooting

### Common Issues

#### 1. NFC Not Available

**Symptoms:** App reports NFC is not available

**Solutions:**
- Check device has NFC hardware
- Enable NFC in device settings
- Ensure app has NFC permission
- Restart device

#### 2. HCE Service Not Responding

**Symptoms:** Reader cannot detect the emulated card

**Solutions:**
- Verify AID is correctly configured
- Check service is declared in manifest
- Ensure JSON data is stored
- Check logcat for errors:
  ```bash
  adb logcat | grep "HCE\|APDU"
  ```

#### 3. Invalid JSON Response

**Symptoms:** Reader receives corrupted or incomplete data

**Solutions:**
- Verify JSON is valid before sending
- Check SharedPreferences storage
- Implement proper chunking logic
- Test with smaller JSON payloads

#### 4. Status Word Errors

**Error 6A 82 (File Not Found):**
- JSON data not stored in SharedPreferences
- Invalid offset in GET_CHUNK command
- Check getEmulatedJson() returns data

**Error 67 00 (Wrong Length):**
- Command length doesn't match Lc field
- Missing parameters in command
- Verify command structure

#### 5. Performance Issues

**Symptoms:** Slow NFC transactions

**Solutions:**
- Reduce JSON payload size
- Increase chunk size (max 255 bytes)
- Minimize data processing in HCE service
- Cache frequently used data

### Debug Logging

Add logging to HCE service:

```kotlin
override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
    Log.d("HCE", "Received APDU: ${commandApdu?.toHex()}")
    
    val response = // ... process command
    
    Log.d("HCE", "Sending response: ${response.toHex()}")
    return response
}

fun ByteArray.toHex(): String = joinToString(" ") { "%02X".format(it) }
```

View logs:
```bash
adb logcat -s HCE:D
```

### Testing Checklist

- [ ] NFC is available and enabled on device
- [ ] HCE service is declared in AndroidManifest.xml
- [ ] AID is correctly configured in apduservice.xml
- [ ] JSON data is stored after login
- [ ] SELECT command returns SW_OK
- [ ] GET_CHUNK returns valid data
- [ ] Complete JSON can be reconstructed
- [ ] JSON is valid and parseable
- [ ] Token is valid and not expired

## Security Considerations

### Data Protection

1. **Token Expiration:** Always check token expiry
2. **Secure Storage:** Use encrypted SharedPreferences for production
3. **Token Rotation:** Implement token refresh mechanism
4. **Access Control:** Validate token on backend

### NFC Security

1. **Proximity:** NFC works only at close range (< 4cm)
2. **Timing:** Implement transaction timeouts
3. **Validation:** Always validate data on server side
4. **Replay Protection:** Use nonces or timestamps

### Best Practices

- Never store passwords in emulated data
- Use HTTPS for API communication
- Implement certificate pinning
- Clear sensitive data on logout
- Log security events

## Future Enhancements

### Planned Features

1. **Encrypted NFC Communication**
   - AES encryption of JSON payload
   - Key exchange mechanism

2. **Multiple AID Support**
   - Different AIDs for different services
   - Dynamic AID selection

3. **Offline Mode**
   - Cache credentials locally
   - Sync when online

4. **Enhanced Error Handling**
   - Retry mechanism
   - Fallback options

### Performance Improvements

1. **Optimized Chunking**
   - Adaptive chunk sizes
   - Compression support

2. **Faster Transactions**
   - Pre-cache common data
   - Reduce round trips

3. **Battery Optimization**
   - Smart NFC polling
   - Power-efficient HCE

## References

- [Android HCE Documentation](https://developer.android.com/guide/topics/connectivity/nfc/hce)
- [ISO/IEC 7816-4 (APDU Specification)](https://www.iso.org/standard/54550.html)
- [NFC Forum Specifications](https://nfc-forum.org/build/specifications)
- [Flutter Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels)

## Support

For HCE-related issues:
- Check Android system logs
- Test with known working NFC readers
- Verify AID registration
- Contact development team with logs and device details
