import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/common/room_input_prefs.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';
import 'device_manager_state.dart';

class DeviceManagerPage extends StatefulWidget {
  const DeviceManagerPage({Key? key}) : super(key: key);

  @override
  State<DeviceManagerPage> createState() => _DeviceManagerPageState();
}

class _DeviceManagerPageState extends State<DeviceManagerPage> {
  DeviceManagerState? _state;
  static const _accentColor = Color(0xFF455A64);

  @override
  void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initState() async {
    final userId = RoomInputPrefs.lastUserId;
    final numericRoomId = RoomInputPrefs.lastRoomId;
    final strRoomId = RoomInputPrefs.lastStrRoomId;
    final roomId = int.tryParse(numericRoomId) ?? 0;
    final spec = RoomIdSpec(roomId: roomId, strRoomId: strRoomId);
    final state = DeviceManagerState(userId: userId, roomIdSpec: spec);
    _state = state;
    state.addListener(_onChanged);
    state.resultMessage.addListener(_onResultMessage);
    await state.initialize();
  }

  void _onChanged() => mounted ? setState(() {}) : null;

  void _onResultMessage() {
    final msg = _state?.resultMessage.value;
    if (msg == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    String text;
    if (msg.startsWith('front_camera:')) {
      final val = msg.split(':')[1] == 'true';
      text = l10n.isFrontCameraResult(val);
    } else if (msg.startsWith('max_zoom:')) {
      final val = msg.split(':')[1];
      text = l10n.maxZoomRatioResult(val);
    } else if (msg.startsWith('auto_focus:')) {
      final val = msg.split(':')[1] == 'true';
      text = l10n.autoFocusEnabledResult(val);
    } else if (msg.startsWith('mic_volume:')) {
      text = '${l10n.micVolumeLabel}: ${msg.split(':')[1]}';
    } else if (msg.startsWith('speaker_volume:')) {
      text = '${l10n.speakerVolumeLabel}: ${msg.split(':')[1]}';
    } else if (msg.startsWith('audio_route:')) {
      text = l10n.audioRouteChangedMsg(msg.split(':')[1]);
    } else {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );
    _state!.resultMessage.value = null;
  }

  @override
  void dispose() {
    _state?.resultMessage.removeListener(_onResultMessage);
    _state?.removeListener(_onChanged);
    _state?.dispose();
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
    if (_state == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.deviceManagerTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return ChangeNotifierProvider.value(
      value: _state!,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.deviceManagerTitle),
          actions: [
            Container(
              width: 10, height: 10, margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: _state!.isEnterRoom ? Colors.green : Colors.grey,
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
              _buildQueryCard(l10n),
              const SizedBox(height: 10),
              _buildCameraCard(l10n),
              const SizedBox(height: 10),
              _buildAudioCard(l10n),
              const SizedBox(height: 10),
              _buildFocusCard(l10n),
              const SizedBox(height: 10),
              _buildCaptureCard(l10n),
            ]),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity, height: 48,
              child: FilledButton(
                onPressed: () { _state!.exitRoom(); Navigator.pop(context); },
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
        height: 200,
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(14)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(children: [
            TRTCCloudVideoView(onViewCreated: (v) => _state!.setLocalViewId(v)),
            Positioned(top: 8, left: 12, child: _label(l10n.localPreview, _accentColor)),
          ]),
        ),
      );

  Widget _label(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  // ─── Query card ──────────────────────────────────────────────

  Widget _buildQueryCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.info_outline, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Text(l10n.deviceOperations,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _queryButton(l10n.frontCameraStatus, l10n.getButton,
              () => _state!.queryFrontCamera())),
          const SizedBox(width: 8),
          Expanded(child: _queryButton(l10n.maxZoomRatio, l10n.getButton,
              () => _state!.queryMaxZoomRatio())),
          const SizedBox(width: 8),
          Expanded(child: _queryButton(l10n.autoFocusStatus, l10n.getButton,
              () => _state!.queryAutoFocus())),
        ]),
      ]),
    );
  }

  Widget _queryButton(String label, String buttonLabel, VoidCallback onPressed) {
    return Column(children: [
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), textAlign: TextAlign.center),
      const SizedBox(height: 6),
      SizedBox(
        height: 32,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: _accentColor,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(buttonLabel, style: const TextStyle(fontSize: 12)),
        ),
      ),
    ]);
  }

  // ─── Camera settings card ────────────────────────────────────

  Widget _buildCameraCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.camera_alt_outlined, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Text(l10n.cameraSettings,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        // Front/back camera switch
        ValueListenableBuilder<bool>(
          valueListenable: _state!.frontCamera,
          builder: (_, isFront, __) => _toggleItem(
            l10n.frontCameraLabel, isFront,
            (v) => _state!.toggleFrontCamera(),
          ),
        ),
        const Divider(height: 20),
        // Torch
        ValueListenableBuilder<bool>(
          valueListenable: _state!.cameraTorch,
          builder: (_, torch, __) => _toggleItem(
            l10n.enableCameraTorch, torch,
            (v) => _state!.toggleTorch(),
          ),
        ),
        const Divider(height: 20),
        // Auto focus
        ValueListenableBuilder<bool>(
          valueListenable: _state!.cameraAutoFocus,
          builder: (_, autoFocus, __) => _toggleItem(
            l10n.autoFocusStatus, autoFocus,
            (v) => _state!.toggleAutoFocus(),
          ),
        ),
        const Divider(height: 20),
        // Zoom ratio
        ValueListenableBuilder<double>(
          valueListenable: _state!.cameraZoomRatio,
          builder: (_, ratio, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.zoom_in, size: 18, color: _accentColor),
                const SizedBox(width: 8),
                Text(l10n.zoomRatioLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const Spacer(),
                Container(
                  width: 48, height: 26, alignment: Alignment.center,
                  decoration: BoxDecoration(color: _accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(ratio.toStringAsFixed(1), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _accentColor)),
                ),
              ]),
              Slider(
                value: ratio, min: 1.0, max: 10.0, divisions: 90,
                activeColor: _accentColor,
                onChanged: (v) => _state!.cameraZoomRatio.value = v,
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _toggleItem(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      const Spacer(),
      Switch(value: value, onChanged: onChanged, activeColor: _accentColor),
    ]);
  }

  // ─── Audio settings card ─────────────────────────────────────

  Widget _buildAudioCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.volume_up_outlined, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Text(l10n.audioSettings,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        ValueListenableBuilder<TXAudioRoute>(
          valueListenable: _state!.audioRoute,
          builder: (_, route, __) => Row(children: [
            Text(l10n.audioRouteLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const Spacer(),
            SegmentedButton<TXAudioRoute>(
              segments: [
                ButtonSegment(value: TXAudioRoute.speakerPhone, label: Text(l10n.audioRouteSpeaker, style: const TextStyle(fontSize: 11))),
                ButtonSegment(value: TXAudioRoute.earpiece, label: Text(l10n.audioRouteEarpiece, style: const TextStyle(fontSize: 11))),
              ],
              // External routes (wiredHeadset / bluetooth...) may not be in segments
              selected: (route == TXAudioRoute.speakerPhone || route == TXAudioRoute.earpiece)
                  ? {route}
                  : const <TXAudioRoute>{},
              onSelectionChanged: (s) => _state!.setAudioRoute(s.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ]),
        ),
        const Divider(height: 20),
        // Mic volume + mute
        ValueListenableBuilder<int>(
          valueListenable: _state!.micVolume,
          builder: (_, vol, __) => _volumeRow(
            l10n.micVolumeLabel, vol,
            _state!.micMuted, l10n.micMuteLabel,
            (v) => _state!.setMicVolume(v),
            () => _state!.toggleMicMute(),
          ),
        ),
        const Divider(height: 20),
        // Speaker volume + mute
        ValueListenableBuilder<int>(
          valueListenable: _state!.speakerVolume,
          builder: (_, vol, __) => _volumeRow(
            l10n.speakerVolumeLabel, vol,
            _state!.speakerMuted, l10n.speakerMuteLabel,
            (v) => _state!.setSpeakerVolume(v),
            () => _state!.toggleSpeakerMute(),
          ),
        ),
      ]),
    );
  }

  Widget _volumeRow(String label, int volume, bool muted, String muteLabel,
      ValueChanged<int> onVolumeChanged, VoidCallback onMuteToggle) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const Spacer(),
        Container(
          width: 42, height: 24, alignment: Alignment.center,
          decoration: BoxDecoration(color: _accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
          child: Text('$volume', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _accentColor)),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onMuteToggle,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(muted ? Icons.volume_off : Icons.volume_up,
                size: 20, color: muted ? Colors.red : _accentColor),
          ),
        ),
      ]),
      Slider(
        value: volume.toDouble(), min: 0, max: 100, divisions: 100,
        activeColor: _accentColor,
        onChanged: (v) => onVolumeChanged(v.round()),
      ),
    ]);
  }

  // ─── Focus position card ─────────────────────────────────────

  Widget _buildFocusCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.center_focus_strong_outlined, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Text(l10n.focusPositionLabel,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        _sliderRow(l10n.xAxisLabel, _state!.focusPositionX, (v) => _state!.setFocusPosition(v, _state!.focusPositionY)),
        _sliderRow(l10n.yAxisLabel, _state!.focusPositionY, (v) => _state!.setFocusPosition(_state!.focusPositionX, v)),
      ]),
    );
  }

  Widget _sliderRow(String label, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: Slider(
            value: value, min: 0, max: 1, divisions: 100,
            activeColor: _accentColor,
            label: value.toStringAsFixed(2),
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 40, child: Text(value.toStringAsFixed(2), style: TextStyle(fontSize: 11, color: Colors.grey.shade600))),
      ]),
    );
  }

  // ─── Capture params card ─────────────────────────────────────

  Widget _buildCaptureCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.aspect_ratio_outlined, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Text(l10n.resolutionSettings,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: l10n.widthLabel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: _state!.captureWidth.toString()),
              onChanged: (v) => _state!.captureWidth = int.tryParse(v) ?? 640,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: l10n.heightLabel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: _state!.captureHeight.toString()),
              onChanged: (v) => _state!.captureHeight = int.tryParse(v) ?? 360,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<TXCameraCaptureMode>(
              value: _state!.captureMode,
              decoration: InputDecoration(
                labelText: l10n.captureModeLabel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              items: TXCameraCaptureMode.values.map((m) {
                String label;
                switch (m) {
                  case TXCameraCaptureMode.auto:
                    label = l10n.captureModeAuto;
                    break;
                  case TXCameraCaptureMode.performance:
                    label = l10n.captureModePerformance;
                    break;
                  case TXCameraCaptureMode.highQuality:
                    label = l10n.captureModeHighQuality;
                    break;
                  default:
                    label = m.name;
                }
                return DropdownMenuItem(value: m, child: Text(label, style: const TextStyle(fontSize: 12)));
              }).toList(),
              onChanged: (v) { if (v != null) _state!.captureMode = v; },
            ),
          ),
        ]),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity, height: 40,
          child: FilledButton(
            onPressed: () => _state!.setCaptureParam(
              _state!.captureWidth, _state!.captureHeight, _state!.captureMode),
            style: FilledButton.styleFrom(
              backgroundColor: _accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l10n.cameraCaptureButton, style: const TextStyle(fontSize: 13)),
          ),
        ),
      ]),
    );
  }
}
