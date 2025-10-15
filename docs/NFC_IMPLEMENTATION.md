# UniCheck - NFC HCE Implementációs Útmutató

## Áttekintés

Ez a dokumentum részletesen bemutatja a UniCheck alkalmazás NFC Host Card Emulation (HCE) implementációját, amely lehetővé teszi az Android eszközök számára, hogy NFC kártyaként viselkedjenek.

## Mi az a Host Card Emulation (HCE)?

A Host Card Emulation egy Android 4.4 (KitKat) óta elérhető technológia, amely lehetővé teszi, hogy egy alkalmazás NFC kártyaként viselkedjen, anélkül hogy fizikai Secure Element (SE) szükséges lenne az eszközben.

### Előnyök

- ✅ **Nincs szükség hardveres SE-re**: Minden modern Android eszközön működik
- ✅ **Teljes szoftveres kontroll**: Az alkalmazás kezeli az összes APDU parancsot
- ✅ **Rugalmasság**: Könnyen frissíthető és testreszabható
- ✅ **Multi-applikáció támogatás**: Több HCE szolgáltatás is futhat párhuzamosan

### Hátrányok

- ⚠️ **Biztonsági korlátozások**: Kevésbé biztonságos, mint a hardveres SE
- ⚠️ **OS függőség**: Csak Android 4.4+
- ⚠️ **Power függőség**: Csak bekapcsolt eszközön működik

## Architektúra

### Komponensek Áttekintése

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App Layer                     │
│  - UI (NFC Status Page, Method Channel Demo)           │
│  - Business Logic (Controllers)                         │
└────────────────────────┬────────────────────────────────┘
                         │ Method Channel
┌────────────────────────▼────────────────────────────────┐
│              Android Native Layer (Kotlin)              │
│                                                          │
│  ┌─────────────────┐       ┌──────────────────────┐    │
│  │  MainActivity   │       │   HceService         │    │
│  │                 │       │  (HostApduService)   │    │
│  │  - Method       │       │  - APDU Processing   │    │
│  │    Channel      │◄─────►│  - Token Emulation   │    │
│  │    Handler      │       │  - SharedPreferences │    │
│  └─────────────────┘       └──────────────────────┘    │
│           │                          │                   │
│           ▼                          ▼                   │
│  SharedPreferences             NFC Controller            │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│                  NFC Reader Device                       │
│           (POS Terminal, Access Control)                │
└─────────────────────────────────────────────────────────┘
```

## AndroidManifest.xml Konfiguráció

### 1. Engedélyek

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- NFC használatához szükséges engedély -->
    <uses-permission android:name="android.permission.NFC" />
    
    <!-- NFC feature deklarálása (nem kötelező) -->
    <uses-feature 
        android:name="android.hardware.nfc" 
        android:required="false"/>
</manifest>
```

**Megjegyzés:** A `android:required="false"` lehetővé teszi, hogy az alkalmazás NFC nélküli eszközökre is telepíthető legyen, de a funkcionalitás korlátozva lesz.

### 2. HCE Service Deklarálása

```xml
<service 
    android:name=".MyHostApduService"
    android:exported="true"
    android:permission="android.permission.BIND_NFC_SERVICE">
    
    <!-- Intent filter az NFC rendszer számára -->
    <intent-filter>
        <action android:name="android.nfc.cardemulation.action.HOST_APDU_SERVICE"/>
    </intent-filter>
    
    <!-- AID konfiguráció meta-data -->
    <meta-data
        android:name="android.nfc.cardemulation.host_apdu_service"
        android:resource="@xml/apduservice" />
</service>
```

### 3. AID Konfiguráció (apduservice.xml)

Hozz létre egy `res/xml/apduservice.xml` fájlt:

```xml
<host-apdu-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:description="@string/servicedesc"
    android:requireDeviceUnlock="false">
    
    <aid-group 
        android:description="@string/aiddescription"
        android:category="other">
        
        <!-- Egyedi Application ID -->
        <aid-filter android:name="F0010203040506"/>
        
        <!-- További AID-ok, ha szükséges -->
        <!-- <aid-filter android:name="F0010203040507"/> -->
    </aid-group>
</host-apdu-service>
```

**AID (Application ID) Formátum:**
- Hossz: 5-16 bájt (10-32 hexadecimális karakter)
- Formátum: Hexadecimális string
- Regisztráció: ISO/IEC 7816-4 szabvány szerint

