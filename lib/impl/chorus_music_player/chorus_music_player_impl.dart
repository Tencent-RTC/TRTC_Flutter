import 'package:tencent_rtc_sdk/bindings/chorus_music_player/chorus_music_player_listener_native.dart';
import 'package:tencent_rtc_sdk/bindings/chorus_music_player/chorus_music_player_native.dart';
import 'package:tencent_rtc_sdk/bindings/trtc/trtc_cloud_native.dart';
import 'package:tencent_rtc_sdk/chorus_music_player.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';

class ChorusMusicPlayerImpl extends ChorusMusicPlayer {
  late ChorusMusicPlayerNative _native;
  ChorusPlayerListenerNative? _listenerNative;

  ChorusMusicPlayerImpl(String roomId) {
    _native = ChorusMusicPlayerNative.create(
        TRTCCloudNative.sharedInstanceNativePointer, roomId);
  }

  void dispose() {
    _listenerNative?.unRegisterNativeListener();
    _listenerNative = null;
    _native.destroy();
  }

  static int _chorusRoleToInt(ChorusRole role) {
    switch (role) {
      case ChorusRole.leadSinger:
        return 1;
      case ChorusRole.backSinger:
        return 2;
      case ChorusRole.anchor:
        return 3;
      case ChorusRole.audience:
        return 4;
    }
  }

  static int _chorusMusicTrackToInt(ChorusMusicTrack track) {
    switch (track) {
      case ChorusMusicTrack.accompaniment:
        return 1;
      case ChorusMusicTrack.originalSong:
        return 2;
    }
  }

  @override
  void setChorusRole(ChorusRole role, {TRTCParams? trtcParamsForPlayer}) {
    _native.setChorusRole(_chorusRoleToInt(role), trtcParamsForPlayer);
  }

  @override
  void loadExternalMusic(ChorusExternalMusicParams params) {
    _native.loadExternalMusic(params);
  }

  @override
  void start() {
    _native.start();
  }

  @override
  void stop() {
    _native.stop();
  }

  @override
  void pause() {
    _native.pause();
  }

  @override
  void resume() {
    _native.resume();
  }

  @override
  void seek(int timestampMs) {
    _native.seek(timestampMs);
  }

  @override
  void switchMusicTrack(ChorusMusicTrack track) {
    _native.switchMusicTrack(_chorusMusicTrackToInt(track));
  }

  @override
  void setPlayoutVolume(int volume) {
    _native.setPlayoutVolume(volume);
  }

  @override
  void setPublishVolume(int volume) {
    _native.setPublishVolume(volume);
  }

  @override
  void setMusicPitch(double pitch) {
    _native.setMusicPitch(pitch);
  }

  @override
  void callExperimentalAPI(String jsonStr) {
    _native.callExperimentalAPI(jsonStr);
  }

  @override
  void addListener(ChorusPlayerEventListener listener) {
    _listenerNative ??= ChorusPlayerListenerNative(_native.nativePointer);
    _listenerNative!.addListener(listener);
  }

  @override
  void removeListener(ChorusPlayerEventListener listener) {
    _listenerNative?.removeListener(listener);
  }
}
