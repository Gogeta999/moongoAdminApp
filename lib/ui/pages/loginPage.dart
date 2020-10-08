import 'package:MoonGoAdmin/bloc_patterns/loginBloc/user_login_bloc.dart';
import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

enum LoginButtonState { initial, loading }

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final BehaviorSubject<LoginButtonState> _loginSubject =
      BehaviorSubject.seeded(LoginButtonState.initial);

  final UserLoginBloc _userLoginBloc = UserLoginBloc();

  Widget _blankSpace() => SizedBox(height: 10);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _userLoginBloc,
      child: BlocListener<UserLoginBloc, UserLoginState>(
        listener: (context, state) {
          if (state is UserLoginFailure) {
            _loginSubject.add(LoginButtonState.initial);
            showToast(state.error.toString());
          }
          if (state is UserLoginSuccess) {
            _loginSubject.add(LoginButtonState.initial);
            Navigator.pushNamedAndRemoveUntil(
                context, RouteName.main, (route) => false);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('MoonGo'),
            backgroundColor: Colors.lightBlue[100],
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: Center(
                      child: Text(
                    'MoonGo Admin\nLogin',
                    style: Theme.of(context).textTheme.headline4,
                    textAlign: TextAlign.center,
                  )),
                ),
                CupertinoTextField(
                  controller: _mailController,
                  placeholder: 'Enter mail',
                  textAlign: TextAlign.center,
                ),
                _blankSpace(),
                CupertinoTextField(
                  controller: _passwordController,
                  placeholder: 'Enter password',
                  textAlign: TextAlign.center,
                  obscureText: true,
                ),
                _blankSpace(),
                StreamBuilder<LoginButtonState>(
                    initialData: LoginButtonState.initial,
                    stream: _loginSubject,
                    builder: (context, snapshot) {
                      if (snapshot.data == LoginButtonState.loading) {
                        return CupertinoButton(
                          child: CupertinoActivityIndicator(),
                          onPressed: () {},
                        );
                      }
                      return CupertinoButton(
                        child: Text('Login'),
                        onPressed: _onTapLogin,
                      );
                    })
              ],
            ),
          )),
        ),
      ),
    );
  }

  _onTapLogin() {
    String mail = _mailController.text;
    String password = _passwordController.text;
    if (mail == null || mail.isEmpty) {
      showToast('Mail can\'t be blanked');
      return;
    }
    if (password == null || password.isEmpty) {
      showToast('Password can\'t be blanked');
      return;
    }
    _loginSubject.add(LoginButtonState.loading);
    _userLoginBloc
        .add(UserLoginLogin(mail, password));
  }
}
