import 'dart:convert';

import 'package:MoonGoAdmin/api/moonblink_api.dart';
import 'package:MoonGoAdmin/api/moonblink_dio.dart';
import 'package:MoonGoAdmin/models/login_model.dart';
import 'package:MoonGoAdmin/models/search_user_model.dart';
import 'package:MoonGoAdmin/services/moongo_admin_database.dart';
import 'package:MoonGoAdmin/ui/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

class MoonblinkRepository {
  static Future<LoginModel> login(Map<String, dynamic> data) async {
    FormData formData = FormData.fromMap(data);
    var response = await DioUtils().postwithData(Api.LOGIN, data: formData);
    return LoginModel.fromJson(response.data);
  }

  static Future<List<SearchUserModel>> search(
      String query, int limit, int page) async {
    var response = await DioUtils().get(Api.SearchUser,
        queryParameters: {'name': query, 'limit': limit, 'page': page});
    List<String> suggestions = [];
    List<SearchUserModel> searchUserModels = response.data['data']
        .map<SearchUserModel>((e) {
          var searchUserModel = SearchUserModel.fromJson(e);
          suggestions.add(searchUserModel.name);
      return searchUserModel;
    })
        .toList();
    MoonGoAdminDB().insertSuggestions(suggestions);
    return searchUserModels;
  }

}
