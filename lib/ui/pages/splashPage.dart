import 'package:MoonGoAdmin/generated/l10n.dart';
import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  AnimationController _countdownController;

  @override
  void initState() {
    _countdownController =
        AnimationController(vsync: this, duration: Duration(seconds: 4));
    _countdownController.forward();
//    PushNotificationsManager().showTestNotification();
    super.initState();
  }

  @override
  void dispose() {
    // _logoController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: Align(
          alignment: Alignment.center,
          child: SafeArea(
            child: InkWell(
              onTap: () {
                nextPage(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                margin: EdgeInsets.only(right: 20, bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.black.withAlpha(100),
                ),
                child: AnimatedCountdown(
                  context: context,
                  animation:
                      StepTween(begin: 3, end: 0).animate(_countdownController),
                ),
              ),
            ),
          ),
        ),
        onWillPop: () => Future.value(false),
      ),
    );
  }
}

class AnimatedCountdown extends AnimatedWidget {
  final Animation<int> animation;

  AnimatedCountdown({key, this.animation, context})
      : super(key: key, listenable: animation) {
    this.animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        nextPage(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var value = animation.value + 1;
    return Text(
      (value == 0 ? '' : '$value | ') + G.of(context).splashSkip,
      style: TextStyle(color: Colors.white),
    );
  }
}

void nextPage(context) {
  // final hasUser = StorageManager.localStorage.getItem(mUser);
  var hasUser;

  if (hasUser == null) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(RouteName.login, (route) => false);
  } else {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(RouteName.main, (route) => false);
  }
}
