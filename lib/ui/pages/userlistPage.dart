import 'package:MoonGoAdmin/bloc_patterns/userlistBloc/userlist_bloc.dart';
import 'package:MoonGoAdmin/bloc_patterns/userlistBloc/userlist_event.dart';
import 'package:MoonGoAdmin/bloc_patterns/userlistBloc/userlist_state.dart';
import 'package:MoonGoAdmin/models/userlist_model.dart';
import 'package:MoonGoAdmin/ui/pages/userdetail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  UserListBloc userListBloc = UserListBloc();
  @override
  void initState() {
    userListBloc.add(UserListfetched());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User List"),
      ),
      body: BlocProvider(
        create: (_) => userListBloc,
        child: BlocConsumer<UserListBloc, UserListState>(
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
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserDetailPage(id: user.id)),
                    ),
                  );
                },
              );
            }
            return Center(
              child: Text("Opps,. Error Appear"),
            );
          },
          listener: (BuildContext context, state) {},
        ),
      ),
    );
  }
}
