part of 'user_control_bloc.dart';

abstract class UserControlEvent extends Equatable {
  const UserControlEvent();
}

class UserControlFetched extends UserControlEvent {
  @override
  List<Object> get props => [];
}

class UserControlChangePartnerType extends UserControlEvent {
  final int type;

  const UserControlChangePartnerType(this.type);

  @override
  List<Object> get props => [type];
}

class UserControlTopUpCoin extends UserControlEvent {
  @override
  List<Object> get props => [];
}

class UserControlWithdrawCoin extends UserControlEvent {
  @override
  List<Object> get props => [];
}

class UserControlAcceptUser extends UserControlEvent {
  @override
  List<Object> get props => [];
}

class UserControlRejectUser extends UserControlEvent {
  @override
  List<Object> get props => [];
}
