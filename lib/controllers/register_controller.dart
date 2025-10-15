import 'dart:convert';

import 'package:flutter/material.dart';
//import 'package:food_order_app/models/newmodels/apiError.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:prog24/constants.dart';
import 'package:prog24/login.dart';
import 'package:prog24/models/api_error.dart';



final box = GetStorage();

class RegisterController extends GetxController {
  RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  set setLoading(bool newState){
    _isLoading.value = newState; 
  }

  void registerFunction (String data)  async {
    setLoading = true;

    Uri url = Uri.parse('$baseURL/Auth/register');
    Map<String, String>  headers = {'Content-type' : 'application/json'};
    try {
      print(data);
      print("✅✅✅✅✅✅✅");
      var response = await http.post(url, headers: headers, body: data);
      print(response.statusCode);
      if (response.statusCode == 200) {
      // Show success snackbar
      final responseData = jsonDecode(response.body);
      final token =responseData['token'];
      print(token);
      setLoading = false;
      Get.snackbar(
        "Sikeres regisztráció",
        "Most már bejelentkezhetsz!",
        colorText: Colors.white,
        backgroundColor: Colors.blue,
      );
      // Redirect to login page
      Get.offAll(() => const LoginPage());
    } else {
      var error = apiErrorFromJson(response.body);
      Get.snackbar(
        "Regisztráció sikertelen",
        error.details,
        colorText: Colors.white,
        backgroundColor: Colors.redAccent,
      );
    }
    } catch (e) {
      print(e);
    }
  }
}
