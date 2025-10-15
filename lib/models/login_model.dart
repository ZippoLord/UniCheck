// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
    final String neptunCode;
    final String password;
    //final String passwordVerification;
    final String cardId;

    LoginModel({
        required this.neptunCode,
        required this.password,
        //required this.passwordVerification,
        required this.cardId,
    });

    factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        neptunCode: json["neptunCode"],
        password: json["password"],
        //passwordVerification: json["passwordVerification"],
        cardId: json["cardId"],
    );

    Map<String, dynamic> toJson() => {
        "neptunCode": neptunCode,
        "password": password,
        "cardId": cardId,
    };
}
