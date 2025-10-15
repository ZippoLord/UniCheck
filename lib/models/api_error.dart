// To parse this JSON data, do
//
//     final errorResponseModel = errorResponseModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ApiError apiErrorFromJson(String str) => ApiError.fromJson(json.decode(str));

String apiErrorFromJsonToJson(ApiError data) => json.encode(data.toJson());

class ApiError {
    final String error;
    final String details;
    final String stackTrace;

    ApiError({
        required this.error,
        required this.details,
        required this.stackTrace,
    });

    factory ApiError.fromJson(Map<String, dynamic> json) => ApiError(
        error: json["error"],
        details: json["details"],
        stackTrace: json["stackTrace"],
    );

    Map<String, dynamic> toJson() => {
        "error": error,
        "details": details,
        "stackTrace": stackTrace,
    };
}
