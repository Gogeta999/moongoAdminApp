class Post {
  final int id;
  final int userid;
  final String body;
  final List media;
  final int status;
  final int isapproved;
  final Profile profile;
  final String createdAt;
  final String updatedAt;

  Post({
    this.id,
    this.userid,
    this.body,
    this.media,
    this.status,
    this.isapproved,
    this.profile,
    this.createdAt,
    this.updatedAt,
  });

  Post.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userid = json['user_id'],
        body = json['body'],
        media = json['media'],
        status = json['status'],
        isapproved = json['is_approved'],
        profile = Profile.fromJson(json['user']),
        createdAt = json['created_at'],
        updatedAt = json['updated_at'];

  @override
  List<Object> get props => [id];
}

class Profile {
  int userid;
  String username;
  String profileimage;

  Profile({
    this.userid,
    this.username,
    this.profileimage,
  });

  factory Profile.fromJson(Map<String, dynamic> map) {
    return Profile(
      userid: map['id'],
      username: map['name'],
      profileimage: map['profile_image'],
    );
  }
}
