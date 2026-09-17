import 'package:api_example/common/room_id_spec.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import '../../../debug/generate_test_user_sig.dart';

class ScreenShareState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;

  ScreenShareState({required this.userId, required this.roomIdSpec});

  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  bool _isEnterRoom = false;
  int? _localViewId;
  int? _remoteSubViewId;

  bool get isEnterRoom => _isEnterRoom;

  final Map<String, RemoteShareUser> _remoteUsers = {};
  List<RemoteShareUser> get remoteUsers => _remoteUsers.values.toList();

  /// Remote users that currently have an available sub-stream (screen share).
  List<RemoteShareUser> get subStreamUsers =>
      _remoteUsers.values.where((u) => u.isSubStreamAvailable).toList();

  /// Only [TRTCPlatform.isMacOS] / [TRTCPlatform.isWindows] support target
  /// selection (getScreenCaptureSources / selectScreenCaptureTarget).
  bool get isDesktop => TRTCPlatform.isMacOS || TRTCPlatform.isWindows;

  ValueNotifier<bool> isSharing = ValueNotifier(false);
  ValueNotifier<bool> isPaused = ValueNotifier(false);

  /// Latest screen-share lifecycle event, for UI toast (format: "type:detail").
  ValueNotifier<String?> shareEvent = ValueNotifier(null);

  /// The remote user whose sub-stream is currently being viewed.
  ValueNotifier<String?> selectedRemoteUserId = ValueNotifier(null);

  List<TRTCScreenCaptureSourceInfo> shareSources = [];
  TRTCScreenCaptureSourceInfo? selectedSource;

  /// Sub-stream encoder params
  TRTCVideoResolution subStreamResolution = TRTCVideoResolution.res_1920_1080;
  int subStreamBitrate = 1600;
  int subStreamFps = 15;

  /// System audio loopback volume (0-200)
  int loopbackVolume = 100;

  /// Excluded / included window IDs (desktop only)
  final List<int> _excludedWindows = [];
  List<int> get excludedWindows => List.unmodifiable(_excludedWindows);
  final List<int> _includedWindows = [];
  List<int> get includedWindows => List.unmodifiable(_includedWindows);

  Future<void> initialize() async {
    _trtcCloud = await TRTCCloud.sharedInstance();
    _listener = _getListener();
    _trtcCloud?.registerListener(_listener!);
    _enterRoom();
    notifyListeners();
  }

  void _enterRoom() {
    _trtcCloud?.enterRoom(
      TRTCParams(
        sdkAppId: GenerateTestUserSig.sdkAppId,
        userId: userId,
        roomId: roomIdSpec.effectiveRoomId,
        strRoomId: roomIdSpec.effectiveStrRoomId,
        role: TRTCRoleType.anchor,
        userSig: GenerateTestUserSig.genTestSig(userId),
      ),
      TRTCAppScene.videoCall,
    );
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.speech);
  }

  void setLocalViewId(int viewId) {
    if (_localViewId == viewId) return;
    if (!TRTCCloudVideoView.containsViewId(viewId)) return;
    _localViewId = viewId;
    _trtcCloud?.startLocalPreview(true, viewId);
  }

  /// Sets the view id for the remote sub-stream (screen share) preview.
  void setRemoteSubViewId(int viewId) {
    if (_remoteSubViewId == viewId) return;
    if (!TRTCCloudVideoView.containsViewId(viewId)) return;
    _remoteSubViewId = viewId;
    final selected = selectedRemoteUserId.value;
    if (selected != null && selected.isNotEmpty) {
      _trtcCloud?.startRemoteView(selected, TRTCVideoStreamType.sub, viewId);
    }
  }

  /// Selects a remote user to view their sub-stream (screen share).
  /// Pass null to stop viewing.
  void selectRemoteUser(String? remoteUserId) {
    final prev = selectedRemoteUserId.value;
    if (prev == remoteUserId) return;

    // Stop previous
    if (prev != null && prev.isNotEmpty) {
      _trtcCloud?.stopRemoteView(prev, TRTCVideoStreamType.sub);
    }

    selectedRemoteUserId.value = remoteUserId;

    // Start new
    if (remoteUserId != null &&
        remoteUserId.isNotEmpty &&
        _remoteSubViewId != null) {
      _trtcCloud?.startRemoteView(
          remoteUserId, TRTCVideoStreamType.sub, _remoteSubViewId);
    }
  }

  /// Refreshes the list of shareable screens/windows (desktop only).
  void refreshShareSources() {
    if (!isDesktop) return;
    final list = _trtcCloud?.getScreenCaptureSources(
      TRTCSize(width: 120, height: 68),
      TRTCSize(width: 32, height: 32),
    );
    shareSources = list?.sourceList ?? [];
    selectedSource ??= shareSources.isNotEmpty ? shareSources.first : null;
    notifyListeners();
  }

  void selectShareSource(TRTCScreenCaptureSourceInfo source) {
    selectedSource = source;
    notifyListeners();
    if (isSharing.value) {
      _trtcCloud?.selectScreenCaptureTarget(
        source, TRTCRect(), TRTCScreenCaptureProperty());
    }
  }

  void startScreenShare() {
    final param = TRTCVideoEncParam(
      videoResolution: subStreamResolution,
      videoResolutionMode: TRTCVideoResolutionMode.landscape,
      videoBitrate: subStreamBitrate,
      videoFps: subStreamFps,
    );

    if (TRTCPlatform.isIOS) {
      // iOS: use ReplayKit for system-level screen sharing
      _trtcCloud?.startScreenCaptureByReplaykit(
        TRTCVideoStreamType.sub, param, null);
    } else {
      _trtcCloud?.startScreenCapture(0, TRTCVideoStreamType.sub, param);
    }

    // Apply sub-stream encoder params
    _trtcCloud?.setSubStreamEncoderParam(param);

    if (isDesktop && selectedSource != null) {
      _trtcCloud?.selectScreenCaptureTarget(
        selectedSource!, TRTCRect(), TRTCScreenCaptureProperty());
    }
    if (isDesktop) {
      _trtcCloud?.startSystemAudioLoopback();
      _trtcCloud?.setSystemAudioLoopbackVolume(loopbackVolume);
    }
    isSharing.value = true;
    isPaused.value = false;
  }

  void stopScreenShare() {
    _trtcCloud?.stopScreenCapture();
    if (isDesktop) {
      _trtcCloud?.stopSystemAudioLoopback();
    }
    _excludedWindows.clear();
    _includedWindows.clear();
    isSharing.value = false;
    isPaused.value = false;
    notifyListeners();
  }

  void togglePause() {
    if (!isSharing.value) return;
    if (isPaused.value) {
      _trtcCloud?.resumeScreenCapture();
    } else {
      _trtcCloud?.pauseScreenCapture();
    }
  }

  // ─── Sub-stream encoder params ──────────────────────────────

  void setSubStreamResolution(TRTCVideoResolution resolution) {
    subStreamResolution = resolution;
    _applySubStreamParam();
    notifyListeners();
  }

  void setSubStreamBitrate(int bitrate) {
    subStreamBitrate = bitrate;
    _applySubStreamParam();
    notifyListeners();
  }

  void setSubStreamFps(int fps) {
    subStreamFps = fps;
    _applySubStreamParam();
    notifyListeners();
  }

  void _applySubStreamParam() {
    final param = TRTCVideoEncParam(
      videoResolution: subStreamResolution,
      videoResolutionMode: TRTCVideoResolutionMode.landscape,
      videoBitrate: subStreamBitrate,
      videoFps: subStreamFps,
    );
    _trtcCloud?.setSubStreamEncoderParam(param);
  }

  // ─── System audio loopback volume ───────────────────────────

  void setLoopbackVolume(int volume) {
    loopbackVolume = volume;
    _trtcCloud?.setSystemAudioLoopbackVolume(volume);
    notifyListeners();
  }

  // ─── Window exclusion / inclusion (desktop only) ────────────

  void addExcludedWindow(int windowId) {
    if (!_excludedWindows.contains(windowId)) {
      _excludedWindows.add(windowId);
      _trtcCloud?.addExcludedShareWindow(windowId);
      notifyListeners();
    }
  }

  void removeExcludedWindow(int windowId) {
    if (_excludedWindows.remove(windowId)) {
      _trtcCloud?.removeExcludedShareWindow(windowId);
      notifyListeners();
    }
  }

  void clearExcludedWindows() {
    _trtcCloud?.removeAllExcludedShareWindow();
    _excludedWindows.clear();
    notifyListeners();
  }

  void addIncludedWindow(int windowId) {
    if (!_includedWindows.contains(windowId)) {
      _includedWindows.add(windowId);
      _trtcCloud?.addIncludedShareWindow(windowId);
      notifyListeners();
    }
  }

  void removeIncludedWindow(int windowId) {
    if (_includedWindows.remove(windowId)) {
      _trtcCloud?.removeIncludedShareWindow(windowId);
      notifyListeners();
    }
  }

  void clearIncludedWindows() {
    _trtcCloud?.removeAllIncludedShareWindow();
    _includedWindows.clear();
    notifyListeners();
  }

  void exitRoom() {
    if (isSharing.value) {
      _trtcCloud?.stopScreenCapture();
      if (isDesktop) _trtcCloud?.stopSystemAudioLoopback();
    }
    _excludedWindows.clear();
    _includedWindows.clear();
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    _remoteUsers.clear();
    selectedRemoteUserId.value = null;
    notifyListeners();
  }

  TRTCCloudListener _getListener() {
    return TRTCCloudListener(
      onError: (code, msg) => debugPrint('ScreenShare onError: $code, $msg'),
      onEnterRoom: (result) {
        _isEnterRoom = result > 0;
        notifyListeners();
      },
      onRemoteUserEnterRoom: (remoteUserId) {
        _remoteUsers[remoteUserId] = RemoteShareUser(userId: remoteUserId);
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (remoteUserId, reason) {
        _remoteUsers.remove(remoteUserId);
        if (selectedRemoteUserId.value == remoteUserId) {
          selectedRemoteUserId.value = null;
        }
        notifyListeners();
      },
      onUserSubStreamAvailable: (remoteUserId, available) {
        final user = _remoteUsers[remoteUserId] ??
            (_remoteUsers[remoteUserId] = RemoteShareUser(userId: remoteUserId));
        user.isSubStreamAvailable = available;
        if (!available && selectedRemoteUserId.value == remoteUserId) {
          selectedRemoteUserId.value = null;
        }
        notifyListeners();
      },
      onScreenCaptureStarted: () {
        isSharing.value = true;
        isPaused.value = false;
        shareEvent.value = 'started';
      },
      onScreenCapturePaused: (reason) {
        isPaused.value = true;
        shareEvent.value = 'paused:$reason';
      },
      onScreenCaptureResumed: (reason) {
        isPaused.value = false;
        shareEvent.value = 'resumed:$reason';
      },
      onScreenCaptureStopped: (reason) {
        isSharing.value = false;
        isPaused.value = false;
        shareEvent.value = 'stopped:$reason';
      },
      onScreenCaptureCovered: () {
        shareEvent.value = 'covered';
      },
      onSystemAudioLoopbackError: (errCode) {
        shareEvent.value = 'loopback_error:$errCode';
      },
    );
  }

  @override
  void dispose() {
    if (isSharing.value) {
      _trtcCloud?.stopScreenCapture();
      _trtcCloud?.stopSystemAudioLoopback();
    }
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    if (_listener != null) _trtcCloud?.unRegisterListener(_listener!);
    super.dispose();
  }
}

class RemoteShareUser {
  final String userId;
  bool isSubStreamAvailable;
  RemoteShareUser({required this.userId, this.isSubStreamAvailable = false});
}
