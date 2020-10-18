import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DecryptionPage extends StatelessWidget {
  final String text;
  DecryptionPage(this.text);
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
        child: Card(
          child: Container(
            child: Text(
                'Index number 3 Between 8 and o,Sometimes Toast will wrong if userID is more than 5 integers\n$text '),
          ),
        ),
      ),
    );
  }
}
