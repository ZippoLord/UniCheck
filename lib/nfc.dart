import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/services.dart';

class NfcStatusPage extends StatefulWidget {
  const NfcStatusPage({Key? key}) : super(key: key);

  @override
  State<NfcStatusPage> createState() => _NfcStatusPageState();
}

class _NfcStatusPageState extends State<NfcStatusPage> with WidgetsBindingObserver {
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNfc();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNfc();
    }
  }

  Future<void> _checkNfc() async {
    bool available = await NfcManager.instance.isAvailable();
    if (!mounted) return;
    setState(() {
      _isAvailable = available;
    });
  }

  Future<void> _openNfcSettings() async {
    try {
      AppSettings.openAppSettings();
    } on PlatformException catch (e) {
      debugPrint("Nem sikerült megnyitni az NFC beállításokat: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC státusz'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isAvailable ? Icons.nfc : Icons.nfc,
              size: 80,
              color: _isAvailable ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              _isAvailable ? "Az NFC elérhető ezen az eszközön." : "Az NFC nem elérhető vagy ki van kapcsolva.",
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _openNfcSettings,
              child: const Text("NFC beállítások megnyitása"),
            ),
            const SizedBox(height: 10),
            // ElevatedButton(
            //   onPressed: _checkNfc,
            //   child: const Text("NFC státusz frissítése"),
            // ),
           Padding(
  padding: const EdgeInsets.all(8.0),
  child: Container(
    decoration: BoxDecoration(
      color: _isAvailable ? Colors.green : Colors.red,
      borderRadius: BorderRadius.circular(12),
    ),
    child: _isAvailable
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0), 
            child: Text(
              "Elérhető",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0), 
            child: Text(
              "Nem elérhető",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
  ),
),
          ],
        ),
      ),
    );
  }
}