import 'dart:async';

import 'package:MoonGoAdmin/models/user_model.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:MoonGoAdmin/ui/utils/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

part 'user_control_event.dart';
part 'user_control_state.dart';

enum ChangePartnerButtonState { initial, coPlayer, cele, streamer, pro }

class UserControlBloc extends Bloc<UserControlEvent, UserControlState> {
  final int userId;

  UserControlBloc(this.userId) : super(UserControlInitial());

  final BehaviorSubject<ChangePartnerButtonState> changePartnerButtonSubject =
      BehaviorSubject.seeded(ChangePartnerButtonState.initial);

  @override
  Stream<UserControlState> mapEventToState(
    UserControlEvent event,
  ) async* {
    if (event is UserControlFetched) yield* _mapFetchedToState();
    if (event is UserControlChangePartnerType) yield* _mapChangePartnerTypeToState(event.type);
  }

  Stream<UserControlState> _mapFetchedToState() async* {
    try {
      User data = await MoonblinkRepository.userdetail(userId);
      yield UserControlFetchedSuccess(data);
    } catch (e) {
      yield UserControlFetchedFailure(e);
    }
  }

  Stream<UserControlState>_mapChangePartnerTypeToState(int type) async* {
    var btnState = await changePartnerButtonSubject.first;
    if (btnState != ChangePartnerButtonState.initial) return;
    switch (type) {
      case kCoPlayer:
        changePartnerButtonSubject.add(ChangePartnerButtonState.coPlayer);
        yield* _changePartnerType(type);
        break;
      case kCele:
        changePartnerButtonSubject.add(ChangePartnerButtonState.cele);
        yield* _changePartnerType(type);
        break;
      case kStreamer:
        changePartnerButtonSubject.add(ChangePartnerButtonState.streamer);
        yield* _changePartnerType(type);
        break;
      case kPro:
        changePartnerButtonSubject.add(ChangePartnerButtonState.pro);
        yield* _changePartnerType(type);
        break;
    }
  }

  Stream<UserControlState> _changePartnerType(int type) async* {
    try {
      await MoonblinkRepository.updateUserType(userId, type);
      try {
        User data = await MoonblinkRepository.userdetail(userId);
        changePartnerButtonSubject.add(ChangePartnerButtonState.initial);
        yield UserControlFetchedSuccess(data);
      } catch (e) {
        changePartnerButtonSubject.add(ChangePartnerButtonState.initial);
        yield UserControlFetchedFailure(e);
      }
    } catch (e) {
      changePartnerButtonSubject.add(ChangePartnerButtonState.initial);
      yield UserControlChangePartnerTypeFailure(e);
    }
  }
}
