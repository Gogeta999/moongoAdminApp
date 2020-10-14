import 'dart:async';
import 'package:MoonGoAdmin/models/userlist_model.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'userlist_event.dart';
import 'userlist_state.dart';

const int transactionLimit = 10;

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  UserListBloc() : super(UserListInit());

  // final GlobalKey<AnimatedListState> _listKey;
  // final Widget Function(BuildContext context, int index,
  //     Animation<double> animation, UserList data) buildRemovedItem;

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
    if (event is UserListfetched && !_hasReachedMax(currentState)) {
      yield* _mapFetchedToState(currentState);
    }
    if (event is UserListrefresh) {
      yield* _mapRefreshedToState(currentState);
    }
    // if (event is UserListremoved) {
    //   yield* _mapRemoveToState(currentState, event.index);
    // }
  }

  Stream<UserListState> _mapFetchedToState(UserListState currentState) async* {
    if (currentState is UserListInit) {
      List<UserList> data = [];
      try {
        data = await _fetchUserList(limit: transactionLimit, page: 1);
        print(data);
      } catch (_) {
        yield UserListNoData();
        return;
      }
      bool hasReachedMax = data.length < transactionLimit ? true : false;
      yield UserListSuccess(data: data, hasReachedMax: hasReachedMax, page: 1);
      // for (int i = 0; i < data.length; i++) {
      //   await Future.delayed(Duration(milliseconds: 70));
      //   _listKey.currentState.insertItem(i);
      // }
    }
    if (currentState is UserListSuccess) {
      final nextPage = currentState.page + 1;
      List<UserList> data = [];
      try {
        data = await _fetchUserList(limit: transactionLimit, page: nextPage);
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
      // for (int i = currentState.data.length;
      //     i < (currentState.data + data).length;
      //     i++) {
      //   await Future.delayed(Duration(milliseconds: 70));
      //   _listKey.currentState.insertItem(i);
      // }
    }

    print(currentState);
  }

  Stream<UserListState> _mapRefreshedToState(
      UserListState currentState) async* {
    List<UserList> data = [];
    print('Refreshing');
    if (currentState is UserListSuccess) {
      for (int i = currentState.data.length - 1; i >= 0; --i) {
        await Future.delayed(Duration(milliseconds: 20));
        // _listKey.currentState.removeItem(i, (context, animation) {
        //   return buildRemovedItem(context, i, animation, currentState.data[i]);
        // } /*, duration: Duration(milliseconds: 70)*/);
      }
      //currentState.data.clear();
    }
    try {
      data = await _fetchUserList(limit: transactionLimit, page: 1);
    } catch (error) {
      yield UserListFail(error: error);
    }
    bool hasReachedMax = data.length < transactionLimit ? true : false;
    yield data.isEmpty
        ? UserListNoData()
        : UserListSuccess(data: data, hasReachedMax: hasReachedMax, page: 1);
    // for (int i = 0; i < data.length; i++) {
    //   await Future.delayed(Duration(milliseconds: 70));
    //   _listKey.currentState.insertItem(i);
    // }
  }

  bool _hasReachedMax(UserListState state) =>
      state is UserListSuccess && state.hasReachedMax;

  Future<List<UserList>> _fetchUserList({int limit, int page}) async {
    List<UserList> blockedUsersList =
        await MoonblinkRepository.userlist(limit, page);
    return blockedUsersList;
  }
}
