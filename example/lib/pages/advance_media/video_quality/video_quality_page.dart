import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'video_quality_state.dart';

class VideoQualityPage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const VideoQualityPage({
    Key? key,
    required this.userId,
    required this.roomIdSpec,
  }) : super(key: key);

  @override
  State<VideoQualityPage> createState() => _VideoQualityPageState();
}

class _VideoQualityPageState extends State<VideoQualityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late VideoQualityState _state;

  static const _accentColor = Color(0xFF5C6BC0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _state = VideoQualityState(
      userId: widget.userId,
      roomIdSpec: widget.roomIdSpec,
    );
    _state.addListener(_onStateChanged);
    _state.initialize();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    _state.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ── UI helpers ──

  InputDecoration _decoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
    );
  }

  Color _qualityColor(TRTCQuality q) {
    switch (q) {
      case TRTCQuality.excellent:
        return Colors.green;
      case TRTCQuality.good:
        return Colors.lightGreen;
      case TRTCQuality.poor:
        return Colors.amber;
      case TRTCQuality.bad:
        return Colors.orange;
      case TRTCQuality.vBad:
        return Colors.red;
      case TRTCQuality.down:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _qualityText(TRTCQuality q, AppLocalizations l10n) {
    switch (q) {
      case TRTCQuality.excellent:
        return l10n.qualityExcellent;
      case TRTCQuality.good:
        return l10n.qualityGood;
      case TRTCQuality.poor:
        return l10n.qualityPoor;
      case TRTCQuality.bad:
        return l10n.qualityBad;
      case TRTCQuality.vBad:
        return l10n.qualityVBad;
      case TRTCQuality.down:
        return l10n.qualityDown;
      default:
        return l10n.qualityUnknown;
    }
  }

  String _resolutionLabel(TRTCVideoResolution res) {
    const map = {
      TRTCVideoResolution.res_120_120: '120×120',
      TRTCVideoResolution.res_160_160: '160×160',
      TRTCVideoResolution.res_270_270: '270×270',
      TRTCVideoResolution.res_480_480: '480×480',
      TRTCVideoResolution.res_160_120: '160×120 (4:3)',
      TRTCVideoResolution.res_240_180: '240×180 (4:3)',
      TRTCVideoResolution.res_280_210: '280×210 (4:3)',
      TRTCVideoResolution.res_320_240: '320×240 (4:3)',
      TRTCVideoResolution.res_400_300: '400×300 (4:3)',
      TRTCVideoResolution.res_480_360: '480×360 (4:3)',
      TRTCVideoResolution.res_640_480: '640×480 (4:3)',
      TRTCVideoResolution.res_960_720: '960×720 (4:3)',
      TRTCVideoResolution.res_160_90: '160×90 (16:9)',
      TRTCVideoResolution.res_256_144: '256×144 (16:9)',
      TRTCVideoResolution.res_320_180: '320×180 (16:9)',
      TRTCVideoResolution.res_480_270: '480×270 (16:9)',
      TRTCVideoResolution.res_640_360: '640×360 (16:9)',
      TRTCVideoResolution.res_960_540: '960×540 (16:9)',
      TRTCVideoResolution.res_1280_720: '1280×720 (16:9)',
      TRTCVideoResolution.res_1920_1080: '1920×1080 (16:9)',
    };
    return map[res] ?? '1280×720 (16:9)';
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider.value(
      value: _state,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.videoQualityTitle),
          actions: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: _state.isEnterRoom ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildVideoArea(l10n),
            _buildNetworkQualityBar(l10n),
            Expanded(
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: _accentColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: l10n.encoderSettingsTab),
                      Tab(text: l10n.networkSettingsTab),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildEncoderSettings(l10n),
                        _buildNetworkSettings(l10n),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    _state.exitRoom();
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(l10n.exitRoomButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Video area: local + remote grid ──

  Widget _buildVideoArea(AppLocalizations l10n) {
    final remotes = _state.remoteUsers
        .where((u) => u.isVideoAvailable)
        .toList();
    final hasRemote = remotes.isNotEmpty;

    return SizedBox(
      height: hasRemote ? 280 : 200,
      child: hasRemote ? _buildVideoGrid(l10n, remotes) : _buildLocalOnly(l10n),
    );
  }

  Widget _buildLocalOnly(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            TRTCCloudVideoView(
              onViewCreated: (viewId) => _state.setLocalViewId(viewId),
            ),
            Positioned(
              top: 8,
              left: 12,
              child: _videoLabel(l10n.localPreview, _accentColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoGrid(
      AppLocalizations l10n, List<RemoteVideoUser> remotes) {
    final all = [
      _VideoTileData(isLocal: true, label: l10n.localPreview),
      ...remotes.map((u) => _VideoTileData(
            isLocal: false,
            label: '${l10n.remoteUser}: ${u.userId}',
            user: u,
          )),
    ];
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: all.length,
      itemBuilder: (context, index) => _buildVideoTile(all[index]),
    );
  }

  Widget _buildVideoTile(_VideoTileData data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (data.isLocal)
              TRTCCloudVideoView(
                onViewCreated: (viewId) => _state.setLocalViewId(viewId),
              )
            else
              TRTCCloudVideoView(
                onViewCreated: (viewId) =>
                    _state.setRemoteViewId(data.user!.userId, viewId),
              ),
            Positioned(
              top: 6,
              left: 10,
              child: _videoLabel(
                data.label,
                data.isLocal ? _accentColor : Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _videoLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Network quality bar ──

  Widget _buildNetworkQualityBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.wifi, size: 16, color: _qualityColor(_state.localQuality)),
          const SizedBox(width: 6),
          Text('${l10n.networkQuality}: ',
              style: const TextStyle(fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _qualityColor(_state.localQuality).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _qualityColor(_state.localQuality),
                width: 0.5,
              ),
            ),
            child: Text(
              _qualityText(_state.localQuality, l10n),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _qualityColor(_state.localQuality),
              ),
            ),
          ),
          const Spacer(),
          if (_state.remoteUsers.isEmpty)
            Text(l10n.noRemoteUser,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // ── Encoder settings tab ──

  Widget _buildSliderCard({
    required String label,
    required String valueText,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Text(valueText,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _accentColor)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: _accentColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchCard({
    required String label,
    required IconData icon,
    required ValueNotifier<bool> notifier,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          ValueListenableBuilder<bool>(
            valueListenable: notifier,
            builder: (context, value, _) {
              return Switch(
                value: value,
                activeColor: _accentColor,
                onChanged: (v) => notifier.value = v,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownCard<T>({
    required String label,
    required IconData icon,
    required ValueNotifier<T> notifier,
    required List<DropdownMenuItem<T>> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: ValueListenableBuilder<T>(
        valueListenable: notifier,
        builder: (context, value, _) {
          return DropdownButtonFormField<T>(
            value: value,
            decoration: _decoration(label, icon: icon),
            items: items,
            onChanged: (v) {
              if (v != null) notifier.value = v;
            },
          );
        },
      ),
    );
  }

  Widget _buildEncoderSettings(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ValueListenableBuilder<int>(
            valueListenable: _state.minVideoBitrate,
            builder: (context, v, _) => _buildSliderCard(
              label: l10n.minVideoBitrateLabel(v),
              valueText: '$v kbps',
              value: v.toDouble(),
              min: 0, max: 1000, divisions: 100,
              onChanged: (val) => _state.minVideoBitrate.value = val.toInt(),
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: _state.videoBitrate,
            builder: (context, v, _) => _buildSliderCard(
              label: l10n.videoBitrateLabel(v),
              valueText: '$v kbps',
              value: v.toDouble(),
              min: 0, max: 2000, divisions: 100,
              onChanged: (val) => _state.videoBitrate.value = val.toInt(),
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: _state.videoFps,
            builder: (context, v, _) => _buildSliderCard(
              label: l10n.videoFpsLabel(v),
              valueText: '$v fps',
              value: v.toDouble(),
              min: 1, max: 30, divisions: 29,
              onChanged: (val) => _state.videoFps.value = val.toInt(),
            ),
          ),
          _buildDropdownCard<TRTCVideoResolution>(
            label: l10n.enableResolutionAdjustment,
            icon: Icons.aspect_ratio,
            notifier: _state.videoResolution,
            items: TRTCVideoResolution.values
                .map((r) => DropdownMenuItem(
                      value: r,
                      child: Text(_resolutionLabel(r), style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
          ),
          _buildDropdownCard<TRTCVideoResolutionMode>(
            label: l10n.portraitMode,
            icon: Icons.screen_rotation,
            notifier: _state.videoResolutionMode,
            items: TRTCVideoResolutionMode.values
                .map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(
                        m == TRTCVideoResolutionMode.portrait
                            ? l10n.portraitMode
                            : l10n.landscapeMode,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ))
                .toList(),
          ),
          _buildSwitchCard(
            label: l10n.enableResolutionAdjustment,
            icon: Icons.tune,
            notifier: _state.enableAdjustRes,
          ),
          _buildSwitchCard(
            label: l10n.encoderMirror,
            icon: Icons.flip,
            notifier: _state.videoEncoderMirror,
          ),
        ],
      ),
    );
  }

  // ── Network settings tab ──

  Widget _buildNetworkSettings(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // QoS preference
          _buildDropdownCard<TRTCVideoQosPreference>(
            label: l10n.networkQosPreference,
            icon: Icons.network_check,
            notifier: _state.preference,
            items: TRTCVideoQosPreference.values
                .map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(
                        p == TRTCVideoQosPreference.smooth
                            ? l10n.smoothFirst
                            : l10n.clearFirst,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Network quality detail card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.networkQuality,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _qualityRow(l10n.localPreview, _state.localQuality),
                ..._state.remoteUsers.map((u) =>
                    _qualityRow('${l10n.remoteUser}: ${u.userId}', u.quality)),
                if (_state.remoteUsers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(l10n.noRemoteUser,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qualityRow(String label, TRTCQuality quality) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.wifi, size: 16, color: _qualityColor(quality)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _qualityColor(quality).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _qualityText(quality, l10n),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _qualityColor(quality),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoTileData {
  final bool isLocal;
  final String label;
  final RemoteVideoUser? user;

  _VideoTileData({required this.isLocal, required this.label, this.user});
}
