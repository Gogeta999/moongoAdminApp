import 'dart:async';

import 'package:MoonGoAdmin/bloc_patterns/userlistBloc/userlist_bloc.dart';
import 'package:MoonGoAdmin/bloc_patterns/userlistBloc/userlist_event.dart';
import 'package:MoonGoAdmin/bloc_patterns/userlistBloc/userlist_state.dart';
import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:MoonGoAdmin/models/userlist_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final _scrollController = ScrollController();
  final _scrollThreshold = 600.0;
  Completer<void> _refreshCompleter;
  var _userList;

  @override
  void initState() {
    _userList = UserListBloc(_listKey);
    _scrollController.addListener(_onScroll);
    _refreshCompleter = Completer<void>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main'),
        backgroundColor: Colors.lightBlue[100],
        actions: [
          // IconButton(
          //   icon: Icon(Icons.search),
          //   onPressed: () => Navigator.pushNamed(context, RouteName.search),
          // )
        ],
      ),
      body: BlocProvider<UserListBloc>(
        create: (_) => _userList..add(UserListFetched()),
        child: RefreshIndicator(
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

              if (state is UserListSuccess) {
                return ListView.builder(
                  itemExtent: 100,
                  itemCount: state.data.length,
                  itemBuilder: (context, index) {
                    UserList user = state.data[index];
                    return ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: user.profile.profileimage,
                        placeholder: (_, __) => CupertinoActivityIndicator(),
                        errorWidget: (_, __, ___) => Icon(Icons.error),
                        imageBuilder: (context, imageProvider) => Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.fill),
                          ),
                        ),
                      ),
                      title: Text(user.name),
                      onTap: () => Navigator.pushNamed(
                          context, RouteName.userControl,
                          arguments: state.data[index].id),
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
