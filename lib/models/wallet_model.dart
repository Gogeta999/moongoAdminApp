class Wallet {
  int id;
  int userid;
  int value;
  int topUpCoin;
  int earningCoin;
  String createdat;
  String updatedat;
  // Wallet(this.id, this.userid, this.value, this.createdat, this.updatedat);

  Wallet.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userid = json['user_id'],
        value = json['value'],
        topUpCoin = json['topup_coin'],
        earningCoin = json['earning_coin'],
        createdat = json['created_at'],
        updatedat = json['updated_at'];
}
