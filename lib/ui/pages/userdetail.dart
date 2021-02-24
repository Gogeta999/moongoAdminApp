import 'package:MoonGoAdmin/api/bloc_patterns/userdetailbloc/userdetail_bloc.dart';
import 'package:MoonGoAdmin/api/bloc_patterns/userdetailbloc/userdetail_event.dart';
import 'package:MoonGoAdmin/api/bloc_patterns/userdetailbloc/userdetail_state.dart';
import 'package:MoonGoAdmin/ui/helper/image_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';

class UserDetailPage extends StatefulWidget {
  final int id;
  UserDetailPage({@required this.id});
  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  UserDetailBloc userDetailBloc = UserDetailBloc();
  @override
  void initState() {
    userDetailBloc.add(UserDetailGet(id: widget.id));
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

  _padding(double height) {
    return Divider(
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Warrior Detail"),
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
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ImageView(state.user.profile.coverimage)));
                          },
                          child: CachedNetworkImage(
                            imageUrl: state.user.profile.coverimage,
                            placeholder: (_, __) =>
                                CupertinoActivityIndicator(),
                            errorWidget: (_, __, ___) => Icon(Icons.error),
                            imageBuilder: (context, imageProvider) => Container(
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.fill),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 200),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ImageView(
                                        state.user.profile.profileimage)));
                              },
                              child: CachedNetworkImage(
                                imageUrl: state.user.profile.profileimage,
                                placeholder: (_, __) =>
                                    CupertinoActivityIndicator(),
                                errorWidget: (_, __, ___) => Icon(Icons.error),
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
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      FlutterClipboard.copy(state.user.profile.phone).then(
                        (value) {
                          showToast('Copy Success');
                          print('copied');
                        },
                      );
                    },
                    child: tileBox("Phone", state.user.profile.phone),
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
                  if (state.user.nrcProfile != null)
                    Container(
                      height: 200,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ImageView(state.user.nrcProfile.nrcFront)));
                        },
                        child: CachedNetworkImage(
                          imageUrl: state.user.nrcProfile.nrcFront,
                          placeholder: (_, __) => CupertinoActivityIndicator(),
                          errorWidget: (_, __, ___) => Icon(Icons.error),
                          imageBuilder: (context, imageProvider) => Container(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (state.user.nrcProfile != null) _padding(10),
                  if (state.user.nrcProfile != null)
                    Container(
                      height: 200,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ImageView(state.user.nrcProfile.nrcBack)));
                        },
                        child: CachedNetworkImage(
                          imageUrl: state.user.nrcProfile.nrcBack,
                          placeholder: (_, __) => CupertinoActivityIndicator(),
                          errorWidget: (_, __, ___) => Icon(Icons.error),
                          imageBuilder: (context, imageProvider) => Container(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ),
                    ),
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
