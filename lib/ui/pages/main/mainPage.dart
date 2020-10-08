import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
      body: Center(
        child: CupertinoButton(
          onPressed: () => showToast('0'),
          child: Text("Hola from Main Page"),
        ),
      ),
    );
  }
}