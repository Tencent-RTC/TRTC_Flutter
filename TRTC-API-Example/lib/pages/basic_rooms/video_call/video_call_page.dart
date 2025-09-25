import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'video_call_state.dart';

class VideoCallPage extends StatefulWidget {
  final String userId;
  final int roomId;

  const VideoCallPage({
    Key? key,
    required this.userId,
    required this.roomId,
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
      roomId: widget.roomId,
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
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
    return Consumer<VideoCallState>(
      builder: (context, callState, child) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                'Room ID: ${callState.roomId}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  callState.statusMessage,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCallControls() {
    return Consumer<VideoCallState>(
      builder: (context, callState, child) {
        return Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTextButton(
                  text: callState.isMuteAllRemoteAudio ? 'UnMute\nAll\nAudio' : 'Mute\nAll\nAudio',
                  onPressed: () {
                    _callState.muteAllRemoteAudio(!callState.isMuteAllRemoteAudio);
                  },
                ),
                TextButton(
                  onPressed: _callState.stopAllRemoteView,
                  child: const Text(
                    "Stop\nAll\nRemote\nView",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                _buildTextButton(
                  text: callState.isMuteAllRemoteVideo ? 'UnMute\nAll\nVideo' : 'Mute\nAll\nVideo',
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
                  label: 'Mic',
                  onPressed: () {
                    _callState.muteLocalAudio(!callState.isLocalMicrophoneMute);
                  },
                ),
                _buildControlButton(
                  icon: Icons.call_end,
                  label: 'End Call',
                  backgroundColor: Colors.red,
                  onPressed: _endCall,
                ),
                _buildControlButton(
                  icon: callState.isLocalCameraMute ? Icons.videocam_off : Icons.videocam,
                  label: 'Camera',
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
