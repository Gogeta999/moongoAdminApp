class LoginModel {
  final String tokenType;
  final String token;
  final String expiry;
  final int id;
  final String name;
  final String email;
  final int type;
  final String profileImage;
  final String coverImage;

  LoginModel.fromJson(Map<String, dynamic> json)
      : tokenType = json['token_type'],
        token = json['token'],
        expiry = json['expiry'],
        id = json['id'],
        name = json['name'],
        email = json['email'],
        type = json['type'],
        profileImage = json['profile_image'],
        coverImage = json['cover_image'];
}
