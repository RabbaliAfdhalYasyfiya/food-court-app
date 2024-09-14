import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppService extends ChangeNotifier {
  ActivePrefs activePrefs = ActivePrefs();

  bool isOpen = false;
  bool get getIsOpen => isOpen;

  set setIsOpenActive(bool value) {
    isOpen = value;
    activePrefs.toggleSwitch(value);
    notifyListeners();
  }
}

class ActivePrefs {
  static const isOpen = 'isOpen';

  toggleSwitch(bool newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(isOpen, newValue);
  }

  Future<bool> getActive() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isOpen) ?? false;
  }
}
