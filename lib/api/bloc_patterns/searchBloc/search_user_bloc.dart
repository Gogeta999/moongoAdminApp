import 'dart:async';

import 'package:MoonGoAdmin/global/storage_manager.dart';
import 'package:MoonGoAdmin/models/search_user_model.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:MoonGoAdmin/services/moongo_admin_database.dart';
import 'package:MoonGoAdmin/ui/utils/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

part 'search_user_event.dart';
part 'search_user_state.dart';

class SearchUserBloc extends Bloc<SearchUserEvent, SearchUserState> {
  SearchUserBloc() : super(SearchUserInitial());

  final int _initialSearchLimit = 20;
  final int _initialPage = 1;

  List<String> _searchHistories =
      StorageManager.sharedPreferences.getStringList(kSearchHistory) ?? [];
  bool _isFetching = false;

  @override
  Stream<Transition<SearchUserEvent, SearchUserState>> transformEvents(
      Stream<SearchUserEvent> events, transitionFn) {
    return super.transformEvents(
        events.debounceTime(const Duration(milliseconds: 500)), transitionFn);
  }

  @override
  Stream<SearchUserState> mapEventToState(
    SearchUserEvent event,
  ) async* {
    final currentState = state;
    if (event is SearchUserNotSearching) yield* _mapNotSearchingToState();
    if (event is SearchUserSearched)
      yield* _mapSearchedToState(currentState, event.query);
    if (event is SearchUserSearchedMore)
      yield* _mapSearchedMoreToState(currentState);
    if (event is SearchUserSuggestions) yield* _mapSuggestionsToState(event.query);
  }

  Stream<SearchUserState> _mapNotSearchingToState() async* {
    List<String> reversedSearchHistories = List.from(_searchHistories.reversed);
    yield SearchUserNotSearchingSuccess(reversedSearchHistories);
  }

  Stream<SearchUserState> _mapSearchedToState(
      SearchUserState state, String query) async* {
    _storeHistory(query);
    yield SearchUserInitial();
    try {
      List<SearchUserModel> data = await MoonblinkRepository.search(
          query, _initialSearchLimit, _initialPage);
      yield SearchUserSearchingSuccess(
          data, _initialPage, data.length < _initialSearchLimit, query);
    } catch (e) {
      MoonGoAdminDB().deleteSuggestion(query);
      yield SearchUserSearchingFailure(e);
    }
  }

  Stream<SearchUserState> _mapSearchedMoreToState(
      SearchUserState currentState) async* {
    if (currentState is SearchUserSearchingSuccess &&
        !currentState.hasReachedMax &&
        !_isFetching) {
      _isFetching = true;
      try {
        int nextPage = currentState.page + 1;
        String query = currentState.query;
        List<SearchUserModel> data = await MoonblinkRepository.search(
            query, _initialSearchLimit, nextPage);
        yield SearchUserSearchingSuccess(currentState.data + data, nextPage,
            data.length < _initialSearchLimit, query);
      } catch (e) {
        yield SearchUserSearchingSuccess(currentState.data, currentState.page,
            true, currentState.query);
      }
      _isFetching = false;
    }
  }

  Stream<SearchUserState> _mapSuggestionsToState(String like) async* {
    List<String> suggestions = await MoonGoAdminDB().retrieveSuggestions(like) ?? [];
    yield SearchUserSuggestionsSuccess(suggestions);
  }

  bool _hasReachedMax(SearchUserState state) =>
      state is SearchUserSearchingSuccess && state.hasReachedMax;

  _storeHistory(String query) {
    if (_searchHistories.contains(query)) {
      _searchHistories.remove(query);
      _searchHistories.add(query);
      if (_searchHistories.length > 15) _searchHistories.removeLast();
      StorageManager.sharedPreferences
          .setStringList(kSearchHistory, _searchHistories);
    } else {
      _searchHistories.add(query);
      if (_searchHistories.length > 15) _searchHistories.removeLast();
      StorageManager.sharedPreferences
          .setStringList(kSearchHistory, _searchHistories);
    }
  }
}
