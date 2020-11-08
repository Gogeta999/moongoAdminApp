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

  final productIdOrAmountSubject = BehaviorSubject.seeded(true);

  /// true = amount, false = product_id
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

  final List<String> userTypes = <String>[
    'CoPlayer', //1
    'Streamer', //2
    'Cele', //3
    'Pro' //4
  ];

  final selectedUserTypeSubject = BehaviorSubject.seeded('CoPlayer');

  final updateSubject = BehaviorSubject.seeded(false);
  final rejectSubject = BehaviorSubject.seeded(false);

  final TextEditingController topUpAmountController = TextEditingController();
  final TextEditingController withdrawAmountController =
      TextEditingController();
  final TextEditingController rejectCommentController = TextEditingController();

  void dispose() {
    List<Future> futures = [
      changePartnerButtonSubject.close(),
      productIdOrAmountSubject.close(),
      topUpSubject.close(),
      withdrawSubject.close(),
      selectedProductSubject.close(),
      selectedUserTypeSubject.close(),
      updateSubject.close(),
      rejectSubject.close(),
    ];
    Future.wait(futures);
    topUpAmountController.dispose();
    rejectCommentController.dispose();
    withdrawAmountController.dispose();
    this.close();
  }

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
    if (event is UserControlAcceptUser)
      yield* _mapAcceptUserToState(currentState);
    if (event is UserControlRejectUser)
      yield* _mapRejectUserToState(currentState);
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
    final customize = await productIdOrAmountSubject.first;
    if (customize) {
      if (currentState is UserControlFetchedSuccess) {
        final amount = int.tryParse(topUpAmountController.text);
        if (amount == null) {
          yield UserControlTopUpFailure('Please type a valid amount');
          yield UserControlFetchedSuccess(currentState.data);
          topUpSubject.add(false);
          return;
        }
        final map = {'topup': amount};
        try {
          Wallet wallet = await MoonblinkRepository.topUpUserCoin(userId, map);
          User data = currentState.data;
          data.wallet = wallet;
          yield UserControlTopUpSuccess();
          yield UserControlFetchedSuccess(data);
          topUpAmountController.clear();
          topUpSubject.add(false);
        } catch (e) {
          yield UserControlWithdrawFailure(e);
          topUpSubject.add(false);
        }
      }
    } else {
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
          yield* _topUpCoinWithProductId(currentState, kCoin200);
          break;
        case '500 Coins':
          yield* _topUpCoinWithProductId(currentState, kCoin500);
          break;
        case '1000 Coins':
          yield* _topUpCoinWithProductId(currentState, kCoin1000);
          break;
        default:
          print('Error TopUp DropDown');
          break;
      }
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

  Stream<UserControlState> _mapAcceptUserToState(
      UserControlState currentState) async* {
    if (currentState is UserControlFetchedSuccess) {
      updateSubject.add(true);
      final String userTypeName = await selectedUserTypeSubject.first;
      final int userType = userTypes.indexOf(userTypeName) + 1;
      try {
        await MoonblinkRepository.updateUserType(userId, userType);
        yield UserControlAcceptUserSuccess();
        try {
          User data = await MoonblinkRepository.userdetail(userId);
          updateSubject.add(false);
          yield UserControlFetchedSuccess(data);
        } catch (e) {
          updateSubject.add(false);
          yield UserControlFetchedFailure(e);
        }
      } catch (e) {
        yield UserControlAcceptUserFailure(e);
        updateSubject.add(false);
      }
    }
  }

  Stream<UserControlState> _mapRejectUserToState(
      UserControlState currentState) async* {
    if (currentState is UserControlFetchedSuccess) {
      rejectSubject.add(true);
      try {
        await MoonblinkRepository.rejectPendingUser(
            userId, rejectCommentController.text);
        yield UserControlRejectUserSuccess();
        try {
          User data = await MoonblinkRepository.userdetail(userId);
          rejectSubject.add(false);
          yield UserControlFetchedSuccess(data);
        } catch (e) {
          rejectSubject.add(false);
          yield UserControlFetchedFailure(e);
        }
      } catch (e) {
        yield UserControlRejectUserFailure(e);
        rejectSubject.add(false);
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

  Stream<UserControlState> _topUpCoinWithProductId(
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
