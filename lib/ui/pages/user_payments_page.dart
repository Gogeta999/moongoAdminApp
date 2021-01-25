import 'package:MoonGoAdmin/api/bloc_patterns/user_payments/user_payments_bloc.dart';
import 'package:MoonGoAdmin/models/payment.dart';
import 'package:MoonGoAdmin/ui/helper/full_screen_image_view.dart';
import 'package:MoonGoAdmin/ui/utils/constants.dart';
import 'package:MoonGoAdmin/ui/utils/formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _userPaymentsBloc.queryPayment();
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
                    padding: EdgeInsets.zero,
                    child: CupertinoActivityIndicator(),
                    onPressed: () {},
                  );
                }
                return CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text('Query Payments'),
                  onPressed: () => _userPaymentsBloc.queryPayment(),
                );
              })
        ],
      ),
    );
  }

  _showConfirmDialog(int paymentId, String productName, String title) {
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
    if (status == 1 && productName == customProduct) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            final _controller = TextEditingController();
            return CupertinoAlertDialog(
              title: Text('Confirm $title'),
              content: CupertinoTextField(
                controller: _controller,
                placeholder: 'Add coins amount',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.done,
              ),
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
                      _userPaymentsBloc.changeStatusOfPayment(
                        paymentId,
                        productName,
                        "",
                        status,
                        _controller.text,
                      );
                    })
              ],
            );
          });
    } else if (status == 2) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            final _controller = TextEditingController();
            return CupertinoAlertDialog(
              title: Text('Confirm $title'),
              content: CupertinoTextField(
                controller: _controller,
                placeholder: 'Add a note',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
              ),
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
                      _userPaymentsBloc.changeStatusOfPayment(
                          paymentId, productName, _controller.text, status);
                    })
              ],
            );
          });
    } else {
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
                      _userPaymentsBloc.changeStatusOfPayment(
                          paymentId, productName, "", status);
                    })
              ],
            );
          });
    }
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
                child: Center(child: Text('No Payments')));
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
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        fullscreenDialog: true,
                                        builder: (_) => FullScreenImageView(
                                            imageUrls: item.transactionImage)));
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.blue, width: 1),
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.all(4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: item.userProfileImage,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  CircleAvatar(
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            backgroundImage: imageProvider,
                                          ),
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(item.username),
                                        )
                                      ],
                                    ),
                                    () {
                                      if (item.item.name == customProduct) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('No: ${index + 1} '),
                                            Text('Product -> Custom Product'),
                                            Text(
                                                'Transfer Amount -> ${item.transferAmount}'),
                                            Text(
                                                'Description -> ${item.description}'),
                                            getPaymentStatus(item.status),
                                            Text('CreatedAt -> ' +
                                                Formatter.yyyymmdd(
                                                    DateTime.parse(
                                                        item.createdAt))),
                                            Text(
                                                'UpdatedBy -> ${item.updatedBy}'),
                                            if (item.note != null &&
                                                item.note.isNotEmpty)
                                              Text('Note -> ${item.note}'),
                                          ],
                                        );
                                      } else {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('No: ${index + 1} '),
                                            Text(
                                                'Product -> Coins -${item.item.mbCoin}'),
                                            Text(
                                                'Value -> ${item.item.value} ${item.item.currencyCode}'),
                                            getPaymentStatus(item.status),
                                            Text('CreatedAt -> ' +
                                                Formatter.yyyymmdd(
                                                    DateTime.parse(
                                                        item.createdAt))),
                                            Text(
                                                'UpdatedBy -> ${item.updatedBy}'),
                                            if (item.note != null &&
                                                item.note.isNotEmpty)
                                              Text('Note -> ${item.note}'),
                                          ],
                                        );
                                      }
                                    }(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          child: Text(enumToString(
                                              PaymentStatus.SUCCESS)),
                                          onPressed: () {
                                            _showConfirmDialog(
                                                item.id,
                                                item.item.name,
                                                enumToString(
                                                    PaymentStatus.SUCCESS));
                                          },
                                        ),
                                        CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          child: Text(enumToString(
                                              PaymentStatus.REJECT)),
                                          onPressed: () {
                                            _showConfirmDialog(
                                                item.id,
                                                item.item.name,
                                                enumToString(
                                                    PaymentStatus.REJECT));
                                          },
                                        ),
                                        CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          child: Text(enumToString(
                                              PaymentStatus.REFUND)),
                                          onPressed: () {
                                            _showConfirmDialog(
                                                item.id,
                                                item.item.name,
                                                enumToString(
                                                    PaymentStatus.REFUND));
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                          itemCount: snapshot2.data
                              ? snapshot.data.length + 1
                              : snapshot.data.length,
                          controller: _userPaymentsBloc.scrollController
                            ..addListener(
                                () => _userPaymentsBloc.queryPaymentMore()));
                    })),
          );
        });
  }

  Widget get _blankSpace => SizedBox(height: 10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment List'),
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
