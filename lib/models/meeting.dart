import 'dart:collection';

import 'package:flutter/foundation.dart';

class MeetingModel extends ChangeNotifier {
  /// Internal, private state of the cart.
  List _userList = [];
  Map _userInfo = {};
  Map _userSetting = {};

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView get userList => UnmodifiableListView(_userList);

  void setList(list) {
    _userList = list;
    notifyListeners();
  }

  void setUserInfo(userInfo) {
    _userInfo = userInfo;
  }

  void setUserSettig(userSetting) {
    _userSetting = userSetting;
  }

  getUserSetting() {
    return _userSetting;
  }

  getUserInfo() {
    return _userInfo;
  }

  getList() {
    return _userList;
  }

  /// Removes all items from the cart.
  void removeAll() {
    _userList.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
