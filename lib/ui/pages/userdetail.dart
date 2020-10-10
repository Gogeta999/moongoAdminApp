import 'package:MoonGoAdmin/bloc_patterns/userdetailbloc/userdetail_bloc.dart';
import 'package:MoonGoAdmin/bloc_patterns/userdetailbloc/userdetail_event.dart';
import 'package:MoonGoAdmin/bloc_patterns/userdetailbloc/userdetail_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserDetailPage extends StatefulWidget {
  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  UserDetailBloc userDetailBloc = UserDetailBloc();
  @override
  void initState() {
    userDetailBloc.add(UserDetailGet());
    super.initState();
  }

  tileBox(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Detail"),
      ),
      body: BlocProvider(
        create: (_) => userDetailBloc,
        child: BlocConsumer<UserDetailBloc, UserDetailState>(
          listener: (context, state) {},
          builder: (context, state) {
            print("Building state");
            print(state);
            if (state is UserDetailProgress) {
              return Center(child: CupertinoActivityIndicator());
            }
            if (state is UserDetailSuccess) {
              return ListView(
                children: [
                  Container(
                    height: 400,
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: state.user.profile.coverimage,
                          placeholder: (_, __) => CupertinoActivityIndicator(),
                          errorWidget: (_, __, ___) => Text('Sorry, Error'),
                          imageBuilder: (context, imageProvider) => Container(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.fill),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 200),
                            child: CachedNetworkImage(
                              imageUrl: state.user.profile.profileimage,
                              placeholder: (_, __) =>
                                  CupertinoActivityIndicator(),
                              errorWidget: (_, __, ___) => Text('Sorry, Error'),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: 150.0,
                                height: 150.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.fill),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  tileBox("Name", state.user.name),
                  tileBox("LastName", state.user.lastname),
                  tileBox("Email", state.user.email),
                  tileBox("NRC", state.user.profile.nrc),
                  tileBox("Gender", state.user.profile.gender),
                  tileBox("Bios", state.user.profile.bios),
                  tileBox("Date of Birth", state.user.profile.dob),
                  tileBox("Address", state.user.profile.address),
                  tileBox("Wallet", state.user.wallet.value.toString()),
                  tileBox(
                      "Follower Count", state.user.followercount.toString()),
                  tileBox(
                      "Following Count", state.user.followingcount.toString()),
                  tileBox("ID", state.user.id.toString()),
                  tileBox("Rating", state.user.rating.toString()),
                  tileBox("Type", state.user.type.toString()),
                  tileBox("Status", state.user.status.toString()),
                ],
              );
            }
            if (state is UserDetailFail) {
              return Center(
                child: Text("Fail"),
              );
            }
            return Center(
              child: Text("User Detail Fail"),
            );
          },
        ),
      ),
    );
  }
}
