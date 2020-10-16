class LoginModel {
  final String tokenType;
  final String token;
  final String expiry;

  LoginModel.fromJson(Map<String, dynamic> json)
    : tokenType = json['token_type'],
      token = json['token'],
      expiry = json['expiry'];
}