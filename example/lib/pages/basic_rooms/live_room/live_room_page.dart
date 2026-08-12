import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'live_room_state.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';

class LiveRoomPage extends StatefulWidget {
  final String userId;
  final int roomId;

  const LiveRoomPage({
    Key? key,
    required this.userId,
    required this.roomId,
  }) : super(key: key);

  @override
  State<LiveRoomPage> createState() => _LiveRoomPageState();
}

class _LiveRoomPageState extends State<LiveRoomPage> {
  bool _isInitializing = true;
  late LiveRoomState state;

  @override
  void initState() {
    super.initState();
    state = LiveRoomState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeRoom();
    });
  }

  Future<void> _initializeRoom() async {
    await state.initializeRoom(
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
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: state,
      child: Scaffold(
        body: _buildRoomContent(),
      ),
    );
  }

  Widget _buildRoomContent() {
    return Consumer<LiveRoomState>(
      builder: (context, state, child) {
        return Stack(
          children: [
            _buildVideoGrid(state),
            _buildRoomHeader(state),
            _buildRoomControls(state),
          ],
        );
      },
    );
  }

  Widget _buildVideoGrid(LiveRoomState state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.6),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 9 / 16,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: ViewManager.MAX_ANCHOR_COUNT,
          itemBuilder: (context, index) {
            return _buildVideoTile(state, index);
          },
        ),
      ),
    );
  }

  Widget _buildVideoTile(LiveRoomState state, int index) {
    final userId = state.viewManager.getUserIdByViewKey(index);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                TRTCCloudVideoView(
                  key: Key(index.toString()),
                  onViewCreated: (viewId) {
                    state.setViewId(viewId);
                  },
                ),
                if (userId == null)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.videocam_off,
                        color: Colors.white54,
                        size: 32,
                      ),
                    ),
                  ),
                if (userId != null) ...[
                  Positioned(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.swap_horiz, color: Colors.white),
                          onPressed: () => state.switchViewPosition(userId, (index + 1) % 4),
                        ),
                        IconButton(
                          icon: const Icon(Icons.swap_horiz, color: Colors.white),
                          onPressed: () => state.switchViewPosition(userId, (index + 2) % 4),
                        ),
                        IconButton(
                          icon: const Icon(Icons.swap_horiz, color: Colors.white),
                          onPressed: () => state.switchViewPosition(userId, (index + 3) % 4),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        state.localUserId == userId ? '$userId(Me)' : userId,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            height: 40,
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: state.getUserAudioMutedStatus(userId)
                      ? const Icon(Icons.voice_over_off, color: Colors.white)
                      : const Icon(Icons.record_voice_over, color: Colors.white),
                  onPressed: () => state.muteAudioStream(userId),
                ),
                Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: state.getUserVideoMutedStatus(userId)
                      ? const Icon(Icons.videocam_off_outlined, color: Colors.white)
                      : const Icon(Icons.videocam_outlined, color: Colors.white),
                  onPressed: () => state.muteVideoStream(userId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomHeader(LiveRoomState state) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                state.exitRoom();
                Navigator.pop(context);
              }
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Room ID: ${state.roomId}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.statusMessage,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: state.isAnchor ? Colors.red : Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: InkWell(
                onTap: state.isAnchor || state.canBecomeAnchor ? () => state.switchRole() : null,
                child: Text(
                  state.isAnchor ? 'Anchor' : 'Audience',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    decoration: !state.isAnchor && !state.canBecomeAnchor ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomControls(LiveRoomState state) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (state.isAnchor) ...[
              _buildControlButton(
                icon: Icons.videocam,
                isEnabled: state.isLocalCameraEnabled,
                onPressed: () => state.updateLocalCameraState(!state.isLocalCameraEnabled),
              ),
              _buildControlButton(
                icon: Icons.mic,
                isEnabled: state.isLocalMicrophoneEnabled,
                onPressed: () => state.updateLocalMicrophoneState(!state.isLocalMicrophoneEnabled),
              ),
              _buildControlButton(
                icon: Icons.switch_camera,
                isEnabled: true,
                onPressed: () => state.switchCamera(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        color: isEnabled ? (color ?? Colors.white) : Colors.grey,
        size: 28,
      ),
      onPressed: onPressed,
    );
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }
}
