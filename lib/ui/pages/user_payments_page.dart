import 'package:MoonGoAdmin/api/bloc_patterns/user_payments/user_payments_bloc.dart';
import 'package:MoonGoAdmin/models/payment.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:MoonGoAdmin/ui/helper/full_screen_image_view.dart';
import 'package:MoonGoAdmin/ui/utils/constants.dart';
import 'package:MoonGoAdmin/ui/utils/formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:oktoast/oktoast.dart';

class UserPaymentsPage extends StatefulWidget {
  @override
  _UserPaymentsPageState createState() => _UserPaymentsPageState();
}

class _UserPaymentsPageState extends State<UserPaymentsPage> {
  UserPaymentsBloc _userPaymentsBloc = UserPaymentsBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _userPaymentsBloc.dispose();
    super.dispose();
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
                  stream: _userPaymentsBloc.startDateSubject,
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
                                _userPaymentsBloc.startDateSubject
                                    .add(Formatter.yyyymmdd(dateTime));
                              });
                            })
                      ],
                    );
                  }),
              //End Date
              StreamBuilder<String>(
                  initialData: null,
                  stream: _userPaymentsBloc.endDateSubject,
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
                                _userPaymentsBloc.endDateSubject
                                    .add(Formatter.yyyymmdd(dateTime));
                              });
                            })
                      ],
                    );
                  }),
              // Status
              StreamBuilder<int>(
                initialData: 0,
                stream: _userPaymentsBloc.statusSubject,
                builder: (context, snapshot) {
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _userPaymentsBloc.statusTypes[snapshot.data],
                      hint: Text('All'),
                      icon: Icon(Icons.keyboard_arrow_down),
                      onChanged: (String newValue) {
                        int status = 0;
                        if (newValue == 'All') {
                          status = 0;
                        } else if (newValue == 'Pending') {
                          status = 1;
                        } else if (newValue == 'Success') {
                          status = 2;
                        } else if (newValue == 'Reject') {
                          status = 3;
                        } else if (newValue == 'Refund') {
                          status = 4;
                        } else {
                          status = 0;
                        }
                        _userPaymentsBloc.statusSubject.add(status);
                      },
                      items: _userPaymentsBloc.statusTypes
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, textAlign: TextAlign.center),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
          StreamBuilder<bool>(
              initialData: false,
              stream: _userPaymentsBloc.querySubject,
              builder: (context, snapshot) {
                if (snapshot.data) {
                  return CupertinoButton(
                    child: CupertinoActivityIndicator(),
                    onPressed: () {},
                  );
                }
                return CupertinoButton(
                  child: Text('Query Transaction'),
                  onPressed: () => _userPaymentsBloc.queryTransaction(),
                );
              })
        ],
      ),
    );
  }

  _showConfirmDialog(int paymentId, String title) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Confirm $title'),
            actions: [
              CupertinoButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              CupertinoButton(
                  child: Text('$title'),
                  onPressed: () {
                    Navigator.pop(context);
                    int status = -1;
                    if (title == enumToString(PaymentStatus.SUCCESS)) {
                      status = 1;
                    } else if (title == enumToString(PaymentStatus.REJECT)) {
                      status = 2;
                    } else if (title == enumToString(PaymentStatus.REFUND)) {
                      status = 3;
                    }
                    if (status == -1) {
                      showToast("Wrong Staus");
                      return;
                    }
                    _userPaymentsBloc.changeStatusOfPayment(paymentId, status);
                  })
            ],
          );
        });
  }

  String enumToString(PaymentStatus paymentStatus) {
    return paymentStatus.toString().split('.')[1];
  }

  Widget getPaymentStatus(int status) {
    if (status == PaymentStatus.PENDING.index) {
      return Text('Pending',
          style: TextStyle(color: Colors.blue, fontSize: 16.0));
    } else if (status == PaymentStatus.SUCCESS.index) {
      return Text('Success',
          style: TextStyle(color: Colors.green, fontSize: 16.0));
    } else if (status == PaymentStatus.REJECT.index) {
      return Text('Reject',
          style: TextStyle(color: Colors.red, fontSize: 16.0));
    } else if (status == PaymentStatus.REFUND.index) {
      return Text('Refund',
          style: TextStyle(color: Colors.amber, fontSize: 16.0));
    } else {
      return Text('Unknown',
          style: TextStyle(color: Colors.grey, fontSize: 16.0));
    }
  }

  Widget _buildTransactionList() {
    return StreamBuilder<List<Payment>>(
        initialData: null,
        stream: _userPaymentsBloc.paymentsSubject,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          }
          if (snapshot.data.isEmpty) {
            return Card(
                elevation: 8,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Center(child: Text('No Transactions')));
          }
          return Expanded(
            child: Card(
                elevation: 8,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: StreamBuilder<bool>(
                    initialData: false,
                    stream: _userPaymentsBloc.hasReachedMax,
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
                            final item = snapshot.data[index];
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
                                  Text('No: ${index + 1} '),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CupertinoButton(
                                            child: CachedNetworkImage(
                                                imageUrl: item.transactionImage,
                                                imageBuilder:
                                                    (context, provider) {
                                                  return Container(
                                                      width: double.infinity,
                                                      constraints:
                                                          BoxConstraints(
                                                        maxHeight:
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.4,
                                                      ),
                                                      child: Image(
                                                          image: provider,
                                                          fit: BoxFit.cover));
                                                },
                                                placeholder: (_, __) =>
                                                    CupertinoActivityIndicator(),
                                                errorWidget: (_, __, ___) =>
                                                    Icon(Icons.error)),
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                      fullscreenDialog: true,
                                                      builder: (_) =>
                                                          FullScreenImageView(
                                                              imageUrl: item
                                                                  .transactionImage)));
                                            }),
                                        Text(
                                            'Product -> Coins -${item.item.mbCoin}'),
                                        Text('Value -> ${item.item.value}'),
                                        getPaymentStatus(item.status),
                                        Text('CreatedAt -> ${item.createdAt}'),
                                        Text('UpdatedBy -> ${item.updatedBy}'),
                                        Row(
                                          children: [
                                            CupertinoButton(
                                              child: Text(enumToString(
                                                  PaymentStatus.SUCCESS)),
                                              onPressed: () {
                                                _showConfirmDialog(
                                                    item.id,
                                                    enumToString(
                                                        PaymentStatus.SUCCESS));
                                              },
                                            ),
                                            CupertinoButton(
                                              child: Text(enumToString(
                                                  PaymentStatus.REJECT)),
                                              onPressed: () {
                                                _showConfirmDialog(
                                                    item.id,
                                                    enumToString(
                                                        PaymentStatus.REJECT));
                                              },
                                            ),
                                            CupertinoButton(
                                              child: Text(enumToString(
                                                  PaymentStatus.REFUND)),
                                              onPressed: () {
                                                _showConfirmDialog(
                                                    item.id,
                                                    enumToString(
                                                        PaymentStatus.REFUND));
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                          itemCount: snapshot2.data
                              ? snapshot.data.length + 1
                              : snapshot.data.length,
                          controller: _userPaymentsBloc.scrollController
                            ..addListener(() =>
                                _userPaymentsBloc.queryTransactionMore()));
                    })),
          );
        });
  }

  Widget get _blankSpace => SizedBox(height: 10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction List'),
      ),
      body: Column(
        children: [
          _blankSpace,
          _buildUserTransaction(),
          _blankSpace,
          _buildTransactionList(),
          _blankSpace,
        ],
      ),
    );
  }
}
