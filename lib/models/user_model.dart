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
  int vip;
  NRCProfile nrcProfile;
  Coin coin;
  int isPending;

  User.fromJson(Map<String, dynamic> json)
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
        wallet = Wallet.fromJson(json['wallet']),
        followercount = json['follower_count'],
        followingcount = json['following_count'],
        rating = json['rating'].toDouble(),
        profile = Profile.fromJson(json['profile']),
        vip = json['vip'] is String ? int.tryParse(json['vip']) : json['vip'],
        nrcProfile = json['profile_image'] != null
            ? NRCProfile.fromJson(json['profile_image'])
            : null,
        coin = Coin.fromJson(json['coin']),
        isPending = json['is_pending'];
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

class NRCProfile {
  int id;
  int userId;
  int profileId;
  String nrcFront;
  String nrcBack;
  String createdat;
  String updatedat;
  NRCProfile.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        profileId = json['profile_id'],
        nrcFront = json['nrc_front_image'],
        nrcBack = json['nrc_back_image'],
        createdat = json['created_at'],
        updatedat = json['updated_at'];
}

class Coin {
  int id;
  int userid;
  int value;
  int topUpCoin;
  int earningCoin;
  String createdat;
  String updatedat;

  Coin.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userid = json['user_id'],
        value = json['value'],
        topUpCoin = json['topup_coin'],
        earningCoin = json['earning_coin'],
        createdat = json['created_at'],
        updatedat = json['updated_at'];
}
