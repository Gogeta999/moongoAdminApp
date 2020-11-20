import 'dart:async';
import 'package:MoonGoAdmin/models/userlist_model.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:equatable/equatable.dart';

part 'pending_list_event.dart';
part 'pending_list_state.dart';

const int transactionLimit = 10;

class PendingListBloc extends Bloc<PendingListEvent, PendingListState> {
  PendingListBloc(this._listKey, this.buildRemovedItem)
      : super(PendingListInit());

  final genderSubject = BehaviorSubject.seeded('ALL');
  final userGenders = <String>['ALL', 'Male', 'Female'];
  final GlobalKey<AnimatedListState> _listKey;
  final Widget Function(BuildContext context, int index,
      Animation<double> animation, ListUser data) buildRemovedItem;

  void dispose() {
    genderSubject.close();
    this.close();
  }

  @override
  Stream<Transition<PendingListEvent, PendingListState>> transformEvents(
      Stream<PendingListEvent> events, transitionFn) {
    return super.transformEvents(
        events.debounceTime(const Duration(milliseconds: 500)), transitionFn);
  }

  @override
  Stream<PendingListState> mapEventToState(
    PendingListEvent event,
  ) async* {
    final currentState = state;
    if (event is PendingListFetched && !_hasReachedMax(currentState)) {
      yield* _mapFetchedToState(currentState);
    }
    if (event is PendingListRefresh) {
      yield* _mapRefreshedToState(currentState);
    }
    if (event is PendingListUpdated) {
      yield* _mapUpdatedToState(currentState);
    }
    if (event is PendingListRemoveUser)
      yield* _mapRemoveUserToState(currentState, event.index);
  }

  Stream<PendingListState> _mapFetchedToState(
      PendingListState currentState) async* {
    if (currentState is PendingListInit) {
      try {
        final gender = await genderSubject.first;
        UsersList data = await MoonblinkRepository.getPendingUserList(
            transactionLimit, 1, 1, gender);
        bool hasReachedMax =
            data.usersList.length < transactionLimit ? true : false;
        yield PendingListSuccess(
            data: data.usersList,
            totalCount: data.totalCount,
            hasReachedMax: hasReachedMax,
            page: 1);
        for (int i = 0; i < data.usersList.length; i++) {
          await Future.delayed(Duration(milliseconds: 70));
          _listKey.currentState.insertItem(i);
        }
      } catch (_) {
        yield PendingListFail();
      }
    }
    if (currentState is PendingListSuccess) {
      try {
        final nextPage = currentState.page + 1;
        final gender = await genderSubject.first;
        UsersList data = await MoonblinkRepository.getPendingUserList(
            transactionLimit, nextPage, 1, gender);
        bool hasReachedMax =
            data.usersList.length < transactionLimit ? true : false;
        yield data.usersList.isEmpty
            ? currentState.copyWith(hasReachedMax: true)
            : PendingListSuccess(
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
        yield currentState.copyWith();
      }
    }
  }

  Stream<PendingListState> _mapRefreshedToState(
      PendingListState currentState) async* {
    if (currentState is PendingListSuccess) {
      for (int i = currentState.data.length - 1; i >= 0; --i) {
        await Future.delayed(Duration(milliseconds: 10));
        _listKey.currentState.removeItem(i, (context, animation) {
          return buildRemovedItem(context, i, animation, currentState.data[i]);
        });
      }
    }
    try {
      final gender = await genderSubject.first;
      UsersList data = await MoonblinkRepository.getPendingUserList(
          transactionLimit, 1, 1, gender);
      bool hasReachedMax = data.usersList.length < transactionLimit;
      yield data.usersList.isEmpty
          ? PendingListSuccess(
              data: [],
              totalCount: data.totalCount,
              hasReachedMax: hasReachedMax,
              page: 1)
          : PendingListSuccess(
              data: data.usersList,
              totalCount: data.totalCount,
              hasReachedMax: hasReachedMax,
              page: 1);
      for (int i = 0; i < data.usersList.length; i++) {
        await Future.delayed(Duration(milliseconds: 70));
        _listKey.currentState.insertItem(i);
      }
    } catch (error) {
      yield PendingListFail(error: error);
    }
  }

  Stream<PendingListState> _mapUpdatedToState(
      PendingListState currentState) async* {
    if (currentState is PendingListSuccess) {
      for (int i = currentState.data.length - 1; i >= 0; --i) {
        await Future.delayed(Duration(milliseconds: 10));
        _listKey.currentState.removeItem(i, (context, animation) {
          return buildRemovedItem(context, i, animation, currentState.data[i]);
        });
      }
    }
    try {
      final gender = await genderSubject.first;
      UsersList data = await MoonblinkRepository.getPendingUserList(
          transactionLimit, 1, 1, gender);
      bool hasReachedMax = data.usersList.length < transactionLimit;
      yield data.usersList.isEmpty
          ? PendingListSuccess(
              data: [],
              totalCount: data.totalCount,
              hasReachedMax: hasReachedMax,
              page: 1)
          : PendingListSuccess(
              data: data.usersList,
              totalCount: data.totalCount,
              hasReachedMax: hasReachedMax,
              page: 1);
      for (int i = 0; i < data.usersList.length; i++) {
        await Future.delayed(Duration(milliseconds: 70));
        _listKey.currentState.insertItem(i);
      }
    } catch (error) {
      yield PendingListFail(error: error);
    }
  }

  Stream<PendingListState> _mapRemoveUserToState(
      PendingListState currentState, int index) async* {
    if (currentState is PendingListSuccess) {
      List<ListUser> data = List.from(currentState.data);
      _listKey.currentState.removeItem(index, (context, animation) {
        return buildRemovedItem(
            context, index, animation, currentState.data[index]);
      });
      data.removeAt(index);
      yield PendingListSuccess(
          data: data,
          hasReachedMax: currentState.hasReachedMax,
          page: currentState.page);
    }
  }

  bool _hasReachedMax(PendingListState state) =>
      state is PendingListSuccess && state.hasReachedMax;
}
