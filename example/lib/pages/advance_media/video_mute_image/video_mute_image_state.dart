import 'dart:io';
import 'dart:ui' as ui;

import 'package:api_example/common/room_id_spec.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tencent_rtc_sdk/bindings/trtc/trtc_cloud_native.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import '../../../debug/generate_test_user_sig.dart';

class VideoMuteImageState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;

  VideoMuteImageState({required this.userId, required this.roomIdSpec});

  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  bool _isEnterRoom = false;
  int? _localViewId;

  bool get isEnterRoom => _isEnterRoom;

  final Map<String, RemoteVideoUser> _remoteUsers = {};
  List<RemoteVideoUser> get remoteUsers => _remoteUsers.values.toList();

  ValueNotifier<bool> isLocalVideoMuted = ValueNotifier(false);
  ValueNotifier<String> muteImagePath = ValueNotifier('');
  ValueNotifier<int> muteImageFps = ValueNotifier(5);

  static const List<String> presetAssets = [
    'assets/images/avatar3.png',
    'assets/images/user_icon.png',
    'assets/images/watermark_img.png',
  ];

  /// Copies a bundled asset to a temp file and returns the file path.
  Future<String> _assetToFilePath(String assetPath) async {
    final dir = await _getTempDir();
    final fileName = assetPath.split('/').last;
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    if (!await file.exists()) {
      final data = await rootBundle.load(assetPath);
      await file.writeAsBytes(data.buffer.asUint8List());
    }
    return filePath;
  }

  Future<Directory> _getTempDir() async {
    // Use getTemporaryDirectory via path_provider if available,
    // otherwise fall back to system temp.
    try {
      return await _getTmpDirViaPathProvider();
    } catch (_) {
      return Directory.systemTemp;
    }
  }

  Future<Directory> _getTmpDirViaPathProvider() async {
    // Import path_provider lazily to avoid dependency issues
    return await _pathProviderTempDir();
  }

  static Future<Directory> _pathProviderTempDir() async {
    final pp = await _getPathProvider();
    return pp;
  }

  static Future<Directory> _getPathProvider() async {
    // Use platform channel to get temp dir
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    final path = await channel.invokeMethod<String>('getTemporaryDirectory');
    return Directory(path!);
  }

  Future<void> _setMuteImage(String filePath, int fps) async {
    if (Platform.isIOS || Platform.isAndroid) {
      _trtcCloud?.setVideoMuteImage(filePath, fps);
    } else {
      await _setMuteImageViaFFI(filePath, fps);
    }
  }

  /// Decodes an image file to BGRA pixels and calls FFI setVideoMuteImage.
  ///
  /// The MethodChannel-based setVideoMuteImage doesn't work in FFI mode.
  /// This reads the file, decodes with dart:ui, converts RGBA→BGRA, and
  /// passes the raw pixel buffer to TRTCCloudNative.setVideoMuteImage.
  Future<void> _setMuteImageViaFFI(String filePath, int fps) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('setVideoMuteImage: file not found: $filePath');
        return;
      }
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return;

      // Convert RGBA → BGRA
      final rgba = byteData.buffer.asUint8List();
      final bgra = Uint8List(rgba.length);
      for (var i = 0; i < rgba.length; i += 4) {
        bgra[i] = rgba[i + 2]; // B
        bgra[i + 1] = rgba[i + 1]; // G
        bgra[i + 2] = rgba[i]; // R
        bgra[i + 3] = rgba[i + 3]; // A
      }

      final imageBuffer = TRTCImageBuffer(
        buffer: bgra,
        length: bgra.length,
        width: image.width,
        height: image.height,
      );
      TRTCCloudNative.instance.setVideoMuteImage(imageBuffer, fps);
      debugPrint(
          'setVideoMuteImage FFI success: ${image.width}x${image.height} fps=$fps');
    } catch (e) {
      debugPrint('setVideoMuteImage FFI error: $e');
    }
  }

  Future<void> selectPresetImage(String assetPath) async {
    try {
      final filePath = await _assetToFilePath(assetPath);
      muteImagePath.value = filePath;
      await _setMuteImage(filePath, muteImageFps.value);
      _reapplyMuteIfActive();
      notifyListeners();
    } catch (e) {
      debugPrint('selectPresetImage error: $e');
    }
  }

  Future<void> initialize() async {
    _trtcCloud = await TRTCCloud.sharedInstance();
    _listener = _getListener();
    _trtcCloud?.registerListener(_listener!);
    _enterRoom();
    await selectPresetImage(presetAssets[0]);
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

  void setRemoteViewId(String remoteUserId, int viewId) {
    if (!TRTCCloudVideoView.containsViewId(viewId)) return;
    final user = _remoteUsers[remoteUserId];
    if (user == null || user.viewId == viewId) return;
    user.viewId = viewId;
    if (user.isVideoAvailable) {
      _trtcCloud?.startRemoteView(remoteUserId, TRTCVideoStreamType.big, viewId);
    }
  }

  void toggleLocalVideoMute() {
    isLocalVideoMuted.value = !isLocalVideoMuted.value;
    if (isLocalVideoMuted.value) {
      if (muteImagePath.value.isNotEmpty) {
        _setMuteImage(muteImagePath.value, muteImageFps.value);
      }
      _trtcCloud?.muteLocalVideo(TRTCVideoStreamType.big, true);
    } else {
      _trtcCloud?.muteLocalVideo(TRTCVideoStreamType.big, false);
    }
    notifyListeners();
  }

  /// Re-triggers muteLocalVideo(true) so the SDK picks up the updated image/fps.
  void _reapplyMuteIfActive() {
    if (isLocalVideoMuted.value) {
      _trtcCloud?.muteLocalVideo(TRTCVideoStreamType.big, true);
    }
  }

  void updateMuteImagePath(String path) {
    muteImagePath.value = path;
    if (path.isNotEmpty) {
      _setMuteImage(path, muteImageFps.value);
      _reapplyMuteIfActive();
    }
  }

  void updateMuteImageFps(int fps) {
    muteImageFps.value = fps;
    if (muteImagePath.value.isNotEmpty) {
      _setMuteImage(muteImagePath.value, fps);
      _reapplyMuteIfActive();
    }
  }

  void exitRoom() {
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    _remoteUsers.clear();
    notifyListeners();
  }

  TRTCCloudListener _getListener() {
    return TRTCCloudListener(
      onError: (code, msg) => debugPrint('VideoMuteImage onError: $code, $msg'),
      onEnterRoom: (result) {
        _isEnterRoom = result > 0;
        notifyListeners();
      },
      onRemoteUserEnterRoom: (remoteUserId) {
        _remoteUsers[remoteUserId] = RemoteVideoUser(userId: remoteUserId);
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (remoteUserId, reason) {
        _remoteUsers.remove(remoteUserId);
        notifyListeners();
      },
      onUserVideoAvailable: (remoteUserId, available) {
        final user = _remoteUsers[remoteUserId];
        if (user == null) return;
        user.isVideoAvailable = available;
        if (available) {
          if (user.viewId != null && user.viewId! > 0) {
            _trtcCloud?.startRemoteView(remoteUserId, TRTCVideoStreamType.big, user.viewId);
          }
        } else {
          _trtcCloud?.stopRemoteView(remoteUserId, TRTCVideoStreamType.big);
        }
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    if (_listener != null) _trtcCloud?.unRegisterListener(_listener!);
    super.dispose();
  }
}

class RemoteVideoUser {
  final String userId;
  int? viewId;
  bool isVideoAvailable;
  RemoteVideoUser({required this.userId, this.viewId, this.isVideoAvailable = false});
}
