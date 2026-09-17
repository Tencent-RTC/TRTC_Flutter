import 'package:api_example/l10n/gen/app_localizations.dart';

/// 通话/房间运行时状态语义枚举。
/// 用于替代直接存储英文硬编码字符串，保证状态文案能随语言切换正确展示。
enum CallStatusCode {
  preparing,
  initializing,
  enteringRoom,
  error,
  roomEnteredSuccess,
  failedToEnterRoom,
  userJoined,
  userLeft,
  roomAnchorLimitReached,
  switchToAnchor,
  switchToAudience,
}

/// 承载状态语义 + 动态参数，页面侧通过 [toText] 结合 [AppLocalizations] 渲染最终文案。
class CallStatus {
  final CallStatusCode code;
  final String? userId;
  final String? errorMsg;
  final int? result;

  const CallStatus(this.code, {this.userId, this.errorMsg, this.result});

  static const CallStatus preparing = CallStatus(CallStatusCode.preparing);
  static const CallStatus initializing = CallStatus(CallStatusCode.initializing);
  static const CallStatus enteringRoom = CallStatus(CallStatusCode.enteringRoom);
  static const CallStatus roomEnteredSuccess = CallStatus(CallStatusCode.roomEnteredSuccess);
  static const CallStatus roomAnchorLimitReached = CallStatus(CallStatusCode.roomAnchorLimitReached);
  static const CallStatus switchToAnchor = CallStatus(CallStatusCode.switchToAnchor);
  static const CallStatus switchToAudience = CallStatus(CallStatusCode.switchToAudience);

  factory CallStatus.error(String errorMsg) => CallStatus(CallStatusCode.error, errorMsg: errorMsg);

  factory CallStatus.failedToEnterRoom(int result) => CallStatus(CallStatusCode.failedToEnterRoom, result: result);

  factory CallStatus.userJoined(String userId) => CallStatus(CallStatusCode.userJoined, userId: userId);

  factory CallStatus.userLeft(String userId) => CallStatus(CallStatusCode.userLeft, userId: userId);

  String toText(AppLocalizations l10n) {
    switch (code) {
      case CallStatusCode.preparing:
        return l10n.preparing;
      case CallStatusCode.initializing:
        return l10n.initializing;
      case CallStatusCode.enteringRoom:
        return l10n.enteringRoom;
      case CallStatusCode.error:
        return l10n.error(errorMsg ?? '');
      case CallStatusCode.roomEnteredSuccess:
        return l10n.roomEnteredSuccess;
      case CallStatusCode.failedToEnterRoom:
        return l10n.failedToEnterRoom(result ?? -1);
      case CallStatusCode.userJoined:
        return l10n.userJoined(userId ?? '');
      case CallStatusCode.userLeft:
        return l10n.userLeft(userId ?? '');
      case CallStatusCode.roomAnchorLimitReached:
        return l10n.roomAnchorLimitReached;
      case CallStatusCode.switchToAnchor:
        return l10n.switchToAnchor;
      case CallStatusCode.switchToAudience:
        return l10n.switchToAudience;
    }
  }
}
