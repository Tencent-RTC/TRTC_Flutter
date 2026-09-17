import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'video_call_state.dart';

class VideoCallPage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const VideoCallPage({
    Key? key,
    required this.userId,
    required this.roomIdSpec,
  }) : super(key: key);

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  late VideoCallState _callState;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    _callState = VideoCallState();
    await _callState.initializeCall(
      userId: widget.userId,
      roomIdSpec: widget.roomIdSpec,
    );

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _callState.endCall();
    _callState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                l10n.initializing,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _callState,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade900,
                Colors.blue.shade700,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildCallHeader(),
                Expanded(
                  child: _buildVideoGrid(),
                ),
                _buildCallControls(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCallHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<VideoCallState>(
      builder: (context, callState, child) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.roomIdDisplay(callState.roomId ?? ''),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  callState.status.toText(l10n),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              if (callState.connectionState != 'normal' ||
                  callState.rtt != null)
                _buildQualityPanel(callState, l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQualityPanel(VideoCallState callState, AppLocalizations l10n) {
    final items = <Widget>[];

    // Connection state
    if (callState.connectionState != 'normal') {
      String label;
      Color color;
      switch (callState.connectionState) {
        case 'reconnecting':
          label = l10n.connStateReconnecting;
          color = Colors.orangeAccent;
          break;
        case 'lost':
          label = l10n.connStateLost;
          color = Colors.redAccent;
          break;
        case 'recovered':
          label = l10n.connStateRecovered;
          color = Colors.greenAccent;
          break;
        default:
          label = '';
          color = Colors.white;
      }
      items.add(_qualityChip(Icons.wifi, label, color));
    }

    // Statistics
    if (callState.rtt != null) {
      items.add(_qualityChip(
          Icons.speed, 'RTT ${callState.rtt}ms', Colors.white70));
    }
    if (callState.upLoss != null) {
      items.add(_qualityChip(
          Icons.upload, '↑${callState.upLoss}%', Colors.white70));
    }
    if (callState.downLoss != null) {
      items.add(_qualityChip(
          Icons.download, '↓${callState.downLoss}%', Colors.white70));
    }
    if (callState.appCpu != null) {
      items.add(_qualityChip(
          Icons.memory, 'CPU ${callState.appCpu}%', Colors.white70));
    }

    // Warning
    if (callState.lastWarning != null) {
      items.add(_qualityChip(Icons.warning_amber,
          '${l10n.warningLabel} ${callState.lastWarning}', Colors.amberAccent));
    }

    // First-frame events
    for (final e in callState.frameEvents.take(3)) {
      String text;
      switch (e.type) {
        case 'localVideo':
          text = l10n.firstLocalVideoFrame;
          break;
        case 'localAudio':
          text = l10n.firstLocalAudioFrame;
          break;
        case 'remoteVideo':
          text = l10n.firstRemoteVideoFrame(e.userId ?? '');
          break;
        case 'remoteAudio':
          text = l10n.firstRemoteAudioFrame(e.userId ?? '');
          break;
        default:
          text = e.type;
      }
      items.add(_qualityChip(Icons.movie_outlined, text, Colors.white54));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: items,
      ),
    );
  }

  Widget _qualityChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  Widget _buildVideoGrid() {
    return Consumer<VideoCallState>(
      builder: (context, callState, child) {
        final allParticipants = [
          RemoteUserState(
            userId: callState.localUserId!,
            isCameraMuted: callState.isLocalCameraMute,
            isMicrophoneMuted: callState.isLocalMicrophoneMute,
          ),
          ...callState.remoteUsers,
        ];

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: allParticipants.length,
          itemBuilder: (context, index) {
            final participant = allParticipants[index];
            return _buildVideoTile(participant);
          },
        );
      },
    );
  }

  Widget _buildVideoTile(RemoteUserState participant) {
    final isLocalUser = participant.userId == _callState.localUserId;
    return Stack(
      key: ValueKey(participant.userId),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: TRTCCloudVideoView(
              onViewCreated: (viewId) {
                if (isLocalUser) {
                  _callState.setLocalViewId(viewId);
                } else {
                  _callState.setRemoteViewId(participant.userId, viewId);
                }
              },
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          child: Row(
            children: [
              Text(
                participant.userId,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              if (participant.isCameraMuted)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.videocam_off,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              if (participant.isMicrophoneMuted)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.mic_off,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              if (participant.videoWidth != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '${participant.videoWidth}x${participant.videoHeight}',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
        if (participant.isVideoBuffering || participant.isAudioBuffering)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppLocalizations.of(context)!.avStatusLoading,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCallControls() {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<VideoCallState>(
      builder: (context, callState, child) {
        return Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTextButton(
                  text: callState.isMuteAllRemoteAudio ? l10n.unmuteAllAudio : l10n.muteAllAudio,
                  onPressed: () {
                    _callState.muteAllRemoteAudio(!callState.isMuteAllRemoteAudio);
                  },
                ),
                TextButton(
                  onPressed: _callState.stopAllRemoteView,
                  child: Text(
                    l10n.stopAllRemoteView,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                _buildTextButton(
                  text: callState.isMuteAllRemoteVideo ? l10n.unmuteAllVideo : l10n.muteAllVideo,
                  onPressed: () {
                    _callState.muteAllRemoteVideo(!callState.isMuteAllRemoteVideo);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: callState.isLocalMicrophoneMute ? Icons.mic_off : Icons.mic,
                  label: l10n.microphone,
                  onPressed: () {
                    _callState.muteLocalAudio(!callState.isLocalMicrophoneMute);
                  },
                ),
                _buildControlButton(
                  icon: Icons.call_end,
                  label: l10n.endCall,
                  backgroundColor: Colors.red,
                  onPressed: _endCall,
                ),
                _buildControlButton(
                  icon: callState.isLocalCameraMute ? Icons.videocam_off : Icons.videocam,
                  label: l10n.camera,
                  onPressed: () {
                    _callState.muteLocalVideo(!callState.isLocalCameraMute);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.white,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: backgroundColor,
          child: IconButton(
            icon: Icon(icon),
            onPressed: onPressed,
            color: backgroundColor == Colors.white ? Colors.blue : Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildTextButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        TextButton(
          onPressed: onPressed,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  _endCall() {
    _callState.endCall();
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
