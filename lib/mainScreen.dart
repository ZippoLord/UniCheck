import 'package:flutter/material.dart';

class Mainscreen extends StatelessWidget {
  const Mainscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Főképernyő'),
      ),
      body: const Center(
        child: Text(
          'Üdvözlünk a főképernyőn!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}