import 'dart:async';

import 'package:MoonGoAdmin/api/bloc_patterns/pendingListBloc/pending_list_bloc.dart';
import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:MoonGoAdmin/models/userlist_model.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:MoonGoAdmin/ui/helper/image_helper.dart';
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
  var _pendingListBloc;

  @override
  void initState() {
    _pendingListBloc =
        PendingListBloc(_listKey, _buildRemoveItem, isPending: '1');
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
          value: BlocProvider.of<PendingListBloc>(context),
          child: PendingListTile(
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
          value: BlocProvider.of<PendingListBloc>(context),
          child: PendingListTile(
            data: data,
            index: index,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PendingListBloc>(
      create: (_) => _pendingListBloc..add(PendingListFetched()),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<PendingListBloc, PendingListState>(
            builder: (context, state) {
              if (state is PendingListInit) {
                return Text('Pending List');
              }
              if (state is PendingListNoData) {
                return Column(
                  children: [
                    Text('Pending List'),
                    Text('Total: 0'),
                  ],
                );
              }
              if (state is PendingListFail) {
                return Column(
                  children: [
                    Text('Pending List'),
                    Text('Total: UNKNOWN'),
                  ],
                );
              }
              if (state is PendingListSuccess) {
                return Column(
                  children: [
                    Text('Pending List'),
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
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: BlocConsumer<PendingListBloc, PendingListState>(
            listener: (BuildContext context, state) {
              if (state is PendingListSuccess) {
                _refreshCompleter.complete();
                _refreshCompleter = Completer();
              }
              if (state is PendingListFail) {
                _refreshCompleter.completeError(state.error);
                _refreshCompleter = Completer();
              }
            },
            builder: (BuildContext context, state) {
              print(state);
              if (state is PendingListInit) {
                return Center(child: CupertinoActivityIndicator());
              }
              if (state is PendingListFail) {
                return Center(
                  child: Text(state.error),
                );
              }
              if (state is PendingListNoData) {
                return Center(
                  child: Text("Opps,. No data ah"),
                );
              }
              if (state is PendingListSuccess) {
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
      _pendingListBloc.add(PendingListFetched());
    }
  }

  Future<void> _onRefresh() {
    _pendingListBloc.add(PendingListRefresh());
    return _refreshCompleter.future;
  }
}

class PendingListTile extends StatefulWidget {
  final ListUser data;
  final int index;

  PendingListTile({Key key, this.data, this.index}) : super(key: key);

  @override
  _PendingListTileState createState() => _PendingListTileState();
}

class _PendingListTileState extends State<PendingListTile> {
  final List<String> _userTypes = <String>[
    'CoPlayer', //1
    'Streamer', //2
    'Cele', //3
    'Pro' //4
  ];

  final _selectedUserTypeSubject = BehaviorSubject.seeded('CoPlayer');

  final _updateSubject = BehaviorSubject.seeded(false);
  final _rejectSubject = BehaviorSubject.seeded(false);

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
      case kStreamer:
        userType = 'Streamer';
        break;
      case kCele:
        userType = 'Cele';
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
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ImageView(widget.data.profile.profileimage)));
                },
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
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
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
                Row(
                  children: [
                    // CupertinoButton(child: Text(''), onPressed: null)
                    //Still Unsupport
                    StreamBuilder<bool>(
                        initialData: false,
                        stream: _rejectSubject,
                        builder: (context, snapshot) {
                          if (snapshot.data) {
                            return CupertinoButton(
                              child: CupertinoActivityIndicator(),
                              onPressed: () {},
                            );
                          }
                          return CupertinoButton(
                            child: Text('Reject'),
                            onPressed: () {
                              rejectDialog();
                            },
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
                )
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
      BlocProvider.of<PendingListBloc>(context)
          .add(PendingListRemoveUser(widget.index));
      _updateSubject.add(false);
    } catch (e) {
      showToast(e.toString());
      _updateSubject.add(false);
    }
  }

  //Reject Dialog
  rejectDialog() {
    showDialog(
      context: context,
      builder: (_) {
        TextEditingController comment = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          title: Text("Reject this partner"),
          content: Container(
            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
            ),
            child: TextField(
              textAlign: TextAlign.center,
              maxLines: null,
              controller: comment,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: "Comment",
              ),
            ),
          ),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            FlatButton(
              onPressed: () {
                _rejectUser(comment.text);
              },
              child: Text("Reject"),
            ),
          ],
        );
      },
    );
  }

  _rejectUser(String comment) async {
    _rejectSubject.add(true);
    try {
      //await Future.delayed(Duration(milliseconds: 2000));
      await MoonblinkRepository.rejectPendingUser(widget.data.id, comment);
      BlocProvider.of<PendingListBloc>(context)
          .add(PendingListRemoveUser(widget.index));
      _rejectSubject.add(false);
    } catch (e) {
      showToast(e.toString());
      _rejectSubject.add(false);
    }
  }
}
