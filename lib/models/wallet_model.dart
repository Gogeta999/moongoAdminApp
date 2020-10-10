class Wallet {
  int id;
  int userid;
  int value;
  String createdat;
  String updatedat;
  // Wallet(this.id, this.userid, this.value, this.createdat, this.updatedat);

  Wallet.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userid = json['user_id'],
        value = json['value'],
        createdat = json['created_at'],
        updatedat = json['updated_at'];
}
