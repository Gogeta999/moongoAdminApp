class SearchWarriorModel {
  final int id;
  final String name;
  final String lastName;
  final String email;
  final int verified;
  final String verifiedAt;
  final int type;
  final int status;
  final String createdAt;
  final String updatedAt;
  final String profileImage;

  SearchWarriorModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        lastName = json['last_name'],
        email = json['email'],
        verified = json['verified'],
        verifiedAt = json['verified_at'],
        type = json['type'],
        status = json['status'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        profileImage = json['profile_image'];
}
