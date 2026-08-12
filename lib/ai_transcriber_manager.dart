/// Parameters for real-time transcription.
class TranscriberParams {
  /// Unique ID of the transcriber robot.
  /// If not specified, SDK will generate a default ID: "transcriber_${roomid}_robot_${userid}".
  String? transcriberRobotId;

  /// Source language code (e.g., "zh" for Chinese, "en" for English).
  String? sourceLanguage;

  /// List of user IDs to transcribe. If empty, transcribes all users in the room.
  List<String>? userIdsToTranscribe;

  /// Target language codes for translation.
  /// Supported: "zh", "en", "vi", "ja", "ko", "id", "th", "pt", "ar", "es", "fr", "ms", "de", "it", "ru".
  List<String>? translationLanguages;

  TranscriberParams({
    this.transcriberRobotId,
    this.sourceLanguage,
    this.userIdsToTranscribe,
    this.translationLanguages,
  });

  Map<String, dynamic> toJson() {
    return {
      'transcriberRobotId': transcriberRobotId,
      'sourceLanguage': sourceLanguage,
      'userIdsToTranscribe': userIdsToTranscribe,
      'translationLanguages': translationLanguages,
    };
  }

  factory TranscriberParams.fromJson(Map<String, dynamic> json) {
    return TranscriberParams(
      transcriberRobotId: json['transcriberRobotId'] as String?,
      sourceLanguage: json['sourceLanguage'] as String?,
      userIdsToTranscribe:
          (json['userIdsToTranscribe'] as List<dynamic>?)?.cast<String>(),
      translationLanguages:
          (json['translationLanguages'] as List<dynamic>?)?.cast<String>(),
    );
  }
}

/// Transcription message structure.
class TranscriberMessage {
  /// Unique ID of the message segment.
  String segmentId;

  /// User ID of the speaker.
  String speakerUserId;

  /// Recognized source language text (Unicode encoded).
  String sourceText;

  /// Translated texts mapped by language code.
  Map<String, String> translationTexts;

  /// UTC timestamp in milliseconds.
  int timestamp;

  /// Whether the transcription is completed.
  /// true: sentence completed, false: intermediate result.
  bool isCompleted;

  TranscriberMessage({
    required this.segmentId,
    required this.speakerUserId,
    required this.sourceText,
    required this.translationTexts,
    required this.timestamp,
    required this.isCompleted,
  });

  factory TranscriberMessage.fromJson(Map<String, dynamic> json) {
    return TranscriberMessage(
      segmentId: json['segmentId'] as String? ?? '',
      speakerUserId: json['speakerUserId'] as String? ?? '',
      sourceText: json['sourceText'] as String? ?? '',
      translationTexts: (json['translationTexts'] as Map<dynamic, dynamic>?)
              ?.map((k, v) => MapEntry(k.toString(), v.toString())) ??
          {},
      timestamp: json['timestamp'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'segmentId': segmentId,
      'speakerUserId': speakerUserId,
      'sourceText': sourceText,
      'translationTexts': translationTexts,
      'timestamp': timestamp,
      'isCompleted': isCompleted,
    };
  }
}

/// Reason for stopping transcription.
enum TranscriberStopReason {
  /// User manually stopped the transcription.
  userStopped(0),

  /// Room was dismissed by backend.
  roomDismissed(1),

  /// All users left the room for more than 30 seconds.
  allUsersLeft(2);

  final int value;
  const TranscriberStopReason(this.value);

  static TranscriberStopReason fromValue(int value) {
    switch (value) {
      case 0:
        return TranscriberStopReason.userStopped;
      case 1:
        return TranscriberStopReason.roomDismissed;
      case 2:
        return TranscriberStopReason.allUsersLeft;
      default:
        return TranscriberStopReason.userStopped;
    }
  }
}

/// Callback for AI real-time transcription events.
class AITranscriberListener {
  /// Called when transcription starts successfully.
  ///
  /// - **Parameters:**
  ///   - **roomId(String)**:
  ///     - The room ID where transcription started.
  ///   - **transcriberRobotId(String)**:
  ///     - The unique ID of the transcriber robot.
  final void Function(String roomId, String transcriberRobotId)?
      onRealtimeTranscriberStarted;

  /// Called when a transcription message is received.
  ///
  /// - **Parameters:**
  ///   - **roomId(String)**:
  ///     - The room ID where the message came from.
  ///   - **message([TranscriberMessage])**:
  ///     - The transcription message containing text and translation.
  final void Function(String roomId, TranscriberMessage message)?
      onReceiveTranscriberMessage;

  /// Called when transcription stops.
  ///
  /// - **Parameters:**
  ///   - **roomId(String)**:
  ///     - The room ID where transcription stopped.
  ///   - **transcriberRobotId(String)**:
  ///     - The unique ID of the transcriber robot.
  ///   - **reason([TranscriberStopReason])**:
  ///     - The reason why transcription stopped.
  final void Function(String roomId, String transcriberRobotId,
      TranscriberStopReason reason)? onRealtimeTranscriberStopped;

  /// Called when a transcription error occurs.
  ///
  /// - **Parameters:**
  ///   - **roomId(String)**:
  ///     - The room ID where the error occurred.
  ///   - **transcriberRobotId(String)**:
  ///     - The unique ID of the transcriber robot.
  ///   - **error(int)**:
  ///     - The error code.
  ///   - **errorInfo(String)**:
  ///     - The error message.
  final void Function(String roomId, String transcriberRobotId, int error,
      String errorInfo)? onRealtimeTranscriberError;

  AITranscriberListener({
    this.onRealtimeTranscriberStarted,
    this.onReceiveTranscriberMessage,
    this.onRealtimeTranscriberStopped,
    this.onRealtimeTranscriberError,
  });
}

/// Manager for AI real-time transcription and translation.
abstract class AITranscriberManager {
  /// Start real-time transcription.
  void startRealtimeTranscriber(TranscriberParams params);

  /// Stop real-time transcription.
  void stopRealtimeTranscriber(String transcriberRobotId);

  /// Pause receiving transcription messages.
  void pauseReceivingMessage();

  /// Resume receiving transcription messages.
  void resumeReceivingMessage();

  /// Add event listener for transcription events.
  void addListener(AITranscriberListener listener);

  /// Remove event listener.
  void removeListener(AITranscriberListener listener);
}
