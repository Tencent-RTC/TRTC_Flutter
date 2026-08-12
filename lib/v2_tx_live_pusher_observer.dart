// ignore_for_file: unintended_html_in_doc_comment, comment_references

/// Callback notification for Tencent Cloud Live streaming.<br/>
/// Some callback events of V2TXLivePusher include ingest status, ingest volume, statistics, warnings, and error messages.
enum V2TXLivePusherListenerType {
  /// Error callbacks indicate that the SDK is unrecoverable, and must be listened to and given appropriate UI prompts to the user according to the situation
  ///
  /// **Parameter:**
  ///
  /// `code` Error code（[V2TXLiveCode]）
  ///
  /// `msg` Error message（String）
  ///
  /// `extraInfo` Extended Information (Map)
  onError,

  /// A warning callback to inform you of non-critical issues, such as stuttering or recoverable decoding failures.
  ///
  /// **Parameter:**
  ///
  /// `code` Warning code（[V2TXLiveCode]）
  ///
  /// `msg` Warning message（String）
  ///
  /// `extraInfo` Extended Information (Map)
  onWarning,

  /// Callback notification that the first frame of audio capture is completed
  onCaptureFirstAudioFrame,

  /// Callback notification when the first frame of video capture is completed
  onCaptureFirstVideoFrame,

  /// The microphone collects the volume value callback
  ///
  /// **Parameter:**
  ///
  /// `volume` volume (int)
  onMicrophoneVolumeUpdate,

  /// Callback notification of the connection status of the streamer
  ///
  /// **Parameter:**
  ///
  /// `status` status（String）
  ///
  /// `errMsg` Connection status information（String）
  ///
  /// `extraInfo` Extended Information (Map)
  onPushStatusUpdate,

  /// Callback of live streaming data of the live streamer
  ///
  /// **Parameter:**
  ///
  /// `appCpu`  CPU usage of the current app (%) (int)
  ///
  /// `systemCpu`  CPU Utilization of Current System (%) (int)
  ///
  /// `width`  Video width(int)
  ///
  /// `height`  Video height(int)
  ///
  /// `fps`  Frame rate(int)
  ///
  /// `videoBitrate`  Video bitrate（Kbps）(int)
  ///
  /// `audioBitrate`  Audio bitrate（Kbps）(int)
  onStatisticsUpdate,

  /// Screenshot callback
  ///
  /// **Parameter:**
  ///
  /// `image`  Captured video footage (Uint8List)
  onSnapshotComplete,

  /// Notification of create of the OpenGL environment inside the SDK
  onGLContextCreated,

  /// Custom video processing callbacks
  onProcessVideoFrame,

  /// Notification of destruction of the OpenGL environment inside the SDK
  onGLContextDestroyed,

  /// Set the callback for the MixTranscoding parameter in the cloud
  ///
  /// **Parameter:**
  ///
  /// `errCode` Error code（[V2TXLiveCode]）
  ///
  /// `errMsg` Error message（String）
  onSetMixTranscodingConfig,

  /// When screen sharing starts, the SDK notifies you with this callback
  onScreenCaptureStarted,

  /// When screen sharing stops, the SDK notifies you with this callback
  onScreenCaptureStopped,
}

typedef V2TXLivePusherObserver<P> = void Function(
    V2TXLivePusherListenerType type, P? params);
