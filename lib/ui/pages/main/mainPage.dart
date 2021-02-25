import 'package:MoonGoAdmin/api/moonblink_dio.dart';
import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:MoonGoAdmin/global/storage_manager.dart';
import 'package:MoonGoAdmin/models/wallet_model.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:MoonGoAdmin/ui/pages/agency_transactions_page.dart';
import 'package:MoonGoAdmin/ui/pages/user_transactions_page.dart';
import 'package:MoonGoAdmin/ui/pages/warrior_partners_page.dart';
import 'package:MoonGoAdmin/ui/utils/constants.dart';
import 'package:MoonGoAdmin/ui/utils/decrypt.dart';
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
  BehaviorSubject<Wallet> _userWallet = BehaviorSubject();

  Widget _padding(double height) => SizedBox(
        height: height,
      );

  @override
  void initState() {
    MoonblinkRepository.getUserWallet().then((value) => _userWallet.add(value),
        onError: (e) => _userWallet.addError(e));
    super.initState();
  }

  @override
  void dispose() {
    _logoutButton.close();
    _userWallet.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.lightBlue[100],
      ),
      body: SafeArea(
        child: ListView(padding: EdgeInsets.all(16), children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Welcome, ${StorageManager.sharedPreferences.getString(kUserName)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          _padding(10),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(10.0)),
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Coins'),
                StreamBuilder<Wallet>(
                    initialData: null,
                    stream: _userWallet,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error');
                      }
                      if (snapshot.data == null) {
                        return CupertinoActivityIndicator();
                      }
                      return Text(
                        snapshot.data.value.toString(),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      );
                    })
              ],
            ),
          ),
          _padding(20),
          CupertinoButton.filled(
            child: Text('Search Your Warrior Partner'),
            onPressed: () => Navigator.pushNamed(context, RouteName.search),
          ),
          _padding(20),
          CupertinoButton.filled(
            onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => WarriorPartnersPage()),
            ),
            child: Text('Your Warrior Partners'),
          ),
          _padding(20),
          CupertinoButton.filled(
            onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => AgencyTransactionsPage()),
            ),
            child: Text('Transaction List'),
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
    await StorageManager.sharedPreferences.remove(kUserId);
    await StorageManager.sharedPreferences.remove(kUserName);
    await StorageManager.sharedPreferences.remove(kUserEmail);
    await StorageManager.sharedPreferences.remove(kUserType);
    await StorageManager.sharedPreferences.remove(kProfileImage);
    await StorageManager.sharedPreferences.remove(kCoverImage);
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
