import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('es');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['es', 'en'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners(); // Esto avisa a la App que debe redibujarse
  }
}