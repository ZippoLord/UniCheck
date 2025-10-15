import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prog24/controllers/password_controller.dart';

class PasswordVerificationTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;

  const PasswordVerificationTextField({
    super.key,
    this.controller,
    this.hintText = "Jelszó újra",
  });

  @override
  State<PasswordVerificationTextField> createState() => _PasswordVerificationTextFieldState();
}

class _PasswordVerificationTextFieldState extends State<PasswordVerificationTextField> {
  late final PasswordVerificationController passwordVerController;

  @override
  void initState() {
    super.initState();
    passwordVerController = Get.put(PasswordVerificationController(), tag: widget.key.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextFormField(
        controller: widget.controller,
        obscureText: passwordVerController.password.value,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(6),
          prefixIcon: const Icon(Icons.lock, color: Colors.black),
          suffixIcon: IconButton(
            icon: Icon(
              passwordVerController.password.value
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.black,
            ),
            onPressed: passwordVerController.togglePasswordVisibility,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
    ));
  }
}