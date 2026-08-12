// ignore_for_file: unintended_html_in_doc_comment
///
/// Player callback notification of Tencent Cloud Live.<br/>
/// You can receive some callback notifications from V2TXLivePlayer, including player status, playback volume callback, audio and video first frame callback, statistics, warnings, and error messages.
///
enum V2TXLivePlayerListenerType {
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

  /// Notification of the change in the resolution of the live broadcast player
  ///
  /// **Parameter:**
  ///
  /// `width` Video width(int)
  ///
  /// `height` Video height(int)
  onVideoResolutionChanged,

  /// You have successfully connected to the server
  ///
  /// **Parameter:**
  ///
  /// `extraInfo` Extended Information (Map)
  onConnected,

  /// Video playback events
  ///
  /// **Parameter:**
  ///
  /// `firstPlay` The flag of the first play（bool）
  ///
  /// `extraInfo`  Extended Information (Map)
  onVideoPlaying,

  /// Audio playback events
  ///
  /// **Parameter:**
  ///
  /// `firstPlay` The flag of the first play（bool）
  ///
  /// `extraInfo`  Extended Information (Map)
  onAudioPlaying,

  /// Video load events
  ///
  /// **Parameter:**
  ///
  /// `extraInfo`  Extended Information (Map)
  onVideoLoading,

  /// Audio load event
  ///
  /// **Parameter:**
  ///
  /// `extraInfo`  Extended Information (Map)
  onAudioLoading,

  /// Player volume
  ///
  /// **Parameter:**
  ///
  /// `volume` Volume (int) in the range of 0 to 100.
  onPlayoutVolumeUpdate,

  /// Callback for live player statistics
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

  /// Custom video rendering callbacks
  ///
  /// **Parameter:**
  ///
  /// `videoFrame` Video frame data (Map)
  onRenderVideoFrame,

  /// A callback is received for the SEI message
  ///
  /// **Parameter:**
  ///
  /// `payloadType` The type of message (int)
  ///
  /// `data` The content of message (Uint8List)
  onReceiveSeiMessage,

  /// Picture-in-picture status change callback
  ///
  /// **Parameter:**
  ///
  /// `state` state code (int)
  ///
  /// `message`  message（String）
  ///
  /// `extraInfo` Extended Information (Map)
  onPictureInPictureStateUpdate,

  onStreamSwitched,

  /// Notify whether the recording task has started successfully.
  ///
  /// **Parameter:**
  ///
  /// `code` state code (int)
  ///
  /// `storagePath` recording filePath (string)
  onLocalRecordBegin,

  /// Notify that the recording task is in progress
  ///
  /// **Parameter:**
  ///
  /// `durationMs` recording duration (long)
  ///
  /// `storagePath` recording filePath (string)
  onLocalRecording,

  /// Notify whether the recording task has stopped successfully.
  ///
  /// **Parameter:**
  ///
  /// `durationMs` recording duration (long)
  ///
  /// `storagePath` recording filePath (string)
  onLocalRecordComplete,
}

typedef V2TXLivePlayerObserver<P> = void Function(
    V2TXLivePlayerListenerType type, P? params);
