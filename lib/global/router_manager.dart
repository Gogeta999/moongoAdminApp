import 'package:MoonGoAdmin/ui/pages/loginPage.dart';
import 'package:MoonGoAdmin/ui/pages/main/mainPage.dart';
import 'package:MoonGoAdmin/ui/pages/search_user_page.dart';
import 'package:MoonGoAdmin/ui/pages/splashPage.dart';
import 'package:MoonGoAdmin/ui/pages/user_control_page.dart';
import 'package:MoonGoAdmin/ui/pages/userdetail.dart';
import 'package:MoonGoAdmin/ui/utils/page_route_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class RouteName {
  static const String splash = 'splash';
  static const String main = '/';
  static const String login = 'login';
  static const String search = 'search';
  static const String userControl = 'userControl';
  static const String userDetail = 'userDetail';
}

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.splash:
        return NoAnimRouteBuilder(SplashPage());
      case RouteName.main:
        return NoAnimRouteBuilder(MainPage());
      case RouteName.login:
        return CupertinoPageRoute(
            fullscreenDialog: true, builder: (_) => LoginPage());
      case RouteName.search:
        return CupertinoPageRoute(builder: (_) => SearchUserPage());
      case RouteName.userControl:
        return CupertinoPageRoute(builder: (_) => UserControlPage(userId: settings.arguments));
      case RouteName.userDetail:
        return CupertinoPageRoute(builder: (_) => UserDetailPage(id: settings.arguments));
      default:
        return CupertinoPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ));
    }
  }
}

//Pop route
class PopRoute extends PopupRoute {
  final Duration _duration = Duration(milliseconds: 300);
  Widget child;

  PopRoute({@required this.child});

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Duration get transitionDuration => _duration;
}
