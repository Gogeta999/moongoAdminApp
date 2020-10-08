part of 'user_login_bloc.dart';

abstract class UserLoginState extends Equatable {
  const UserLoginState();
}

class UserLoginInitial extends UserLoginState {
  @override
  List<Object> get props => [];

  @override
  String toString() {
    return 'UserLoginInitial';
  }
}

class UserLoginSuccess extends UserLoginState {
  @override
  List<Object> get props => [];

  @override
  String toString() {
    return 'UserLoginSuccess';
  }
}

class UserLoginFailure extends UserLoginState {
  final error;

  const UserLoginFailure(this.error);

  @override
  List<Object> get props => [];

  @override
  String toString() {
    return 'UserLoginFailure';
  }
}