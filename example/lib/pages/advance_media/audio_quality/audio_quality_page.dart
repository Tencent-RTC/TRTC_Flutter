import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'audio_quality_state.dart';

class _QualityOption {
  final TRTCAudioQuality quality;
  final String label;
  final IconData icon;
  const _QualityOption(this.quality, this.label, this.icon);
}

class AudioQualityPage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const AudioQualityPage({
    Key? key,
    required this.userId,
    required this.roomIdSpec,
  }) : super(key: key);

  @override
  State<AudioQualityPage> createState() => _AudioQualityPageState();
}

class _AudioQualityPageState extends State<AudioQualityPage> {
  late AudioQualityState _state;
  static const _accentColor = Color(0xFF00897B);

  @override
  void initState() {
    super.initState();
    _state = AudioQualityState(userId: widget.userId, roomIdSpec: widget.roomIdSpec);
    _state.addListener(_onChanged);
    _state.queriedCaptureVolume.addListener(_onChanged);
    _state.queriedPlayoutVolume.addListener(_onChanged);
    _state.initialize();
  }

  void _onChanged() => mounted ? setState(() {}) : null;

  @override
  void dispose() {
    _state.queriedCaptureVolume.removeListener(_onChanged);
    _state.queriedPlayoutVolume.removeListener(_onChanged);
    _state.removeListener(_onChanged);
    _state.dispose();
    super.dispose();
  }

  BoxDecoration _cardDec() => BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider.value(
      value: _state,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.audioQualityTitle),
          actions: [
            Container(
              width: 10, height: 10, margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: _state.isEnterRoom ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        body: Column(children: [
          _buildUserList(l10n),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _buildQualityCard(l10n),
              const SizedBox(height: 10),
              _buildVolumeCard(l10n),
              const SizedBox(height: 10),
              _buildDeviceCard(l10n),
            ]),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity, height: 48,
              child: FilledButton(
                onPressed: () { _state.exitRoom(); Navigator.pop(context); },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(l10n.exitRoomButton),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ─── User list ───────────────────────────────────────────────

  Widget _buildUserList(AppLocalizations l10n) {
    final users = _state.users;
    if (users.isEmpty) {
      return SizedBox(height: 80, child: Center(child: Text(l10n.noRemoteUser, style: TextStyle(color: Colors.grey.shade400))));
    }
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: users.length,
        itemBuilder: (_, i) => _buildUserTile(users[i], l10n),
      ),
    );
  }

  Widget _buildUserTile(AudioUser user, AppLocalizations l10n) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: _cardDec().color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: user.isSpeaking ? Colors.green.withOpacity(0.5) : Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Stack(alignment: Alignment.center, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: user.isSpeaking ? Colors.green.withOpacity(0.2) : Colors.transparent,
            ),
          ),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: user.isLocalUser ? _accentColor : Colors.grey.shade400,
            ),
            child: Icon(user.isMuted ? Icons.mic_off : Icons.mic, color: Colors.white, size: 16),
          ),
        ]),
        const SizedBox(height: 4),
        Text(
          user.isLocalUser ? '${user.userId}${l10n.meSuffix}' : user.userId,
          style: const TextStyle(fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        GestureDetector(
          onTap: () => _state.toggleUserMute(user.userId),
          child: Icon(user.isMuted ? Icons.volume_off : Icons.volume_up,
              size: 14, color: user.isMuted ? Colors.red : Colors.grey),
        ),
      ]),
    );
  }

  // ─── Quality mode card ───────────────────────────────────────

  Widget _buildQualityCard(AppLocalizations l10n) {
    final modes = [
      _QualityOption(TRTCAudioQuality.speech, l10n.audioQualitySpeech, Icons.record_voice_over_outlined),
      _QualityOption(TRTCAudioQuality.defaultMode, l10n.audioQualityStandard, Icons.graphic_eq_outlined),
      _QualityOption(TRTCAudioQuality.music, l10n.audioQualityMusic, Icons.music_note_outlined),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(l10n.audioSettings, Icons.equalizer_outlined),
        const SizedBox(height: 12),
        Row(children: modes.map((m) {
          final selected = _state.selectedQuality == m.quality;
          return Expanded(child: GestureDetector(
            onTap: () => _state.setQuality(m.quality),
            child: Container(
              margin: EdgeInsets.only(right: m.quality != modes.last.quality ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? _accentColor.withOpacity(0.12) : Colors.grey.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: selected ? _accentColor : Colors.transparent, width: 1.5),
              ),
              child: Column(children: [
                Icon(m.icon, size: 22, color: selected ? _accentColor : Colors.grey),
                const SizedBox(height: 4),
                Text(m.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: selected ? _accentColor : Colors.grey.shade700)),
              ]),
            ),
          ));
        }).toList()),
      ]),
    );
  }

  // ─── Volume card ─────────────────────────────────────────────

  Widget _buildVolumeCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(l10n.audioSettings, Icons.volume_up_outlined),
        const SizedBox(height: 12),
        _volumeRow(
          l10n.captureVolume, _state.captureVolume.toDouble(),
          (v) => _state.setCaptureVolume(v.round()),
          _state.queriedCaptureVolume.value,
          _state.queryCaptureVolume,
        ),
        const Divider(height: 20),
        _volumeRow(
          l10n.playbackVolume, _state.playbackVolume.toDouble(),
          (v) => _state.setPlaybackVolume(v.round()),
          _state.queriedPlayoutVolume.value,
          _state.queryPlayoutVolume,
        ),
      ]),
    );
  }

  Widget _volumeRow(String label, double value, ValueChanged<double> onChanged,
      int? queriedValue, VoidCallback onQuery) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const Spacer(),
        if (queriedValue != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('SDK: $queriedValue',
                style: TextStyle(fontSize: 10, color: Colors.blue.shade600, fontWeight: FontWeight.w600)),
          ),
        SizedBox(
          height: 26,
          child: OutlinedButton(
            onPressed: onQuery,
            child: Text('Get', style: TextStyle(fontSize: 10, color: _accentColor)),
            style: OutlinedButton.styleFrom(
              foregroundColor: _accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(36, 26),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 36, height: 24, alignment: Alignment.center,
          decoration: BoxDecoration(color: _accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
          child: Text('${value.round()}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _accentColor)),
        ),
      ]),
      Slider(
        value: value, min: 0, max: 100, divisions: 100,
        activeColor: _accentColor,
        label: value.round().toString(),
        onChanged: onChanged,
      ),
    ]);
  }

  // ─── Device card ─────────────────────────────────────────────

  Widget _buildDeviceCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(l10n.audioSettings, Icons.devices_outlined),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _deviceToggle(
            l10n.captureVolume, _state.micEnabled,
            Icons.mic, Icons.mic_off, _state.toggleMic,
          )),
          const SizedBox(width: 10),
          Expanded(child: _deviceToggle(
            l10n.playbackVolume, _state.speakerEnabled,
            Icons.volume_up, Icons.volume_down, _state.toggleSpeaker,
          )),
        ]),
      ]),
    );
  }

  Widget _deviceToggle(String label, bool enabled, IconData onIcon, IconData offIcon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: enabled ? _accentColor.withOpacity(0.08) : Colors.grey.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: enabled ? _accentColor.withOpacity(0.3) : Colors.transparent),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(enabled ? onIcon : offIcon, size: 18,
              color: enabled ? _accentColor : Colors.red),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: enabled ? _accentColor : Colors.grey.shade600)),
        ]),
      ),
    );
  }

  Widget _cardHeader(String title, IconData icon) => Row(children: [
        Icon(icon, size: 18, color: _accentColor),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ]);
}
