import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'publish_media_stream_audience_state.dart';

class PublishMediaStreamAudiencePage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const PublishMediaStreamAudiencePage({
    Key? key,
    required this.userId,
    required this.roomIdSpec,
  }) : super(key: key);

  @override
  State<PublishMediaStreamAudiencePage> createState() =>
      _PublishMediaStreamAudiencePageState();
}

class _PublishMediaStreamAudiencePageState
    extends State<PublishMediaStreamAudiencePage> {
  late PublishMediaStreamAudienceState _state;
  static const _accentColor = Color(0xFF6A1B9A);

  late final TextEditingController _strRoomIdController;
  late final TextEditingController _userIdController;

  @override
  void initState() {
    super.initState();
    _state = PublishMediaStreamAudienceState(
      userId: widget.userId,
      roomIdSpec: widget.roomIdSpec,
    );
    _state.addListener(_onChanged);
    _state.initialize();
    _strRoomIdController = TextEditingController(text: _state.strRoomId);
    _userIdController = TextEditingController(text: _state.userId);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _strRoomIdController.dispose();
    _userIdController.dispose();
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
          title: Text(l10n.audience),
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
                child: _buildRoomCard(l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoArea(AppLocalizations l10n) {
    final remotes = _state.remoteUsers;
    final hasRemote = remotes.isNotEmpty;
    return SizedBox(
      height: hasRemote ? 260 : 180,
      child: hasRemote
          ? _buildVideoGrid(l10n, remotes)
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tv_off,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(l10n.noRemoteUser,
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade500)),
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
      itemCount: remotes.length,
      itemBuilder: (context, index) {
        final user = remotes[index];
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
                  key: ValueKey('audience_remote_${user.userId}'),
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

  Widget _buildRoomCard(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.meeting_room, size: 18, color: _accentColor),
              const SizedBox(width: 8),
              Text(l10n.enterRoom,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 14),
            TextField(
              enabled: !_state.isEnterRoom,
              decoration: _decoration(l10n.roomIdLabel),
              controller: _strRoomIdController,
              onChanged: _state.setStrRoomId,
            ),
            const SizedBox(height: 10),
            TextField(
              enabled: !_state.isEnterRoom,
              decoration: _decoration(l10n.userIdLabel),
              controller: _userIdController,
              onChanged: _state.setUserId,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: _state.isEnterRoom
                    ? () => _state.exitRoom()
                    : () => _state.enterRoom(),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      _state.isEnterRoom ? Colors.red : _accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_state.isEnterRoom
                    ? l10n.exitRoomButton
                    : l10n.enterRoom),
              ),
            ),
            const SizedBox(height: 10),
            Text(l10n.audienceWatchHint,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
