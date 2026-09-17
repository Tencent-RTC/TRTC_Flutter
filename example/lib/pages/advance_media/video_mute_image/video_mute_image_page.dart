import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'video_mute_image_state.dart';

class VideoMuteImagePage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const VideoMuteImagePage({Key? key, required this.userId, required this.roomIdSpec})
      : super(key: key);

  @override
  State<VideoMuteImagePage> createState() => _VideoMuteImagePageState();
}

class _VideoMuteImagePageState extends State<VideoMuteImagePage> {
  late VideoMuteImageState _state;
  static const _accentColor = Color(0xFF455A64);

  @override
  void initState() {
    super.initState();
    _state = VideoMuteImageState(userId: widget.userId, roomIdSpec: widget.roomIdSpec);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider.value(
      value: _state,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.sceneVideoMuteImage),
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
              // Hint text
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _accentColor.withOpacity(0.2)),
                ),
                child: Row(children: [
                  Icon(Icons.info_outline, size: 18, color: _accentColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l10n.muteImageHint,
                        style: TextStyle(fontSize: 12, color: _accentColor)),
                  ),
                ]),
              ),
              // Mute local video switch
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: _cardDec(),
                child: Row(children: [
                  Icon(_state.isLocalVideoMuted.value ? Icons.videocam_off : Icons.videocam,
                      size: 22, color: _state.isLocalVideoMuted.value ? Colors.red : _accentColor),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.muteLocalVideoLabel, style: const TextStyle(fontSize: 15))),
                  ValueListenableBuilder<bool>(
                    valueListenable: _state.isLocalVideoMuted,
                    builder: (_, v, __) => Switch(value: v, activeColor: Colors.red, onChanged: (_) => _state.toggleLocalVideoMute()),
                  ),
                ]),
              ),
              // Preset image selector
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: _cardDec(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.selectDefaultImage, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Row(
                      children: VideoMuteImageState.presetAssets.map((asset) {
                        final isSelected = _state.muteImagePath.value.contains(asset.split('/').last);
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _state.selectPresetImage(asset),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? _accentColor : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(asset, height: 60, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              // Image path input
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: _cardDec(),
                child: ValueListenableBuilder<String>(
                  valueListenable: _state.muteImagePath,
                  builder: (_, v, __) => TextFormField(
                    initialValue: v,
                    decoration: _dec(l10n.muteImagePathLabel, icon: Icons.image),
                    onChanged: (val) => _state.updateMuteImagePath(val),
                  ),
                ),
              ),
              // FPS slider
              ValueListenableBuilder<int>(
                valueListenable: _state.muteImageFps,
                builder: (_, v, __) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                  decoration: _cardDec(),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(l10n.muteImageFpsLabel, style: const TextStyle(fontSize: 14)),
                      Text('$v fps', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _accentColor)),
                    ]),
                    Slider(value: v.toDouble(), min: 1, max: 15, divisions: 14, activeColor: _accentColor,
                        onChanged: (val) => _state.updateMuteImageFps(val.toInt())),
                  ]),
                ),
              ),
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
      ...remotes.map((u) => _Tile(isLocal: false, label: '${l10n.remoteUser}: ${u.userId}', userId: u.userId)),
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
            Positioned(top: 6, left: 10, child: _label(t.label, t.isLocal ? _accentColor : Colors.blueGrey)),
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
