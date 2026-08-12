// ignore_for_file: comment_references
import 'package:json_annotation/json_annotation.dart';
part 'tx_audio_effect_manager.g.dart';

/// Reverb Effects
///
/// Reverb effects can be applied to human voice. Based on acoustic
/// algorithms, they can mimic voice in different environments. The
/// following effects are supported currently:
///
/// 0: original;
/// 1: karaoke;
/// 2: room;
/// 3: hall;
/// 4: low and deep;
/// 5: resonant;
/// 6: metal;
/// 7: husky;
/// 8: ethereal;
/// 9: studio;
/// 10: melodious;
/// 11: studio2;
@JsonEnum(alwaysCreate: true)
enum TXVoiceReverbType {
  /// - disable
  @JsonValue(0)
  type0,

  /// - KTV
  @JsonValue(1)
  type1,

  /// - small room
  @JsonValue(2)
  type2,

  /// - great hall
  @JsonValue(3)
  type3,

  /// - deep voice
  @JsonValue(4)
  type4,

  /// - loud voice
  @JsonValue(5)
  type5,

  /// - metallic sound
  @JsonValue(6)
  type6,

  /// - magnetic sound
  @JsonValue(7)
  type7,

  /// - ethereal
  @JsonValue(8)
  type8,

  /// - studio
  @JsonValue(9)
  type9,

  /// - melodious
  @JsonValue(10)
  type10,

  /// - studio2
  @JsonValue(11)
  type11,
}

/// @nodoc
extension TXVoiceReverbTypeExt on TXVoiceReverbType {
  /// @nodoc
  static TXVoiceReverbType fromValue(int value) {
    return $enumDecode(_$TXVoiceReverbTypeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TXVoiceReverbTypeEnumMap[this]!;
  }
}

/// Voice Changing Effects
///
/// Voice changing effects can be applied to human voice. Based on
/// acoustic algorithms, they change the tone of voice. The following
/// effects are supported currently:
///
/// 0: original;
/// 1: child;
/// 2: little girl;
/// 3: middle-aged man;
/// 4: metal;
/// 5: nasal;
/// 6: foreign accent;
/// 7: trapped beast;
/// 8: otaku;
/// 9: electric;
/// 10: robot;
/// 11: ethereal;
@JsonEnum(alwaysCreate: true)
enum TXVoiceChangerType {
  /// - disable
  @JsonValue(0)
  type0,

  /// - naughty kid
  @JsonValue(1)
  type1,

  /// - Lolita
  @JsonValue(2)
  type2,

  /// - uncle
  @JsonValue(3)
  type3,

  /// - heavy metal
  @JsonValue(4)
  type4,

  /// - catch cold
  @JsonValue(5)
  type5,

  /// - foreign accent
  @JsonValue(6)
  type6,

  /// - caged animal trapped beast
  @JsonValue(7)
  type7,

  /// - indoorsman
  @JsonValue(8)
  type8,

  /// - strong current
  @JsonValue(9)
  type9,

  /// - heavy machinery
  @JsonValue(10)
  type10,

  /// - intangible
  @JsonValue(11)
  type11,
}

/// @nodoc
extension TXVoiceChangerTypeExt on TXVoiceChangerType {
  /// @nodoc
  static TXVoiceChangerType fromValue(int value) {
    return $enumDecode(_$TXVoiceChangerTypeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TXVoiceChangerTypeEnumMap[this]!;
  }
}

/// Background Music Playback Information
///
/// The information, including playback ID, file path, and loop times,
/// is passed in the [startPlayMusic] API.
///
/// 1. If you play the same music track multiple times, please use the
///    same ID instead of a separate ID for each playback.
///
/// 2. If you want to play different music tracks at the same time,
///    use different IDs for them.
///
/// 3. If you use the same ID to play a music track different from the
///    current one, the SDK will stop the current one before playing
///    the new one.
class AudioMusicParam {
  /// - Field description: Music ID.
  /// - **Note**: The SDK supports playing multiple music tracks. IDs are used to distinguish different music tracks
  ///   and control their start, end, volume, etc.
  int id;

