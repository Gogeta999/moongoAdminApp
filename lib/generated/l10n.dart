// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class G {
  G();
  
  static G current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<G> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      G.current = G();
      
      return G.current;
    });
  } 

  static G of(BuildContext context) {
    return Localizations.of<G>(context, G);
  }

  /// `Follow System`
  String get autoWithSystem {
    return Intl.message(
      'Follow System',
      name: 'autoWithSystem',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `Please Login First`
  String get forceLoginTitle {
    return Intl.message(
      'Please Login First',
      name: 'forceLoginTitle',
      desc: '',
      args: [],
    );
  }

  /// `You need to login to continue`
  String get forceLoginContent {
    return Intl.message(
      'You need to login to continue',
      name: 'forceLoginContent',
      desc: '',
      args: [],
    );
  }

  /// `Update Your App Version`
  String get forceUpdateTitle {
    return Intl.message(
      'Update Your App Version',
      name: 'forceUpdateTitle',
      desc: '',
      args: [],
    );
  }

  /// `You need to update app version`
  String get forceUpdateContent {
    return Intl.message(
      'You need to update app version',
      name: 'forceUpdateContent',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get splashSkip {
    return Intl.message(
      'Skip',
      name: 'splashSkip',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<G> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<G> load(Locale locale) => G.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}