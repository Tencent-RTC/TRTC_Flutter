import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'audio_quality_state.dart';

class AudioQualityPage extends StatefulWidget {
  final String userId;
  final String roomId;

  const AudioQualityPage({
    Key? key,
    required this.userId,
    required this.roomId,
  }) : super(key: key);

  @override
  State<AudioQualityPage> createState() => _AudioQualityPageState();
}

class _AudioQualityPageState extends State<AudioQualityPage> {
  late AudioQualityState _state;

  @override
  void initState() {
    super.initState();
    _state = AudioQualityState(
      userId: widget.userId,
      roomId: widget.roomId,
    );
    _state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    _state.exitRoom();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              _buildTopBar(),
              if (!_state.isInitialized)
                Expanded(
                  child: Center(
                    child: Text(
                      _state.statusMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              else
                Expanded(
                  child: _buildUserList(),
                ),
              _buildBottomSettings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Room ID: ${_state.roomId}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'User ID: ${_state.userId}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 9 / 16,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _state.users.length,
        itemBuilder: (context, index) {
          final user = _state.users[index];
          return _buildUserTile(user);
        },
      ),
    );
  }

  Widget _buildUserTile(AudioUser user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white24,
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(user.isSpeaking ? 1 : 0),
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
                      user.hasStream ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              Text(
                user.isLocalUser ? '${user.userId}(Me)' : user.userId,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              InkWell(
                onTap: () => _state.toggleUserMute(user.userId),
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(
                    user.isMuted ? Icons.volume_off : Icons.volume_up,
                    color: user.isMuted ? Colors.red : Colors.white,
                    size: 16,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Audio Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQualityModeButton(TRTCAudioQuality.speech),
              _buildQualityModeButton(TRTCAudioQuality.defaultMode),
              _buildQualityModeButton(TRTCAudioQuality.music),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildVolumeSlider(
                  label: 'Capture Volume',
                  value: _state.captureVolume,
                  onChanged: _state.updateCaptureVolume,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildVolumeSlider(
                  label: 'Playback Volume',
                  value: _state.playbackVolume,
                  onChanged: _state.updatePlaybackVolume,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityModeButton(TRTCAudioQuality quality) {
    String mode = _state.getQualityString(quality);
    final isSelected = _state.selectedQualityMode == quality;
    return ElevatedButton(
      onPressed: () => _state.updateQualityMode(quality),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.white.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        mode,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildVolumeSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            Text(
              '${value.round()}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.blue,
            inactiveTrackColor: Colors.white.withOpacity(0.1),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withOpacity(0.2),
            valueIndicatorColor: Colors.blue,
            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 100,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}