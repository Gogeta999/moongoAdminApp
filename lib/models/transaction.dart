class Transaction {
  final int id;
  final int userId;
  final String type;
  final int itemId;
  final int value;
  final int operation;
  final int bookingId;
  final String createdAt;
  final String updatedAt;
  final String createdBy;
  final TransactionUser user;

  Transaction.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        type = json['type'],
        itemId = json['item_id'],
        value = json['value'],
        operation = json['operation'],
        bookingId = json['booking_id'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        createdBy = json['created_by'],
        user = TransactionUser.fromJson((json['user']));
}

class TransactionUser {
  final int id;
  final String name;

  TransactionUser.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];
}