  /// - Field description: Absolute path of the music file or URL.
  /// - Supported formats: mp3, aac, m4a, wav.
  String path;

  /// - Field description: Number of times the music track is looped.
  /// - Valid values: 0 or any positive integer.
  ///   0 (default) indicates that the music is played once, 1 twice, and so on.
  int loopCount;

  /// - Field description: Whether to send the music to remote users.
  /// - Valid values:
  ///   - `true`: remote users can hear the music played locally;
  ///   - `false` (default): only the local user can hear the music.
  bool publish;

  /// - Field description: Whether the music played is a short music track.
  /// - Valid values:
  ///   - `true`: short music track that needs to be looped;
  ///   - `false` (default): normal-length music track.
  bool isShortFile;

  /// - Field description: The point in time in milliseconds for starting music playback.
  int startTimeMS;

  /// - Field description: The point in time in milliseconds for ending music playback.
  ///   0 indicates that playback continues till the end of the music track.
  int endTimeMS;

  AudioMusicParam({
    required this.id,
    required this.path,
    this.loopCount = 0,
    this.publish = false,
    this.isShortFile = false,
    this.startTimeMS = 0,
    this.endTimeMS = 0,
  });
}

class TXMusicPlayObserver {
  /// Background Music Started
  ///
  /// Called after the background music starts.
  ///
  /// - **Param**:
  ///   - **errCode**:
  ///     - 0: Start playing successfully
  ///     - -4001: Failed to open the file, such as invalid data found when processing input, ffmpeg protocol not found, etc.
  ///     - -4005: Invalid path, please check whether the path you passed points to a legal music file.
  ///     - -4006: Invalid URL, please use a browser to check whether the URL address you passed in can download the desired music file.
  ///     - -4007: No audio stream, please confirm whether the file you passed is a legal audio file and whether the file is damaged.
  ///     - -4008: Unsupported format, please confirm whether the file format you passed is a supported file format. The mobile version supports [mp3, aac, m4a, wav, ogg, mp4, mkv], and the desktop version supports [mp3, aac, m4a, wav, mp4, mkv].
  ///   - **id**: music ID.
  final void Function(int id, int errorCode) onStart;

  /// Playback progress of background music
  ///
  /// - **Param**:
  ///   - **id**: music ID.
  ///   - **curPtsMSm**: Current Playback Time Point in Milliseconds.
  ///   - **durationMS**: Total Duration in Milliseconds.
  final void Function(int id, int curPtsMSm, int durationMS) onPlayProgress;

  /// Background Music Ended
  ///
  /// Called when the background music playback ends or an error occurs.
  ///
  /// - **Param**:
  ///   - **errCode**:
  ///     - 0: End of play
  ///     - -4002: Decoding failure, such as audio file corruption, inaccessible network audio file server, etc.
  ///   - **id**: music ID.
  final void Function(int id, int errorCode) onComplete;

  TXMusicPlayObserver({
    required this.onStart,
    required this.onPlayProgress,
    required this.onComplete,
  });
}

class TXMusicPreloadObserver {
  /// Background music preload progress
  ///
  /// - **Param**:
  ///   - **id(int)**: music ID.
  ///   - **progress(int)**: music preload progress.
  final void Function(int id, int progress) onLoadProgress;

  /// Background Music Preload Error
  ///
  /// - **Param**:
  ///   - **id(int)**: music ID.
  ///   - **errorCode(int)**:
  ///     - -4001: Failed to open the file, such as invalid data found when processing input, ffmpeg protocol not found, etc.
  ///     - -4002: Decoding failure, such as audio file corruption, inaccessible network audio file server, etc.
  ///     - -4003: The number of preloads exceeded the limit. Please call stopPlayMusic first to release the useless preload.
  ///     - -4005: Invalid path, please check whether the path you passed points to a legal music file.
  ///     - -4006: Invalid URL, please use a browser to check whether the URL address you passed in can download the desired music file.
  ///     - -4007: No audio stream, please confirm whether the file you passed is a legal audio file and whether the file is damaged.
  ///     - -4008: Unsupported format, please confirm whether the file format you passed is a supported file format.
  ///     The mobile version supports [mp3, aac, m4a, wav, ogg, mp4, mkv], and the desktop version supports [mp3, aac, m4a, wav, mp4, mkv].
  final void Function(int id, int errorCode) onLoadError;

