class RegisterModel {
  final String name;
  final String neptunCode;
  final String password;
  final String cardId;

  RegisterModel({
    required this.name,
    required this.neptunCode,
    required this.password,
    required this.cardId, 
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "neptunCode": neptunCode,
        "password": password,
        "cardId": cardId,
      };
}