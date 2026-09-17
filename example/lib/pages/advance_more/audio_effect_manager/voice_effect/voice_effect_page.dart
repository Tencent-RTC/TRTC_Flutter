import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:tencent_rtc_sdk/tx_audio_effect_manager.dart';
import 'voice_effect_state.dart';

class _EffectOption<T> {
  final T value;
  final String label;
  final IconData icon;
  const _EffectOption(this.value, this.label, this.icon);
}

class VoiceEffectPage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const VoiceEffectPage({Key? key, required this.userId, required this.roomIdSpec})
      : super(key: key);

  @override
  State<VoiceEffectPage> createState() => _VoiceEffectPageState();
}

class _VoiceEffectPageState extends State<VoiceEffectPage> {
  late VoiceEffectState _state;
  static const _accentColor = Color(0xFF283593);

  @override
  void initState() {
    super.initState();
    _state = VoiceEffectState(userId: widget.userId, roomIdSpec: widget.roomIdSpec);
    _state.addListener(_onChanged);
    _state.initialize();
  }

  void _onChanged() => mounted ? setState(() {}) : null;

  @override
  void dispose() {
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
          title: Text(l10n.voiceEffectTitle),
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
          _buildPreview(l10n),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _buildEarMonitorCard(l10n),
              const SizedBox(height: 10),
              _buildReverbCard(l10n),
              const SizedBox(height: 10),
              _buildChangerCard(l10n),
              const SizedBox(height: 10),
              _buildSliderCard(l10n),
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

  // ─── Local preview ───────────────────────────────────────────

  Widget _buildPreview(AppLocalizations l10n) => Container(
        margin: const EdgeInsets.all(12),
        height: 160,
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(14)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(children: [
            TRTCCloudVideoView(onViewCreated: (v) => _state.setLocalViewId(v)),
            Positioned(
              top: 8, left: 12,
              child: _label(l10n.localPreview, _accentColor),
            ),
          ]),
        ),
      );

  Widget _label(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  // ─── Ear monitor card ────────────────────────────────────────

  Widget _buildEarMonitorCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.headphones, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Text(l10n.earMonitorSection,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          Switch(
            value: _state.earMonitorEnabled,
            onChanged: (_) => _state.toggleEarMonitor(),
            activeColor: _accentColor,
          ),
        ]),
        if (_state.earMonitorEnabled) ...[
          const SizedBox(height: 8),
          _sliderRow(l10n.volumeLabel, _state.earMonitorVolume.toDouble(), 0, 150, 150,
              (v) => _state.setEarMonitorVolume(v.round())),
        ],
      ]),
    );
  }

  // ─── Reverb card ─────────────────────────────────────────────

  Widget _buildReverbCard(AppLocalizations l10n) {
    final types = [
      _EffectOption(TXVoiceReverbType.type0, l10n.reverbOff, Icons.close),
      _EffectOption(TXVoiceReverbType.type1, l10n.reverbKtv, Icons.mic),
      _EffectOption(TXVoiceReverbType.type2, l10n.reverbSmallRoom, Icons.meeting_room_outlined),
      _EffectOption(TXVoiceReverbType.type3, l10n.reverbGreatHall, Icons.business_center_outlined),
      _EffectOption(TXVoiceReverbType.type4, l10n.reverbDeep, Icons.graphic_eq),
      _EffectOption(TXVoiceReverbType.type5, l10n.reverbLoud, Icons.volume_up_outlined),
      _EffectOption(TXVoiceReverbType.type6, l10n.reverbMetallic, Icons.hardware_outlined),
      _EffectOption(TXVoiceReverbType.type7, l10n.reverbMagnetic, Icons.record_voice_over_outlined),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.surround_sound_outlined, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Text(l10n.voiceReverbSection,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: types.map((t) {
          final selected = _state.reverbType == t.value;
          return _effectChip(t.label, t.icon, selected, () => _state.setReverbType(t.value));
        }).toList()),
      ]),
    );
  }

  // ─── Changer card ────────────────────────────────────────────

  Widget _buildChangerCard(AppLocalizations l10n) {
    final types = [
      _EffectOption(TXVoiceChangerType.type0, l10n.changerOff, Icons.close),
      _EffectOption(TXVoiceChangerType.type1, l10n.changerNaughtyKid, Icons.child_care_outlined),
      _EffectOption(TXVoiceChangerType.type2, l10n.changerLolita, Icons.face_2_outlined),
      _EffectOption(TXVoiceChangerType.type3, l10n.changerUncle, Icons.face_outlined),
      _EffectOption(TXVoiceChangerType.type4, l10n.changerHeavyMetal, Icons.music_note_outlined),
      _EffectOption(TXVoiceChangerType.type5, l10n.changerCold, Icons.sick_outlined),
      _EffectOption(TXVoiceChangerType.type6, l10n.changerForeigner, Icons.public_outlined),
      _EffectOption(TXVoiceChangerType.type7, l10n.changerTrapped, Icons.pets_outlined),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.record_voice_over, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Text(l10n.voiceChangerSection,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: types.map((t) {
          final selected = _state.changerType == t.value;
          return _effectChip(t.label, t.icon, selected, () => _state.setChangerType(t.value));
        }).toList()),
      ]),
    );
  }

  Widget _effectChip(String label, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _accentColor.withOpacity(0.12) : Colors.grey.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? _accentColor : Colors.transparent, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: selected ? _accentColor : Colors.grey),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: selected ? _accentColor : Colors.grey.shade700,
          )),
        ]),
      ),
    );
  }

  // ─── Volume & Pitch sliders ──────────────────────────────────

  Widget _buildSliderCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(children: [
        _sliderRow(l10n.voiceCaptureVolumeSection, _state.captureVolume.toDouble(), 0, 150, 150,
            (v) => _state.setCaptureVolume(v.round())),
        const Divider(height: 20),
        _sliderRow(l10n.voicePitchSection, _state.voicePitch, -1, 1, 20,
            (v) => _state.setVoicePitch(v)),
      ]),
    );
  }

  Widget _sliderRow(String label, double value, double min, double max, int divisions,
      ValueChanged<double> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.tune, size: 18, color: _accentColor),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        Container(
          width: 48, height: 26, alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
          child: Text(value.toStringAsFixed(divisions < 10 ? 0 : 2),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _accentColor)),
        ),
      ]),
      Slider(
        value: value, min: min, max: max, divisions: divisions,
        activeColor: _accentColor,
        label: value.toStringAsFixed(2),
        onChanged: onChanged,
      ),
    ]);
  }
}
