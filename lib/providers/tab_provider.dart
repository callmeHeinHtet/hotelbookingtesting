import 'package:flutter/material.dart';

enum TabType { rooms, services, coupons }

class TabProvider extends ChangeNotifier {
  TabType _currentTab = TabType.rooms;

  TabType get currentTab => _currentTab;

  void setTab(TabType tab) {
    if (_currentTab != tab) {
      _currentTab = tab;
      notifyListeners();
    }
  }
} 