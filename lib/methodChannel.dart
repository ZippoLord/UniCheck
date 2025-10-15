import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const platform = MethodChannel('com.example.app/hce');



class Methodchannel extends StatefulWidget {
  @override
  State<Methodchannel> createState() => _MethodchannelState();
}

class _MethodchannelState extends State<Methodchannel> {
  final String sampleJson = '''
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiI5IiwidW5pcXVlX25hbWUiOiJiZW4iLCJuZXB0dW4iOiJ0ZXN0MTIzIiwicm9sZSI6IlN0dWRlbnQiLCJuYmYiOjE3NjA0NDg3MTcsImV4cCI6MTc2MDQ3NzUxNywiaWF0IjoxNzYwNDQ4NzE3fQ.zW_TqEyleqsr-3au01yzSufzFpijeuDE0z-sOxTlxEs",
  "name": "ben",
  "role": 2
}
''';

  Future<void> _pushJsonToHce() async {
    try {
      await platform.invokeMethod('setEmulatedJson', {'json': sampleJson});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('JSON átadva az HCE service-nek')));
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hiba: $e')));
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: Text('HCE emuláció példa')),
      body: Center(
        child: ElevatedButton(
          onPressed: _pushJsonToHce,
          child: Text('JSON emulálása NFC-vel'),
        ),
      ),
    );
  }
}
