import 'dart:async';

import 'package:MoonGoAdmin/bloc_patterns/userlistBloc/userlist_bloc.dart';
import 'package:MoonGoAdmin/bloc_patterns/userlistBloc/userlist_event.dart';
import 'package:MoonGoAdmin/bloc_patterns/userlistBloc/userlist_state.dart';
import 'package:MoonGoAdmin/models/userlist_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PendingListPage extends StatefulWidget {
  @override
  _PendingListPageState createState() => _PendingListPageState();
}

class _PendingListPageState extends State<PendingListPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final _scrollController = ScrollController();
  final _scrollThreshold = 600.0;
  Completer<void> _refreshCompleter;
  var _userList;

  @override
  void initState() {
    _userList = UserListBloc(_listKey, _buildRemoveItem, isPending: '1');
    _scrollController.addListener(_onScroll);
    _refreshCompleter = Completer<void>();
    super.initState();
  }

  Widget _buildItem(BuildContext context, int index,
      Animation<double> animation, ListUser data) {
    return SlideTransition(
        position: CurvedAnimation(
          curve: Curves.easeOut,
          parent: animation,
        ).drive(Tween<Offset>(
          begin: Offset(1, 0),
          end: Offset(0, 0),
        )),
        child: UserListTile(
          data: data,
          index: index,
        ));
  }

  Widget _buildRemoveItem(BuildContext context, int index,
      Animation<double> animation, ListUser data) {
    return SlideTransition(
        position: CurvedAnimation(
          curve: Curves.easeOut,
          parent: animation,
        ).drive(Tween<Offset>(
          begin: Offset(1, 0),
          end: Offset(0, 0),
        )),
        child: UserListTile(
          data: data,
          index: index,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserListBloc>(
      create: (_) => _userList..add(UserListFetched()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Main'),
          backgroundColor: Colors.lightBlue[100],
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: BlocConsumer<UserListBloc, UserListState>(
            listener: (BuildContext context, state) {
              if (state is UserListSuccess) {
                _refreshCompleter.complete();
                _refreshCompleter = Completer();
              }
              if (state is UserListFail) {
                _refreshCompleter.completeError(state.error);
                _refreshCompleter = Completer();
              }
            },
            builder: (BuildContext context, state) {
              print(state);
              if (state is UserListInit) {
                return Center(child: CupertinoActivityIndicator());
              }
              if (state is UserListFail) {
                return Center(
                  child: Text(state.error),
                );
              }
              if (state is UserListNoData) {
                return Center(
                  child: Text("Opps,. No data ah"),
                );
              }
              if (state is UserListSuccess) {
                return AnimatedList(
                  shrinkWrap: true,
                  key: _listKey,
                  controller: _scrollController,
                  itemBuilder: (BuildContext context, int index, animation) {
                    return Column(
                      children: <Widget>[
                        _buildItem(
                            context, index, animation, state.data[index]),
                        Divider(),
                        if (state.hasReachedMax == false &&
                            index >= state.data.length - 1)
                          Center(child: CupertinoActivityIndicator())
                      ],
                    );
                  },
                );
              }
              return Center(
                child: Text("Opps,. Error Appear"),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _userList.add(UserListFetched());
    }
  }

  Future<void> _onRefresh() {
    _userList.add(UserListRefresh());
    return _refreshCompleter.future;
  }
}

class UserListTile extends StatelessWidget {
  final ListUser data;
  final int index;

  const UserListTile({Key key, this.data, this.index}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      title: Text(data.name),
      subtitle: Text('User type is ${data.type}'),
      leading: CachedNetworkImage(
        imageUrl: data.profile.profileimage,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 32,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }
}