  TXMusicPreloadObserver({
    required this.onLoadProgress,
    required this.onLoadError,
  });
}

abstract class TXAudioEffectManager {
  /// Enabling In-Ear Monitoring
  ///
  /// - After enabling in-ear monitoring, anchors can hear their own voice captured by the mic through earphones.
  ///   This feature is designed for singing scenarios.
  ///
  /// - In-ear monitoring cannot be enabled for Bluetooth earphones due to high latency.
  ///   Please remind anchors to use wired earphones via a UI reminder.
  ///
  /// - Given that not all phones deliver excellent in-ear monitoring effects,
  ///   this feature has been blocked on some phones.
  ///
  /// - **Param**:
  ///   - **enable(bool)**:
  ///     - `true`: enable
  ///     - `false`: disable
  ///
  /// > **Note**:
  /// > In-ear monitoring can be enabled only when earphones are used.
  /// > Please remind anchors to use wired earphones.
  void enableVoiceEarMonitor(bool enable);

  /// Setting In-Ear Monitoring Volume
  ///
  /// - This API is used to set the volume of in-ear monitoring.
  ///
  /// - **Param**:
  ///   - **volume(int)**:
  ///     - Volume. Value range: 0-100; default: 100.
  ///
  /// > **Note**:
  /// > If 100 is still not loud enough for you, you can set the volume up to 150,
  /// > but there may be side effects.
  void setVoiceEarMonitorVolume(int volume);

  /// Setting Voice Reverb Effects
  ///
  /// - This API is used to set reverb effects for human voice.
  ///   For the effects supported, please see [TXVoiceReverbType].
  ///
  /// > **Note**:
  /// > Effects become invalid after room exit.
  /// > If you want to use the same effect after you enter the room again,
  /// > you need to set the effect again using this API.
  void setVoiceReverbType(TXVoiceReverbType type);

  /// Setting Voice Changing Effects
  ///
  /// - This API is used to set voice changing effects.
  ///   For the effects supported, please see [TXVoiceChangeType].
  ///
  /// > **Note**:
  /// > Effects become invalid after room exit.
  /// > If you want to use the same effect after you enter the room again,
  /// > you need to set the effect again using this API.
  void setVoiceChangerType(TXVoiceChangerType type);

  /// Setting Speech Volume
  ///
  /// - This API is used to set the volume of speech.
  ///   It is often used together with the music volume setting API [setAllMusicVolume]
  ///   to balance between the volume of music and speech.
  ///
  /// - **Parameters:**
  ///   - **volume(int)**: Volume.
  ///     - Value range: 0-100;
  ///     - Default: 100
  ///
  /// > **Note**:
  /// > If 100 is still not loud enough for you,
  /// > you can set the volume to up to 150, but there may be side effects.
  void setVoiceCaptureVolume(int volume);

  /// Setting Speech Pitch
  ///
  /// - This API is used to set the pitch of speech.
  ///
  /// - **Parameters:**
  ///   - **pitch(double)**:
  ///     - Pitch.
  ///     - Value range: -1.0f to 1.0f;
  ///     - Default: 0.0f.
  void setVoicePitch(double pitch);

  /// Setting the Background Music Callback
  ///
  /// - Before playing background music, please use this API to set the music callback,
  ///   which can inform you of the playback progress.
  ///
  /// - **Parameters:**
  ///   - **musicId(int)**:
  ///     - Music ID.
  ///   - **observer([TXMusicPlayObserver])**
  ///
  /// > **Note**:
  /// > 1. If the ID does not need to be used,
  /// >    the observer can be set to NULL to release it completely.
  void setMusicObserver(int musicId, TXMusicPlayObserver? observer);

