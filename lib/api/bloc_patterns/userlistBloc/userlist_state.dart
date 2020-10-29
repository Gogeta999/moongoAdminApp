import 'package:MoonGoAdmin/models/userlist_model.dart';
import 'package:equatable/equatable.dart';

abstract class UserListState extends Equatable {
  const UserListState();
}

class UserListInit extends UserListState {
  @override
  List<Object> get props => [];
}

class UserListFail extends UserListState {
  final error;

  const UserListFail({this.error});

  @override
  List<Object> get props => [error];
}

class UserListNoData extends UserListState {
  @override
  List<Object> get props => [];
}

class UserListSuccess extends UserListState {
  final List<ListUser> data;
  final int totalCount;
  final bool hasReachedMax;
  final int page;

  const UserListSuccess(
      {this.data, this.totalCount, this.hasReachedMax, this.page});

  UserListSuccess copyWith(
      {List<ListUser> data, int totalCount, bool hasReachedMax, int page}) {
    return UserListSuccess(
      data: data ?? this.data,
      totalCount: totalCount ?? this.totalCount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
    );
  }

  @override
  List<Object> get props => [data, totalCount, hasReachedMax, page];

  @override
  String toString() =>
      'BlockedUsersSuccess: ${data.length}, hasReachedMax: $hasReachedMax';
}
