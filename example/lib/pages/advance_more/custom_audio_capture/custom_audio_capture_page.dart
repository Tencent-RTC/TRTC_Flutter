import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'custom_audio_capture_state.dart';

class CustomAudioCapturePage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const CustomAudioCapturePage({
    Key? key,
    required this.userId,
    required this.roomIdSpec,
  }) : super(key: key);

  @override
  State<CustomAudioCapturePage> createState() => _CustomAudioCapturePageState();
}

class _CustomAudioCapturePageState extends State<CustomAudioCapturePage> {
  late CustomAudioCaptureState _captureState;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _captureState = CustomAudioCaptureState();
    await _captureState.initialize(
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
    _captureState.exitRoom();
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

    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider.value(
      value: _captureState,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.customAudioCaptureTitle),
          backgroundColor: Colors.deepPurple,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple.shade900,
                Colors.deepPurple.shade700,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildParticipantsGrid(),
                ),
                _buildControlPanel(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<CustomAudioCaptureState>(
      builder: (context, state, child) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.roomIdDisplay(state.roomId ?? ''),
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
                  state.status.toText(AppLocalizations.of(context)!),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (state.isCustomAudioEnabled) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.fiber_manual_record,
                        color: Colors.green,
                        size: 12,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.framesSent(state.frameCount),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticipantsGrid() {
    return Consumer<CustomAudioCaptureState>(
      builder: (context, state, child) {
        final allParticipants = [
          RemoteUserState(
            userId: state.localUserId!,
            hasAudio: state.isCustomAudioEnabled,
          ),
          ...state.remoteUsers,
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
    final isLocalUser = participant.userId == _captureState.localUserId;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isLocalUser ? Colors.green : Colors.white24,
          width: 2,
        ),
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
                  color: Colors.deepPurple.shade700,
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
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                participant.hasAudio ? Icons.mic : Icons.mic_off,
                color: participant.hasAudio ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                participant.hasAudio ? AppLocalizations.of(context)!.audioOnLabel : AppLocalizations.of(context)!.audioOffLabel,
                style: TextStyle(
                  color: participant.hasAudio ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<CustomAudioCaptureState>(
      builder: (context, state, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                l10n.customAudioCaptureControls,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: state.isCustomAudioEnabled ? Icons.stop : Icons.play_arrow,
                    label: state.isCustomAudioEnabled ? l10n.stopCaptureButton : l10n.startCaptureButton,
                    backgroundColor: state.isCustomAudioEnabled ? Colors.red : Colors.green,
                    onPressed: () => _toggleCustomAudioCapture(!state.isCustomAudioEnabled),
                  ),
                  _buildControlButton(
                    icon: Icons.exit_to_app,
                    label: l10n.exitRoomButton,
                    backgroundColor: Colors.orange,
                    onPressed: _exitRoom,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aboutCustomAudioCapture,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.customAudioCaptureInfo,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(icon, size: 30, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _toggleCustomAudioCapture(bool enable) async {
    await _captureState.enableCustomAudioCapture(enable);
  }

  Future<void> _exitRoom() async {
    await _captureState.exitRoom();
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
