import 'package:MoonGoAdmin/bloc_patterns/user_control/user_control_bloc.dart';
import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MoonGoAdmin/ui/utils/constants.dart';
import 'package:oktoast/oktoast.dart';

class UserControlPage extends StatefulWidget {
  final int userId;

  const UserControlPage({Key key, this.userId}) : super(key: key);

  @override
  _UserControlPageState createState() => _UserControlPageState();
}

class _UserControlPageState extends State<UserControlPage> {
  UserControlBloc _userControlBloc;

  @override
  void initState() {
    _userControlBloc = UserControlBloc(widget.userId);
    _userControlBloc.add(UserControlFetched());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildPartnerType(int type) {
    String text = '';
    switch (type) {
      case kNormal:
        text = 'This user type is **Normal**';
        break;
      case kCoPlayer:
        text = 'This partner type is **CoPlayer**';
        break;
      case kCele:
        text = 'This partner type is **Cele**';
        break;
      case kStreamer:
        text = 'This partner type is **Streamer**';
        break;
      case kPro:
        text = 'This partner type is **Pro**';
        break;
      default:
        text = 'Unknown User';
        break;
    }
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Text(text),
      ),
    );
  }

  Widget _buildUpdatePartnerType(int type) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          children: [
            Text('Change Partner Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            StreamBuilder<ChangePartnerButtonState>(
                initialData: ChangePartnerButtonState.initial,
                stream: _userControlBloc.changePartnerButtonSubject,
                builder: (context, snapshot) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoButton(
                        child: snapshot.data == ChangePartnerButtonState.coPlayer
                            ? CupertinoActivityIndicator()
                            : Text('CoPlayer'),
                        onPressed: type == 1
                            ? null
                            : () => _userControlBloc
                                .add(UserControlChangePartnerType(kCoPlayer)),
                      ),
                      CupertinoButton(
                        child: snapshot.data == ChangePartnerButtonState.cele
                            ? CupertinoActivityIndicator()
                            : Text('Cele'),
                        onPressed: type == 2
                            ? null
                            : () => _userControlBloc
                                .add(UserControlChangePartnerType(kCele)),
                      ),
                      CupertinoButton(
                        child: snapshot.data == ChangePartnerButtonState.streamer
                            ? CupertinoActivityIndicator()
                            : Text('Streamer'),
                        onPressed: type == 3
                            ? null
                            : () => _userControlBloc
                                .add(UserControlChangePartnerType(kStreamer)),
                      ),
                      CupertinoButton(
                        child: snapshot.data == ChangePartnerButtonState.pro
                            ? CupertinoActivityIndicator()
                            : Text('Pro'),
                        onPressed: type == 4
                            ? null
                            : () => _userControlBloc
                                .add(UserControlChangePartnerType(kPro)),
                      ),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Control'),
        // actions: [
        //   CupertinoButton(
        //     child: Text('Cash In', style: TextStyle(color: Colors.black)),
        //     onPressed: () {},
        //   )
        // ],
      ),
      body: BlocProvider(
        create: (_) => _userControlBloc,
        child: BlocConsumer<UserControlBloc, UserControlState>(
          listener: (context, state) {
            if (state is UserControlChangePartnerTypeFailure) {
              showToast(state.error.toString());
            }
          },
          buildWhen: (previous, current) {
            return !(current is UserControlChangePartnerTypeFailure);
          },
          builder: (context, state) {
            if (state is UserControlInitial) {
              return Center(child: CupertinoActivityIndicator());
            }
            if (state is UserControlFetchedFailure) {
              return Center(child: Text(state.error.toString()));
            }
            if (state is UserControlFetchedSuccess) {
              return Column(
                children: [
              _buildPartnerType(state.data.type),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: CupertinoButton(
                  child: Text('Go To Detail Page'),
                  onPressed: () => Navigator.pushNamed(context, RouteName.userDetail, arguments: state.data.id),
                ),
              ),
              if (state.data.type != 0)
                _buildUpdatePartnerType(state.data.type)
                ],
              );
            }
            return Text('Oops! Something went wrong!');
          },
        ),
      ),
    );
  }
}
