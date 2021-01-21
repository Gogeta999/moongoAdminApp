import 'dart:async';
import 'package:MoonGoAdmin/models/userlist_model.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';
import 'userlist_event.dart';
import 'userlist_state.dart';

const int transactionLimit = 10;

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  UserListBloc(this._listKey, this.buildRemovedItem) : super(UserListInit());

  final GlobalKey<AnimatedListState> _listKey;
  final Widget Function(BuildContext context, int index,
      Animation<double> animation, ListUser data) buildRemovedItem;

  final List<String> userTypes = <String>[
    'All', //-1,
    'Normal', //0
    'CoPlayer', //1
    'Streamer', //2
    'Cele', //3
    'Pro', //4
    'VIP', // 5
  ];

  final List<String> userGenders = <String>['', 'Male', 'Female'];

  final typeSubject = BehaviorSubject.seeded('All');
  final genderSubject = BehaviorSubject.seeded('');

  @override
  Stream<Transition<UserListEvent, UserListState>> transformEvents(
      Stream<UserListEvent> events, transitionFn) {
    return super.transformEvents(
        events.debounceTime(const Duration(milliseconds: 500)), transitionFn);
  }

  void dispose() {
    typeSubject.close();
    genderSubject.close();
    this.close();
  }

  @override
  Stream<UserListState> mapEventToState(
    UserListEvent event,
  ) async* {
    final currentState = state;
    if (event is UserListFetched && !_hasReachedMax(currentState)) {
      yield* _mapFetchedToState(currentState);
    }
    if (event is UserListRefresh) {
      yield* _mapRefreshedToState(currentState);
    }
    if (event is UserListUpdated) {
      yield* _mapUpdatedToState(currentState);
    }
  }

  Stream<UserListState> _mapFetchedToState(UserListState currentState) async* {
    if (currentState is UserListInit) {
      try {
        final type = _getType(await typeSubject.first);
        final gender = await genderSubject.first;
        print('Type: $type');
        print('Gender: $gender');
        UsersList data = await MoonblinkRepository.getUserList(
            transactionLimit, 1, type, gender);
        bool hasReachedMax = data.usersList.length < transactionLimit;
        yield UserListSuccess(
            data: data.usersList,
            totalCount: data.totalCount,
            hasReachedMax: hasReachedMax,
            page: 1);
        for (int i = 0; i < data.usersList.length; i++) {
          await Future.delayed(Duration(milliseconds: 70));
          _listKey.currentState.insertItem(i);
        }
      } catch (e) {
        yield UserListFail(error: e);
      }
    }
    if (currentState is UserListSuccess) {
      try {
        final nextPage = currentState.page + 1;
        final type = _getType(await typeSubject.first);
        final gender = await genderSubject.first;
        print('Type: $type');
        print('Gender: $gender');
        UsersList data = await MoonblinkRepository.getUserList(
            transactionLimit, nextPage, type, gender);
        print('Fetching More');
        bool hasReachedMax = data.usersList.length < transactionLimit;
        yield data.usersList.isEmpty
            ? currentState.copyWith(hasReachedMax: true)
            : UserListSuccess(
                data: currentState.data + data.usersList,
                totalCount: data.totalCount,
                hasReachedMax: hasReachedMax,
                page: nextPage);
        for (int i = currentState.data.length;
            i < (currentState.data + data.usersList).length;
            i++) {
          await Future.delayed(Duration(milliseconds: 70));
          _listKey.currentState.insertItem(i);
        }
      } catch (error) {
        showToast(error.toString());
        yield currentState.copyWith();
      }
    }
  }

  Stream<UserListState> _mapRefreshedToState(
      UserListState currentState) async* {
    if (currentState is UserListSuccess) {
      for (int i = currentState.data.length - 1; i >= 0; --i) {
        await Future.delayed(Duration(milliseconds: 10));
        _listKey.currentState.removeItem(i, (context, animation) {
          return buildRemovedItem(context, i, animation, currentState.data[i]);
        });
      }
    }
    try {
      final type = _getType(await typeSubject.first);
      final gender = await genderSubject.first;
      UsersList data = await MoonblinkRepository.getUserList(
          transactionLimit, 1, type, gender);
      bool hasReachedMax =
          data.usersList.length < transactionLimit ? true : false;
      yield data.usersList.isEmpty
          ? UserListSuccess(
              data: [],
              totalCount: data.totalCount,
              hasReachedMax: hasReachedMax,
              page: 1)
          : UserListSuccess(
              data: data.usersList,
              totalCount: data.totalCount,
              hasReachedMax: hasReachedMax,
              page: 1);
      for (int i = 0; i < data.usersList.length; i++) {
        await Future.delayed(Duration(milliseconds: 70));
        _listKey.currentState.insertItem(i);
      }
    } catch (error) {
      yield UserListFail(error: error);
    }
  }

  Stream<UserListState> _mapUpdatedToState(UserListState currentState) async* {
    if (currentState is UserListSuccess) {
      for (int i = currentState.data.length - 1; i >= 0; --i) {
        await Future.delayed(Duration(milliseconds: 10));
        _listKey.currentState.removeItem(i, (context, animation) {
          return buildRemovedItem(context, i, animation, currentState.data[i]);
        });
      }
    }
    try {
      final type = _getType(await typeSubject.first);
      final gender = await genderSubject.first;
      UsersList data = await MoonblinkRepository.getUserList(
          transactionLimit, 1, type, gender);
      bool hasReachedMax =
          data.usersList.length < transactionLimit ? true : false;
      yield data.usersList.isEmpty
          ? UserListSuccess(
              data: [],
              totalCount: data.totalCount,
              hasReachedMax: hasReachedMax,
              page: 1)
          : UserListSuccess(
              data: data.usersList,
              totalCount: data.totalCount,
              hasReachedMax: hasReachedMax,
              page: 1);
      for (int i = 0; i < data.usersList.length; i++) {
        await Future.delayed(Duration(milliseconds: 70));
        _listKey.currentState.insertItem(i);
      }
    } catch (error) {
      yield UserListFail(error: error);
    }
  }

  _getType(String type) {
    switch (type) {
      case 'All':
        return -1;
      case 'Normal':
        return 0;
      case 'CoPlayer':
        return 1;
      case 'Streamer':
        return 2;
      case 'Cele':
        return 3;
      case 'Pro':
        return 4;
      case 'VIP':
        return 5;
      default:
        return -1;
    }
  }

  bool _hasReachedMax(UserListState state) =>
      state is UserListSuccess && state.hasReachedMax;
}