**Példa AID-ok:**
```
F0010203040506  - Egyedi test AID
A0000000031010  - Visa típusú AID (csak példa)
D2760000850101  - Mifare DESFire típusú AID (csak példa)
```

**⚠️ Fontos:** Használj egyedi AID-t, ami nem ütközik más alkalmazásokkal!

### 4. String Erőforrások

`res/values/strings.xml`:

```xml
<resources>
    <string name="servicedesc">UniCheck Digital Student Card</string>
    <string name="aiddescription">UniCheck HCE Service</string>
</resources>
```

## Kotlin HCE Service Implementáció

### HceService.kt Teljes Implementáció

```kotlin
package com.example.prog24

import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import android.content.Context
import android.util.Log

class MyHostApduService : HostApduService() {
    
    // SharedPreferences konstansok
    private val PREF_NAME = "hce_prefs"
    private val KEY_JSON = "emulated_json"
    private val TAG = "MyHostApduService"

    /**
     * JSON token lekérése SharedPreferences-ből
     */
    private fun getEmulatedJson(): ByteArray {
        val prefs = getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val json = prefs.getString(KEY_JSON, "") ?: ""
        Log.d(TAG, "Retrieved JSON length: ${json.length}")
        return json.toByteArray(Charsets.UTF_8)
    }

    /**
     * APDU parancsok feldolgozása
     * 
     * Az NFC olvasó APDU parancsokat küld, ezt a metódust hívja a rendszer
     * minden egyes parancs esetén.
     */
    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
        if (commandApdu == null || commandApdu.isEmpty()) {
            Log.w(TAG, "Received null or empty command APDU")
            return UNKNOWN
        }

        // APDU struktúra parse-olása
        val cla = commandApdu[0].toInt() and 0xFF  // Class byte
        val ins = commandApdu[1].toInt() and 0xFF  // Instruction byte
        val p1 = commandApdu[2].toInt() and 0xFF   // Parameter 1
        val p2 = commandApdu[3].toInt() and 0xFF   // Parameter 2

        Log.d(TAG, "Received APDU - CLA: ${cla.toHex()}, INS: ${ins.toHex()}, P1: ${p1.toHex()}, P2: ${p2.toHex()}")

        // SELECT parancs feldolgozása (INS = 0xA4)
        if (ins == 0xA4) {
            Log.d(TAG, "SELECT command received")
            return SW_OK
        }

        // GET_CHUNK parancs feldolgozása (INS = 0x10)
        // Ez a custom parancs az adatok olvasására szolgál chunk-okban
        if (ins == 0x10) {
            return handleGetChunk(commandApdu)
        }

        // GET_LENGTH parancs (INS = 0x11) - opcionális
        // Teljes adatméret lekérdezése
        if (ins == 0x11) {
            return handleGetLength()
        }

        // Ismeretlen parancs
        Log.w(TAG, "Unknown instruction: ${ins.toHex()}")
        return SW_INS_NOT_SUPPORTED
    }

    /**
     * GET_CHUNK parancs kezelése
     * 
     * APDU formátum:
     * CLA INS P1  P2  Lc  Data...
     * 00  10  00  00  03  [offset_hi][offset_lo][length]
     */
    private fun handleGetChunk(commandApdu: ByteArray): ByteArray {
        // Minimális hossz ellenőrzés (CLA, INS, P1, P2, Lc + 3 data byte)
        if (commandApdu.size < 8) {
            Log.e(TAG, "GET_CHUNK: Invalid command length")
            return SW_WRONG_LENGTH
        }

        try {
            // Offset és length kiolvasása
            val offsetHi = commandApdu[5].toInt() and 0xFF
            val offsetLo = commandApdu[6].toInt() and 0xFF
            val length = commandApdu[7].toInt() and 0xFF
            
            val offset = (offsetHi shl 8) or offsetLo

            Log.d(TAG, "GET_CHUNK - Offset: $offset, Length: $length")

            // JSON bytes lekérése
            val jsonBytes = getEmulatedJson()
            
            if (jsonBytes.isEmpty()) {
                Log.w(TAG, "No data available for emulation")
                return SW_FILE_NOT_FOUND
            }

            // Offset validáció
            if (offset >= jsonBytes.size) {
                Log.e(TAG, "Offset out of bounds: $offset >= ${jsonBytes.size}")
                return SW_FILE_NOT_FOUND
            }

            // Chunk kiszámítása
            val end = minOf(jsonBytes.size, offset + length)
            val chunk = jsonBytes.copyOfRange(offset, end)

            Log.d(TAG, "Returning chunk: ${chunk.size} bytes")
            
            // Chunk visszaadása + success status
            return chunk + SW_OK
            
        } catch (e: Exception) {
            Log.e(TAG, "Error processing GET_CHUNK", e)
            return SW_UNKNOWN
        }
    }

    /**
     * GET_LENGTH parancs kezelése
     * 
     * Visszaadja a teljes emulált adat méretét
     */
    private fun handleGetLength(): ByteArray {
        val jsonBytes = getEmulatedJson()
        val length = jsonBytes.size
        
        // Length két bájtban (big-endian)
        val lengthHi = (length shr 8) and 0xFF
        val lengthLo = length and 0xFF
        
        Log.d(TAG, "GET_LENGTH - Total length: $length")
        
        return byteArrayOf(lengthHi.toByte(), lengthLo.toByte()) + SW_OK
    }

    /**
     * NFC kapcsolat megszakadásakor hívódik
     */
    override fun onDeactivated(reason: Int) {
        val reasonStr = when (reason) {
            DEACTIVATION_LINK_LOSS -> "LINK_LOSS"
            DEACTIVATION_DESELECTED -> "DESELECTED"
            else -> "UNKNOWN"
        }
        Log.d(TAG, "Service deactivated: $reasonStr")
    }

    companion object {
        // Status Word (SW) válasz kódok - ISO/IEC 7816-4
        val SW_OK = byteArrayOf(0x90.toByte(), 0x00.toByte())
        val SW_FILE_NOT_FOUND = byteArrayOf(0x6A.toByte(), 0x82.toByte())
        val SW_WRONG_LENGTH = byteArrayOf(0x67.toByte(), 0x00.toByte())
        val SW_INS_NOT_SUPPORTED = byteArrayOf(0x6D.toByte(), 0x00.toByte())
        val SW_CLA_NOT_SUPPORTED = byteArrayOf(0x6E.toByte(), 0x00.toByte())
        val UNKNOWN = byteArrayOf(0x6F.toByte(), 0x00.toByte())
        val SW_UNKNOWN = byteArrayOf(0x6F.toByte(), 0x00.toByte())
    }
}

/**
 * Extension function: Int to Hex String
 */
private fun Int.toHex(): String = "0x${this.toString(16).uppercase().padStart(2, '0')}"
```

