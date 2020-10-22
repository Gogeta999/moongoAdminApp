import 'package:MoonGoAdmin/models/user_model.dart';
import 'package:equatable/equatable.dart';

abstract class UserDetailState extends Equatable {
  const UserDetailState();

  @override
  List<Object> get props => [];
}

class UserDetailProgress extends UserDetailState {
  @override
  List<Object> get props => [];

  @override
  String toString() {
    return 'UserDetailProgress';
  }
}

class UserDetailSuccess extends UserDetailState {
  final User user;
  UserDetailSuccess(this.user);
  @override
  List<Object> get props => [user];

  @override
  String toString() {
    return 'UserDetailSuccess';
  }
}

class UserDetailFail extends UserDetailState {
  final error;

  const UserDetailFail(this.error);
  @override
  String toString() {
    return 'UserDetailFail';
  }
}
