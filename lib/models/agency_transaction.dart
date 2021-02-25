class AgencyTransaction {
  final int id;
  final int agentId;
  final int bookingId;
  final int boostServiceId;
  final int amount;
  final String createdAt;
  final String updatedAt;
  final Booking booking;
  //final BoostOrder boostOrder;
  ///Warrior
  final int warriorId;
  final String warriorName;
  final String warriorLastName;
  final String warriorEmail;
  final int warriorVerified;
  final String warriorVerifiedAt;
  final int warriorType;
  final int warriorStatus;
  final String warriorCreatedAt;
  final String warriorUpdatedAt;
  final String warriorProfileImage;

  AgencyTransaction.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        agentId = json['agent_id'],
        bookingId = json['booking_id'],
        boostServiceId = json['boost_service_id'],
        amount = json['amount'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        booking = Booking.fromJson(json['booking']),
        warriorId = json['warrior_id'],
        warriorName = json['warrior']['name'],
        warriorLastName = json['warrior']['last_name'],
        warriorEmail = json['warrior']['email'],
        warriorVerified = json['warrior']['verified'],
        warriorVerifiedAt = json['warrior']['verified_at'],
        warriorType = json['warrior']['type'],
        warriorStatus = json['warrior']['status'],
        warriorCreatedAt = json['warrior']['created_at'],
        warriorUpdatedAt = json['warrior']['updated_at'],
        warriorProfileImage = json['warrior']['profile_image'];
}

class Booking {
  final int id;
  final int userId;
  final int bookingUserId;
  final int gameType;
  final String startTime;
  final String endTime;
  final int status;
  final String createdAt;
  final String updatedAt;
  final int count;

  Booking.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        bookingUserId = json['booking_user_id'],
        gameType = json['game_type'],
        startTime = json['start_time'],
        endTime = json['end_time'],
        status = json['status'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        count = json['count'];
}

// class BoostOrder {

// }
