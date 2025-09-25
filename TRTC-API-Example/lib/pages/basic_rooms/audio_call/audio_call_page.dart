import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio_call_state.dart';

class AudioCallPage extends StatefulWidget {
  final String userId;
  final int roomId;

  const AudioCallPage({
    Key? key,
    required this.userId,
    required this.roomId,
  }) : super(key: key);

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  late AudioCallState _callState;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    _callState = AudioCallState();
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
                  child: _buildParticipantsGrid(),
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
    return Consumer<AudioCallState>(
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

  Widget _buildParticipantsGrid() {
    return Consumer<AudioCallState>(
      builder: (context, callState, child) {
        final allParticipants = [
          RemoteUserState(
            userId: callState.localUserId!,
            isMuted: !callState.isLocalMicrophoneEnabled,
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
            return _buildParticipantTile(participant);
          },
        );
      },
    );
  }

  Widget _buildParticipantTile(RemoteUserState participant) {
    final isLocalUser = participant.userId == _callState.localUserId;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.blue.shade700,
                ),
              ),
              if (isLocalUser)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            participant.userId,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          if (participant.isMuted)
            const Icon(
              Icons.mic_off,
              color: Colors.white,
              size: 20,
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    return Consumer<AudioCallState>(
      builder: (context, callState, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              icon: callState.isLocalMicrophoneEnabled ? Icons.mic : Icons.mic_off,
              label: 'Microphone',
              onPressed: () {
                _onMicrophoneToggle(!callState.isLocalMicrophoneEnabled);
              },
            ),
            _buildControlButton(
              icon: callState.isLocalSpeakerEnabled ? Icons.volume_up : Icons.volume_off,
              label: 'Speaker',
              onPressed: () {
                _onSpeakerToggle(!callState.isLocalSpeakerEnabled);
              },
            ),
            _buildControlButton(
              icon: Icons.call_end,
              label: 'End Call',
              backgroundColor: Colors.red,
              onPressed: _endCall,
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

  Future<void> _onMicrophoneToggle(bool enabled) async {
    await _callState.updateLocalMicrophoneState(enabled);
  }

  Future<void> _onSpeakerToggle(bool enabled) async {
    await _callState.updateLocalSpeakerState(enabled);
  }

  Future<void> _endCall() async {
    await _callState.endCall();
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
