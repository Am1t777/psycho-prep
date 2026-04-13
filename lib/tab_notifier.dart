import 'package:flutter/foundation.dart';

class TabNotifier extends ChangeNotifier {
  int _index = 0;
  int get index => _index;

  void setTab(int i) {
    if (_index == i) return;
    _index = i;
    notifyListeners();
  }
}
