part of 'user_transactions_bloc.dart';

abstract class UserTransactionsState extends Equatable {
  const UserTransactionsState();
  
  @override
  List<Object> get props => [];
}

class UserTransactionsInitial extends UserTransactionsState {}
