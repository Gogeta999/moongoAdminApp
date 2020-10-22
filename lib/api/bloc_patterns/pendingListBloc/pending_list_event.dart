part of 'pending_list_bloc.dart';

abstract class PendingListEvent extends Equatable {
  const PendingListEvent();

  @override
  List<Object> get props => [];
}

class PendingListFetched extends PendingListEvent {}

class PendingListUpdated extends PendingListEvent {}

class PendingListRefresh extends PendingListEvent {}

class PendingListRemoveUser extends PendingListEvent {
  final int index;

  const PendingListRemoveUser(this.index);

  @override
  List<Object> get props => [index];
}
