import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:path_provider/path_provider.dart';

class MeetingTool {
  static toast(text, context) {
    showToast(text, context: context, position: StyledToastPosition.center);
  }

  static int screenLen = 6;
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
    if (screenSize.width > screenSize.height) {
      return Size(screenSize.width / 3, screenSize.height / 2);
    }
    return Size(screenSize.width / 2, screenSize.height / 3);
  }

  static Future<String> copyAssetToLocal(String asset,
      {bool rewrite: false}) async {
    int lastIndex = asset.lastIndexOf("/");

    final dir = await getApplicationDocumentsDirectory();
    Directory rootDir = new Directory(
        "${dir.path}${lastIndex != -1 ? "/${asset.substring(0, lastIndex)}" : ""}");
    if (!(await rootDir.exists())) {
      await rootDir.create(recursive: true);
    }

    final file = new File(
        "${rootDir.path}${lastIndex == -1 ? asset : asset.substring(lastIndex)}");
    if (await file.exists() && rewrite) {
      file.deleteSync();
    }

    if (!(await file.exists())) {
      final soundData = await rootBundle.load(asset);
      final bytes = soundData.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    }

    return file.path;
  }
}
