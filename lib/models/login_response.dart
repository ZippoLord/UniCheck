// To parse this JSON data, do
//
//     final loginResponseModel = loginResponseModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) => LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) => json.encode(data.toJson());

class LoginResponseModel {
    final String token;
    final String name;
    final int role;

    LoginResponseModel({
        required this.token,
        required this.name,
        required this.role,
    });

    factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
        token: json["token"],
        name: json["name"],
        role: json["role"],
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "name": name,
        "role": role,
    };
}
