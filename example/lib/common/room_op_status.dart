import 'package:api_example/l10n/gen/app_localizations.dart';

/// switch_room / connect_other_room / custom_message 等场景共用的运行时状态语义。
/// 用于替代直接存储英文硬编码字符串，保证状态文案能随语言切换正确展示。
enum RoomOpStatusCode {
  notInRoom,
  enteringRoom,
  enterRoomSuccess,
  enterRoomFailed,
  exitedRoom,
  errorWithCode,
  switchingRoom,
  switchRoomSuccess,
  switchRoomFailed,
  connectingOtherRoom,
  disconnectingOtherRoom,
  connectOtherRoomSuccess,
  connectOtherRoomFailed,
  disconnectOtherRoomSuccess,
  disconnectOtherRoomFailed,
}

class RoomOpStatus {
  final RoomOpStatusCode code;
  final int? result;
  final String? errMsg;
  final int? errCode;

  const RoomOpStatus(this.code, {this.result, this.errMsg, this.errCode});

  static const RoomOpStatus notInRoom = RoomOpStatus(RoomOpStatusCode.notInRoom);
  static const RoomOpStatus enteringRoom = RoomOpStatus(RoomOpStatusCode.enteringRoom);
  static const RoomOpStatus enterRoomSuccess = RoomOpStatus(RoomOpStatusCode.enterRoomSuccess);
  static const RoomOpStatus exitedRoom = RoomOpStatus(RoomOpStatusCode.exitedRoom);
  static const RoomOpStatus switchingRoom = RoomOpStatus(RoomOpStatusCode.switchingRoom);
  static const RoomOpStatus switchRoomSuccess = RoomOpStatus(RoomOpStatusCode.switchRoomSuccess);
  static const RoomOpStatus connectingOtherRoom = RoomOpStatus(RoomOpStatusCode.connectingOtherRoom);
  static const RoomOpStatus disconnectingOtherRoom = RoomOpStatus(RoomOpStatusCode.disconnectingOtherRoom);
  static const RoomOpStatus connectOtherRoomSuccess = RoomOpStatus(RoomOpStatusCode.connectOtherRoomSuccess);
  static const RoomOpStatus disconnectOtherRoomSuccess = RoomOpStatus(RoomOpStatusCode.disconnectOtherRoomSuccess);

  factory RoomOpStatus.enterRoomFailed(int result) => RoomOpStatus(RoomOpStatusCode.enterRoomFailed, result: result);

  factory RoomOpStatus.errorWithCode(String errMsg, int errCode) =>
      RoomOpStatus(RoomOpStatusCode.errorWithCode, errMsg: errMsg, errCode: errCode);

  factory RoomOpStatus.switchRoomFailed(String errMsg, int errCode) =>
      RoomOpStatus(RoomOpStatusCode.switchRoomFailed, errMsg: errMsg, errCode: errCode);

  factory RoomOpStatus.connectOtherRoomFailed(String errMsg, int errCode) =>
      RoomOpStatus(RoomOpStatusCode.connectOtherRoomFailed, errMsg: errMsg, errCode: errCode);

  factory RoomOpStatus.disconnectOtherRoomFailed(String errMsg, int errCode) =>
      RoomOpStatus(RoomOpStatusCode.disconnectOtherRoomFailed, errMsg: errMsg, errCode: errCode);

  String toText(AppLocalizations l10n) {
    switch (code) {
      case RoomOpStatusCode.notInRoom:
        return l10n.notInRoom;
      case RoomOpStatusCode.enteringRoom:
        return l10n.enteringRoom;
      case RoomOpStatusCode.enterRoomSuccess:
        return l10n.enterRoomSuccessShort;
      case RoomOpStatusCode.enterRoomFailed:
        return l10n.enterRoomFailedShort(result ?? -1);
      case RoomOpStatusCode.exitedRoom:
        return l10n.exitedRoom;
      case RoomOpStatusCode.errorWithCode:
        return l10n.errorWithCode(errMsg ?? '', errCode ?? -1);
      case RoomOpStatusCode.switchingRoom:
        return l10n.switchingRoom;
      case RoomOpStatusCode.switchRoomSuccess:
        return l10n.switchRoomSuccess;
      case RoomOpStatusCode.switchRoomFailed:
        return l10n.switchRoomFailed(errMsg ?? '', errCode ?? -1);
      case RoomOpStatusCode.connectingOtherRoom:
        return l10n.connectingOtherRoom;
      case RoomOpStatusCode.disconnectingOtherRoom:
        return l10n.disconnectingOtherRoom;
      case RoomOpStatusCode.connectOtherRoomSuccess:
        return l10n.connectOtherRoomSuccess;
      case RoomOpStatusCode.connectOtherRoomFailed:
        return l10n.connectOtherRoomFailed(errMsg ?? '', errCode ?? -1);
      case RoomOpStatusCode.disconnectOtherRoomSuccess:
        return l10n.disconnectOtherRoomSuccess;
      case RoomOpStatusCode.disconnectOtherRoomFailed:
        return l10n.disconnectOtherRoomFailed(errMsg ?? '', errCode ?? -1);
    }
  }
}
