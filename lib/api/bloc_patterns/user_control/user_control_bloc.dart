import 'dart:async';

import 'package:MoonGoAdmin/models/transaction.dart';
import 'package:MoonGoAdmin/models/user_model.dart';
import 'package:MoonGoAdmin/models/wallet_model.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:MoonGoAdmin/ui/utils/constants.dart';
import 'package:MoonGoAdmin/ui/utils/formatter.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:oktoast/oktoast.dart';
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
    'Pro', //4
    // 'VIP USER(Unverified)', //5
    // 'Warrior', //6
  ];

  final List<String> transactionTypes = <String>[
    'Transaction Type',
    'TopUp',
    'Withdraw',
    'Booking'
  ];

  final List<String> vipTypes = <String>['Vip 0', 'Vip 1', 'Vip 2', 'Vip 3'];

  final selectedUserTypeSubject = BehaviorSubject.seeded('CoPlayer');
  final selectedVipTypeSubect = BehaviorSubject.seeded('Vip 0');
  final updateVipButtonSubject = BehaviorSubject.seeded(false);
  final updateSubject = BehaviorSubject.seeded(false);
  final rejectSubject = BehaviorSubject.seeded(false);
  final startDateSubject =
      BehaviorSubject.seeded(Formatter.yyyymmdd(DateTime.now()));
  final endDateSubject =
      BehaviorSubject.seeded(Formatter.yyyymmdd(DateTime.now()));
  final typeSubject = BehaviorSubject.seeded('Transaction Type');
  final transactionsSubject = BehaviorSubject<List<Transaction>>.seeded(null);
  final querySubject = BehaviorSubject.seeded(false);
  final _pageSubject = BehaviorSubject.seeded(1);
  final scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  Timer _debounce;
  final hasReachedMax = BehaviorSubject.seeded(false);

  final TextEditingController topUpAmountController = TextEditingController();
  final TextEditingController withdrawAmountController =
      TextEditingController();
  final TextEditingController rejectCommentController = TextEditingController();

  void dispose() {
    changePartnerButtonSubject.close();
    productIdOrAmountSubject.close();
    topUpSubject.close();
    withdrawSubject.close();
    selectedProductSubject.close();
    selectedUserTypeSubject.close();
    selectedVipTypeSubect.close();
    updateSubject.close();
    rejectSubject.close();
    startDateSubject.close();
    endDateSubject.close();
    transactionsSubject.close();
    updateVipButtonSubject.close();
    typeSubject.close();
    querySubject.close();
    _pageSubject.close();
    hasReachedMax.close();
    _debounce?.cancel();
    topUpAmountController.dispose();
    rejectCommentController.dispose();
    withdrawAmountController.dispose();
    scrollController.dispose();
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
    if (event is UserControlUpdateUserVip)
      yield* _mapUpdateUserVipToState(currentState);
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

  Stream<UserControlState> _mapUpdateUserVipToState(
      UserControlState currentState) async* {
    if (currentState is UserControlFetchedSuccess) {
      updateVipButtonSubject.add(true);
      final selectedVip = vipTypes.indexOf(await selectedVipTypeSubect.first);
      try {
        await MoonblinkRepository.updateUserVip(userId, selectedVip);
        yield UserControlUpdateUserVipSuccess();
        try {
          User data = await MoonblinkRepository.userdetail(userId);
          updateVipButtonSubject.add(false);
          yield UserControlFetchedSuccess(data);
        } catch (e) {
          updateVipButtonSubject.add(false);
          yield UserControlFetchedFailure(e);
        }
      } catch (e) {
        yield UserControlUpdateUserVipFailure(e);
        updateVipButtonSubject.add(false);
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

  void queryTransaction() async {
    querySubject.add(true);
    final startDate = await startDateSubject.first;
    final endDate = await endDateSubject.first;
    final type = (await typeSubject.first).toLowerCase();
    if (type == transactionTypes.first.toLowerCase()) {
      showToast('Please select a transaction type');
      querySubject.add(false);
      return;
    }
    final limit = 10;
    final page = 1;
    print("$startDate - $endDate - $type - $limit - $page");
    MoonblinkRepository.getUserTransactionList(
            startDate, endDate, type, userId, limit, page)
        .then((transactions) {
      transactionsSubject.add(transactions);
      hasReachedMax.add(false);
      _pageSubject.add(1);
      querySubject.add(false);
    }, onError: (e) {
      showToast(e.toString());
      hasReachedMax.add(false);
      transactionsSubject.add([]);
      querySubject.add(false);
    });
  }

  void queryTransactionMore() async {
    if (await hasReachedMax.first) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () async {
        querySubject.add(true);
        final startDate = await startDateSubject.first;
        final endDate = await endDateSubject.first;
        final type = (await typeSubject.first).toLowerCase();
        if (type.isEmpty || type == null) {
          showToast('Please select a transaction type');
          querySubject.add(false);
          return;
        }
        final limit = 10;
        final nextPage = (await _pageSubject.first) + 1;
        final previous = await transactionsSubject.first;
        print("$startDate - $endDate - $type - $limit - $nextPage");
        MoonblinkRepository.getUserTransactionList(
                startDate, endDate, type, userId, limit, nextPage)
            .then((transactions) {
          transactionsSubject.add(previous + transactions);
          _pageSubject.add(nextPage);
          querySubject.add(false);
          hasReachedMax.add(transactions.length < limit);
        }, onError: (e) {
          showToast(e.toString());
          hasReachedMax.add(true);
          querySubject.add(false);
        });
      });
    }
  }
}
