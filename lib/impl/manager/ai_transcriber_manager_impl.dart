import 'package:tencent_rtc_sdk/ai_transcriber_manager.dart';
import 'package:tencent_rtc_sdk/bridge/trtc/trtc_method_channel.dart';

class AITranscriberManagerImpl extends AITranscriberManager {
  static final AITranscriberManagerImpl _instance =
      AITranscriberManagerImpl._internal();
  final TRTCMethodChannel _methodChannel = TRTCMethodChannel();

  final Set<AITranscriberListener> _listeners = {};
  bool _callbacksRegistered = false;

  AITranscriberManagerImpl._internal();

  factory AITranscriberManagerImpl() => _instance;

  void _ensureCallbacksRegistered() {
    if (_callbacksRegistered) return;
    _callbacksRegistered = true;
    _methodChannel.setTranscriberCallbacks(
      onStarted: _handleOnRealtimeTranscriberStarted,
      onMessage: _handleOnReceiveTranscriberMessage,
      onStopped: _handleOnRealtimeTranscriberStopped,
      onError: _handleOnRealtimeTranscriberError,
    );
    _methodChannel.addTranscriberListener();
  }

  void _handleOnRealtimeTranscriberStarted(dynamic arguments) {
    final Map<dynamic, dynamic> args = arguments as Map<dynamic, dynamic>;
    final String roomId = args['roomId'] as String? ?? '';
    final String transcriberRobotId =
        args['transcriberRobotId'] as String? ?? '';

    for (final listener in List<AITranscriberListener>.from(_listeners)) {
      listener.onRealtimeTranscriberStarted?.call(roomId, transcriberRobotId);
    }
  }

  void _handleOnReceiveTranscriberMessage(dynamic arguments) {
    final Map<dynamic, dynamic> args = arguments as Map<dynamic, dynamic>;
    final String roomId = args['roomId'] as String? ?? '';
    final Map<dynamic, dynamic>? messageMap =
        args['message'] as Map<dynamic, dynamic>?;

    if (messageMap != null) {
      final message =
          TranscriberMessage.fromJson(Map<String, dynamic>.from(messageMap));
      for (final listener in List<AITranscriberListener>.from(_listeners)) {
        listener.onReceiveTranscriberMessage?.call(roomId, message);
      }
    }
  }

  void _handleOnRealtimeTranscriberStopped(dynamic arguments) {
    final Map<dynamic, dynamic> args = arguments as Map<dynamic, dynamic>;
    final String roomId = args['roomId'] as String? ?? '';
    final String transcriberRobotId =
        args['transcriberRobotId'] as String? ?? '';
    final int reasonValue = args['reason'] as int? ?? 0;
    final reason = TranscriberStopReason.fromValue(reasonValue);

    for (final listener in List<AITranscriberListener>.from(_listeners)) {
      listener.onRealtimeTranscriberStopped
          ?.call(roomId, transcriberRobotId, reason);
    }
  }

  void _handleOnRealtimeTranscriberError(dynamic arguments) {
    final Map<dynamic, dynamic> args = arguments as Map<dynamic, dynamic>;
    final String roomId = args['roomId'] as String? ?? '';
    final String transcriberRobotId =
        args['transcriberRobotId'] as String? ?? '';
    final int error = args['error'] as int? ?? 0;
    final String errorInfo = args['errorInfo'] as String? ?? '';

    for (final listener in List<AITranscriberListener>.from(_listeners)) {
      listener.onRealtimeTranscriberError
          ?.call(roomId, transcriberRobotId, error, errorInfo);
    }
  }

  @override
  void startRealtimeTranscriber(TranscriberParams params) {
    _ensureCallbacksRegistered();
    _methodChannel.startRealtimeTranscriber(params.toJson());
  }

  @override
  void stopRealtimeTranscriber(String transcriberRobotId) {
    _methodChannel.stopRealtimeTranscriber(transcriberRobotId);
  }

  @override
  void pauseReceivingMessage() {
    _methodChannel.pauseReceivingTranscriberMessage();
  }

  @override
  void resumeReceivingMessage() {
    _methodChannel.resumeReceivingTranscriberMessage();
  }

  @override
  void addListener(AITranscriberListener listener) {
    _ensureCallbacksRegistered();
    _listeners.add(listener);
  }

  @override
  void removeListener(AITranscriberListener listener) {
    _listeners.remove(listener);
  }
}
