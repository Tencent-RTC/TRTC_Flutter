// ignore_for_file: avoid_print
import 'package:tencent_rtc_sdk/chorus_music_player.dart';

class ChorusPlayerListenerParse {
  final Set<ChorusPlayerEventListener> _listeners = {};

  void addListener(ChorusPlayerEventListener listener) {
    _listeners.add(listener);
  }

  void removeListener(ChorusPlayerEventListener listener) {
    _listeners.remove(listener);
  }

  void clearListeners() {
    _listeners.clear();
  }

  void _notifyListeners(
      void Function(ChorusPlayerEventListener listener) callback) {
    final snapshot = Set<ChorusPlayerEventListener>.from(_listeners);
    for (final listener in snapshot) {
      try {
        callback(listener);
      } catch (e) {
        print('Listener callback error: $e');
      }
    }
  }

  void handleListener(String type, Map<String, dynamic> param) {
    switch (type) {
      case "onChorusError":
        _handleOnChorusError(param);
        break;
      case "onChorusRequireLoadMusic":
        _handleOnChorusRequireLoadMusic(param);
        break;
      case "onChorusMusicLoadProgress":
        _handleOnChorusMusicLoadProgress(param);
        break;
      case "onChorusMusicLoadSucceed":
        _handleOnChorusMusicLoadSucceed(param);
        break;
      case "onChorusStarted":
        _handleOnChorusStarted(param);
        break;
      case "onChorusPaused":
        _handleOnChorusPaused(param);
        break;
      case "onChorusResumed":
        _handleOnChorusResumed(param);
        break;
      case "onChorusStopped":
        _handleOnChorusStopped(param);
        break;
      case "onMusicProgressUpdated":
        _handleOnMusicProgressUpdated(param);
        break;
      default:
        break;
    }
  }

  void _handleOnChorusError(Map<String, dynamic> param) {
    int errCode = param['errCode'] ?? 1;
    String errMsg = param['errMsg'] ?? '';
    ChorusError error;
    switch (errCode) {
      case 1:
        error = ChorusError.invalidParameters;
        break;
      case 2:
        error = ChorusError.trtcCloudNotFound;
        break;
      case 3:
        error = ChorusError.restrictedToLeadSinger;
        break;
      case 4:
        error = ChorusError.musicPreloadRequired;
        break;
      case 5:
        error = ChorusError.musicLoadFailed;
        break;
      case 6:
        error = ChorusError.musicDecodeFailed;
        break;
      case 7:
        error = ChorusError.enterRoomFailed;
        break;
      case 8:
        error = ChorusError.roomDisconnected;
        break;
      case 9:
        error = ChorusError.trtcError;
        break;
      default:
        error = ChorusError.invalidParameters;
        break;
    }
    _notifyListeners((listener) {
      listener.onChorusError?.call(error, errMsg);
    });
  }

  void _handleOnChorusRequireLoadMusic(Map<String, dynamic> param) {
    String musicId = param['musicId'] ?? '';
    _notifyListeners((listener) {
      listener.onChorusRequireLoadMusic?.call(musicId);
    });
  }

  void _handleOnChorusMusicLoadProgress(Map<String, dynamic> param) {
    String musicId = param['musicId'] ?? '';
    double progress = (param['progress'] ?? 0.0).toDouble();
    _notifyListeners((listener) {
      listener.onChorusMusicLoadProgress?.call(musicId, progress);
    });
  }

  void _handleOnChorusMusicLoadSucceed(Map<String, dynamic> param) {
    String musicId = param['musicId'] ?? '';
    _notifyListeners((listener) {
      listener.onChorusMusicLoadSucceed?.call(musicId);
    });
  }

  void _handleOnChorusStarted(Map<String, dynamic> param) {
    _notifyListeners((listener) {
      listener.onChorusStarted?.call();
    });
  }

  void _handleOnChorusPaused(Map<String, dynamic> param) {
    _notifyListeners((listener) {
      listener.onChorusPaused?.call();
    });
  }

  void _handleOnChorusResumed(Map<String, dynamic> param) {
    _notifyListeners((listener) {
      listener.onChorusResumed?.call();
    });
  }

  void _handleOnChorusStopped(Map<String, dynamic> param) {
    _notifyListeners((listener) {
      listener.onChorusStopped?.call();
    });
  }

  void _handleOnMusicProgressUpdated(Map<String, dynamic> param) {
    int progressMs = param['progressMs'] ?? 0;
    int durationMs = param['durationMs'] ?? 0;
    _notifyListeners((listener) {
      listener.onMusicProgressUpdated?.call(progressMs, durationMs);
    });
  }
}
