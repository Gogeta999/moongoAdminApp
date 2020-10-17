import 'dart:async';
import 'package:MoonGoAdmin/models/userlist_model.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:MoonGoAdmin/ui/helper/filter_helper.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'userlist_event.dart';
import 'userlist_state.dart';

const int transactionLimit = 10;

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  UserListBloc(this._listKey, {this.isPending, this.filterByType})
      : super(UserListInit());
  final isPending;
  final filterByType;
  final GlobalKey<AnimatedListState> _listKey;
  // final Widget Function(BuildContext context, int index,
  //     Animation<double> animation, UserList data) buildUpdatedItem;

  @override
  Stream<Transition<UserListEvent, UserListState>> transformEvents(
      Stream<UserListEvent> events, transitionFn) {
    return super.transformEvents(
        events.debounceTime(const Duration(milliseconds: 500)), transitionFn);
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
      List<ListUser> data = [];
      try {
        data = await _fetchUserList(
            limit: transactionLimit,
            page: 1,
            isPending: isPending,
            type: filterByType);
        // print(data);
      } catch (_) {
        yield UserListNoData();
        return;
      }
      bool hasReachedMax = data.length < transactionLimit ? true : false;
      yield UserListSuccess(data: data, hasReachedMax: hasReachedMax, page: 1);
      for (int i = 0; i < data.length; i++) {
        await Future.delayed(Duration(milliseconds: 70));
        _listKey.currentState.insertItem(i);
      }
    }
    if (currentState is UserListSuccess) {
      final nextPage = currentState.page + 1;
      List<ListUser> data = [];
      try {
        data = await _fetchUserList(
            limit: transactionLimit,
            page: nextPage,
            isPending: isPending,
            type: filterByType);
      } catch (error) {
        yield UserListFail(error: error);
      }
      bool hasReachedMax = data.length < transactionLimit ? true : false;
      yield data.isEmpty
          ? currentState.copyWith(hasReachedMax: true)
          : UserListSuccess(
              data: currentState.data + data,
              hasReachedMax: hasReachedMax,
              page: nextPage);
      for (int i = currentState.data.length;
          i < (currentState.data + data).length;
          i++) {
        await Future.delayed(Duration(milliseconds: 70));
        _listKey.currentState.insertItem(i);
      }
      print(currentState);
    }
  }

  Stream<UserListState> _mapRefreshedToState(
      UserListState currentState) async* {
    List<ListUser> data = [];
    print('Refreshing');
    if (currentState is UserListSuccess) {
      for (int i = currentState.data.length - 1; i >= 0; --i) {
        await Future.delayed(Duration(milliseconds: 20));
        // _listKey.currentState.removeItem(i, (context, animation) {
        //   return buildRemovedItem(context, i, animation, currentState.data[i]);
        // } /*, duration: Duration(milliseconds: 70)*/);
      }
      currentState.data.clear();
    }
    try {
      data = await _fetchUserList(
          limit: transactionLimit,
          page: 1,
          isPending: isPending,
          type: filterByType);
    } catch (error) {
      yield UserListFail(error: error);
    }
    bool hasReachedMax = data.length < transactionLimit ? true : false;
    yield data.isEmpty
        ? UserListNoData()
        : UserListSuccess(data: data, hasReachedMax: hasReachedMax, page: 1);
    for (int i = 0; i < data.length; i++) {
      await Future.delayed(Duration(milliseconds: 70));
      _listKey.currentState.insertItem(i);
    }
  }

  Stream<UserListState> _mapUpdatedToState(UserListState currentState) async* {
    List<ListUser> data = [];
    print('Refreshing');
    if (currentState is UserListSuccess) {
      for (int i = currentState.data.length - 1; i >= 0; --i) {
        await Future.delayed(Duration(milliseconds: 20));
        // _listKey.currentState.removeItem(i, (context, animation) {
        //   return buildRemovedItem(context, i, animation, currentState.data[i]);
        // } /*, duration: Duration(milliseconds: 70)*/);
      }
      currentState.data.clear();
    }
    try {
      data = await _fetchUserList(
          limit: transactionLimit,
          page: 1,
          isPending: globalPending,
          type: filterByType);
    } catch (error) {
      yield UserListFail(error: error);
    }
    bool hasReachedMax = data.length < transactionLimit ? true : false;
    yield data.isEmpty
        ? UserListNoData()
        : UserListSuccess(data: data, hasReachedMax: hasReachedMax, page: 1);
    for (int i = 0; i < data.length; i++) {
      await Future.delayed(Duration(milliseconds: 70));
      _listKey.currentState.insertItem(i);
    }
  }

  bool _hasReachedMax(UserListState state) =>
      state is UserListSuccess && state.hasReachedMax;

  Future<List<ListUser>> _fetchUserList(
      {int isPending, int type, int limit, int page}) async {
    UsersList usersList = await MoonblinkRepository.userList(limit, page,
        isPending: isPending, type: type);
    return usersList.usersList;
  }
}
