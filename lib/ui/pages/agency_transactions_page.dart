import 'dart:async';

import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:MoonGoAdmin/models/agency_transaction.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

class AgencyTransactionsPage extends StatefulWidget {
  @override
  _AgencyTransactionsPageState createState() => _AgencyTransactionsPageState();
}

class _AgencyTransactionsPageState extends State<AgencyTransactionsPage> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  final limit = 20;
  Completer<void> _refreshCompleter = Completer();
  int nextPage = 1;
  bool hasReachedMax = false;

  final _agencyTransactions = BehaviorSubject<List<AgencyTransaction>>();

  @override
  void initState() {
    MoonblinkRepository.getAgencyTransactions(limit, nextPage).then((value) {
      _agencyTransactions.add(value);
      nextPage++;
      hasReachedMax = value.length < limit;
    }, onError: (e) => _agencyTransactions.addError(e));
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _agencyTransactions.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        // actions: [
        //   StreamBuilder<List<AgencyTransaction>>(
        //     initialData: null,
        //     stream: _agencyTransactions,
        //     builder: (context, snapshot) {
        //       if (snapshot.hasError) {
        //         return Container();
        //       }
        //       if (snapshot.data == null) {
        //         return CupertinoActivityIndicator();
        //       }
        //       return CupertinoButton(
        //         child: Text(
        //           'Total: ${snapshot.data.first.totalCount}',
        //           style: TextStyle(color: Colors.white),
        //         ),
        //         onPressed: () {},
        //       );
        //     },
        //   )
        // ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: StreamBuilder<List<AgencyTransaction>>(
              initialData: null,
              stream: _agencyTransactions,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }
                if (snapshot.data == null) {
                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
                if (snapshot.data.isEmpty) {
                  return Center(
                    child: Text('Empty'),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  physics: ClampingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemCount: hasReachedMax
                      ? snapshot.data.length
                      : snapshot.data.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= snapshot.data.length) {
                      return Center(
                        child: CupertinoActivityIndicator(),
                      );
                    }
                    final item = snapshot.data[index];
                    return ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: item.warriorProfileImage,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        placeholderFadeInDuration: Duration.zero,
                        placeholder: (context, url) =>
                            CupertinoActivityIndicator(),
                        imageBuilder: (context, provider) {
                          return CircleAvatar(
                            backgroundImage: provider,
                            radius: 24,
                          );
                        },
                      ),
                      title: Text('${item.warriorName}'),
                      subtitle: Text('Income to you--'),
                      trailing: Text('${item.amount} Coins'),
                      onTap: () => Navigator.pushNamed(
                          context, RouteName.userDetail,
                          arguments: item.id),
                    );
                  },
                );
              }),
        ),
      ),
    );
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      MoonblinkRepository.getAgencyTransactions(limit, nextPage).then((value) {
        _agencyTransactions.add(_agencyTransactions.value + value);
        nextPage++;
        hasReachedMax = value.length < limit;
      });
    }
  }

  Future<void> _onRefresh() {
    nextPage = 1;
    MoonblinkRepository.getAgencyTransactions(limit, nextPage).then((value) {
      _agencyTransactions.add(value);
      nextPage++;
      hasReachedMax = value.length < limit;
      _refreshCompleter.complete();
    }, onError: (e) {
      _refreshCompleter.completeError(e);
    }).whenComplete(() => _refreshCompleter = Completer<void>());
    return _refreshCompleter.future;
  }
}
