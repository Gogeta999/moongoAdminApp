import 'package:MoonGoAdmin/models/wallet_model.dart';

class User {
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
  Wallet wallet;
  int followercount;
  int followingcount;
  double rating;
  Profile profile;
  Coin coin;

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        lastname = json['last_name'],
        email = json['email'],
        verified = json['verifited'],
        verifiedat = json['verified_at'],
        type = json['type'],
        status = json['status'],
        createdat = json['created_at'],
        updatedat = json['updated_at'],
        wallet = Wallet.fromJson(json['wallet']),
        followercount = json['follower_count'],
        followingcount = json['following_count'],
        rating = json['rating'],
        profile = Profile.fromJson(json['profile']),
        coin = Coin.fromJson(json['coin']);
}

class Profile {
  int id;
  int userid;
  String phone;
  String mail;
  String address;
  String profileimage;
  String coverimage;
  String dob;
  String gender;
  String nrc;
  String bios;
  String createdat;
  String updatedat;

  Profile.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userid = json['user_id'],
        phone = json['phone'],
        mail = json['mail'],
        address = json['address'],
        profileimage = json['profile_image'],
        coverimage = json['cover_image'],
        dob = json['dob'],
        gender = json['gender'],
        nrc = json['nrc'],
        bios = json['bios'],
        createdat = json['created_at'],
        updatedat = json['updated_at'];
}

class Coin {
  int id;
  int userid;
  int value;
  String createdat;
  String updatedat;

  Coin.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userid = json['user_id'],
        value = json['value'],
        createdat = json['created_at'],
        updatedat = json['updated_at'];
}