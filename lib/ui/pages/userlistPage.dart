import 'dart:async';

import 'package:MoonGoAdmin/api/bloc_patterns/userlistBloc/userlist_bloc.dart';
import 'package:MoonGoAdmin/api/bloc_patterns/userlistBloc/userlist_event.dart';
import 'package:MoonGoAdmin/api/bloc_patterns/userlistBloc/userlist_state.dart';
import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:MoonGoAdmin/models/userlist_model.dart';
import 'package:MoonGoAdmin/ui/helper/filter_helper.dart';
import 'package:MoonGoAdmin/ui/helper/image_helper.dart';
import 'package:MoonGoAdmin/ui/utils/constants.dart';
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
  String dropdownValue = '';

  @override
  void initState() {
    _userList = UserListBloc(_listKey, _buildRemoveItem);
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
    var filterName;

    return BlocProvider<UserListBloc>(
      create: (_) => _userList..add(UserListFetched()),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<UserListBloc, UserListState>(
            builder: (context, state) {
              if (state is UserListInit) {
                return Text('User List');
              }
              if (state is UserListNoData) {
                return Column(
                  children: [
                    Text('User List'),
                    Text('Total: 0'),
                  ],
                );
              }
              if (state is UserListFail) {
                return Column(
                  children: [
                    Text('User List'),
                    Text('Total: UNKNOWN'),
                  ],
                );
              }
              if (state is UserListSuccess) {
                return Column(
                  children: [
                    Text('User List'),
                    Text('Total: ${state.totalCount}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))
                  ],
                );
              }
              return Text('Something went wrong!');
            },
          ),
          backgroundColor: Colors.lightBlue[100],
          actions: [
            Container(
              width: 100,
              color: Colors.white,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dropdownValue,
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValue = newValue;
                      globalFilter = dropdownValue;
                    });
                    print('GlobalFilter Type : $globalFilter');
                    _onUpdated();
                  },
                  items: <String>[
                    '',
                    '0',
                    '1',
                    '2',
                    '3',
                    '4',
                  ].map<DropdownMenuItem<String>>((String value) {
                    switch (value) {
                      case tAll:
                        filterName = 'All';
                        break;
                      case tNormal:
                        filterName = 'Normal';
                        break;
                      case tCoPlayer:
                        filterName = 'CoPlayer';
                        break;
                      case tCele:
                        filterName = 'Cele';
                        break;
                      case tStreamer:
                        filterName = 'Streamer';
                        break;
                      case tPro:
                        filterName = 'Pro';
                        break;
                      default:
                        filterName = 'Null Error';
                        break;
                    }
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(filterName),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
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
                  physics: ClampingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
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

  void _onUpdated() {
    _userList.add(UserListUpdated());
    return _userList;
  }
}

class UserListTile extends StatelessWidget {
  final ListUser data;
  final int index;

  const UserListTile({Key key, this.data, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var userType;
    switch (data.type) {
      case kNormal:
        userType = 'Normal';
        break;
      case kCoPlayer:
        userType = 'CoPlayer';
        break;
      case kCele:
        userType = 'Cele';
        break;
      case kStreamer:
        userType = 'Streamer';
        break;
      case kPro:
        userType = 'Pro';
        break;
      default:
        userType = 'Unknown User';
        break;
    }
    return ListTile(
      onTap: () => Navigator.pushNamed(context, RouteName.userControl,
          arguments: data.id),
      isThreeLine: true,
      title: Text(data.name),
      subtitle: Text('User type is $userType\nID is ${data.id}'),
      leading: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ImageView(data.profile.profileimage)));
        },
        child: CachedNetworkImage(
          imageUrl: data.profile.profileimage,
          imageBuilder: (context, imageProvider) => CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            backgroundImage: imageProvider,
          ),
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }
}
