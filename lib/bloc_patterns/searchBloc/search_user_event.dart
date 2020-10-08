part of 'search_user_bloc.dart';

abstract class SearchUserEvent extends Equatable {
  const SearchUserEvent();
}

class SearchUserNotSearching extends SearchUserEvent {
  @override
  List<Object> get props => [];
}

class SearchUserSearched extends SearchUserEvent {
  final String query;

  const SearchUserSearched(this.query);

  @override
  List<Object> get props => [];
}

class SearchUserSearchedMore extends SearchUserEvent {
  @override
  List<Object> get props => [];
}