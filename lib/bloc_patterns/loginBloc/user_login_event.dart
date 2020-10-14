part of 'user_login_bloc.dart';

abstract class UserLoginEvent extends Equatable {
  const UserLoginEvent();
}

class UserLoginLogin extends UserLoginEvent {
  final String mail;
  final String password;
  final String token = "";
  final String fcmToken = "";

  const UserLoginLogin(this.mail, this.password);

  @override
  List<Object> get props => [];
}
