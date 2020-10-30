import 'package:MoonGoAdmin/models/user_model.dart';

class UsersList {
  final List<ListUser> usersList;
  final int totalCount;
  UsersList({this.usersList, this.totalCount});
  factory UsersList.fromJson(Map<String, dynamic> json) {
    List<dynamic> dataJson = json['data'];
    int total = json['total_count'];
    List<ListUser> usersList =
        dataJson.map((e) => ListUser.fromJson(e)).toList();

    return UsersList(usersList: usersList, totalCount: total);
  }

  @override
  String toString() =>
      'gameList: ${usersList[0].id} And TotalCount IS :$totalCount';
  // int id;
  // String name;
  // String lastname;
  // String email;
  // int verified;
  // String verifiedat;
  // int type;
  // int status;
  // String createdat;
  // String updatedat;
  // Profile profile;

  // UserList.fromJson(Map<String, dynamic> json)
  //     : id = json['id'],
  //       name = json['name'],
  //       lastname = json['last_name'],
  //       email = json['email'],
  //       verified = json['verified'],
  //       verifiedat = json['verified_at'],
  //       type = json['type'],
  //       status = json['status'],
  //       createdat = json['created_at'],
  //       updatedat = json['updated_at'],
  //       profile = Profile.fromJson(json['profile']);
}

class ListUser {
  int id;
  String name;
  String lastName;
  String email;
  int verified;
  String verifiedAt;
  int type;
  int status;
  String createdat;
  String updatedat;
  Profile profile;

  ListUser(
      {this.id,
      this.name,
      this.lastName,
      this.email,
      this.verified,
      this.verifiedAt,
      this.type,
      this.status,
      this.createdat,
      this.updatedat,
      this.profile});
  ListUser.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        lastName = json['last_name'],
        email = json['email'],
        verified = json['verified'],
        verifiedAt = json['verified_at'],
        type = json['type'],
        status = json['status'],
        createdat = json['created_at'],
        updatedat = json['updated_at'],
        profile = Profile.fromJson(json['profile']);
}