### Status Word (SW) Kódok Magyarázata

| Kód | Név | Jelentés |
|-----|-----|----------|
| `90 00` | SW_OK | Sikeres végrehajtás |
| `6A 82` | SW_FILE_NOT_FOUND | Fájl/adat nem található |
| `67 00` | SW_WRONG_LENGTH | Hibás adathossz |
| `6D 00` | SW_INS_NOT_SUPPORTED | Nem támogatott instrukció |
| `6E 00` | SW_CLA_NOT_SUPPORTED | Nem támogatott class |
| `6F 00` | SW_UNKNOWN | Ismeretlen hiba |

## MainActivity - Method Channel

### MainActivity.kt Implementáció

```kotlin
package com.example.prog24

import android.os.Bundle
import android.preference.PreferenceManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.prog24/hce"
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Method Channel beállítása
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                
                when (call.method) {
                    "setEmulatedJson" -> {
                        try {
                            val json = call.argument<String>("json")
                            
                            if (json == null) {
                                result.error("INVALID_ARGUMENT", "JSON cannot be null", null)
                                return@setMethodCallHandler
                            }
                            
                            Log.d(TAG, "Saving JSON to SharedPreferences: ${json.length} chars")
                            
                            // SharedPreferences-be mentés
                            val sharedPref = PreferenceManager.getDefaultSharedPreferences(this)
                            sharedPref.edit()
                                .putString("emulated_json", json)
                                .apply()
                            
                            result.success(true)
                            
                        } catch (e: Exception) {
                            Log.e(TAG, "Error saving JSON", e)
                            result.error("SAVE_ERROR", e.message, null)
                        }
                    }
                    
                    "getEmulatedJson" -> {
                        try {
                            val sharedPref = PreferenceManager.getDefaultSharedPreferences(this)
                            val json = sharedPref.getString("emulated_json", "")
                            result.success(json)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error reading JSON", e)
                            result.error("READ_ERROR", e.message, null)
                        }
                    }
                    
                    "clearEmulatedJson" -> {
                        try {
                            val sharedPref = PreferenceManager.getDefaultSharedPreferences(this)
                            sharedPref.edit()
                                .remove("emulated_json")
                                .apply()
                            result.success(true)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error clearing JSON", e)
                            result.error("CLEAR_ERROR", e.message, null)
                        }
                    }
                    
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
}
```

