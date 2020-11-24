import 'dart:async';

import 'package:MoonGoAdmin/models/transaction.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:MoonGoAdmin/ui/utils/formatter.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

part 'user_transactions_event.dart';
part 'user_transactions_state.dart';

class UserTransactionsBloc
    extends Bloc<UserTransactionsEvent, UserTransactionsState> {
  UserTransactionsBloc() : super(UserTransactionsInitial());

  final List<String> transactionTypes = <String>[
    'Transaction Type',
    'TopUp',
    'Withdraw',
    'Booking'
  ];

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

  void dispose() {
    List<Future> futures = [
      transactionsSubject.close(),
      startDateSubject.close(),
      endDateSubject.close(),
      typeSubject.close(),
      querySubject.close(),
      _pageSubject.close(),
      hasReachedMax.close()
    ];
    _debounce?.cancel();
    Future.wait(futures);
    scrollController.dispose();
    this.close();
  }

  @override
  Stream<UserTransactionsState> mapEventToState(
    UserTransactionsEvent event,
  ) async* {}

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
    final limit = 20;
    final page = 1;
    print("$startDate - $endDate - $type - $limit - $page");
    MoonblinkRepository.getAllTransactionList(
            startDate, endDate, type, limit, page)
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
        final limit = 20;
        final nextPage = (await _pageSubject.first) + 1;
        final previous = await transactionsSubject.first;
        print("$startDate - $endDate - $type - $limit - $nextPage");
        MoonblinkRepository.getAllTransactionList(
                startDate, endDate, type, limit, nextPage)
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
