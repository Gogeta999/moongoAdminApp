import 'package:MoonGoAdmin/api/moonblink_dio.dart';
import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:MoonGoAdmin/global/storage_manager.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:MoonGoAdmin/ui/pages/decryptionPage.dart';
import 'package:MoonGoAdmin/ui/pages/pendinglistPage.dart';
import 'package:MoonGoAdmin/ui/pages/pendingpostlist.dart';
import 'package:MoonGoAdmin/ui/pages/user_payments_page.dart';
import 'package:MoonGoAdmin/ui/pages/user_transactions_page.dart';
import 'package:MoonGoAdmin/ui/pages/userlistPage.dart';
import 'package:MoonGoAdmin/ui/utils/constants.dart';
import 'package:MoonGoAdmin/ui/utils/decrypt.dart';
import 'package:MoonGoAdmin/ui/pages/userdetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final inputText = TextEditingController();
  BehaviorSubject<bool> _logoutButton = BehaviorSubject.seeded(false);

  Widget _padding(double height) => SizedBox(
        height: height,
      );

  // @override
  // void initState() {
  //   super.initState();
  //   _initData();
  // }

  // void _initData() {
  //   Future.wait([
  //     _initUserWallet(),
  //   ], eagerError: true)
  //       .then((value) {
  //     setState(() {
  //       // _isPageLoading = false;
  //     });
  //   });
  // }

  // Future<void> _initUserWallet() async {
  //   MoonblinkRepository.getAdminPosts(3, 1).then((value) {
  //     print(value);
  //   }, onError: (e) {
  //     print(e);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main'),
        backgroundColor: Colors.lightBlue[100],
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, RouteName.search),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(padding: EdgeInsets.all(16), children: [
          CupertinoTextField(
            maxLines: null,
            minLines: null,
            expands: true,
            controller: inputText,
            placeholder: 'Input Encrypted Code Here',
            autocorrect: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => _onTapDecrypt(),
            clearButtonMode: OverlayVisibilityMode.always,
            // onEditingComplete: () {
            //   var userId = decrypt(inputText.text);
            //   print(userId.substring(9, 12));
            //   inputText.text =
            //       'Index number 3 Between 8 and o,Sometimes Toast will wrong if userID is more than 5 integers\n$userId ';
            //   var _id = userId.substring(9, 13);
            //   showToast('User ID is: ' '$_id');
            // },
          ),
          _padding(20),
          CupertinoButton.filled(
            onPressed: () => _onTapDecrypt(),
            child: Text("Decrypt ID, Paste Correctly"),
          ),
          _padding(20),
          CupertinoButton.filled(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserListPage()),
            ),
            child: Text("User List"),
          ),
          _padding(20),
          CupertinoButton.filled(
            onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => PendingListPage()),
            ),
            child: Text('Pending List'),
          ),
          _padding(20),
          CupertinoButton.filled(
            onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => PendingPostListPage()),
            ),
            child: Text('Pending Posts'),
          ),
          _padding(20),
          CupertinoButton.filled(
            onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => UserTransactionsPage()),
            ),
            child: Text('Transaction List'),
          ),
          _padding(20),
          CupertinoButton.filled(
            onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => UserPaymentsPage()),
            ),
            child: Text('Payment List'),
          ),
          _padding(200),
          StreamBuilder<bool>(
              initialData: false,
              stream: _logoutButton,
              builder: (context, snapshot) {
                if (snapshot.data) {
                  return CupertinoButton.filled(
                    onPressed: () {},
                    child: CupertinoActivityIndicator(),
                  );
                }
                return CupertinoButton.filled(
                  onPressed: () => _logout(),
                  child: Text('Log Out'),
                );
              }),
        ]),
      ),
    );
  }

  _logout() async {
    await StorageManager.sharedPreferences.remove(token);
    DioUtils().initWithoutAuthorization();
    _logoutButton.add(false);
    Navigator.pushNamedAndRemoveUntil(
        context, RouteName.login, (route) => false);
  }

  _onTapDecrypt() {
    try {
      final String s = decrypt(inputText.text);
      var userID = int.parse(s);
      // int userId = 0;
      // int commaCount = 0;
      // for (int i = 0; i < s.length; ++i) {
      //   if (s[i] == ',') {
      //     commaCount++;
      //     if (commaCount == 3) {
      //       for (int j = i + 2; j < s.length; ++j) {
      //         if (s[j] == ',') break;
      //         userId *= 10;
      //         switch (s[j]) {
      //           case '0':
      //             userId += 0;
      //             break;
      //           case '1':
      //             userId += 1;
      //             break;
      //           case '2':
      //             userId += 2;
      //             break;
      //           case '3':
      //             userId += 3;
      //             break;
      //           case '4':
      //             userId += 4;
      //             break;
      //           case '5':
      //             userId += 5;
      //             break;
      //           case '6':
      //             userId += 6;
      //             break;
      //           case '7':
      //             userId += 7;
      //             break;
      //           case '8':
      //             userId += 8;
      //             break;
      //           case '9':
      //             userId += 9;
      //             break;
      //         }
      //       }
      //     }
      //   }
      // }
      // print("$userId");
      Navigator.pushNamed(context, RouteName.userControl, arguments: userID);
    } catch (e) {
      print("$e");
      showToast("Wrong Encrypted Code");
    }
  }
}
