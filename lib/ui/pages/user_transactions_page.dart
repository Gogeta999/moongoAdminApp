import 'package:MoonGoAdmin/api/bloc_patterns/user_control/user_control_bloc.dart';
import 'package:MoonGoAdmin/api/bloc_patterns/user_transactions/bloc/user_transactions_bloc.dart';
import 'package:MoonGoAdmin/models/transaction.dart';
import 'package:MoonGoAdmin/ui/utils/formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class UserTransactionsPage extends StatefulWidget {
  @override
  _UserTransactionsPageState createState() => _UserTransactionsPageState();
}

class _UserTransactionsPageState extends State<UserTransactionsPage> {
  UserTransactionsBloc _userTransactionsBloc;

  @override
  void initState() {
    _userTransactionsBloc = UserTransactionsBloc();
    super.initState();
  }

  @override
  void dispose() {
    _userTransactionsBloc.dispose();
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
                  stream: _userTransactionsBloc.startDateSubject,
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
                                _userTransactionsBloc.startDateSubject
                                    .add(Formatter.yyyymmdd(dateTime));
                              });
                            })
                      ],
                    );
                  }),
              //End Date
              StreamBuilder<String>(
                  initialData: null,
                  stream: _userTransactionsBloc.endDateSubject,
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
                                _userTransactionsBloc.endDateSubject
                                    .add(Formatter.yyyymmdd(dateTime));
                              });
                            })
                      ],
                    );
                  }),
              StreamBuilder<String>(
                stream: _userTransactionsBloc.typeSubject,
                builder: (context, snapshot) {
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: snapshot.data,
                      hint: Text('Transaction Type'),
                      icon: Icon(Icons.keyboard_arrow_down),
                      onChanged: (String newValue) {
                        _userTransactionsBloc.typeSubject.add(newValue);
                      },
                      items: _userTransactionsBloc.transactionTypes
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
              stream: _userTransactionsBloc.querySubject,
              builder: (context, snapshot) {
                if (snapshot.data) {
                  return CupertinoButton(
                    child: CupertinoActivityIndicator(),
                    onPressed: () {},
                  );
                }
                return CupertinoButton(
                  child: Text('Query Transaction'),
                  onPressed: () => _userTransactionsBloc.queryTransaction(),
                );
              })
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return StreamBuilder<List<Transaction>>(
        initialData: null,
        stream: _userTransactionsBloc.transactionsSubject,
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
                    stream: _userTransactionsBloc.hasReachedMax,
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
                                      Text(
                                          'Name            -${item.user.name}'),
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
                          controller: _userTransactionsBloc.scrollController
                            ..addListener(() =>
                                _userTransactionsBloc.queryTransactionMore()));
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
