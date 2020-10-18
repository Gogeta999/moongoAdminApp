import 'dart:async';

import 'package:MoonGoAdmin/bloc_patterns/userlistBloc/userlist_bloc.dart';
import 'package:MoonGoAdmin/bloc_patterns/userlistBloc/userlist_event.dart';
import 'package:MoonGoAdmin/bloc_patterns/userlistBloc/userlist_state.dart';
import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:MoonGoAdmin/models/userlist_model.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:MoonGoAdmin/ui/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

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
        child: BlocProvider.value(
          value: BlocProvider.of<UserListBloc>(context),
          child: UserListTile(
            data: data,
            index: index,
          ),
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
        child: BlocProvider.value(
          value: BlocProvider.of<UserListBloc>(context),
          child: UserListTile(
            data: data,
            index: index,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserListBloc>(
      create: (_) => _userList..add(UserListFetched()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pending'),
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
}

class UserListTile extends StatefulWidget {
  final ListUser data;
  final int index;

  UserListTile({Key key, this.data, this.index}) : super(key: key);

  @override
  _UserListTileState createState() => _UserListTileState();
}

class _UserListTileState extends State<UserListTile> {
  final List<String> _userTypes = <String>[
    'CoPlayer', //1
    'Streamer', //2
    'Cele', //3
    'Pro' //4
  ];

  final _selectedUserTypeSubject = BehaviorSubject.seeded('CoPlayer');

  final _updateSubject = BehaviorSubject.seeded(false);

  @override
  Widget build(BuildContext context) {
    var userType;
    switch (widget.data.type) {
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
    return InkWell(
      onTap: () => Navigator.pushNamed(context, RouteName.userControl,
          arguments: widget.data.id),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              child: CachedNetworkImage(
                imageUrl: widget.data.profile.profileimage,
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  radius: 32,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  backgroundImage: imageProvider,
                ),
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data.name,
                ),
                Text('User type is $userType\n ID is ${widget.data.id}'),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StreamBuilder<String>(
                    initialData: _userTypes.first,
                    stream: _selectedUserTypeSubject,
                    builder: (context, snapshot) {
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: snapshot.data,
                          icon: Icon(Icons.keyboard_arrow_down),
                          onChanged: (String newValue) {
                            _selectedUserTypeSubject.add(newValue);
                          },
                          items: _userTypes
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, textAlign: TextAlign.center),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                StreamBuilder<bool>(
                    initialData: false,
                    stream: _updateSubject,
                    builder: (context, snapshot) {
                      if (snapshot.data) {
                        return CupertinoButton(
                          child: CupertinoActivityIndicator(),
                          onPressed: () {},
                        );
                      }
                      return CupertinoButton(
                        child: Text('Update'),
                        onPressed: _updateUser,
                      );
                    })
              ],
            ),
          ),
        ],
      ),
    );
  }

  _updateUser() async {
    _updateSubject.add(true);
    final String userTypeName = await _selectedUserTypeSubject.first;
    final int userType = _userTypes.indexOf(userTypeName) + 1;
    try {
      await MoonblinkRepository.updateUserType(widget.data.id, userType);
      BlocProvider.of<UserListBloc>(context)
          .add(UserListRemoveUser(widget.index));
      _updateSubject.add(false);
    } catch (e) {
      showToast(e.toString());
      _updateSubject.add(false);
    }
  }
}
/* return ListTile(
      onTap: () => Navigator.pushNamed(context, RouteName.userControl,
          arguments: data.id),
      isThreeLine: true,
      title: Text(data.name),
      subtitle: Text('Type: $userType\n ID: ${data.id}'),
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
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<String>(
              initialData: _userTypes.first,
              stream: _selectedUserTypeSubject,
              builder: (context, snapshot) {
                return DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: snapshot.data,
                    icon: Icon(Icons.keyboard_arrow_down),
                    onChanged: (String newValue) {
                      _selectedUserTypeSubject.add(newValue);
                    },
                    items: _userTypes
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                );
              }),
          CupertinoButton(child: Text('Update'), onPressed: (){},)
        ],
      ),
    );*/
