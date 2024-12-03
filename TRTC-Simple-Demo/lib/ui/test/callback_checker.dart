

import 'dart:async';

import 'package:flutter/cupertino.dart';

class CallbackChecker {
  static bool isDetecting = false;

  static String? _validationToken;

  static CheckerCallback? _callback;

  static Timer? _timer;

  static void setValidationToken(String token, CheckerCallback callback) {
    if (isDetecting) {
      callback.onCheckerCallback(false, "already detecting");
      return;
    }
    isDetecting = true;
    _callback = callback;
    _validationToken = token;

    Duration timeout = Duration(seconds: 3);

    _timer = Timer(timeout, () {
      isDetecting = false;
      _validationToken = null;
      _callback?.onCheckerCallback(false, "check timeout");
      _callback = null;
      _timer = null;
    });
  }

  static void invokeCheck(String s) {
    if (isSubString(s)) {
      _timer?.cancel();
      isDetecting = false;
      _validationToken = null;
      _callback!.onCheckerCallback(true, s);
      _callback = null;
      _timer = null;
    }
  }

  static bool isSubString(String str) {
    if (_validationToken == null) {
      return false;
    }
    str = str.replaceAll(RegExp(r'[\r\n]+'), ' ');
    debugPrint("_validationToken : $_validationToken, str : $str");
    return str.toLowerCase().contains(_validationToken!.toLowerCase());
  }

}

class CheckerCallback {
  void Function(bool checkerResult, String errorMessage) onCheckerCallback;

  CheckerCallback(this.onCheckerCallback);
}