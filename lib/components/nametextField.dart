import 'package:flutter/material.dart';

class Nametextfield extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;

  const Nametextfield({
    super.key,
    this.controller,
    this.hintText = "Teljes Név",
  });

  @override
  State<Nametextfield> createState() => _NametextfieldState();
}

class _NametextfieldState extends State<Nametextfield> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(6),
          prefixIcon: const Icon(Icons.people, color: Colors.black),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
    );
  }
}