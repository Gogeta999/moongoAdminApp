part of 'pending_post_bloc.dart';

abstract class PendingPostEvent extends Equatable {
  const PendingPostEvent();

  @override
  List<Object> get props => [];
}

class PendingPostFetched extends PendingPostEvent {}

class PendingPostUpdated extends PendingPostEvent {}

class PendingPostRefresh extends PendingPostEvent {}

class PendingPostRemoveUser extends PendingPostEvent {
  final int index;

  const PendingPostRemoveUser(this.index);

  @override
  List<Object> get props => [index];
}
