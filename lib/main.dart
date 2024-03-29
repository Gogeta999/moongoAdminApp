import 'package:MoonGoAdmin/api/bloc_patterns/simple_bloc_observer.dart';
import 'package:MoonGoAdmin/api/moonblink_dio.dart';

import 'package:MoonGoAdmin/generated/l10n.dart';
import 'package:MoonGoAdmin/global/router_manager.dart' as Nav;
import 'package:MoonGoAdmin/global/storage_manager.dart';
import 'package:MoonGoAdmin/services/locator.dart';
import 'package:MoonGoAdmin/services/moongo_admin_database.dart';
import 'package:MoonGoAdmin/services/navigation_service.dart';
import 'package:MoonGoAdmin/ui/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageManager.init();
  await MoonGoAdminDB().init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('$state');
    if (state == AppLifecycleState.inactive) {
      StorageManager.sharedPreferences.setBool(isUserOnForeground, false);
      print(StorageManager.sharedPreferences.get(isUserOnForeground));
    }
    if (state == AppLifecycleState.resumed) {
      StorageManager.sharedPreferences.setBool(isUserOnForeground, true);
      print(StorageManager.sharedPreferences.get(isUserOnForeground));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    MoonGoAdminDB().dispose();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> _init() async {
    Bloc.observer = SimpleBlocObserver();
    setupLocator();
    //Banned landscape
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light));
    DioUtils();

    /// will init instance with authorization or not
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: themeModel.themeData(),
      // darkTheme: themeModel.themeData(platformDarkMode: true),
      // locale: localModel.locale,
      localizationsDelegates: const [
        G.delegate,
        // GlobalCupertinoLocalizations.delegate,
        // GlobalMaterialLocalizations.delegate,
        // GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: G.delegate.supportedLocales,
      onGenerateRoute: Nav.Router.generateRoute,
      initialRoute: Nav.RouteName.splash,
      navigatorKey: locator<NavigationService>().navigatorKey,
    ));
  }
}
