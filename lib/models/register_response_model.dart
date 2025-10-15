class RegisterResponseModel {
  final String token;
  final String name;
  final int role;

  RegisterResponseModel({
    required this.token,
    required this.name,
    required this.role,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) =>
      RegisterResponseModel(
        token: json["token"],
        name: json["name"],
        role: json["role"],
      );
}