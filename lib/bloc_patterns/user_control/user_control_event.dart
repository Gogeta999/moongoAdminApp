part of 'user_control_bloc.dart';

abstract class UserControlEvent extends Equatable {
  const UserControlEvent();
}

class UserControlFetched extends UserControlEvent {
  @override
  List<Object> get props => throw UnimplementedError();
}

class UserControlChangePartnerType extends UserControlEvent {
  final int type;

  const UserControlChangePartnerType(this.type);

  @override
  List<Object> get props => [type];
}