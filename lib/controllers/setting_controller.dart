import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier {
  bool   _isDarkMode      = false;
  double _notifFrequency  = 1; // 0=Quiet, 1=Standard, 2=Frequent
  bool   _incognito       = false;

  bool   get isDarkMode      => _isDarkMode;
  double get notifFrequency  => _notifFrequency;
  bool   get incognito       => _incognito;

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void setNotifFrequency(double value) {
    _notifFrequency = value;
    notifyListeners();
  }

  void setIncognito(bool value) {
    _incognito = value;
    notifyListeners();
  }
}