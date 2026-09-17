import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'small_video_stream_state.dart';

class SmallVideoStreamPage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const SmallVideoStreamPage({Key? key, required this.userId, required this.roomIdSpec})
      : super(key: key);

  @override
  State<SmallVideoStreamPage> createState() => _SmallVideoStreamPageState();
}

class _SmallVideoStreamPageState extends State<SmallVideoStreamPage> {
  late SmallVideoStreamState _state;
  static const _accentColor = Color(0xFF00838F);

  @override
  void initState() {
    super.initState();
    _state = SmallVideoStreamState(userId: widget.userId, roomIdSpec: widget.roomIdSpec);
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

  InputDecoration _dec(String label, {IconData? icon}) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      );

  BoxDecoration _cardDec() => BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      );

  String _resLabel(TRTCVideoResolution r) {
    const m = {
      TRTCVideoResolution.res_120_120: '120×120', TRTCVideoResolution.res_160_160: '160×160',
      TRTCVideoResolution.res_270_270: '270×270', TRTCVideoResolution.res_480_480: '480×480',
      TRTCVideoResolution.res_160_90: '160×90 (16:9)', TRTCVideoResolution.res_256_144: '256×144 (16:9)',
      TRTCVideoResolution.res_320_180: '320×180 (16:9)', TRTCVideoResolution.res_480_270: '480×270 (16:9)',
      TRTCVideoResolution.res_640_360: '640×360 (16:9)', TRTCVideoResolution.res_960_540: '960×540 (16:9)',
      TRTCVideoResolution.res_1280_720: '1280×720 (16:9)', TRTCVideoResolution.res_1920_1080: '1920×1080 (16:9)',
    };
    return m[r] ?? '320×180';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider.value(
      value: _state,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.sceneSmallVideoStream),
          actions: [
            Container(
              width: 10, height: 10, margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(color: _state.isEnterRoom ? Colors.green : Colors.grey, shape: BoxShape.circle),
            ),
          ],
        ),
        body: Column(children: [
          _buildVideoArea(l10n),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // Enable small stream switch
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: _cardDec(),
                child: Row(children: [
                  const Icon(Icons.picture_in_picture_alt, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.descSmallVideoStream, style: const TextStyle(fontSize: 14))),
                  ValueListenableBuilder<bool>(
                    valueListenable: _state.enableSmallStream,
                    builder: (_, v, __) => Switch(value: v, activeColor: _accentColor, onChanged: (_) => _state.enableSmallStream.value = !v),
                  ),
                ]),
              ),
              // Bitrate slider
              ValueListenableBuilder<int>(
                valueListenable: _state.smallVideoBitrate,
                builder: (_, v, __) => _slider('Bitrate', '$v kbps', v.toDouble(), 100, 1000, 9,
                    (val) => _state.smallVideoBitrate.value = val.toInt()),
              ),
              // FPS slider
              ValueListenableBuilder<int>(
                valueListenable: _state.smallVideoFps,
                builder: (_, v, __) => _slider('FPS', '$v fps', v.toDouble(), 5, 30, 5,
                    (val) => _state.smallVideoFps.value = val.toInt()),
              ),
              // Resolution dropdown
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: _cardDec(),
                child: ValueListenableBuilder<TRTCVideoResolution>(
                  valueListenable: _state.smallVideoResolution,
                  builder: (_, v, __) => DropdownButtonFormField<TRTCVideoResolution>(
                    value: v,
                    decoration: _dec('Resolution', icon: Icons.aspect_ratio),
                    items: TRTCVideoResolution.values
                        .map((r) => DropdownMenuItem(value: r, child: Text(_resLabel(r), style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (val) { if (val != null) _state.smallVideoResolution.value = val; },
                  ),
                ),
              ),
              // Remote stream type toggle
              if (_state.remoteUsers.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(l10n.remoteUser, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ..._state.remoteUsers.map((u) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: _cardDec(),
                  child: Row(children: [
                    Icon(Icons.person, size: 18, color: _accentColor),
                    const SizedBox(width: 8),
                    Expanded(child: Text(u.userId, style: const TextStyle(fontSize: 13))),
                    Text(u.useSmallStream ? 'Small' : 'Big',
                        style: TextStyle(fontSize: 12, color: u.useSmallStream ? _accentColor : Colors.grey)),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _state.toggleRemoteStreamType(u.userId),
                      child: Text('Switch', style: TextStyle(color: _accentColor, fontSize: 12)),
                    ),
                  ]),
                )),
              ],
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

  Widget _slider(String label, String val, double value, double min, double max, int div, ValueChanged<double> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _accentColor)),
        ]),
        Slider(value: value, min: min, max: max, divisions: div, activeColor: _accentColor, onChanged: onChanged),
      ]),
    );
  }

  Widget _buildVideoArea(AppLocalizations l10n) {
    final remotes = _state.remoteUsers.where((u) => u.isVideoAvailable).toList();
    final hasRemote = remotes.isNotEmpty;
    return SizedBox(
      height: hasRemote ? 280 : 200,
      child: hasRemote ? _buildGrid(l10n, remotes) : _buildLocalOnly(l10n),
    );
  }

  Widget _buildLocalOnly(AppLocalizations l10n) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(children: [
            TRTCCloudVideoView(onViewCreated: (v) => _state.setLocalViewId(v)),
            Positioned(top: 8, left: 12, child: _label(l10n.localPreview, _accentColor)),
          ]),
        ),
      );

  Widget _buildGrid(AppLocalizations l10n, List<RemoteVideoUser> remotes) {
    final all = [
      _Tile(isLocal: true, label: l10n.localPreview),
      ...remotes.map((u) => _Tile(isLocal: false, label: '${l10n.remoteUser}: ${u.userId}\n${u.useSmallStream ? "small" : "big"}', userId: u.userId)),
    ];
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: all.length,
      itemBuilder: (_, i) => _buildTile(all[i]),
    );
  }

  Widget _buildTile(_Tile t) => Container(
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(children: [
            t.isLocal
                ? TRTCCloudVideoView(onViewCreated: (v) => _state.setLocalViewId(v))
                : TRTCCloudVideoView(onViewCreated: (v) => _state.setRemoteViewId(t.userId!, v)),
            Positioned(top: 6, left: 10, child: _label(t.label, t.isLocal ? _accentColor : Colors.cyan)),
          ]),
        ),
      );

  Widget _label(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}

class _Tile {
  final bool isLocal;
  final String label;
  final String? userId;
  _Tile({required this.isLocal, required this.label, this.userId});
}
