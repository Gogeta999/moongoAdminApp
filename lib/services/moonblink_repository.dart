import 'package:MoonGoAdmin/api/moonblink_api.dart';
import 'package:MoonGoAdmin/api/moonblink_dio.dart';
import 'package:MoonGoAdmin/models/login_model.dart';
import 'package:MoonGoAdmin/models/search_user_model.dart';
import 'package:MoonGoAdmin/models/user_model.dart';
import 'package:MoonGoAdmin/models/userlist_model.dart';
import 'package:MoonGoAdmin/models/wallet_model.dart';
import 'package:MoonGoAdmin/services/moongo_admin_database.dart';
import 'package:dio/dio.dart';

class MoonblinkRepository {
  static Future<LoginModel> login(Map<String, dynamic> data) async {
    FormData formData = FormData.fromMap(data);
    var response =
        await DioUtils().postwithData(Api.AdminLogin, data: formData);
    return LoginModel.fromJson(response.data);
  }

  static Future<List<SearchUserModel>> search(
      String query, int limit, int page) async {
    var response = await DioUtils().get(Api.SearchUser,
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

  //User List
  static Future userList(
    int limit,
    int page, {
    String isPending,
    String type,
  }) async {
    var response = await DioUtils().get(Api.Admin, queryParameters: {
      'type': type,
      'limit': limit,
      'page': page,
      'is_pending': isPending
    });

    return UsersList.fromJson(response.data);
  }

  static Future updateUserType(int userId, int type) async {
    var response = await DioUtils()
        .put(Api.UpdateUserType + '/$userId', queryParameters: {'type': type});
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
