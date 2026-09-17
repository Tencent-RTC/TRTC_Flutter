import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/ai_transcriber_manager.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';

enum TranscriberStatus { enteringRoom, idle, starting, transcribing, paused, stopping, error }

class AITranscriberState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;
  final String sourceLanguage;
  final List<String> translationLanguages;

  AITranscriberState({
    required this.userId,
    required this.roomIdSpec,
    required this.sourceLanguage,
    required this.translationLanguages,
  });

  TRTCCloud? _trtcCloud;
  AITranscriberManager? _transcriberManager;
  TRTCCloudListener? _listener;
  AITranscriberListener? _transcriberListener;

  bool _isEnterRoom = false;
  TranscriberStatus _status = TranscriberStatus.enteringRoom;
  String? _robotId;
  String? _errorMessage;

  final List<TranscriptItem> _transcripts = [];

  /// Event notification for SnackBar (format: "type:message")
  ValueNotifier<String?> eventMessage = ValueNotifier(null);

  bool get isEnterRoom => _isEnterRoom;
  TranscriberStatus get status => _status;
  String? get robotId => _robotId;
  String? get errorMessage => _errorMessage;
  List<TranscriptItem> get transcripts => List.unmodifiable(_transcripts);
  int get completedCount => _transcripts.where((t) => t.isCompleted).length;
  int get pendingCount => _transcripts.where((t) => !t.isCompleted).length;

  Future<void> initialize() async {
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
      onError: (code, msg) {
        _errorMessage = '$code: $msg';
        _status = TranscriberStatus.error;
        _emitEvent('error:$msg');
        notifyListeners();
      },
      onEnterRoom: (result) {
        _isEnterRoom = result > 0;
        if (_isEnterRoom) {
          _status = TranscriberStatus.idle;
          _emitEvent('room_success');
        } else {
          _status = TranscriberStatus.error;
          _errorMessage = 'Enter room failed: $result';
          _emitEvent('room_failed:$result');
        }
        notifyListeners();
      },
      onExitRoom: (reason) {
        _isEnterRoom = false;
        notifyListeners();
      },
    );

    _trtcCloud?.registerListener(_listener!);
    _trtcCloud?.enterRoom(
      TRTCParams(
        sdkAppId: GenerateTestUserSig.sdkAppId,
        userId: userId,
        roomId: roomIdSpec.effectiveRoomId,
        strRoomId: roomIdSpec.effectiveStrRoomId,
        userSig: GenerateTestUserSig.genTestSig(userId),
        role: TRTCRoleType.anchor,
      ),
      TRTCAppScene.audioCall,
    );
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.speech);
    notifyListeners();
  }

  void startTranscriber() {
    if (_transcriberManager == null) return;
    final params = TranscriberParams(
      sourceLanguage: sourceLanguage,
      translationLanguages: translationLanguages,
    );
    _transcriberManager?.startRealtimeTranscriber(params);
    _status = TranscriberStatus.starting;
    _errorMessage = null;
    notifyListeners();
  }

  void stopTranscriber() {
    _transcriberManager?.stopRealtimeTranscriber('');
    _status = TranscriberStatus.stopping;
    notifyListeners();
  }

  void pauseReceiving() {
    _transcriberManager?.pauseReceivingMessage();
    _status = TranscriberStatus.paused;
    _emitEvent('paused');
    notifyListeners();
  }

  void resumeReceiving() {
    _transcriberManager?.resumeReceivingMessage();
    _status = TranscriberStatus.transcribing;
    _emitEvent('resumed');
    notifyListeners();
  }

  void clearTranscripts() {
    _transcripts.clear();
    notifyListeners();
  }

  void _onTranscriberStarted(String roomId, String robotId) {
    _robotId = robotId;
    _status = TranscriberStatus.transcribing;
    _emitEvent('started:$robotId');
    notifyListeners();
  }

  void _onTranscriberMessage(String roomId, TranscriberMessage message) {
    int existingIndex = -1;
    if (message.segmentId.isNotEmpty) {
      existingIndex = _transcripts.indexWhere((t) => t.segmentId == message.segmentId);
    } else {
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
    _status = TranscriberStatus.idle;
    _emitEvent('stopped:${reason.name}');
    notifyListeners();
  }

  void _onTranscriberError(String roomId, String robotId, int error, String errorInfo) {
    _status = TranscriberStatus.error;
    _errorMessage = '$error: $errorInfo';
    _emitEvent('error:$errorInfo');
    notifyListeners();
  }

  void _emitEvent(String event) {
    eventMessage.value = event;
  }

  void exitRoom() {
    if (_status == TranscriberStatus.transcribing || _status == TranscriberStatus.paused) {
      _transcriberManager?.stopRealtimeTranscriber('');
    }
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    _status = TranscriberStatus.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_transcriberListener != null) {
      _transcriberManager?.removeListener(_transcriberListener!);
    }
    _trtcCloud?.exitRoom();
    if (_listener != null) _trtcCloud?.unRegisterListener(_listener!);
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
