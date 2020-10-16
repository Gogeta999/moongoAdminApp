import 'package:equatable/equatable.dart';

abstract class UserListEvent extends Equatable {
  const UserListEvent();

  @override
  List<Object> get props => [];
}

class UserListFetched extends UserListEvent {}

class UserListRefresh extends UserListEvent {}
