import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  void setLocale(Locale locale) {
    if (_locale.languageCode != locale.languageCode) {
      _locale = locale;
      notifyListeners();
    }
  }

  void setEnglish() => setLocale(const Locale('en'));
  void setArabic() => setLocale(const Locale('ar'));
}
