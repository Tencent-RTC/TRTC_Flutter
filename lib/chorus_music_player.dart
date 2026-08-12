// Copyright (c) 2025 Tencent. All rights reserved.
// Module:   Chorus Module
// Function: Provides multi-person chorus functionality within a TRTC room.

import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/impl/chorus_music_player/chorus_music_player_impl.dart';

/// Chorus role
enum ChorusRole {
  leadSinger,

  backSinger,

  anchor,

  audience,
}

/// Chorus music track type
enum ChorusMusicTrack {
  accompaniment,

  originalSong,
}

/// Chorus error codes
enum ChorusError {
  invalidParameters,

  trtcCloudNotFound,

  restrictedToLeadSinger,

  musicPreloadRequired,

  musicLoadFailed,

  musicDecodeFailed,

  enterRoomFailed,

  roomDisconnected,

  trtcError,
}

/// Parameters for copyrighted music in chorus.

/// Parameters for external music in chorus.
class ChorusExternalMusicParams {
  String? musicId;

  String? musicUrl;

  String? accompanyUrl;

  ChorusExternalMusicParams({
    this.musicId,
    this.musicUrl,
    this.accompanyUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'musicId': musicId,
      'musicUrl': musicUrl,
      'accompanyUrl': accompanyUrl,
    };
  }

  factory ChorusExternalMusicParams.fromJson(Map<String, dynamic> json) {
    return ChorusExternalMusicParams(
      musicId: json['musicId'] as String?,
      musicUrl: json['musicUrl'] as String?,
      accompanyUrl: json['accompanyUrl'] as String?,
    );
  }
}

/// Callback listener for chorus player events.
class ChorusPlayerEventListener {
  /// Called when a chorus error occurs.
  ///
  /// **Parameters:**
  /// - **errCode([ChorusError])**: The error code.
  /// - **errMsg(String)**: The error message.
  final void Function(ChorusError errCode, String errMsg)? onChorusError;

  /// Called when the chorus requires loading music.
  /// This callback is triggered for back singers when the lead singer starts loading music.
  ///
  /// **Parameters:**
  /// - **musicId(String)**: The ID of the music to load.
  final void Function(String musicId)? onChorusRequireLoadMusic;

  /// Called when music loading progress is updated.
  ///
  /// **Parameters:**
  /// - **musicId(String)**: The ID of the music being loaded.
  /// - **progress(double)**: Loading progress (0.0 to 1.0).
  final void Function(String musicId, double progress)?
      onChorusMusicLoadProgress;

  /// Called when music is loaded successfully.
  ///
  /// **Parameters:**
  /// - **musicId(String)**: The ID of the loaded music.
  final void Function(String musicId)? onChorusMusicLoadSucceed;

  /// Called when the chorus has started playing.
  final void Function()? onChorusStarted;

  /// Called when the chorus is paused.
  final void Function()? onChorusPaused;

  /// Called when the chorus is resumed.
  final void Function()? onChorusResumed;

  /// Called when the chorus is stopped.
  final void Function()? onChorusStopped;

  /// Called when music playback progress is updated.
  ///
  /// **Parameters:**
  /// - **progressMs(int)**: Current playback progress in milliseconds.
  /// - **durationMs(int)**: Total music duration in milliseconds.
  final void Function(int progressMs, int durationMs)? onMusicProgressUpdated;

  ChorusPlayerEventListener({
    this.onChorusError,
    this.onChorusRequireLoadMusic,
    this.onChorusMusicLoadProgress,
    this.onChorusMusicLoadSucceed,
    this.onChorusStarted,
    this.onChorusPaused,
    this.onChorusResumed,
    this.onChorusStopped,
    this.onMusicProgressUpdated,
  });
}

/// Chorus music player interface.
///
/// This class provides multi-person chorus functionality within a TRTC room.
/// Use [ChorusMusicPlayer.create] to create an instance and [ChorusMusicPlayer.destroy] to release it.
abstract class ChorusMusicPlayer {
  /// Create a chorus music player instance.
  ///
  /// **Parameters:**
  /// - **roomId(String)**: The room ID for the chorus session.
  ///
  /// **Return:**
  /// - A [ChorusMusicPlayer] instance.
  static ChorusMusicPlayer create(String roomId) {
    return ChorusMusicPlayerImpl(roomId);
  }

  /// Destroy a chorus music player instance and release all resources.
  ///
  /// **Parameters:**
  /// - **player([ChorusMusicPlayer])**: The chorus music player instance to destroy.
  static void destroy(ChorusMusicPlayer player) {
    if (player is ChorusMusicPlayerImpl) {
      player.dispose();
    }
  }

  /// Set the chorus role and optional TRTC parameters for the player.
  ///
  /// **Parameters:**
  /// - **role([ChorusRole])**: The chorus role for the current user.
  /// - **trtcParamsForPlayer([TRTCParams]?)**: Optional TRTC parameters for the internal player.
  ///   Required for lead singer and back singer roles.
  void setChorusRole(ChorusRole role, {TRTCParams? trtcParamsForPlayer});

  /// Load external music for chorus.
  ///
  /// **Parameters:**
  /// - **params([ChorusExternalMusicParams])**: External music parameters including music URL and accompaniment URL.
  void loadExternalMusic(ChorusExternalMusicParams params);

  /// Start chorus playback.
  ///
  /// This should be called by the lead singer after music is loaded successfully.
  void start();

  /// Stop chorus playback.
  void stop();

  /// Pause chorus playback.
  void pause();

  /// Resume chorus playback.
  void resume();

  /// Seek to a specific position in the music.
  ///
  /// **Parameters:**
  /// - **timestampMs(int)**: The target position in milliseconds.
  void seek(int timestampMs);

  /// Switch between accompaniment and original song track.
  ///
  /// **Parameters:**
  /// - **track([ChorusMusicTrack])**: The music track to switch to.
  void switchMusicTrack(ChorusMusicTrack track);

  /// Set the local playout volume of the music.
  ///
  /// **Parameters:**
  /// - **volume(int)**: Volume level. Value range: [0, 100]. Default: 100.
  void setPlayoutVolume(int volume);

  /// Set the publish (remote) volume of the music.
  ///
  /// **Parameters:**
  /// - **volume(int)**: Volume level. Value range: [0, 100]. Default: 100.
  void setPublishVolume(int volume);

  /// Set the pitch of the music.
  ///
  /// **Parameters:**
  /// - **pitch(double)**: Pitch adjustment value.
  void setMusicPitch(double pitch);

  /// Call experimental API.
  ///
  /// **Parameters:**
  /// - **jsonStr(String)**: JSON string containing experimental API parameters.
  void callExperimentalAPI(String jsonStr);

  /// Add event listener for chorus player events.
  ///
  /// **Parameters:**
  /// - **listener([ChorusPlayerEventListener])**: The event listener to add.
  void addListener(ChorusPlayerEventListener listener);

  /// Remove event listener.
  ///
  /// **Parameters:**
  /// - **listener([ChorusPlayerEventListener])**: The event listener to remove.
  void removeListener(ChorusPlayerEventListener listener);
}
