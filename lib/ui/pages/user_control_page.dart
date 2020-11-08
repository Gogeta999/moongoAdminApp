import 'package:MoonGoAdmin/api/bloc_patterns/user_control/user_control_bloc.dart';
import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:MoonGoAdmin/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _userControlBloc.dispose();
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
                        onPressed: type == kCoPlayer
                            ? null
                            : () => _userControlBloc
                                .add(UserControlChangePartnerType(kCoPlayer)),
                      ),
                      CupertinoButton(
                        child: snapshot.data == ChangePartnerButtonState.cele
                            ? CupertinoActivityIndicator()
                            : Text('Cele'),
                        onPressed: type == kCele
                            ? null
                            : () => _userControlBloc
                                .add(UserControlChangePartnerType(kCele)),
                      ),
                      CupertinoButton(
                        child:
                            snapshot.data == ChangePartnerButtonState.streamer
                                ? CupertinoActivityIndicator()
                                : Text('Streamer'),
                        onPressed: type == kStreamer
                            ? null
                            : () => _userControlBloc
                                .add(UserControlChangePartnerType(kStreamer)),
                      ),
                      CupertinoButton(
                        child: snapshot.data == ChangePartnerButtonState.pro
                            ? CupertinoActivityIndicator()
                            : Text('Pro'),
                        onPressed: type == kPro
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

  Widget _buildManagePartnerType() {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            StreamBuilder<bool>(
                initialData: false,
                stream: _userControlBloc.rejectSubject,
                builder: (context, snapshot) {
                  if (snapshot.data) {
                    return CupertinoButton(
                      child: CupertinoActivityIndicator(),
                      onPressed: () {},
                    );
                  }
                  return CupertinoButton(
                      child: Text('Reject'), onPressed: () => _rejectDialog());
                }),
            StreamBuilder<bool>(
                initialData: false,
                stream: _userControlBloc.updateSubject,
                builder: (context, snapshot) {
                  if (snapshot.data) {
                    return CupertinoButton(
                      child: CupertinoActivityIndicator(),
                      onPressed: () {},
                    );
                  }
                  return CupertinoButton(
                    child: Text('Update'),
                    onPressed: () =>
                        _userControlBloc.add(UserControlAcceptUser()),
                  );
                }),
            StreamBuilder<String>(
                initialData: _userControlBloc.userTypes.first,
                stream: _userControlBloc.selectedUserTypeSubject,
                builder: (context, snapshot) {
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: snapshot.data,
                      icon: Icon(Icons.keyboard_arrow_down),
                      onChanged: (String newValue) {
                        _userControlBloc.selectedUserTypeSubject.add(newValue);
                      },
                      items: _userControlBloc.userTypes
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, textAlign: TextAlign.center),
                        );
                      }).toList(),
                    ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(
                        '${user.name} has ${user.wallet.topUpCoin} topup coins and ${user.wallet.earningCoin} earning coins',
                        textAlign: TextAlign.center)),
              ],
            ),
            _blankSpace,
            Row(
              children: [
                Text('CustomizeTopUp'),
                SizedBox(width: 5),
                StreamBuilder<bool>(
                    initialData: true,
                    stream: _userControlBloc.productIdOrAmountSubject,
                    builder: (context, snapshot) {
                      return CupertinoSwitch(
                          value: snapshot.data,
                          onChanged: (value) => _userControlBloc
                              .productIdOrAmountSubject
                              .add(value));
                    }),
              ],
            ),
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
                        StreamBuilder(
                          initialData: true,
                          stream: _userControlBloc.productIdOrAmountSubject,
                          builder: (context, snapshot) {
                            if (snapshot.data) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CupertinoTextField(
                                  controller:
                                      _userControlBloc.topUpAmountController,
                                  clearButtonMode:
                                      OverlayVisibilityMode.editing,
                                  placeholder: 'TopUp Amount',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                              );
                            } else {
                              return StreamBuilder<String>(
                                  initialData:
                                      _userControlBloc.productList.first,
                                  stream:
                                      _userControlBloc.selectedProductSubject,
                                  builder: (context, snapshot) {
                                    return DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: snapshot.data,
                                        icon: Icon(Icons.keyboard_arrow_down),
                                        onChanged: (String newValue) {
                                          _userControlBloc
                                              .selectedProductSubject
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
                                  });
                            }
                          },
                        ),
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
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            // onChanged: (value) {
                            //   if (value.length > 0)
                            //     try {
                            //       int intValue = int.parse(value);
                            //       _userControlBloc.withdrawAmountController
                            //           .text = intValue.toString();
                            //     } catch (e) {
                            //       showToast('Pleas type valid number');
                            //       _userControlBloc.withdrawAmountController
                            //           .clear();
                            //     }
                            // },
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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('User Control'),
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
                    _blankSpace,
                    if (state.data.type != 0)
                      _buildUpdatePartnerType(state.data.type),
                    if (state.data.isPending == 1) _buildManagePartnerType()
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

  //Reject Dialog
  _rejectDialog() {
    showDialog(
      context: context,
      builder: (_) {
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
              controller: _userControlBloc.rejectCommentController,
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
                _userControlBloc.add(UserControlRejectUser());
                Navigator.pop(context);
              },
              child: Text("Reject"),
            ),
          ],
        );
      },
    );
  }
}