## Flutter Implementáció

### Method Channel Használata

```dart
// lib/methodChannel.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const platform = MethodChannel('com.example.prog24/hce');

class NfcEmulationService {
  
  /// JSON token beállítása NFC emulációhoz
  static Future<bool> setEmulatedJson(String json) async {
    try {
      final result = await platform.invokeMethod('setEmulatedJson', {
        'json': json
      });
      return result == true;
    } on PlatformException catch (e) {
      print('Error setting emulated JSON: ${e.message}');
      return false;
    }
  }
  
  /// Aktuális emulált JSON lekérése
  static Future<String?> getEmulatedJson() async {
    try {
      final String? json = await platform.invokeMethod('getEmulatedJson');
      return json;
    } on PlatformException catch (e) {
      print('Error getting emulated JSON: ${e.message}');
      return null;
    }
  }
  
  /// Emulált JSON törlése
  static Future<bool> clearEmulatedJson() async {
    try {
      final result = await platform.invokeMethod('clearEmulatedJson');
      return result == true;
    } on PlatformException catch (e) {
      print('Error clearing emulated JSON: ${e.message}');
      return false;
    }
  }
}
```

### Használat Controllerben

```dart
// lib/controllers/nfc_controller.dart
import 'package:get/get.dart';
import 'package:prog24/methodChannel.dart';

class NfcController extends GetxController {
  
  /// Token beállítása bejelentkezéskor
  Future<void> setupNfcToken(String token, String name, int role) async {
    final jsonData = {
      "token": token,
      "name": name,
      "role": role,
      "timestamp": DateTime.now().toIso8601String(),
    };
    
    final jsonString = jsonEncode(jsonData);
    
    final success = await NfcEmulationService.setEmulatedJson(jsonString);
    
    if (success) {
      Get.snackbar(
        "NFC Aktív",
        "Digitális diákigazolvány aktiválva",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Token törlése kijelentkezéskor
  Future<void> clearNfcToken() async {
    await NfcEmulationService.clearEmulatedJson();
  }
}
```

## NFC Olvasó Oldal (Példa Python)

### Python NFC Olvasó Script

```python
#!/usr/bin/env python3
import nfc
import json

def on_connect(tag):
    """
    Callback amikor NFC tag/HCE eszköz érintkezik az olvasóval
    """
    print(f"Connected to: {tag}")
    
    # SELECT parancs küldése
    select_cmd = bytes([0x00, 0xA4, 0x04, 0x00, 0x07, 
                        0xF0, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x00])
    
    response = tag.transceive(select_cmd)
    print(f"SELECT Response: {response.hex()}")
    
    if response[-2:] != bytes([0x90, 0x00]):
        print("SELECT failed")
        return False
    
    # GET_LENGTH parancs (opcionális)
    get_length_cmd = bytes([0x00, 0x11, 0x00, 0x00, 0x00])
    response = tag.transceive(get_length_cmd)
    
    if response[-2:] == bytes([0x90, 0x00]):
        length = (response[0] << 8) | response[1]
        print(f"Total data length: {length} bytes")
    else:
        length = 4096  # Max length fallback
    
    # Adatok olvasása chunk-okban
    data = bytearray()
    offset = 0
    chunk_size = 200  # Adjust based on NFC reader capability
    
    while offset < length:
        # GET_CHUNK parancs
        offset_hi = (offset >> 8) & 0xFF
        offset_lo = offset & 0xFF
        read_length = min(chunk_size, length - offset)
        
        get_chunk_cmd = bytes([0x00, 0x10, 0x00, 0x00, 0x03,
                              offset_hi, offset_lo, read_length])
        
        response = tag.transceive(get_chunk_cmd)
        
        if response[-2:] != bytes([0x90, 0x00]):
            print(f"GET_CHUNK failed at offset {offset}")
            break
        
        chunk = response[:-2]  # Remove SW bytes
        data.extend(chunk)
        offset += len(chunk)
        
        print(f"Read {len(chunk)} bytes (total: {len(data)})")
        
        if len(chunk) < read_length:
            break  # No more data
    
    # JSON parse
    try:
        json_str = data.decode('utf-8')
        json_data = json.loads(json_str)
        print("\n=== Received JSON ===")
        print(json.dumps(json_data, indent=2))
        
        # Token validálás
        validate_token(json_data)
        
    except Exception as e:
        print(f"Error parsing JSON: {e}")
    
    return True

def validate_token(data):
    """
    JWT token validálás (egyszerűsített)
    """
    if 'token' not in data:
        print("⚠️  No token found")
        return
    
    token = data['token']
    # Itt valódi JWT validálás történne
    print(f"✅ Token received: {token[:20]}...")
    print(f"✅ Name: {data.get('name', 'Unknown')}")
    print(f"✅ Role: {data.get('role', 'Unknown')}")

def main():
    """
    NFC Olvasó fő ciklus
    """
    clf = nfc.ContactlessFrontend('usb')
    
    if clf is None:
        print("No NFC reader found")
        return
    
    print(f"NFC Reader: {clf}")
    print("Waiting for NFC device...")
    
    try:
        while True:
            target = clf.connect(rdwr={'on-connect': on_connect})
            if target is None:
                break
    except KeyboardInterrupt:
        print("\nStopped by user")
    finally:
        clf.close()

if __name__ == '__main__':
    main()
```

