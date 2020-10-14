import 'package:MoonGoAdmin/models/user_model.dart';

class UserList {
  int id;
  String name;
  String lastname;
  String email;
  int verified;
  String verifiedat;
  int type;
  int status;
  String createdat;
  String updatedat;
  Profile profile;

  UserList.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        lastname = json['last_name'],
        email = json['email'],
        verified = json['verified'],
        verifiedat = json['verified_at'],
        type = json['type'],
        status = json['status'],
        createdat = json['created_at'],
        updatedat = json['updated_at'],
        profile = Profile.fromJson(json['profile']);
}
