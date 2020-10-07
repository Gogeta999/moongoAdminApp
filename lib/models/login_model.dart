class LoginModel {
  final String tokenType;
  final String token;
  final String expiry;
  final int id;
  final String name;
  final String email;
  final int verify;
  final int type;
  final int status;
  final String profileImage;
  final String coverImage;
  final int gameProfileCount;

  LoginModel.fromJson(Map<String, dynamic> json)
    : tokenType = json['token_type'],
      token = json['token'],
      expiry = json['expiry'],
      id = json['id'],
      name = json['name'],
      email = json['email'],
      verify = json['verify'],
      type = json['type'],
      status = json['status'],
      profileImage = json['profile_image'],
      coverImage = json['cover_image'],
      gameProfileCount = json['game_profile_count'];
}