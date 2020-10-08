import 'package:MoonGoAdmin/api/moonblink_api.dart';
import 'package:MoonGoAdmin/api/moonblink_dio.dart';
import 'package:MoonGoAdmin/models/login_model.dart';
import 'package:MoonGoAdmin/models/search_user_model.dart';
import 'package:dio/dio.dart';

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
    return response.data['data']
        .map<SearchUserModel>((e) => SearchUserModel.fromJson(e))
        .toList();
  }
}
