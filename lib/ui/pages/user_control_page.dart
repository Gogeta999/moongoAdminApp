import 'package:MoonGoAdmin/bloc_patterns/user_control/user_control_bloc.dart';
import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:MoonGoAdmin/models/user_model.dart';
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

  Widget _buildPartnerType(String name, int type) {
    String text = '';
    switch (type) {
      case kNormal:
        text = '$name\'s user type is **Normal**';
        break;
      case kCoPlayer:
        text = '$name\'s partner type is **CoPlayer**';
        break;
      case kCele:
        text = '$name\'s partner type is **Cele**';
        break;
      case kStreamer:
        text = '$name\'s partner type is **Streamer**';
        break;
      case kPro:
        text = '$name\'s partner type is **Pro**';
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
                        child:
                            snapshot.data == ChangePartnerButtonState.coPlayer
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
                        child:
                            snapshot.data == ChangePartnerButtonState.streamer
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

  Widget _buildGoToDetailPage(int id) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: CupertinoButton(
        child: Text('Go To Detail Page'),
        onPressed: () =>
            Navigator.pushNamed(context, RouteName.userDetail, arguments: id),
      ),
    );
  }

  Widget _buildCoinControl(User user) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          children: [
            Text('${user.name} has ${user.wallet.value} coins'),
            _blankSpace,
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue)),
                    child: Column(
                      children: [
                        StreamBuilder<String>(
                            initialData: _userControlBloc.productList.first,
                            stream: _userControlBloc.selectedProductSubject,
                            builder: (context, snapshot) {
                              return DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: snapshot.data,
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  onChanged: (String newValue) {
                                    _userControlBloc.selectedProductSubject
                                        .add(newValue);
                                  },
                                  items: _userControlBloc.productList
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              );
                            }),
                        StreamBuilder<bool>(
                            initialData: false,
                            stream: _userControlBloc.topUpSubject,
                            builder: (context, snapshot) {
                              if (snapshot.data) {
                                return CupertinoButton(
                                  child: CupertinoActivityIndicator(),
                                  onPressed: () {},
                                );
                              }
                              return CupertinoButton(
                                child: Text('TopUp'),
                                onPressed: () => _userControlBloc
                                    .add(UserControlTopUpCoin()),
                              );
                            })
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CupertinoTextField(
                            controller:
                                _userControlBloc.withdrawAmountController,
                            clearButtonMode: OverlayVisibilityMode.editing,
                            placeholder: 'Withdraw Amount',
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              if (value.length > 0)
                                try {
                                  int intValue = int.parse(value);
                                  _userControlBloc.withdrawAmountController
                                      .text = intValue.toString();
                                } catch (e) {
                                  showToast('Pleas type valid number');
                                  _userControlBloc.withdrawAmountController
                                      .clear();
                                }
                            },
                          ),
                        ),
                        StreamBuilder<bool>(
                            initialData: false,
                            stream: _userControlBloc.withdrawSubject,
                            builder: (context, snapshot) {
                              if (snapshot.data) {
                                return CupertinoButton(
                                  child: CupertinoActivityIndicator(),
                                  onPressed: () {},
                                );
                              }
                              return CupertinoButton(
                                child: Text('Withdraw'),
                                onPressed: () => _userControlBloc
                                    .add(UserControlWithdrawCoin()),
                              );
                            })
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget get _blankSpace => SizedBox(height: 10);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _userControlBloc.withdrawAmountController.clear();
      },
      child: Scaffold(
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
              if (state is UserControlTopUpFailure) {
                showToast(state.error.toString());
              }
              if (state is UserControlTopUpSuccess) {
                showToast('TopUp Success');
              }
              if (state is UserControlWithdrawFailure) {
                showToast(state.error.toString());
              }
              if (state is UserControlWithdrawSuccess) {
                showToast('Withdraw Success');
              }
            },
            buildWhen: (previous, current) {
              return !(current is UserControlChangePartnerTypeFailure) &&
                  !(current is UserControlTopUpFailure) &&
                  !(current is UserControlTopUpSuccess) &&
                  !(current is UserControlWithdrawFailure) &&
                  !(current is UserControlWithdrawSuccess);
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
                    _buildPartnerType(state.data.name, state.data.type),
                    _blankSpace,
                    _buildGoToDetailPage(state.data.id),
                    _blankSpace,
                    _buildCoinControl(state.data),
                    if (state.data.type != 0)
                      _buildUpdatePartnerType(state.data.type)
                  ],
                );
              }
              return Text('Oops! Something went wrong!');
            },
          ),
        ),
      ),
    );
  }
}
