import 'dart:async';

import 'package:MoonGoAdmin/bloc_patterns/userlistBloc/userlist_bloc.dart';
import 'package:MoonGoAdmin/bloc_patterns/userlistBloc/userlist_event.dart';
import 'package:MoonGoAdmin/bloc_patterns/userlistBloc/userlist_state.dart';
import 'package:MoonGoAdmin/models/userlist_model.dart';
import 'package:MoonGoAdmin/ui/helper/filter_helper.dart';
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
    _userList = UserListBloc(_listKey);
    _scrollController.addListener(_onScroll);
    _refreshCompleter = Completer<void>();
    super.initState();
  }

  void _onInitAgain() {
    _userList = UserListBloc(_listKey, filterByType: 3);
    return _userList;
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

//   Widget dropdownButtonItem(
//     String title,
//     List data,
//     Map selectedItem,
//     int selectedId,
//     Function handleChange,
//   ) {
//     List<Widget> widgets = [
//       Text(title),
//       DropdownButtonHideUnderline(
// //  DropdownButton默认有一条下划线（如上图），此widget去除下划线
//         child: DropdownButton(
//           items: data
//               .map((item) => DropdownMenuItem(
//                     value: item,
//                     child: Text(
//                       item['name'],
//                       style: TextStyle(
//                           color: item['id'] == selectedId
//                               ? Colors.lightBlue[100]
//                               : Colors.grey),
//                     ),
//                   ))
//               .toList(),
//           hint: Text('请选择'),
//           onChanged: handleChange,
//           value: selectedItem,
//         ),
//       ),
//     ];
//     return optionItemDecorator(widgets);
//   }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserListBloc>(
      create: (_) => _userList..add(UserListFetched()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Main'),
          backgroundColor: Colors.lightBlue[100],
          actions: [
            // RaisedButton(
            //   onPressed: () {
            //     setState(() {
            //       globalPending = '1';
            //     });
            //     _onUpdated();
            //   },
            //   child: Text("Change To Pending List"),
            // ),
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
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
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