  /// Starting Background Music
  ///
  /// - You must assign an ID to each music track so that you can start, stop,
  ///   or set the volume of music tracks by ID.
  ///
  /// - **Parameters:**
  ///   - **musicParam([AudioMusicParam])**:
  ///     - Music parameter.
  ///
  /// > **Note**:
  /// > 1. If you play the same music track multiple times,
  /// >    please use the same ID instead of a separate ID for each playback.
  /// > 2. If you want to play different music tracks at the same time,
  /// >    use different IDs for them.
  /// > 3. If you use the same ID to play a music track different from the current one,
  /// >    the SDK will stop the current one before playing the new one.
  void startPlayMusic(AudioMusicParam musicParam);

  /// Stopping Background Music
  ///
  /// - **Parameters:**
  ///   - **id(int)**:
  ///     - Music ID.
  void stopPlayMusic(int id);

  /// Pausing Background Music
  ///
  /// - **Parameters:**
  ///   - **id(int)**:
  ///     - Music ID.
  void pausePlayMusic(int id);

  /// Resuming Background Music
  ///
  /// - **Parameters:**
  ///   - **id(int)**:
  ///     - Music ID.
  void resumePlayMusic(int id);

  /// Setting the Local and Remote Playback Volume of Background Music
  ///
  /// This API is used to set the local and remote playback volume of background music.
  /// - **Local volume**: The volume of music heard by anchors.
  /// - **Remote volume**: The volume of music heard by the audience.
  ///
  /// - **Parameters:**
  ///   - **volume(int)**:
  ///     - Volume. Value range: 0-100; default: 60.
  ///
  /// > **Note**
  /// > If 100 is still not loud enough for you, you can set the volume to up to 150, but there may be side effects.
  void setAllMusicVolume(int volume);

  /// Setting the Remote Playback Volume of a Specific Music Track
  ///
  /// This API is used to control the remote playback volume (the volume heard by the audience) of a specific music track.
  ///
  /// - **Parameters:**
  ///   - **id(int)**:
  ///     - Music ID.
  ///   - **volume(int)**:
  ///     - Volume. Value range: 0-100; default: 60.
  ///
  /// > **Note**
  /// > If 100 is still not loud enough for you, you can set the volume to up to 150, but there may be side effects.
  void setMusicPublishVolume(int id, int volume);

  /// Setting the Local Playback Volume of a Specific Music Track
  ///
  /// This API is used to control the local playback volume (the volume heard by anchors) of a specific music track.
  ///
  /// - **Parameters:**
  ///   - **id(int)**:
  ///     - Music ID.
  ///   - **volume(int)**:
  ///     - Volume. Value range: 0-100; default: 60.
  ///
  /// > **Note**
  /// > If 100 is still not loud enough for you, you can set the volume to up to 150, but there may be side effects.
  void setMusicPlayoutVolume(int id, int volume);

  /// Adjusting the Pitch of Background Music
  ///
  /// This API is used to adjust the pitch of background music.
  ///
  /// - **Parameters:**
  ///   - **id(int)**:
  ///     - Music ID.
  ///   - **pitch(int)**:
  ///     - Pitch. Value range: floating point numbers in the range of [-1, 1]; default: 0.0f.
  void setMusicPitch(int id, double pitch);

  /// Changing the Speed of Background Music
  ///
  /// This API is used to change the speed of background music.
  ///
  /// - **Parameters:**
  ///   - **id(int)**:
  ///     - Music ID.
  ///   - **speedRate(double)**:
  ///     - Music speed. Value range: floating point numbers in the range of [0.5, 2]; default: 1.0f.
  void setMusicSpeedRate(int id, double rate);

  /// Getting the Playback Progress (ms) of Background Music
  ///
  /// This API is used to retrieve the playback progress of background music.
  ///
  /// - **Parameters:**
  ///   - **id(int)**:
  ///     - Music ID.
  ///
  /// Return Description:
  /// The milliseconds that have passed since playback started.
  /// -1 indicates failure to get the playback progress.
  int getMusicCurrentPosInMS(int id);

