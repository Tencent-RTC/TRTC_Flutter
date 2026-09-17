import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'publish_media_stream_anchor_state.dart';

class PublishMediaStreamAnchorPage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const PublishMediaStreamAnchorPage({
    Key? key,
    required this.userId,
    required this.roomIdSpec,
  }) : super(key: key);

  @override
  State<PublishMediaStreamAnchorPage> createState() =>
      _PublishMediaStreamAnchorPageState();
}

class _PublishMediaStreamAnchorPageState
    extends State<PublishMediaStreamAnchorPage> {
  late PublishMediaStreamAnchorState _state;
  static const _accentColor = Color(0xFF6A1B9A);

  late final TextEditingController _strRoomIdController;
  late final TextEditingController _userIdController;
  late final TextEditingController _mixStrRoomIdController;
  late final TextEditingController _mixUserIdController;
  late final TextEditingController _cdnUrlController;

  @override
  void initState() {
    super.initState();
    _state = PublishMediaStreamAnchorState(
      userId: widget.userId,
      roomIdSpec: widget.roomIdSpec,
    );
    _state.addListener(_onChanged);
    _state.initialize();
    _strRoomIdController = TextEditingController(text: _state.localStrRoomId);
    _userIdController = TextEditingController(text: _state.localUserId);
    _mixStrRoomIdController = TextEditingController(text: _state.mixStrRoomId);
    _mixUserIdController = TextEditingController(text: _state.mixUserId);
    _cdnUrlController = TextEditingController(text: _state.cdnUrl);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _strRoomIdController.dispose();
    _userIdController.dispose();
    _mixStrRoomIdController.dispose();
    _mixUserIdController.dispose();
    _cdnUrlController.dispose();
    _state.removeListener(_onChanged);
    _state.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider.value(
      value: _state,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.anchor),
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildRoomCard(l10n),
                    const SizedBox(height: 12),
                    _buildPublishCard(l10n),
                    const SizedBox(height: 12),
                    _buildEncoderCard(l10n),
                    const SizedBox(height: 12),
                    _buildStatusCard(l10n),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Video area ──

  Widget _buildVideoArea(AppLocalizations l10n) {
    final remotes = _state.remoteUsers;
    final hasRemote = remotes.isNotEmpty;
    return SizedBox(
      height: hasRemote ? 260 : 180,
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
              onViewCreated: (id) => _state.setLocalViewId(id),
            ),
            Positioned(
              top: 8, left: 12,
              child: _label(l10n.localPreview, _accentColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoGrid(l10n, List remotes) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 1 + remotes.length,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  TRTCCloudVideoView(
                    onViewCreated: (id) => _state.setLocalViewId(id),
                  ),
                  Positioned(
                    top: 6, left: 10,
                    child: _label(l10n.localPreview, _accentColor),
                  ),
                ],
              ),
            ),
          );
        }
        final user = remotes[index - 1];
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                TRTCCloudVideoView(
                  key: ValueKey('remote_${user.userId}'),
                  onViewCreated: (id) =>
                      _state.setRemoteViewId(user.userId, id),
                ),
                Positioned(
                  top: 6, left: 10,
                  child: _label('${l10n.remoteUser}: ${user.userId}',
                      Colors.teal),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _label(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  // ── Cards ──

  Widget _buildCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 18, color: _accentColor),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(AppLocalizations l10n) {
    return _buildCard(
      icon: Icons.meeting_room,
      title: l10n.myRoomLabel,
      children: [
        Text(l10n.myRoomHint,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 12),
        TextField(
          enabled: !_state.isEnterRoom,
          decoration: _decoration(l10n.roomIdLabel),
          controller: _strRoomIdController,
          onChanged: _state.setLocalStrRoomId,
        ),
        const SizedBox(height: 10),
        TextField(
          enabled: !_state.isEnterRoom,
          decoration: _decoration(l10n.userIdLabel),
          controller: _userIdController,
          onChanged: _state.setLocalUserId,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: FilledButton(
            onPressed: _state.isEnterRoom
                ? () => _state.exitRoom()
                : () {
                    if (_state.localStrRoomId.isEmpty ||
                        _state.localUserId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.enterUserIdAndRoomId),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    _state.enterRoom();
                  },
            style: FilledButton.styleFrom(
              backgroundColor: _state.isEnterRoom ? Colors.red : _accentColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_state.isEnterRoom
                ? l10n.exitRoomButton
                : l10n.enterRoom),
          ),
        ),
      ],
    );
  }

  Widget _buildPublishCard(AppLocalizations l10n) {
    return _buildCard(
      icon: Icons.stream,
      title: l10n.publishSettingsLabel,
      children: [
        // Mode selector
        Row(children: [
          Expanded(
            child: _modeChip(
              l10n.toRoomButton,
              TRTCPublishMode.mixStreamToRoom,
              Icons.cast_for_education,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _modeChip(
              l10n.toCdnButton,
              TRTCPublishMode.mixStreamToCdn,
              Icons.cloud_upload,
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Text(l10n.publishModeHint,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 10),
        // Audio only switch
        Row(children: [
          Text(l10n.onlyAudioLabel,
              style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Switch(
            value: _state.audioOnly,
            activeTrackColor: _accentColor,
            onChanged: _state.setAudioOnly,
          ),
        ]),
        const SizedBox(height: 10),
        // Mix remote video switch
        Row(children: [
          Expanded(
            child: Text(l10n.mixIncludeRemoteLabel,
                style: const TextStyle(fontSize: 13)),
          ),
          Switch(
            value: _state.mixRemote,
            activeTrackColor: _accentColor,
            onChanged: _state.setMixRemote,
          ),
        ]),
        const SizedBox(height: 10),
        // Mode-specific target fields
        if (_state.publishMode == TRTCPublishMode.mixStreamToRoom)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: TextField(
                    enabled: !_state.isPublishing,
                    decoration: _decoration(l10n.roomIdLabel),
                    controller: _mixStrRoomIdController,
                    onChanged: _state.setMixStrRoomId,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    enabled: !_state.isPublishing,
                    decoration: _decoration(l10n.mixUserIdLabel),
                    controller: _mixUserIdController,
                    onChanged: _state.setMixUserId,
                  ),
                ),
              ]),
              const SizedBox(height: 6),
              Text(l10n.targetRoomHint,
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          )
        else
          TextField(
            enabled: !_state.isPublishing,
            decoration: _decoration(l10n.publishUrlLabel),
            controller: _cdnUrlController,
            onChanged: _state.setCdnUrl,
          ),
        const SizedBox(height: 10),
        // Action buttons
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: _state.isEnterRoom && !_state.isPublishing
                    ? () => _state.startPublishMediaStream()
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.publishButton),
              ),
            ),
          ),
          if (_state.isPublishing) ...[
            const SizedBox(width: 8),
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: () => _state.updatePublishMediaStream(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.updatePublishButton),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: () => _state.stopPublishMediaStream(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.stopPublishButton),
              ),
            ),
          ],
        ]),
      ],
    );
  }

  Widget _modeChip(String label, TRTCPublishMode mode, IconData icon) {
    final selected = _state.publishMode == mode;
    return GestureDetector(
      onTap: _state.isPublishing ? null : () => _state.setPublishMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? _accentColor.withOpacity(0.12) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _accentColor : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16,
              color: selected ? _accentColor : Colors.grey.shade500),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? _accentColor : Colors.grey.shade700,
                )),
          ),
        ]),
      ),
    );
  }

  Widget _buildEncoderCard(AppLocalizations l10n) {
    return _buildCard(
      icon: Icons.tune,
      title: l10n.encoderParamsTitle,
      children: [
        _sliderRow(l10n.videoBitrateLabel(_state.videoBitrate), _state.videoBitrate, 500, 8000, 50,
            'kbps', _state.setVideoBitrate),
        _sliderRow(l10n.videoFpsLabel(_state.videoFps), _state.videoFps, 1, 30, 1, 'fps',
            _state.setVideoFps),
        const SizedBox(height: 8),
        Row(children: [
          Text('${_state.videoWidth}x${_state.videoHeight}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const Spacer(),
          Text('GOP: ${_state.videoGop}s',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(width: 16),
          Text('Audio: ${_state.audioSampleRate}Hz ${_state.audioChannelNum == 2 ? 'Stereo' : 'Mono'} ${_state.audioBitrate}kbps',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ]),
      ],
    );
  }

  Widget _sliderRow(String label, int value, int min, int max, int divisions,
      String unit, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: divisions,
            activeColor: _accentColor,
            label: '$value$unit',
            onChanged: (v) => onChanged(v.toInt()),
          ),
        ),
        SizedBox(
          width: 60,
          child: Text('$value$unit',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _accentColor)),
        ),
      ]),
    );
  }

  Widget _buildStatusCard(AppLocalizations l10n) {
    return _buildCard(
      icon: Icons.info_outline,
      title: l10n.publishStatusTitle,
      children: [
        _statusRow(l10n.publishStatusLabel, _state.publishStatus,
            _state.publishErrCode == 0 || _state.publishStatus.contains('Start') || _state.publishStatus.contains('Updat')),
        if (_state.cdnStatus.isNotEmpty)
          _statusRow('CDN', _state.cdnStatus, true),
        if (_state.taskId.isNotEmpty)
          _statusRow('Task ID', _state.taskId, true),
      ],
    );
  }

  Widget _statusRow(String label, String value, bool ok) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const Spacer(),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: ok ? Colors.green : Colors.orange)),
        ),
      ]),
    );
  }
}
