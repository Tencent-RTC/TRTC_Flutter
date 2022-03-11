import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class MeetingTool {
  static toast(text, context) {
    showToast(text, context: context, position: StyledToastPosition.center);
  }

  static int screenLen = 4;
  static getScreenList(list) {
    int len = screenLen;
    List<List> result = [];
    int index = 1;
    while (true) {
      if (index * len < list.length) {
        List temp = list.skip((index - 1) * len).take(len).toList();
        result.add(temp);
        index++;
        continue;
      }
      List temp = list.skip((index - 1) * len).toList();
      result.add(temp);
      break;
    }
    return result;
  }

  static Size getViewSize(
      Size screenSize, int listLength, int index, int total) {
    if (listLength < 5) {
      if (total == 1) {
        return screenSize;
      }
      if (total == 2) {
        return Size(screenSize.width, screenSize.height / 2);
      }
    }
    return Size(screenSize.width / 2, screenSize.height / 2);
  }
}
