import 'package:flutter/material.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';

class NeptunCode extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;

  const NeptunCode({
    super.key,
    this.controller,
    this.hintText = "Neptun kód",
  });

  @override
  State<NeptunCode> createState() => _NeptunCodeState();
}

class _NeptunCodeState extends State<NeptunCode> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Adj meg helyes Neptun kódot";
          } else if (!GetUtils.isEmail(value)) {
            return "Érvénytelen Neptun kód formátum";
          }
          return null;
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(12),
          prefixIcon: const Icon(Icons.code, color: Colors.black),
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