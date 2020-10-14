import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:MoonGoAdmin/ui/pages/userlistPage.dart';
import 'package:MoonGoAdmin/ui/utils/decrypt.dart';
import 'package:MoonGoAdmin/ui/pages/userdetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final inputText = TextEditingController();
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
          MaterialButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserDetailPage(id: 7)),
            ),
            child: Text("User Detail"),
          ),
          MaterialButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserListPage()),
            ),
            child: Text("User List"),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 15)),
          CupertinoButton(
            onPressed: () => null,
            child: Text("Hola from Main Page"),
          ),
        ]),
      ),
    );
  }
}
