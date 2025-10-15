import 'package:get/get.dart';

class PasswordController extends GetxController {
  var password = true.obs;

  void togglePasswordVisibility() {
    password.value = !password.value;
  }
}

class PasswordVerificationController extends GetxController {
  var password = true.obs;

  void togglePasswordVisibility() {
    password.value = !password.value;
  }
}
