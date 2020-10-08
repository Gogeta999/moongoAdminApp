part of 'search_user_bloc.dart';

abstract class SearchUserState extends Equatable {
  const SearchUserState();
}

class SearchUserInitial extends SearchUserState {
  @override
  List<Object> get props => [];
}

class SearchUserNotSearchingSuccess extends SearchUserState {
  final List<String> histories;

  const SearchUserNotSearchingSuccess(this.histories);

  @override
  List<Object> get props => [histories];
}

class SearchUserSearchingFailure extends SearchUserState {
  final error;

  const SearchUserSearchingFailure(this.error);

  @override
  List<Object> get props => [];
}

class SearchUserSearchingSuccess extends SearchUserState {
  final List<SearchUserModel> data;
  final int page;
  final bool hasReachedMax;
  final String query;

  const SearchUserSearchingSuccess(
      this.data, this.page, this.hasReachedMax, this.query);

  @override
  List<Object> get props => [data, page, hasReachedMax, query];

  @override
  String toString() {
    return 'SearchUserSearchingSuccess, hasReachedMax - ${this.hasReachedMax}, page - ${this.page}';
  }
}

class SearchUserSuggestionsSuccess extends SearchUserState {
  final List<String> suggestions;

  const SearchUserSuggestionsSuccess(this.suggestions);

  @override
  List<Object> get props => [suggestions];

  @override
  String toString() {
    return 'SearchUserSuggestionsSuccess, suggestions count - ${this.suggestions.length}';
  }
}