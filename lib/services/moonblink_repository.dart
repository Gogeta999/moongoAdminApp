import 'package:MoonGoAdmin/api/moonblink_api.dart';
import 'package:MoonGoAdmin/api/moonblink_dio.dart';
import 'package:MoonGoAdmin/models/login_model.dart';
import 'package:MoonGoAdmin/models/search_user_model.dart';
import 'package:MoonGoAdmin/models/user_model.dart';
import 'package:MoonGoAdmin/models/userlist_model.dart';
import 'package:MoonGoAdmin/services/moongo_admin_database.dart';
import 'package:dio/dio.dart';

class MoonblinkRepository {
  static Future<LoginModel> login(Map<String, dynamic> data) async {
    FormData formData = FormData.fromMap(data);
    var response = await DioUtils().postwithData(Api.AdminLogin, data: formData);
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
  static Future<List<UserList>> userList(
    int limit,
    int page, {
    int isPending,
    int type,
  }) async {
    var response = await DioUtils().get(Api.Admin, queryParameters: {
      'user_type': type,
      'limit': limit,
      'page': page,
      'is_pending': isPending
    });
    List<UserList> userlist = response.data['data'].map<UserList>((e) {
      var users = UserList.fromJson(e);
      return users;
    }).toList();
    print("List Success");
    print(userlist.length);
    return userlist;
  }

  static Future updateUserType(int userId, int type) async {
    var response = await DioUtils()
        .put(Api.UpdateUserType + '/$userId', queryParameters: {'type': type});
    return response.data;
  }

  //User Detail
  static Future<User> userdetail(int userid) async {
    print(userid);
    var response = await DioUtils().get(Api.Admindetail + userid.toString());
    return User.fromJson(response.data);
  }

  //User List
  static Future<List<UserList>> userlistOld(int limit, int page) async {
    var response = await DioUtils().get(Api.Adminuserlist);
    List<UserList> userlist = response.data['data'].map<UserList>((e) {
      var users = UserList.fromJson(e);
      return users;
    }).toList();
    print("List Success");
    print(userlist.length);
    return userlist;
  }
}
