```dart
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';

// Fill in your own TRTC credentials
const sdkAppId = 0; // "<-- Insert SDKAppID -->"
const userSig = ""; // "<-- Insert UserSig -->"
const roomId = 123456; // "<-- Insert Room ID -->"

/// Room entry status
enum _RoomStatus { joining, success, failed, hidden }

/// A basic TRTC video call example.
class SimpleDemoPage extends StatefulWidget {
  const SimpleDemoPage({Key? key}) : super(key: key);

  @override
  State<SimpleDemoPage> createState() => _SimpleDemoPageState();
}

class _SimpleDemoPageState extends State<SimpleDemoPage> {
  static const Color _bgColor = Color(0xFF1A2433);
  static const Color _placeholderColor = Color(0xFF243447);

  // Local user ID (random)
  final String _userId = 'user_${100000 + Random().nextInt(900000)}';

  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;

  bool _initialized = false;
  bool _isCameraOn = true;
  bool _isMicOn = true;
  bool _isSpeakerOn = true;
  String? _remoteUserId;

  _RoomStatus _roomStatus = _RoomStatus.joining;
  int _enterRoomResult = 0;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _initAndEnter();
  }

  Future<void> _initAndEnter() async {
    // Request camera / microphone permissions before entering the room.
    if (Platform.isAndroid || Platform.isIOS) {
      await [Permission.microphone, Permission.camera].request();
    }

    debugPrint('[demo] Initializing engine…');
    _trtcCloud = await TRTCCloud.sharedInstance();
    debugPrint('[demo] sharedInstance ready');
    _listener = TRTCCloudListener(
      onEnterRoom: (result) {
        debugPrint('onEnterRoom: $result');
        if (!mounted) return;
        setState(() {
          _enterRoomResult = result;
          _roomStatus = result > 0 ? _RoomStatus.success : _RoomStatus.failed;
        });
        if (result > 0) {
          _statusTimer?.cancel();
          _statusTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) setState(() => _roomStatus = _RoomStatus.hidden);
          });
        }
      },
      onUserVideoAvailable: (userId, available) {
        if (!mounted) return;
        setState(() => _remoteUserId = available ? userId : null);
      },
      onRemoteUserLeaveRoom: (userId, reason) {
        if (!mounted) return;
        if (_remoteUserId == userId) {
          setState(() => _remoteUserId = null);
        }
      },
      onError: (errCode, errMsg) => debugPrint('onError: $errCode $errMsg'),
    );
    _trtcCloud!.registerListener(_listener!);

    _trtcCloud!.enterRoom(
      TRTCParams(
        sdkAppId: sdkAppId,
        userId: _userId,
        userSig: userSig,
        roomId: roomId,
        role: TRTCRoleType.anchor,
      ),
      TRTCAppScene.videoCall,
    );

    _trtcCloud!.startLocalAudio(TRTCAudioQuality.speech);

    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  // Toggle the local camera
  void _toggleCamera() {
    setState(() => _isCameraOn = !_isCameraOn);
    _trtcCloud?.muteLocalVideo(TRTCVideoStreamType.big, !_isCameraOn);
  }

  // Toggle the local microphone
  void _toggleMic() {
    setState(() => _isMicOn = !_isMicOn);
    _trtcCloud?.muteLocalAudio(!_isMicOn);
  }

  // Toggle the speaker on / off
  void _toggleSpeaker() {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    // mute = true stops playing back all remote audio
    _trtcCloud?.muteAllRemoteAudio(!_isSpeakerOn);
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    if (_listener != null) {
      _trtcCloud?.unRegisterListener(_listener!);
    }
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.stopLocalAudio();
    _trtcCloud?.exitRoom();
    TRTCCloud.destroySharedInstance();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bgColor,
        foregroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          'TRTC Video Call',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _remoteVideo()),
          Positioned(top: 12, left: 0, right: 0, child: _roomStatusBanner()),
          Positioned(top: 12, left: 16, child: _localVideo()),
          Positioned(left: 0, right: 0, bottom: 0, child: _controlBar()),
        ],
      ),
    );
  }

  // Room entry status banner
  Widget _roomStatusBanner() {
    if (_roomStatus == _RoomStatus.hidden) return const SizedBox.shrink();
    final (String text, Color color) = switch (_roomStatus) {
      _RoomStatus.joining => ('Joining…', Colors.amber),
      _RoomStatus.success => ('Joined', Colors.green),
      _RoomStatus.failed => ('Failed to enter room (code: $_enterRoomResult)', Colors.redAccent),
      _RoomStatus.hidden => ('', Colors.transparent),
    };
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _roomStatus == _RoomStatus.success
                  ? Icons.check_circle
                  : (_roomStatus == _RoomStatus.failed
                      ? Icons.error
                      : Icons.hourglass_top),
              color: color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // Local preview window (rounded card)
  Widget _localVideo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 110,
        height: 150,
        color: _placeholderColor,
        child: !_initialized
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white54),
                ),
              )
            : Stack(
                children: [
                  Positioned.fill(
                    child: TRTCCloudVideoView(
                      onViewCreated: (viewId) {
                        debugPrint('[demo] Local preview view created, viewId: $viewId');
                        // Call startLocalPreview once, then sync the current mute state
                        _trtcCloud?.startLocalPreview(true, viewId);
                        _trtcCloud?.muteLocalVideo(
                            TRTCVideoStreamType.big, !_isCameraOn);
                        debugPrint('[demo] startLocalPreview called');
                      },
                    ),
                  ),
                  if (!_isCameraOn)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                        child: const Center(
                          child:
                              Icon(Icons.videocam_off, color: Colors.white70),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUserId == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_off_outlined, size: 64, color: Colors.white38),
            SizedBox(height: 16),
            Text(
              'Waiting for remote user…',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return Stack(
      children: [
        Positioned.fill(
          child: TRTCCloudVideoView(
            key: Key(_remoteUserId!),
            onViewCreated: (viewId) {
              _trtcCloud?.startRemoteView(
                _remoteUserId!,
                TRTCVideoStreamType.big,
                viewId,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _controlBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _roundButton(
            icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
            label: 'Camera',
            active: _isCameraOn,
            onTap: _toggleCamera,
          ),
          _roundButton(
            icon: _isMicOn ? Icons.mic : Icons.mic_off,
            label: 'Mic',
            active: _isMicOn,
            onTap: _toggleMic,
          ),
          _roundButton(
            icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
            label: _isSpeakerOn ? 'Speaker on' : 'Speaker off',
            active: _isSpeakerOn,
            onTap: _toggleSpeaker,
          ),
        ],
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool active,
    Color? background,
  }) {
    final Color bg = background ?? (active ? Colors.white : Colors.white24);
    final Color fg = active ? const Color(0xFF121212) : Colors.white70;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: bg,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(icon, color: fg, size: 26),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
```