import 'dart:convert';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:tencent_rtc_sdk/bindings/live/live_load_dynamic_lib.dart';
import 'package:tencent_rtc_sdk/bindings/live/play/v2_tx_live_player_ffi_bindings.dart';
import 'package:tencent_rtc_sdk/bindings/live/push/v2_tx_live_pusher_ffi_bindings.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_def.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_premier.dart';

class LiveLog {
  static void playerPrint(Pointer<V2TXLivePlayerNativePointer> player,
      V2TXLiveLogLevel level, String message) {
    if (player == nullptr) return;
    V2TXLivePlayerFFIBindings bindings =
        V2TXLivePlayerFFIBindings(LiveLoadDynamicLib.getLiteavSDK());

    var nativeMessage = LogInfo(level: level, message: message)
        .toJson()
        .toNativeUtf8()
        .cast<Void>();
    var nativeKey = "printLog".toNativeUtf8().cast<Int8>();
    bindings.setProperty(player, nativeKey, nativeMessage);

    calloc.free(nativeKey);
    calloc.free(nativeMessage);
  }

  static void pusherPrint(Pointer<V2TXLivePusherNativePointer> pusher,
      V2TXLiveLogLevel level, String message) {
    V2TXLivePusherFFIBindings bindings =
        V2TXLivePusherFFIBindings(LiveLoadDynamicLib.getLiteavSDK());

    var nativeMessage = LogInfo(level: level, message: message)
        .toJson()
        .toNativeUtf8()
        .cast<Void>();
    var nativeKey = "printLog".toNativeUtf8().cast<Int8>();
    bindings.setProperty(pusher, nativeKey, nativeMessage);

    calloc.free(nativeKey);
    calloc.free(nativeMessage);
  }

  static void premierPrint(V2TXLiveLogLevel level, String message) =>
      V2TXLivePremier.callExperimentalAPI(
          LogInfo(level: level, message: message).toPremierJson());
}

class LogInfo {
  final String api = "printLog";
  final V2TXLiveLogLevel level;
  final String logMessage;

  LogInfo({required this.level, required message})
      : logMessage = "[Flutter] $message";

  String toJson() {
    var json = {'level': level.index, 'message': logMessage};
    return jsonEncode(json);
  }

  String toPremierJson() {
    var json = {
      "api": api,
      "params": {'level': level.index, 'message': logMessage}
    };
    return jsonEncode(json);
  }
}
