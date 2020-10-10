import 'package:equatable/equatable.dart';

abstract class UserDetailEvent extends Equatable {
  const UserDetailEvent();

  @override
  List<Object> get props => [];
}

class UserDetailGet extends UserDetailEvent {
  final int id;
  const UserDetailGet({this.id});

  @override
  List<Object> get props => [];
}
