import 'package:MoonGoAdmin/generated/l10n.dart';
import 'package:MoonGoAdmin/global/storage_manager.dart';
import 'package:flutter/material.dart';

class LocaleModel extends ChangeNotifier {
//  static const localeNameList = ['auto', '中文', 'English'];
  static const localeValueList = ['', 'en', 'my', 'zh'];

  //
  static const mLocaleIndex = 'mLocaleIndex';

  int _localeIndex;

  int get localeIndex => _localeIndex;

  Locale get locale {
    if (_localeIndex > 0) {
      var value = localeValueList[_localeIndex].split("-");
      return Locale(value[0], value.length == 2 ? value[1] : '');
    }
    // 跟随系统
    return null;
  }

  LocaleModel() {
    _localeIndex = StorageManager.sharedPreferences.getInt(mLocaleIndex) ?? 0;
  }

  switchLocale(int index) {
    _localeIndex = index;
    notifyListeners();
    StorageManager.sharedPreferences.setInt(mLocaleIndex, index);
  }

  static String localeName(index, context) {
    switch (index) {
      case 0:
        return G.of(context).autoWithSystem;
      case 1:
        return G.of(context).english;
      default:
        return '';
    }
  }
}
