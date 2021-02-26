import 'package:MoonGoAdmin/api/bloc_patterns/user_control/user_control_bloc.dart';
import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:MoonGoAdmin/models/transaction.dart';
import 'package:MoonGoAdmin/models/user_model.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:MoonGoAdmin/ui/utils/formatter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MoonGoAdmin/ui/utils/constants.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

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

  Widget _buildPartnerType(String name, int type, int verified) {
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
      case kUnverified:
        text = '$name\'s partner type is **Unverifed**';
        break;
      case kWarrior:
        text = verified == 1
            ? '$name\'s partner type is **Warrior**'
            : '$name mark as Warrior User But Not Verified';
        break;
      default:
        text = 'Unknown User';
        break;
    }
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Text(text, textAlign: TextAlign.center),
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

  Widget _buildUpdateToType6Unverified() {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CupertinoButton(
              child: Text('Update'),
              onPressed: () async {
                try {
                  await MoonblinkRepository.updateUserType(widget.userId, 6);
                  showToast("Success");
                  Navigator.pushReplacementNamed(context, RouteName.userControl,
                      arguments: widget.userId);
                } catch (e) {
                  showToast(e.toString());
                }
              },
            ),
            Text('Mark As Warrior(Not Partner Yet)'),
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

  Widget _buildUserTransaction() {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text('Transaction',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //Start Date
              StreamBuilder<String>(
                  initialData: null,
                  stream: _userControlBloc.startDateSubject,
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: CupertinoActivityIndicator(),
                          onPressed: () {});
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Start Date'),
                        CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Text('${snapshot.data}'),
                            onPressed: () {
                              DatePicker.showDatePicker(context,
                                  currentTime: DateTime.parse(snapshot.data),
                                  onConfirm: (DateTime dateTime) {
                                _userControlBloc.startDateSubject
                                    .add(Formatter.yyyymmdd(dateTime));
                              });
                            })
                      ],
                    );
                  }),
              //End Date
              StreamBuilder<String>(
                  initialData: null,
                  stream: _userControlBloc.endDateSubject,
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: CupertinoActivityIndicator(),
                          onPressed: () {});
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('End Date'),
                        CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Text('${snapshot.data}'),
                            onPressed: () {
                              DatePicker.showDatePicker(context,
                                  currentTime: DateTime.parse(snapshot.data),
                                  onConfirm: (DateTime dateTime) {
                                _userControlBloc.endDateSubject
                                    .add(Formatter.yyyymmdd(dateTime));
                              });
                            })
                      ],
                    );
                  }),
              StreamBuilder<String>(
                stream: _userControlBloc.typeSubject,
                builder: (context, snapshot) {
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: snapshot.data,
                      hint: Text('Transaction Type'),
                      icon: Icon(Icons.keyboard_arrow_down),
                      onChanged: (String newValue) {
                        _userControlBloc.typeSubject.add(newValue);
                      },
                      items: _userControlBloc.transactionTypes
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, textAlign: TextAlign.center),
                        );
                      }).toList(),
                    ),
                  );
                },
              )
            ],
          ),
          StreamBuilder<bool>(
              initialData: false,
              stream: _userControlBloc.querySubject,
              builder: (context, snapshot) {
                if (snapshot.data) {
                  return CupertinoButton(
                    child: CupertinoActivityIndicator(),
                    onPressed: () {},
                  );
                }
                return CupertinoButton(
                  child: Text('Query Transaction'),
                  onPressed: () => _userControlBloc.queryTransaction(),
                );
              })
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return StreamBuilder<List<Transaction>>(
        initialData: null,
        stream: _userControlBloc.transactionsSubject,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          }
          if (snapshot.data.isEmpty) {
            return Card(
                elevation: 8,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Center(child: Text('No Transactions')));
          }
          return Card(
              elevation: 8,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.65,
                child: StreamBuilder<bool>(
                    initialData: false,
                    stream: _userControlBloc.hasReachedMax,
                    builder: (context, snapshot2) {
                      return ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (index >= snapshot.data.length) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 24),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.blue, width: 1),
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  'End',
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            Transaction item = snapshot.data[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 24),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.blue, width: 1),
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('No: ${index + 1}'),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Type            - ${item.type}'),
                                      Text('Value           - ${item.value}'),
                                      Text('CreatedAt   - ${item.createdAt}'),
                                      Text('UpdatedAt   - ${item.updatedAt}'),
                                      Text('CreatedBy   - ${item.createdBy}'),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                          itemCount: snapshot2.data
                              ? snapshot.data.length + 1
                              : snapshot.data.length,
                          controller: _userControlBloc.scrollController
                            ..addListener(
                                () => _userControlBloc.queryTransactionMore()));
                    }),
              ));
        });
  }

  Widget _buildUpdateVip(int vip) {
    return Card(
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Current Vip is **$vip**'),
              StreamBuilder<bool>(
                  initialData: false,
                  stream: _userControlBloc.updateVipButtonSubject,
                  builder: (context, snapshot) {
                    if (snapshot.data) {
                      return CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CupertinoActivityIndicator(),
                        onPressed: () {},
                      );
                    }
                    return CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Update Vip'),
                      onPressed: () {
                        _userControlBloc.add(UserControlUpdateUserVip());
                      },
                    );
                  }),
              StreamBuilder<String>(
                  initialData: _userControlBloc.vipTypes.first,
                  stream: _userControlBloc.selectedVipTypeSubect,
                  builder: (context, snapshot) {
                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: snapshot.data,
                        icon: Icon(Icons.keyboard_arrow_down),
                        onChanged: (String newValue) {
                          _userControlBloc.selectedVipTypeSubect.add(newValue);
                        },
                        items: _userControlBloc.vipTypes
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
        ));
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
          actions: [
            CupertinoButton(
                child: Text(
                  'Detail Page',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  if (_userControlBloc.state is UserControlFetchedSuccess) {
                    Navigator.pushNamed(context, RouteName.userDetail,
                        arguments: (_userControlBloc.state
                                as UserControlFetchedSuccess)
                            .data
                            .id);
                  } else {
                    print('Not in Succes State');
                  }
                })
          ],
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
              if (state is UserControlAcceptUserSuccess) {
                showToast('Accept Success');
              }
              if (state is UserControlAcceptUserFailure) {
                showToast(state.error.toString());
              }
              if (state is UserControlRejectUserSuccess) {
                showToast('Reject Success');
              }
              if (state is UserControlRejectUserFailure) {
                showToast(state.error.toString());
              }
            },
            buildWhen: (previous, current) {
              return current is UserControlInitial ||
                  current is UserControlFetchedFailure ||
                  current is UserControlFetchedSuccess;
            },
            builder: (context, state) {
              if (state is UserControlInitial) {
                return Center(child: CupertinoActivityIndicator());
              }
              if (state is UserControlFetchedFailure) {
                return Center(child: Text(state.error.toString()));
              }
              if (state is UserControlFetchedSuccess) {
                return ListView(
                  children: [
                    _buildPartnerType(
                        state.data.name, state.data.type, state.data.verified),
                    // Text('Verifed Query===' + state.data.verified.toString()),
                    //_blankSpace,
                    //_buildGoToDetailPage(state.data.id),

                    _blankSpace,
                    _buildCoinControl(state.data),
                    _blankSpace,
                    if (state.data.type == 0) _buildUpdateToType6Unverified(),
                    _blankSpace,
                    if (state.data.type != 0)
                      _buildUpdatePartnerType(state.data.type),
                    if (state.data.type != 0) _blankSpace,
                    if (state.data.isPending == 1) _buildManagePartnerType(),
                    if (state.data.isPending == 1) _blankSpace,
                    if (state.data.type == 0 || state.data.type == 5)
                      _buildUpdateVip(state.data.vip),
                    if (state.data.type == 0 || state.data.type == 5)
                      _blankSpace,
                    _buildUserTransaction(),
                    _blankSpace,
                    _buildTransactionList(),
                    _blankSpace,
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
