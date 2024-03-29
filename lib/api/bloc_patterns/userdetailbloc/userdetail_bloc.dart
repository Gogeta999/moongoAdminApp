import 'dart:async';

import 'package:MoonGoAdmin/api/bloc_patterns/userdetailbloc/userdetail_event.dart';
import 'package:MoonGoAdmin/api/bloc_patterns/userdetailbloc/userdetail_state.dart';
import 'package:MoonGoAdmin/models/user_model.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:bloc/bloc.dart';

class UserDetailBloc extends Bloc<UserDetailEvent, UserDetailState> {
  // final int id;
  UserDetailBloc() : super(UserDetailProgress());

  @override
  Stream<UserDetailState> mapEventToState(UserDetailEvent event) async* {
    final currentState = state;
    print(currentState);
    if (event is UserDetailGet) yield* getUserDetail(currentState, event);
  }

  Stream<UserDetailState> getUserDetail(
      UserDetailState state, UserDetailGet event) async* {
    print('Getting User Data');
    // yield UserDetailProgress();
    try {
      print(event.id);
      User user = await MoonblinkRepository.userdetail(event.id);
      yield UserDetailSuccess(user);
    } catch (e) {
      print(e);
      yield UserDetailFail(e);
    }
    print(state);
  }
}
