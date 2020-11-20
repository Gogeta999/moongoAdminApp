import 'package:equatable/equatable.dart';

abstract class UserListEvent extends Equatable {
  const UserListEvent();
}

class UserListFetched extends UserListEvent {
  @override
  List<Object> get props => [];
}

class UserListUpdated extends UserListEvent {
  @override
  List<Object> get props => [];
}

class UserListRefresh extends UserListEvent {
  @override
  List<Object> get props => [];
}