## Tesztelés

### Android Debug Bridge (ADB) Használata

```bash
# NFC status ellenőrzése
adb shell dumpsys nfc

# HCE service ellenőrzése
adb shell dumpsys nfc | grep -A 20 "HCE"

# SharedPreferences megtekintése
adb shell run-as com.example.prog24 \
  cat /data/data/com.example.prog24/shared_prefs/com.example.prog24_preferences.xml

# Logok megtekintése
adb logcat | grep -E "(MyHostApduService|MainActivity)"
```

### Emulált NFC Tesztelés

Android Emulatorban NFC nem működik, fizikai eszköz szükséges!

**Tesztelési eszközök:**
1. **Másik NFC-képes Android telefon** - NFC olvasó applikációval
2. **NFC olvasó hardver** - ACR122U, PN532
3. **Raspberry Pi + NFC modul** - Fejlesztői környezetben

## Hibaelhárítás

### HCE Service nem indul

```bash
# Ellenőrizd a service regisztrációt
adb shell dumpsys package com.example.prog24 | grep -A 5 "Service"

# NFC  engedélyek
adb shell dumpsys package com.example.prog24 | grep permission
```

### NFC olvasó nem érzékeli

1. Ellenőrizd az AID egyezést
2. Győződj meg róla, hogy a HCE alapértelmezett
3. Teszteld más NFC olvasó alkalmazással

### SharedPreferences nem frissül

```dart
// Flutter oldalon explicit flush
await platform.invokeMethod('setEmulatedJson', {'json': json});
await Future.delayed(Duration(milliseconds: 100));
```

## Biztonsági Megfontolások

### Token Titkosítás

```dart
import 'package:encrypt/encrypt.dart';

String encryptToken(String token, String key) {
  final keyBytes = Key.fromUtf8(key.padRight(32));
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(keyBytes));
  
  return encrypter.encrypt(token, iv: iv).base64;
}
```

### Certificate Pinning

Az API kommunikációhoz:

```dart
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

await HttpCertificatePinning.check(
  serverURL: baseURL,
  headerHttp: headers,
  sha: SHA.SHA256,
  allowedSHAFingerprints: [
    'YOUR_CERTIFICATE_SHA256_FINGERPRINT'
  ],
  timeout: 60,
);
```

## Referenciák

- [Android NFC Documentation](https://developer.android.com/guide/topics/connectivity/nfc)
- [Host Card Emulation](https://developer.android.com/guide/topics/connectivity/nfc/hce)
- [ISO/IEC 7816-4](https://www.iso.org/standard/77180.html)
- [Flutter Platform Channels](https://docs.flutter.dev/development/platform-integration/platform-channels)

---

**Verzió:** 1.0.0  
**Utolsó Frissítés:** 2024-01-15
