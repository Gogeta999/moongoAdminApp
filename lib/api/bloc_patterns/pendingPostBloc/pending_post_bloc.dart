import 'dart:async';
import 'package:MoonGoAdmin/models/post.dart';
import 'package:MoonGoAdmin/models/userlist_model.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:equatable/equatable.dart';

part 'pending_post_event.dart';
part 'pending_post_state.dart';

const int transactionLimit = 10;

class PendingPostBloc extends Bloc<PendingPostEvent, PendingPostState> {
  PendingPostBloc(this._listKey, this.buildRemovedItem)
      : super(PendingPostInit());
  final GlobalKey<AnimatedListState> _listKey;
  final Widget Function(BuildContext context, int index,
      Animation<double> animation, Post data) buildRemovedItem;

  void dispose() {
    this.close();
  }

  @override
  Stream<Transition<PendingPostEvent, PendingPostState>> transformEvents(
      Stream<PendingPostEvent> events, transitionFn) {
    return super.transformEvents(
        events.debounceTime(const Duration(milliseconds: 500)), transitionFn);
  }

  @override
  Stream<PendingPostState> mapEventToState(
    PendingPostEvent event,
  ) async* {
    final currentState = state;
    if (event is PendingPostFetched && !_hasReachedMax(currentState)) {
      yield* _mapFetchedToState(currentState);
    }
    if (event is PendingPostRefresh) {
      yield* _mapRefreshedToState(currentState);
    }
    if (event is PendingPostUpdated) {
      yield* _mapUpdatedToState(currentState);
    }
    if (event is PendingPostRemoveUser)
      yield* _mapRemoveUserToState(currentState, event.index);
  }

  Stream<PendingPostState> _mapFetchedToState(
      PendingPostState currentState) async* {
    if (currentState is PendingPostInit) {
      try {
        List<Post> data =
            await MoonblinkRepository.getAdminPosts(transactionLimit, 1);
        bool hasReachedMax = data.length < transactionLimit ? true : false;
        yield PendingPostSuccess(
            data: data,
            totalCount: data.length,
            hasReachedMax: hasReachedMax,
            page: 1);
        for (int i = 0; i < data.length; i++) {
          await Future.delayed(Duration(milliseconds: 70));
          _listKey.currentState.insertItem(i);
        }
      } catch (_) {
        yield PendingPostFail();
      }
    }
    if (currentState is PendingPostSuccess) {
      try {
        final nextPage = currentState.page + 1;
        List<Post> data =
            await MoonblinkRepository.getAdminPosts(transactionLimit, nextPage);
        bool hasReachedMax = data.length < transactionLimit ? true : false;
        yield data.isEmpty
            ? currentState.copyWith(hasReachedMax: true)
            : PendingPostSuccess(
                data: currentState.data + data,
                totalCount: data.length,
                hasReachedMax: hasReachedMax,
                page: nextPage);
        for (int i = currentState.data.length;
            i < (currentState.data + data).length;
            i++) {
          await Future.delayed(Duration(milliseconds: 70));
          _listKey.currentState.insertItem(i);
        }
      } catch (error) {
        yield currentState.copyWith();
      }
    }
  }

  Stream<PendingPostState> _mapRefreshedToState(
      PendingPostState currentState) async* {
    if (currentState is PendingPostSuccess) {
      for (int i = currentState.data.length - 1; i >= 0; --i) {
        await Future.delayed(Duration(milliseconds: 10));
        _listKey.currentState.removeItem(i, (context, animation) {
          return buildRemovedItem(context, i, animation, currentState.data[i]);
        });
      }
    }
    try {
      List<Post> data =
          await MoonblinkRepository.getAdminPosts(transactionLimit, 1);
      bool hasReachedMax = data.length < transactionLimit;
      yield data.isEmpty
          ? PendingPostSuccess(
              data: [],
              totalCount: data.length,
              hasReachedMax: hasReachedMax,
              page: 1)
          : PendingPostSuccess(
              data: data,
              totalCount: data.length,
              hasReachedMax: hasReachedMax,
              page: 1);
      for (int i = 0; i < data.length; i++) {
        await Future.delayed(Duration(milliseconds: 70));
        _listKey.currentState.insertItem(i);
      }
    } catch (error) {
      yield PendingPostFail(error: error);
    }
  }

  Stream<PendingPostState> _mapUpdatedToState(
      PendingPostState currentState) async* {
    if (currentState is PendingPostSuccess) {
      for (int i = currentState.data.length - 1; i >= 0; --i) {
        await Future.delayed(Duration(milliseconds: 10));
        _listKey.currentState.removeItem(i, (context, animation) {
          return buildRemovedItem(context, i, animation, currentState.data[i]);
        });
      }
    }
    try {
      List<Post> data =
          await MoonblinkRepository.getAdminPosts(transactionLimit, 1);
      bool hasReachedMax = data.length < transactionLimit;
      yield data.isEmpty
          ? PendingPostSuccess(
              data: [],
              totalCount: data.length,
              hasReachedMax: hasReachedMax,
              page: 1)
          : PendingPostSuccess(
              data: data,
              totalCount: data.length,
              hasReachedMax: hasReachedMax,
              page: 1);
      for (int i = 0; i < data.length; i++) {
        await Future.delayed(Duration(milliseconds: 70));
        _listKey.currentState.insertItem(i);
      }
    } catch (error) {
      yield PendingPostFail(error: error);
    }
  }

  Stream<PendingPostState> _mapRemoveUserToState(
      PendingPostState currentState, int index) async* {
    if (currentState is PendingPostSuccess) {
      List<Post> data = List.from(currentState.data);
      _listKey.currentState.removeItem(index, (context, animation) {
        return buildRemovedItem(
            context, index, animation, currentState.data[index]);
      });
      data.removeAt(index);
      yield PendingPostSuccess(
          data: data,
          hasReachedMax: currentState.hasReachedMax,
          page: currentState.page);
    }
  }

  bool _hasReachedMax(PendingPostState state) =>
      state is PendingPostSuccess && state.hasReachedMax;
}
