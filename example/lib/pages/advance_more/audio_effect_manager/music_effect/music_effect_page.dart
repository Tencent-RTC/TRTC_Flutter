import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'music_effect_state.dart';

class MusicEffectPage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const MusicEffectPage({Key? key, required this.userId, required this.roomIdSpec})
      : super(key: key);

  @override
  State<MusicEffectPage> createState() => _MusicEffectPageState();
}

class _MusicEffectPageState extends State<MusicEffectPage> {
  late MusicEffectState _state;
  final _pathController = TextEditingController(text: 'assets/music/daoxiang.mp3');
  final _idController = TextEditingController(text: '1');
  final _loopController = TextEditingController(text: '0');
  final _seekController = TextEditingController();
  final _trackController = TextEditingController();
  static const _accentColor = Color(0xFFAD1457);

  @override
  void initState() {
    super.initState();
    _state = MusicEffectState(userId: widget.userId, roomIdSpec: widget.roomIdSpec);
    _state.addListener(_onChanged);
    _state.isPlaying.addListener(_onChanged);
    _state.isPaused.addListener(_onChanged);
    _state.initialize();
  }

  void _onChanged() => mounted ? setState(() {}) : null;

  @override
  void dispose() {
    _state.isPlaying.removeListener(_onChanged);
    _state.isPaused.removeListener(_onChanged);
    _state.removeListener(_onChanged);
    _pathController.dispose();
    _idController.dispose();
    _loopController.dispose();
    _seekController.dispose();
    _trackController.dispose();
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
          title: Text(l10n.musicEffectTitle),
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
              _buildMusicConfigCard(l10n),
              const SizedBox(height: 10),
              _buildPlaybackCard(l10n),
              const SizedBox(height: 10),
              _buildAdjustCard(l10n),
              const SizedBox(height: 10),
              _buildProgressCard(l10n),
              const SizedBox(height: 10),
              _buildTrackPreloadCard(l10n),
              const SizedBox(height: 10),
              _buildLogCard(l10n),
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

  Widget _buildPreview(AppLocalizations l10n) => Container(
        margin: const EdgeInsets.all(12),
        height: 160,
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(14)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(children: [
            TRTCCloudVideoView(onViewCreated: (v) => _state.setLocalViewId(v)),
            Positioned(top: 8, left: 12, child: _label(l10n.localPreview, _accentColor)),
          ]),
        ),
      );

