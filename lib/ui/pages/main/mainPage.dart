import 'package:MoonGoAdmin/api/moonblink_dio.dart';
import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:MoonGoAdmin/global/storage_manager.dart';
import 'package:MoonGoAdmin/ui/pages/pendinglistPage.dart';
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
            onEditingComplete: () {
              var userId = decrypt(inputText.text);
              print(userId.substring(9, 12));
              inputText.text =
                  'Index number 3 Between 8 and o,Sometimes Toast will wrong if userID is more than 5 integers\n$userId ';
              var _id = userId.substring(9, 13);
              showToast('User ID is: ' '$_id');
            },
          ),
          _padding(20),
          RaisedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserDetailPage(id: 6)),
            ),
            child: Text("User Detail"),
          ),
          _padding(20),
          RaisedButton(
            color: Colors.lightBlue[100],
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserListPage()),
            ),
            child: Text("User List"),
          ),
          _padding(20),
          RaisedButton(
            color: Colors.lightBlue[100],
            onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => PendingListPage()),
            ),
            child: Text('Pending List'),
          ),
          _padding(20),
          StreamBuilder<bool>(
              initialData: false,
              stream: _logoutButton,
              builder: (context, snapshot) {
                if (snapshot.data) {
                  return RaisedButton(
                    color: Colors.lightBlue[100],
                    onPressed: () {},
                    child: CupertinoActivityIndicator(),
                  );
                }
                return RaisedButton(
                  color: Colors.lightBlue[100],
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
}
