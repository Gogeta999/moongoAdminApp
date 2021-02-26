class Warrior {
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
  final int totalIncomeAmount;
  //under profile
  final String phone;
  final String address;
  final String profileImage;
  final String coverImage;
  final String dob;
  final String gender;
  final String nrc;
  final String bios;
  int totalCount = 0;

  Warrior.fromJson(Map<String, dynamic> json)
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
        totalIncomeAmount = json['total_income_amount'],
        phone = json['profile']['phone'],
        address = json['profile']['address'],
        profileImage = json['profile']['profile_image'],
        coverImage = json['profile']['cover_image'],
        dob = json['profile']['dob'],
        gender = json['profile']['gender'],
        nrc = json['profile']['nrc'],
        bios = json['profile']['bios'];
}