  /// Getting the Total Length (ms) of Background Music
  ///
  /// This API is used to retrieve the total length of a background music file.
  ///
  /// - **Parameters:**
  ///   - **path(String)**:
  ///     - Path of the music file.
  ///
  /// Return Description:
  /// The length of the specified music file is returned in milliseconds.
  /// -1 indicates failure to get the length.
  int getMusicDurationInMS(String path);

  /// Setting the Playback Progress (ms) of Background Music
  ///
  /// This API is used to set the playback progress of background music.
  ///
  /// - **Parameters:**
  ///   - **id(int)**:
  ///     - Music ID.
  ///   - **pts(int)**:
  ///     - Unit: millisecond.
  ///
  /// > **Note**:
  /// > Do not call this API frequently as the music file may be read and written to each time the API is called, which can be time-consuming.
  /// > Wait until users finish dragging the progress bar before you call this API.
  /// > The progress bar controller on the UI tends to update the progress at a high frequency as users drag the progress bar.
  /// > This will result in poor user experience unless you limit the frequency.
  void seekMusicToPosInTime(int id, int pts);

  /// Adjust the Speed Change Effect of the Scratch Disc
  ///
  /// This API is used to adjust the speed change effect of the scratch disc.
  ///
  /// - **Parameters:**
  ///   - **id(int)**:
  ///     - Music ID.
  ///   - **scratchSpeedRate(double)**:
  ///     - Scratch disc speed. The default value is 1.0f.
  ///     - The range is a floating point number between [-12.0 ~ 12.0].
  ///     - A positive/negative speed value indicates the direction (positive/negative),
  ///     - and the absolute value indicates the speed.
  ///
  /// > **Note**:
  /// > Precondition: `preloadMusic` must succeed before calling this API.
  void setMusicScratchSpeedRate(int id, double scratchSpeedRate);

  /// Setting Music Preload Callback
  ///
  /// Before preloading music, please use this API to set the preload callback,
  /// which can inform you of the preload status.
  ///
  /// - **Parameters:**
  ///   - **observer([TXMusicPreloadObserver])**:
  void setPreloadObserver(TXMusicPreloadObserver? observer);

  /// Preload Background Music
  ///
  /// You must assign an ID to each music track so that you can start, stop,
  /// or set the volume of music tracks by ID.
  ///
  /// - **Parameters:**
  ///   - **musicParam([AudioMusicParam])**:
  ///     - Music parameter.
  ///
  /// > **Note**:
  /// > 1. Preload supports up to 2 preloads with different IDs at the same time,
  /// >    and the preload time does not exceed 10 minutes. You need to call
  /// >    `stopPlayMusic` after use; otherwise, the memory will not be released.
  /// >
  /// > 2. If the music corresponding to the ID is being played, the preloading
  /// >    fails, and `stopPlayMusic` must be called first.
  /// >
  /// > 3. When the `musicParam` passed to `startPlayMusic` is exactly the same,
  /// >    preloading works.
  void preloadMusic(AudioMusicParam musicParam);

  /// Get the Number of Tracks of Background Music
  ///
  /// This API retrieves the number of tracks associated with a specific
  /// background music ID.
  ///
  /// - **Parameters:**
  ///   - **id(int)**:
  ///     - Music ID.
  int getMusicTrackCount(int id);

  /// Specify the Playback Track of Background Music
  ///
  /// This API allows you to specify which track of the background music
  /// to play.
  ///
  /// - **Parameters:**
  ///   - **id(int)**:
  ///     - Music ID.
  ///   - **index(int)**:
  ///     - Specify which track to play (the first track is played by default).
  ///       Value range: [0, total number of tracks).
  ///
  /// > **Note**:
  /// > The total number of tracks can be obtained through the [getMusicTrackCount] interface.
  void setMusicTrack(int id, int trackIndex);
}
