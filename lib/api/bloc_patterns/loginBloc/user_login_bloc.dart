import 'dart:async';

import 'package:MoonGoAdmin/api/moonblink_dio.dart';
import 'package:MoonGoAdmin/global/storage_manager.dart';
import 'package:MoonGoAdmin/models/login_model.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:MoonGoAdmin/ui/utils/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'user_login_event.dart';
part 'user_login_state.dart';

class UserLoginBloc extends Bloc<UserLoginEvent, UserLoginState> {
  UserLoginBloc() : super(UserLoginInitial());

  @override
  Stream<UserLoginState> mapEventToState(
    UserLoginEvent event,
  ) async* {
    final currentState = state;
    if (event is UserLoginLogin) yield* _mapLoginToState(currentState, event);
  }

  Stream<UserLoginState> _mapLoginToState(
      UserLoginState state, UserLoginLogin event) async* {
    try {
      Map<String, dynamic> map = {
        'mail': event.mail,
        'password': event.password,
      };
      LoginModel _loginModel = await MoonblinkRepository.login(map);
      await StorageManager.sharedPreferences.setString(token, _loginModel.token);
      DioUtils().initWithAuthorization();
      yield UserLoginSuccess();
    } catch (e) {
      yield UserLoginFailure(e);
      yield UserLoginInitial();
    }
  }
}