  Widget _label(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  // ─── Music config card ───────────────────────────────────────

  Widget _buildMusicConfigCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(l10n.musicFileSection, Icons.music_note_outlined),
        const SizedBox(height: 12),
        TextField(
          controller: _pathController,
          decoration: _inputDec(l10n.musicFileHint),
          onChanged: (v) => _state.setMusicPath(v),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: TextField(
            controller: _idController,
            decoration: _inputDec(l10n.musicIdLabel),
            keyboardType: TextInputType.number,
            onChanged: (v) => _state.setMusicId(int.tryParse(v) ?? 1),
          )),
          const SizedBox(width: 10),
          Expanded(child: TextField(
            controller: _loopController,
            decoration: _inputDec(l10n.loopCountLabel),
            keyboardType: TextInputType.number,
            onChanged: (v) => _state.setLoopCount(int.tryParse(v) ?? 0),
          )),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _toggleChip(l10n.publishLabel, _state.publish, _state.togglePublish),
          const SizedBox(width: 10),
          _toggleChip(l10n.shortFileLabel, _state.isShortFile, _state.toggleShortFile),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity, height: 44,
          child: FilledButton.icon(
            onPressed: _state.isEnterRoom ? _state.startPlayMusic : null,
            icon: const Icon(Icons.play_arrow, size: 20),
            label: Text(l10n.startMusicButton),
            style: FilledButton.styleFrom(
              backgroundColor: _accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _toggleChip(String label, bool value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value ? _accentColor.withOpacity(0.12) : Colors.grey.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: value ? _accentColor : Colors.transparent),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(value ? Icons.check_circle : Icons.radio_button_unchecked, size: 16,
              color: value ? _accentColor : Colors.grey),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: value ? _accentColor : Colors.grey.shade700)),
        ]),
      ),
    );
  }

  // ─── Playback control card ───────────────────────────────────

  Widget _buildPlaybackCard(AppLocalizations l10n) {
    final playing = _state.isPlaying.value;
    final paused = _state.isPaused.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _cardHeader(l10n.pauseResumeStopSection, Icons.av_timer),
          const Spacer(),
          if (playing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (paused ? Colors.orange : Colors.green).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(paused ? Icons.pause_circle : Icons.equalizer,
                    size: 14, color: paused ? Colors.orange : Colors.green),
                const SizedBox(width: 4),
                Text(paused ? l10n.pauseButton : l10n.startMusicButton,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: paused ? Colors.orange : Colors.green)),
              ]),
            ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _ctrlButton(
            l10n.pauseButton, Icons.pause,
            playing && !paused ? _state.pauseMusic : null,
          )),
          const SizedBox(width: 8),
          Expanded(child: _ctrlButton(
            l10n.resumeButton, Icons.play_arrow,
            paused ? _state.resumeMusic : null,
          )),
          const SizedBox(width: 8),
          Expanded(child: _ctrlButton(
            l10n.stopButton, Icons.stop,
            playing ? _state.stopMusic : null,
            isStop: true,
          )),
        ]),
      ]),
    );
  }

  Widget _ctrlButton(String label, IconData icon, VoidCallback? onPressed, {bool isStop = false}) {
    final enabled = onPressed != null;
    final color = isStop ? Colors.red : _accentColor;
    return SizedBox(
      height: 42,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: enabled ? color : Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // ─── Volume / Pitch / Speed card ─────────────────────────────

  Widget _buildAdjustCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(l10n.musicVolumePitchSection, Icons.tune),
        const SizedBox(height: 8),
        _sliderRow(l10n.allVolumeLabel, _state.allMusicVolume.toDouble(), 0, 150, 150,
            (v) => _state.setAllMusicVolume(v.round())),
        _sliderRow(l10n.playoutVolumeLabel, _state.musicPlayoutVolume.toDouble(), 0, 100, 100,
            (v) => _state.setMusicPlayoutVolume(v.round())),
        _sliderRow(l10n.publishVolumeLabel, _state.musicPublishVolume.toDouble(), 0, 100, 100,
            (v) => _state.setMusicPublishVolume(v.round())),
        _sliderRow(l10n.musicPitchLabel, _state.musicPitch, -1, 1, 20,
            (v) => _state.setMusicPitch(v)),
        _sliderRow(l10n.speedRateLabel, _state.musicSpeedRate, 0.5, 2.0, 15,
            (v) => _state.setMusicSpeedRate(v)),
      ]),
    );
  }

  Widget _sliderRow(String label, double value, double min, double max, int divisions, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const Spacer(),
          Container(
            width: 48, height: 24, alignment: Alignment.center,
            decoration: BoxDecoration(color: _accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(value.toStringAsFixed(divisions < 10 ? 0 : 2),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _accentColor)),
          ),
        ]),
        Slider(value: value, min: min, max: max, divisions: divisions,
            activeColor: _accentColor, label: value.toStringAsFixed(2), onChanged: onChanged),
      ]),
    );
  }

  // ─── Progress card ───────────────────────────────────────────

  Widget _buildProgressCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(l10n.musicProgressSection, Icons.timeline),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _ctrlButton(l10n.getCurrentPosButton, Icons.my_location, _state.getMusicCurrentPos)),
          const SizedBox(width: 8),
          Expanded(child: _ctrlButton(l10n.getDurationButton, Icons.timer, _state.getMusicDuration)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: TextField(
            controller: _seekController,
            decoration: _inputDec(l10n.seekToMsLabel),
            keyboardType: TextInputType.number,
          )),
          const SizedBox(width: 10),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: _state.isEnterRoom ? () {
                final pts = int.tryParse(_seekController.text.trim()) ?? 0;
                _state.seekMusicToPos(pts);
              } : null,
              style: FilledButton.styleFrom(
                backgroundColor: _accentColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(l10n.seekButton),
            ),
          ),
        ]),
      ]),
    );
  }

  // ─── Track & preload card ────────────────────────────────────

  Widget _buildTrackPreloadCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(l10n.trackPreloadSection, Icons.layers_outlined),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _ctrlButton(l10n.getTrackCountButton, Icons.format_list_numbered, _state.getMusicTrackCount)),
          const SizedBox(width: 8),
          Expanded(child: _ctrlButton(l10n.preloadMusicButton, Icons.download_outlined, _state.preloadMusic)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: TextField(
            controller: _trackController,
            decoration: _inputDec(l10n.trackIndexLabel),
            keyboardType: TextInputType.number,
          )),
          const SizedBox(width: 10),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: _state.isEnterRoom ? () {
                final idx = int.tryParse(_trackController.text.trim()) ?? 0;
                _state.setMusicTrack(idx);
              } : null,
              style: FilledButton.styleFrom(
                backgroundColor: _accentColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(l10n.setTrackButton),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _ctrlButton(l10n.setPreloadObserverButton, Icons.notifications_outlined, _state.setPreloadObserver)),
          const SizedBox(width: 8),
          Expanded(child: _ctrlButton(l10n.setMusicObserverButton, Icons.hearing, _state.setMusicObserver)),
        ]),
      ]),
    );
  }

  // ─── Log card ────────────────────────────────────────────────

  Widget _buildLogCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.history, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Text(l10n.callbackLogSection,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          if (_state.logs.isNotEmpty)
            TextButton(
              onPressed: _state.clearLogs,
              child: Text(l10n.clearButton, style: const TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(foregroundColor: Colors.red, padding: EdgeInsets.zero),
            ),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: _state.logs.isEmpty
              ? Center(child: Text('—', style: TextStyle(color: Colors.grey.shade400, fontSize: 24)))
              : ListView.separated(
                  itemCount: _state.logs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => Text(_state.logs[i],
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ),
        ),
      ]),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────

  Widget _cardHeader(String title, IconData icon) => Row(children: [
        Icon(icon, size: 18, color: _accentColor),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ]);

  InputDecoration _inputDec(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      );
}
