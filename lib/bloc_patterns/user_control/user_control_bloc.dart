import 'dart:async';

import 'package:MoonGoAdmin/models/user_model.dart';
import 'package:MoonGoAdmin/models/wallet_model.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:MoonGoAdmin/ui/utils/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

part 'user_control_event.dart';
part 'user_control_state.dart';

enum ChangePartnerButtonState { initial, coPlayer, cele, streamer, pro }

class UserControlBloc extends Bloc<UserControlEvent, UserControlState> {
  final int userId;
  UserControlBloc(this.userId) : super(UserControlInitial());

  final BehaviorSubject<ChangePartnerButtonState> changePartnerButtonSubject =
      BehaviorSubject.seeded(ChangePartnerButtonState.initial);

  final BehaviorSubject<bool> topUpSubject = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> withdrawSubject = BehaviorSubject.seeded(false);

  final BehaviorSubject<String> selectedProductSubject =
      BehaviorSubject.seeded('Select Product');
  final List<String> productList = <String>[
    'Select Product',
    '200 Coins',
    '500 Coins',
    '1000 Coins'
  ];

  final TextEditingController withdrawAmountController =
      TextEditingController();

  @override
  Stream<UserControlState> mapEventToState(
    UserControlEvent event,
  ) async* {
    final currentState = state;
    if (event is UserControlFetched) yield* _mapFetchedToState();
    if (event is UserControlChangePartnerType)
      yield* _mapChangePartnerTypeToState(event.type);
    if (event is UserControlTopUpCoin)
      yield* _mapTopUpCoinToState(currentState);
    if (event is UserControlWithdrawCoin)
      yield* _mapWithdrawCoinToState(currentState);
  }

  ///Event to state transformers
  Stream<UserControlState> _mapFetchedToState() async* {
    try {
      User data = await MoonblinkRepository.userdetail(userId);
      yield UserControlFetchedSuccess(data);
    } catch (e) {
      yield UserControlFetchedFailure(e);
    }
  }

  Stream<UserControlState> _mapChangePartnerTypeToState(int type) async* {
    var btnState = await changePartnerButtonSubject.first;
    if (btnState != ChangePartnerButtonState.initial) return;
    switch (type) {
      case kCoPlayer:
        changePartnerButtonSubject.add(ChangePartnerButtonState.coPlayer);
        yield* _changePartnerType(type);
        break;
      case kCele:
        changePartnerButtonSubject.add(ChangePartnerButtonState.cele);
        yield* _changePartnerType(type);
        break;
      case kStreamer:
        changePartnerButtonSubject.add(ChangePartnerButtonState.streamer);
        yield* _changePartnerType(type);
        break;
      case kPro:
        changePartnerButtonSubject.add(ChangePartnerButtonState.pro);
        yield* _changePartnerType(type);
        break;
    }
  }

  Stream<UserControlState> _mapTopUpCoinToState(
      UserControlState currentState) async* {
    topUpSubject.add(true);
    final productName = await selectedProductSubject.first;
    switch (productName) {
      case 'Select Product':
        if (currentState is UserControlFetchedSuccess) {
          yield UserControlTopUpFailure('Please select a product');
          yield UserControlFetchedSuccess(currentState.data);
          topUpSubject.add(false);
        }
        break;
      case '200 Coins':
        yield* _topUpCoin(currentState, kCoin200);
        break;
      case '500 Coins':
        yield* _topUpCoin(currentState, kCoin500);
        break;
      case '1000 Coins':
        yield* _topUpCoin(currentState, kCoin1000);
        break;
      default:
        print('Error TopUp DropDown');
        break;
    }
  }

  Stream<UserControlState> _mapWithdrawCoinToState(
      UserControlState currentState) async* {
    if (currentState is UserControlFetchedSuccess) {
      withdrawSubject.add(true);
      final amount = int.tryParse(withdrawAmountController.text);
      if (amount == null) {
        yield UserControlWithdrawFailure('Please type a valid amount');
        yield UserControlFetchedSuccess(currentState.data);
        withdrawSubject.add(false);
        return;
      }
      final map = {'withdraw': amount};
      try {
        Wallet wallet = await MoonblinkRepository.withdrawUserCoin(userId, map);
        User data = currentState.data;
        data.wallet = wallet;
        yield UserControlWithdrawSuccess();
        yield UserControlFetchedSuccess(data);
        withdrawAmountController.clear();
        withdrawSubject.add(false);
      } catch (e) {
        yield UserControlWithdrawFailure(e);
        withdrawSubject.add(false);
      }
    }
  }

  ///Private methods
  Stream<UserControlState> _changePartnerType(int type) async* {
    try {
      await MoonblinkRepository.updateUserType(userId, type);
      try {
        User data = await MoonblinkRepository.userdetail(userId);
        changePartnerButtonSubject.add(ChangePartnerButtonState.initial);
        yield UserControlFetchedSuccess(data);
      } catch (e) {
        changePartnerButtonSubject.add(ChangePartnerButtonState.initial);
        yield UserControlFetchedFailure(e);
      }
    } catch (e) {
      changePartnerButtonSubject.add(ChangePartnerButtonState.initial);
      yield UserControlChangePartnerTypeFailure(e);
    }
  }

  Stream<UserControlState> _topUpCoin(
      UserControlState currentState, String productId) async* {
    if (currentState is UserControlFetchedSuccess) {
      final map = {'topup': 1, 'product_id': productId};
      try {
        Wallet wallet = await MoonblinkRepository.topUpUserCoin(userId, map);
        yield UserControlTopUpSuccess();
        User data = currentState.data;
        data.wallet = wallet;
        yield UserControlFetchedSuccess(data);
        topUpSubject.add(false);
      } catch (e) {
        yield UserControlTopUpFailure(e);
        topUpSubject.add(false);
      }
    }
  }
}
