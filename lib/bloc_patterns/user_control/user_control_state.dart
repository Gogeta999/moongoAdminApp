part of 'user_control_bloc.dart';

abstract class UserControlState extends Equatable {
  const UserControlState();
}

class UserControlInitial extends UserControlState {
  @override
  List<Object> get props => [];
}

class UserControlFetchedSuccess extends UserControlState {
  final User data;

  const UserControlFetchedSuccess(this.data);

  @override
  List<Object> get props => [data];
}

class UserControlFetchedFailure extends UserControlState {
  final error;

  const UserControlFetchedFailure(this.error);

  @override
  List<Object> get props => [error];
}

class UserControlChangePartnerTypeSuccess extends UserControlState {
  @override
  List<Object> get props => [];
}

class UserControlChangePartnerTypeFailure extends UserControlState {
  final error;

  const UserControlChangePartnerTypeFailure(this.error);

  @override
  List<Object> get props => [error];
}