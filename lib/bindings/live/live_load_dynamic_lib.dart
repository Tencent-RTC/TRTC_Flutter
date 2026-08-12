import 'dart:ffi';
import 'dart:io';

import 'package:flutter/services.dart';

class LiveLoadDynamicLib {
  static DynamicLibrary dynamicLibraryLiteavSDK = _loadLiteavSDK();
  static MethodChannel pluginChannel = _getPluginChannel();
  static MethodChannel videoViewChannel = _getVideoViewChannel();

  static DynamicLibrary getLiteavSDK() {
    return dynamicLibraryLiteavSDK;
  }

  static MethodChannel getPluginChannel() {
    return pluginChannel;
  }

  static MethodChannel getVideoViewChannel() {
    return videoViewChannel;
  }

  static DynamicLibrary _loadLiteavSDK() {
    if (Platform.isIOS || Platform.isMacOS) {
      return DynamicLibrary.process();
    } else if (Platform.isWindows) {
      return DynamicLibrary.open('liteav.dll');
    } else {
      return DynamicLibrary.open("libliteavsdk.so");
    }
  }

  static MethodChannel _getPluginChannel() {
    return const MethodChannel('TencentRTCffi');
  }

  static MethodChannel _getVideoViewChannel() {
    return const MethodChannel('TXCloudVideoViewChannel');
  }
}
