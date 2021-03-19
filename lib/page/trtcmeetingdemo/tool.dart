import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:system_alert_window/system_alert_window.dart';

class MeetingTool {
  // 每4个一屏，得到一个二维数组
  static getScreenList(list) {
    int len = 4; //4个一屏
    List<List> result = List();
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

  /// 获得视图宽高
  static Size getViewSize(
      Size screenSize, int listLength, int index, int total) {
    if (listLength < 5) {
      // 只有一个显示全屏
      if (total == 1) {
        return screenSize;
      }
      // 两个显示半屏
      if (total == 2) {
        return Size(screenSize.width, screenSize.height / 2);
      }
    }
    return Size(screenSize.width / 2, screenSize.height / 2);
  }

  //屏幕分享时弹出小浮窗，防止切换到后台应用被杀死
  static void showOverlayWindow() {
    SystemWindowHeader header = SystemWindowHeader(
      title: SystemWindowText(
          text: "屏幕分享中", fontSize: 14, textColor: Colors.black45),
      decoration: SystemWindowDecoration(startColor: Colors.grey[100]),
    );
    SystemAlertWindow.showSystemWindow(
      width: 18,
      height: 95,
      header: header,
      margin: SystemWindowMargin(top: 200),
      gravity: SystemWindowGravity.TOP,
    );
  }
}
