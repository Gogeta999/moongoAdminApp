import 'package:MoonGoAdmin/api/moonblink_api.dart';
import 'package:MoonGoAdmin/api/moonblink_dio.dart';
import 'package:MoonGoAdmin/global/storage_manager.dart';
import 'package:MoonGoAdmin/models/login_model.dart';
import 'package:MoonGoAdmin/models/payment.dart';
import 'package:MoonGoAdmin/models/search_user_model.dart';
import 'package:MoonGoAdmin/models/transaction.dart';
import 'package:MoonGoAdmin/models/user_model.dart';
import 'package:MoonGoAdmin/models/userlist_model.dart';
import 'package:MoonGoAdmin/models/wallet_model.dart';
import 'package:MoonGoAdmin/models/warrior_model.dart';
import 'package:MoonGoAdmin/services/moongo_admin_database.dart';
import 'package:MoonGoAdmin/ui/utils/constants.dart';
import 'package:dio/dio.dart';

class MoonblinkRepository {
  static Future<LoginModel> login(Map<String, dynamic> data) async {
    FormData formData = FormData.fromMap(data);
    var response =
        await DioUtils().postwithData(Api.AdminLogin, data: formData);
    return LoginModel.fromJson(response.data);
  }

  static Future<LoginModel> normalLogin(Map<String, dynamic> data) async {
    FormData formData = FormData.fromMap(data);
    var response = await DioUtils().postwithData(Api.LOGIN, data: formData);
    return LoginModel.fromJson(response.data);
  }

  ///user wallet
  static Future<Wallet> getUserWallet() async {
    var userId = StorageManager.sharedPreferences.getInt(kUserId);
    var response = await DioUtils().get(Api.UserWallet + '$userId');
    return Wallet.fromJson(response.data['wallet']);
  }

  static Future<List<Warrior>> getWarriorPartners(int limit, int page) async {
    final userId = StorageManager.sharedPreferences.getInt(kUserId);
    final response = await DioUtils().get(
        'moonblink/api/v1/agency/$userId/user',
        queryParameters: {'limit': limit, 'page': page});
    return response.data['data'].map<Warrior>((e) {
      final warrior = Warrior.fromJson(e);
      warrior.totalCount = response.data['total_count'];
      return warrior;
    }).toList();
  }

  static Future<List<SearchUserModel>> search(
      String query, int limit, int page) async {
    var response = await DioUtils().get(Api.SearchWarrior,
        queryParameters: {'name': query, 'limit': limit, 'page': page});
    List<String> suggestions = [];
    List<int> idList = [];
    List<SearchUserModel> searchUserModels =
        response.data['data'].map<SearchUserModel>((e) {
      var searchUserModel = SearchUserModel.fromJson(e);
      suggestions.add(searchUserModel.name);
      idList.add(searchUserModel.id);
      return searchUserModel;
    }).toList();
    MoonGoAdminDB().insertSuggestions(suggestions, idList);
    return searchUserModels;
  }

  static Future<UsersList> getUserList(
      int limit, int page, int type, String gender) async {
    var response = await DioUtils().get(Api.Admin, queryParameters: {
      'gender': gender,
      'type': type,
      'limit': limit,
      'page': page,
    });
    return UsersList.fromJson(response.data);
  }

  static Future<UsersList> getPendingUserList(
      int limit, int page, int pending, String gender) async {
    var response = await DioUtils().get(Api.Admin, queryParameters: {
      'gender': gender,
      'is_pending': pending,
      'limit': limit,
      'page': page,
    });
    return UsersList.fromJson(response.data);
  }

  static Future<List<Transaction>> getUserTransactionList(String startDate,
      String endDate, String type, int userId, int limit, int page) async {
    String fType = type == 'topup' ? 'top_up' : type;
    final response =
        await DioUtils().get(Api.AdminTransaction, queryParameters: {
      'start_date': startDate,
      'end_date': endDate,
      'type': fType,
      'user_id': userId,
      'limit': limit,
      'page': page,
    });
    return response.data['data']
        .map<Transaction>((e) => Transaction.fromJson(e))
        .toList();
  }

  static Future<List<Transaction>> getAllTransactionList(String startDate,
      String endDate, String type, int limit, int page) async {
    String fType = type == 'topup' ? 'top_up' : type;
    final response =
        await DioUtils().get(Api.AdminTransaction, queryParameters: {
      'start_date': startDate,
      'end_date': endDate,
      'type': fType,
      'limit': limit,
      'page': page,
    });
    return response.data['data']
        .map<Transaction>((e) => Transaction.fromJson(e))
        .toList();
  }

  static Future updateUserType(int userId, int type) async {
    var response = await DioUtils()
        .put(Api.UpdateUserType + '/$userId', queryParameters: {'type': type});
    return response.data;
  }

  static Future rejectPendingUser(int userId, String comment) async {
    var response = await DioUtils().put(Api.UpdateUserType + '/$userId',
        queryParameters: {'type_status': 1, 'fcm_message': comment});
    return response.data;
  }

  ///map with topUp, productId
  static Future<Wallet> topUpUserCoin(
      int userId, Map<String, dynamic> map) async {
    FormData formData = FormData.fromMap(map);
    var response = await DioUtils()
        .postwithData(Api.UpdateUserCoin + '/$userId/topup', data: formData);
    return Wallet.fromJson(response.data);
  }

  static Future<Wallet> withdrawUserCoin(
      int userId, Map<String, dynamic> map) async {
    FormData formData = FormData.fromMap(map);
    var response = await DioUtils()
        .postwithData(Api.UpdateUserCoin + '/$userId/topup', data: formData);
    return Wallet.fromJson(response.data);
  }

  //User Detail
  static Future<User> userdetail(int userid) async {
    print(userid);
    var response = await DioUtils().get(Api.Admindetail + userid.toString());
    return User.fromJson(response.data);
  }

  //get payments
  static Future<List<Payment>> getPayments(
      String endDate, String startDate, int status, int limit, int page) async {
    final response = await DioUtils()
        .get("moonblink/api/v1/admin/payment", queryParameters: {
      'end_date': endDate,
      'start_date': startDate,
      'status': status,
      'limit': limit,
      'page': page
    });
    return response.data['data']
        .map<Payment>((e) => Payment.fromJson(e))
        .toList();
  }

  static Future<Payment> changePaymentStatus(
      int paymentId, String note, int status, String mbCoin) async {
    final response = await DioUtils().put(
        "moonblink/api/v1/admin/payment/$paymentId",
        queryParameters: {'verify': status, 'note': note, 'mb_coin': mbCoin});
    return Payment.fromJson(response.data);
  }

  static Future updateUserVip(int userId, int vip) async {
    final formData = FormData.fromMap({'type': 5, 'vip': vip});
    final response = await DioUtils().postwithData(
        "/moonblink/api/v1/admin/users/$userId/update",
        data: formData);
    return response;
  }

  // //User List
  // static Future<List<UsersList>> userlistOld(int limit, int page) async {
  //   var response = await DioUtils().get(Api.Adminuserlist);
  //   List<UsersList> userlist = response.data['data'].map<UsersList>((e) {
  //     var users = UsersList.fromJson(e);
  //     return users;
  //   }).toList();
  //   print("List Success");
  //   print(userlist.length);
  //   return userlist;
  // }
}
