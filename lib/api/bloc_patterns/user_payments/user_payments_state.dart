part of 'user_payments_bloc.dart';

abstract class UserPaymentsState extends Equatable {
  const UserPaymentsState();

  @override
  List<Object> get props => [];
}

class UserPaymentssInitial extends UserPaymentsState {}
