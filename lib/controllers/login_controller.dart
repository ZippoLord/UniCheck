import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:food_order_app/constants.dart';
// import 'package:food_order_app/models/newmodels/apiError.dart';
// import 'package:food_order_app/models/newmodels/login_model.dart';
// import 'package:food_order_app/models/newmodels/login_response.dart';
// import 'package:food_order_app/pages/admin_page.dart';
// import 'package:food_order_app/pages/home_page.dart';
// import 'package:food_order_app/pages/main_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:prog24/adminPage.dart';
import 'package:prog24/constants.dart';
import 'package:prog24/instructorPage.dart';
import 'package:prog24/mainScreen.dart';
import 'package:prog24/models/api_error.dart';
import 'package:prog24/models/login_response.dart';



final box = GetStorage();
class LoginController extends GetxController {
  RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  set setLoading(bool newState){
    _isLoading.value = newState; 
  }

  void loginFunction (String data)  async {
    setLoading = true;

    Uri url = Uri.parse('$baseURL/api/Auth/login');
    Map<String, String>   headers = {'Content-type' : 'application/json', 'Authorization': 'Bearer ${box.read("token")}'};
    try {
      print("$data  ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅");
      var response = await http.post(url,  headers: headers, body: data);
      if(response.statusCode == 200){
         LoginResponseModel data = loginResponseModelFromJson(response.body);
         String userData = jsonEncode(data);
         box.write("userData", userData);
         box.write("token", data.token);
         setLoading = false;
        Get.snackbar("Sikeres bejelentkezés", "Üdvözöllek ${data.name}",
        colorText: Colors.white, 
        backgroundColor: Colors.blue,);
        if(data.role == 2){
          Get.offAll(() => Mainscreen());
        } else if (data.role == 0){
          Get.offAll(() => AdminPage());
        }
        else{
          Get.offAll(() => InstructorPage());
        }
      }
      else{
        var error =apiErrorFromJson(response.body);
        Get.snackbar("Nem sikerült a bejelentkezés", error.details, colorText: Colors.white, 
        backgroundColor: Colors.redAccent,); //valami jobb szin
      }
    } catch (e) {
      print(e);
    }
  }

//   Future<void> fetchUserData(String token) async {
//   //Uri url = Uri.parse('$baseURL/api/users/');
//   Map<String, String> headers = {
//     'Content-type': 'application/json',
//     'Authorization': 'Bearer $token',
//   };

//   try {
//     var response = await http.get(url, headers: headers);
//     if (response.statusCode == 200) {
//       final jsonData = jsonDecode(response.body);

//       // állítsd be az Rx változót
//       firstSetup.value = jsonData['firstSetup'] ?? false;

//       // ha kell tárolni:
//       box.write("firstSetup", firstSetup.value);

//     } else {
//       print("fetchUserData error: ${response.body}");
//     }
//   } catch (e) {
//     print("fetchUserData exception: $e");
//   }
// }

}
