import 'dart:async';

import 'package:MoonGoAdmin/models/payment.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:MoonGoAdmin/ui/utils/formatter.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

part 'user_payments_event.dart';
part 'user_payments_state.dart';

class UserPaymentsBloc extends Bloc<UserPaymentsEvent, UserPaymentsState> {
  UserPaymentsBloc() : super(UserPaymentssInitial());

  final List<String> statusTypes = <String>[
    'All',
    'Pending',
    'Success',
    'Reject',
    'Refund'
  ];

  final startDateSubject =
      BehaviorSubject.seeded(Formatter.yyyymmdd(DateTime.now()));
  final endDateSubject =
      BehaviorSubject.seeded(Formatter.yyyymmdd(DateTime.now()));
  final statusSubject = BehaviorSubject.seeded(0);
  final paymentsSubject = BehaviorSubject<List<Payment>>.seeded(null);
  final querySubject = BehaviorSubject.seeded(false);
  final _pageSubject = BehaviorSubject.seeded(1);
  final scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  Timer _debounce;
  final hasReachedMax = BehaviorSubject.seeded(false);

  void dispose() {
    List<Future> futures = [
      paymentsSubject.close(),
      statusSubject.close(),
      startDateSubject.close(),
      endDateSubject.close(),
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
  Stream<UserPaymentsState> mapEventToState(
    UserPaymentsEvent event,
  ) async* {}

  void queryTransaction() async {
    querySubject.add(true);
    final startDate = await startDateSubject.first;
    final endDate = await endDateSubject.first;
    final limit = 20;
    final page = 1;
    final status = (await statusSubject.first) - 1;
    print("$startDate - $endDate $status - $limit - $page");
    MoonblinkRepository.getPayments(startDate, endDate, status, limit, page)
        .then((transactions) {
      paymentsSubject.add(transactions);
      hasReachedMax.add(false);
      _pageSubject.add(1);
      querySubject.add(false);
    }, onError: (e) {
      showToast(e.toString());
      hasReachedMax.add(false);
      paymentsSubject.add([]);
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
        final status = (await statusSubject.first) - 1;
        final limit = 20;
        final nextPage = (await _pageSubject.first) + 1;
        final previous = await paymentsSubject.first;
        print("$startDate - $endDate $status - $limit - $nextPage");
        MoonblinkRepository.getPayments(
                startDate, endDate, status, limit, nextPage)
            .then((transactions) {
          paymentsSubject.add(previous + transactions);
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

  void changeStatusOfPayment(int paymentId, int status) {
    MoonblinkRepository.changePaymentStatus(paymentId, status).then(
        (value) async {
      showToast('Success');
      final current = await paymentsSubject.first;
      for (int i = 0; i < current.length; ++i) {
        if (current[i].id == paymentId) {
          current[i] = value;
          print("After: ${current[i].status}");
          break;
        }
      }
      paymentsSubject.add(current);
    }, onError: (e) {
      showToast('$e');
    });
  }
}
