import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'voice_room_state.dart';

class VoiceRoomPage extends StatefulWidget {
  final String userId;
  final int roomId;

  const VoiceRoomPage({
    Key? key,
    required this.userId,
    required this.roomId,
  }) : super(key: key);

  @override
  State<VoiceRoomPage> createState() => _VoiceRoomPageState();
}

class _VoiceRoomPageState extends State<VoiceRoomPage> {
  bool _isInitializing = true;
  late VoiceRoomState state;

  @override
  void initState() {
    super.initState();
    _initializeRoom();
  }

  Future<void> _initializeRoom() async {
    state = VoiceRoomState();
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
        body: _isInitializing
            ? const Center(child: CircularProgressIndicator())
            : _buildRoomContent(),
      ),
    );
  }

  Widget _buildRoomContent() {
    return Consumer<VoiceRoomState>(
      builder: (context, state, child) {
        return Stack(
          children: [
            _buildUserGrid(state),
            _buildRoomHeader(state),
            _buildRoomControls(state),
          ],
        );
      },
    );
  }

  Widget _buildUserGrid(VoiceRoomState state) {
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
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: state.audioUsers.length + 1, // +1 for waiting item
          itemBuilder: (context, index) {
            if (index == state.audioUsers.length) {
              return _buildWaitingItem();
            }
            final user = state.audioUsers[index];
            return _buildUserTile(user);
          },
        ),
      ),
    );
  }

  Widget _buildUserTile(AudioUser user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: user.isSpeaking ? Colors.green : Colors.white24,
          width: user.isSpeaking ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (user.isSpeaking)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.2),
                  ),
                ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: user.isLocalUser ? Colors.blue : Colors.grey,
                ),
                child: Icon(
                  user.isMuted ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user.isLocalUser ? '${user.userId}(Me)' : user.userId,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingItem() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white24,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add,
            color: Colors.white54,
            size: 24,
          ),
          SizedBox(height: 8),
          Text(
            'Waiting to join',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomHeader(VoiceRoomState state) {
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

  Widget _buildRoomControls(VoiceRoomState state) {
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
            if (state.isAnchor)
              _buildControlButton(
                icon: Icons.mic,
                isEnabled: state.isLocalMicrophoneEnabled,
                onPressed: () => state.updateLocalMicrophoneState(!state.isLocalMicrophoneEnabled),
              ),
            _buildControlButton(
              icon: Icons.volume_up,
              isEnabled: state.isLocalSpeakerEnabled,
              onPressed: () => state.updateLocalSpeakerState(!state.isLocalSpeakerEnabled),
            ),
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
    state.exitRoom();
    super.dispose();
  }
}
