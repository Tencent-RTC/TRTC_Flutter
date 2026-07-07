import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/ai_transcriber_manager.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';

class AITranscriberState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  AITranscriberManager? _transcriberManager;
  TRTCCloudListener? _listener;
  AITranscriberListener? _transcriberListener;

  String? _localUserId;
  int? _roomId;
  bool _isEnterRoomSuccess = false;
  bool _isTranscribing = false;
  bool _isPaused = false;
  String _statusMessage = 'Preparing...';
  final List<TranscriptItem> _transcripts = [];

  String? get localUserId => _localUserId;
  int? get roomId => _roomId;
  bool get isEnterRoomSuccess => _isEnterRoomSuccess;
  bool get isTranscribing => _isTranscribing;
  bool get isPaused => _isPaused;
  String get statusMessage => _statusMessage;
  List<TranscriptItem> get transcripts => List.unmodifiable(_transcripts);

  Future<void> initialize({required String userId, required int roomId}) async {
    _localUserId = userId;
    _roomId = roomId;
    _statusMessage = 'Initializing...';
    notifyListeners();

    _trtcCloud = await TRTCCloud.sharedInstance();
    _transcriberManager = _trtcCloud?.getAITranscriberManager();

    _transcriberListener = AITranscriberListener(
      onRealtimeTranscriberStarted: _onTranscriberStarted,
      onReceiveTranscriberMessage: _onTranscriberMessage,
      onRealtimeTranscriberStopped: _onTranscriberStopped,
      onRealtimeTranscriberError: _onTranscriberError,
    );
    _transcriberManager?.addListener(_transcriberListener!);

    _listener = TRTCCloudListener(
      onError: (errorCode, errorMsg) {
        _statusMessage = 'Error: $errorMsg';
        notifyListeners();
      },
      onEnterRoom: (result) {
        if (result > 0) {
          _statusMessage = 'Room entered';
          _isEnterRoomSuccess = true;
        } else {
          _statusMessage = 'Enter room failed: $result';
          _isEnterRoomSuccess = false;
        }
        notifyListeners();
      },
      onRemoteUserEnterRoom: (userId) {
        _statusMessage = 'User $userId joined';
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (userId, reason) {
        _statusMessage = 'User $userId left';
        notifyListeners();
      },
    );

    _trtcCloud?.registerListener(_listener!);
    _trtcCloud?.enterRoom(
      TRTCParams(
        sdkAppId: GenerateTestUserSig.sdkAppId,
        userId: userId,
        roomId: roomId,
        role: TRTCRoleType.anchor,
        userSig: GenerateTestUserSig.genTestSig(userId),
      ),
      TRTCAppScene.audioCall,
    );
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.speech);
  }

  void startTranscriber({
    String? sourceLanguage,
    List<String>? translationLanguages,
  }) {
    if (_transcriberManager == null) return;

    final params = TranscriberParams(
      sourceLanguage: sourceLanguage ?? 'zh',
      translationLanguages: translationLanguages ?? ['en'],
    );

    _transcriberManager?.startRealtimeTranscriber(params);
    _statusMessage = 'Starting transcriber...';
    notifyListeners();
  }

  void stopTranscriber() {
    _transcriberManager?.stopRealtimeTranscriber('');
    _statusMessage = 'Stopping transcriber...';
    notifyListeners();
  }

  void pauseReceiving() {
    _transcriberManager?.pauseReceivingMessage();
    _isPaused = true;
    _statusMessage = 'Paused receiving';
    notifyListeners();
  }

  void resumeReceiving() {
    _transcriberManager?.resumeReceivingMessage();
    _isPaused = false;
    _statusMessage = 'Resumed receiving';
    notifyListeners();
  }

  void clearTranscripts() {
    _transcripts.clear();
    notifyListeners();
  }

  void _onTranscriberStarted(String roomId, String robotId) {
    _isTranscribing = true;
    _statusMessage = 'Transcriber started (robotId: $robotId)';
    notifyListeners();
  }

  void _onTranscriberMessage(String roomId, TranscriberMessage message) {
    // Use segmentId for deduplication, fallback to speakerUserId if segmentId is empty
    int existingIndex = -1;
    if (message.segmentId.isNotEmpty) {
      existingIndex = _transcripts.indexWhere((t) => t.segmentId == message.segmentId);
    } else {
      // If no segmentId, find the last incomplete message from the same speaker
      existingIndex = _transcripts.lastIndexWhere(
        (t) => t.speakerUserId == message.speakerUserId && !t.isCompleted,
      );
    }

    final item = TranscriptItem(
      segmentId: message.segmentId,
      speakerUserId: message.speakerUserId,
      sourceText: message.sourceText,
      translationTexts: message.translationTexts,
      timestamp: message.timestamp,
      isCompleted: message.isCompleted,
    );

    if (existingIndex >= 0) {
      _transcripts[existingIndex] = item;
    } else {
      _transcripts.add(item);
    }
    notifyListeners();
  }

  void _onTranscriberStopped(String roomId, String robotId, TranscriberStopReason reason) {
    _isTranscribing = false;
    _statusMessage = 'Transcriber stopped (reason: ${reason.name})';
    notifyListeners();
  }

  void _onTranscriberError(String roomId, String robotId, int error, String errorInfo) {
    _statusMessage = 'Transcriber error: $error - $errorInfo';
    notifyListeners();
  }

  Future<void> release() async {
    if (_transcriberListener != null) {
      _transcriberManager?.removeListener(_transcriberListener!);
    }
    _trtcCloud?.exitRoom();
    TRTCCloud.destroySharedInstance();
  }

  @override
  void dispose() {
    release();
    super.dispose();
  }
}

class TranscriptItem {
  final String segmentId;
  final String speakerUserId;
  final String sourceText;
  final Map<String, String> translationTexts;
  final int timestamp;
  final bool isCompleted;

  TranscriptItem({
    required this.segmentId,
    required this.speakerUserId,
    required this.sourceText,
    required this.translationTexts,
    required this.timestamp,
    required this.isCompleted,
  });
}
