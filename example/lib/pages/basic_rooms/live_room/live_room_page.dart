import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'live_room_state.dart';

class LiveRoomPage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const LiveRoomPage({
    Key? key,
    required this.userId,
    required this.roomIdSpec,
  }) : super(key: key);

  @override
  State<LiveRoomPage> createState() => _LiveRoomPageState();
}

class _LiveRoomPageState extends State<LiveRoomPage> {
  late LiveRoomState _state;
  static const _accentColor = Color(0xFFC62828);

  @override
  void initState() {
    super.initState();
    _state = LiveRoomState(userId: widget.userId, roomIdSpec: widget.roomIdSpec);
    _state.addListener(_onChanged);
    _state.eventMessage.addListener(_onEvent);
    _state.initialize();
  }

  void _onChanged() => mounted ? setState(() {}) : null;

  void _onEvent() {
    final event = _state.eventMessage.value;
    if (event == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    String msg;
    Color color;
    if (event == 'switch_role_ok') {
      msg = l10n.switchRoleSuccess;
      color = Colors.green;
      _showEventSnackBar(msg, color);
      return;
    }
    if (event.startsWith('switch_role_fail')) {
      final detail =
          event.contains(':') ? event.split(':').sublist(1).join(':') : '';
      msg = l10n.switchRoleFailed(detail);
      color = Colors.red;
      _showEventSnackBar(msg, color);
      return;
    }
    switch (event) {
      case 'switch_anchor':
        msg = l10n.switchToAnchor; color = Colors.green; break;
      case 'switch_audience':
        msg = l10n.switchToAudience; color = Colors.blue; break;
      case 'anchor_limit':
        msg = l10n.roomAnchorLimitReached; color = Colors.orange; break;
      case 'position_occupied':
        msg = l10n.positionAlreadyOccupied; color = Colors.red; break;
      case 'all_video_muted':
        msg = l10n.muteAllVideoDone; color = Colors.orange; break;
      case 'all_video_resumed':
        msg = l10n.resumeAllVideoDone; color = Colors.green; break;
      case 'all_audio_muted':
        msg = l10n.muteAllAudioDone; color = Colors.orange; break;
      case 'all_audio_resumed':
        msg = l10n.resumeAllAudioDone; color = Colors.green; break;
      default: return;
    }
    _showEventSnackBar(msg, color);
  }

  void _showEventSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating),
    );
    _state.eventMessage.value = null;
  }

  @override
  void dispose() {
    _state.eventMessage.removeListener(_onEvent);
    _state.removeListener(_onChanged);
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider.value(
      value: _state,
      child: Scaffold(
        body: Stack(children: [
          _buildVideoGrid(l10n),
          _buildHeader(l10n),
          _buildBottomControls(l10n),
        ]),
      ),
    );
  }

  // ─── Video grid ──────────────────────────────────────────────

  Widget _buildVideoGrid(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade900),
      child: Padding(
        padding: const EdgeInsets.only(top: 90, bottom: 120),
        child: GridView.builder(
          padding: const EdgeInsets.all(6),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 9 / 16,
            crossAxisSpacing: 6, mainAxisSpacing: 6,
          ),
          itemCount: ViewManager.maxAnchorCount,
          itemBuilder: (_, i) => _buildVideoTile(i, l10n),
        ),
      ),
    );
  }

  Widget _buildVideoTile(int index, AppLocalizations l10n) {
    final uid = _state.viewManager.getUserIdByViewKey(index);
    final isLocal = uid == _state.userId;
    final matchedUsers = _state.remoteUsers.where((u) => u.userId == uid);
    final user = uid != null && matchedUsers.isNotEmpty ? matchedUsers.first : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: uid != null ? Colors.white24 : Colors.white10),
      ),
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TRTCCloudVideoView(
            key: Key('view_$index'),
            onViewCreated: (viewId) => _state.setViewId(viewId),
          ),
        ),
        if (uid == null)
          Center(child: Icon(Icons.videocam_off, color: Colors.white24, size: 32)),
        if (uid != null) ...[
          // User label
          Positioned(bottom: 6, left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
              child: Text(
                isLocal ? '$uid${l10n.meSuffix}' : uid,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
          // Audio mute indicator
          if (user != null && user.isAudioMuted)
            Positioned(top: 6, right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), shape: BoxShape.circle),
                child: const Icon(Icons.mic_off, color: Colors.white, size: 12),
              ),
            ),
          // View switch buttons
          Positioned(top: 6, left: 6,
            child: Row(children: [
              for (int i = 1; i <= 3; i++)
                GestureDetector(
                  onTap: () => _state.switchViewPosition(uid, (index + i) % 4),
                  child: Container(
                    width: 20, height: 20, margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                    child: Center(child: Text('${(index + i) % 4 + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 9))),
                  ),
                ),
            ]),
          ),
        ],
      ]),
    );
  }

  // ─── Header ──────────────────────────────────────────────────

  Widget _buildHeader(AppLocalizations l10n) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 48, 12, 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Row(children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () { _state.exitRoom(); Navigator.pop(context); },
          ),
          const SizedBox(width: 4),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.roomIdDisplay(_state.roomIdSpec.display),
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            Row(children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: _state.isEnterRoom ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text('${_state.remoteUsers.length} ${l10n.remoteUser}',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
            ]),
          ])),
          // Role switch
          GestureDetector(
            onTap: _state.isAnchor || _state.canBecomeAnchor ? _state.switchRole : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _state.isAnchor ? _accentColor : Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(_state.isAnchor ? l10n.anchor : l10n.audience,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }

  // ─── Bottom controls ─────────────────────────────────────────

  Widget _buildBottomControls(AppLocalizations l10n) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter, end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: Column(children: [
          // Remote user controls row (if there are remote users)
          if (_state.remoteUsers.any((u) => !u.isLocalUser))
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _state.remoteUsers.where((u) => !u.isLocalUser).length,
                itemBuilder: (_, i) {
                  final user = _state.remoteUsers.where((u) => !u.isLocalUser).elementAt(i);
                  return _remoteUserChip(user, l10n);
                },
              ),
            ),
          if (_state.remoteUsers.any((u) => !u.isLocalUser))
            const SizedBox(height: 8),
          // Mute all buttons
          Row(children: [
            Expanded(child: _ctrlButton(
              l10n.liveMuteAllVideo, _state.allVideoMuted ? Icons.videocam_off : Icons.videocam,
              _state.toggleAllRemoteVideo, _state.allVideoMuted,
            )),
            const SizedBox(width: 8),
            Expanded(child: _ctrlButton(
              l10n.liveMuteAllAudio, _state.allAudioMuted ? Icons.volume_off : Icons.volume_up,
              _state.toggleAllRemoteAudio, _state.allAudioMuted,
            )),
          ]),
          // Anchor controls (only if anchor)
          if (_state.isAnchor) ...[
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _ctrlButton(
                l10n.liveCamera, _state.isLocalCameraEnabled ? Icons.videocam : Icons.videocam_off,
                _state.toggleLocalCamera, !_state.isLocalCameraEnabled,
              )),
              const SizedBox(width: 8),
              Expanded(child: _ctrlButton(
                l10n.liveMic, _state.isLocalMicEnabled ? Icons.mic : Icons.mic_off,
                _state.toggleLocalMic, !_state.isLocalMicEnabled,
              )),
              const SizedBox(width: 8),
              Expanded(child: _ctrlButton(
                l10n.liveSwitchCamera, Icons.switch_camera,
                _state.switchCamera, false,
              )),
            ]),
          ],
        ]),
      ),
    );
  }

  Widget _remoteUserChip(RemoteUserState user, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(user.userId, style: const TextStyle(color: Colors.white, fontSize: 10)),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => _state.toggleRemoteVideo(user.userId),
          child: Icon(user.isVideoMuted ? Icons.videocam_off : Icons.videocam,
              size: 14, color: user.isVideoMuted ? Colors.red : Colors.white70),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => _state.toggleRemoteAudio(user.userId),
          child: Icon(user.isAudioMuted ? Icons.volume_off : Icons.volume_up,
              size: 14, color: user.isAudioMuted ? Colors.red : Colors.white70),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 50,
          child: Slider(
            value: user.volume.toDouble(), min: 0, max: 200, divisions: 200,
            activeColor: Colors.white70, thumbColor: Colors.white,
            onChanged: (v) => _state.setRemoteVolume(user.userId, v.round()),
          ),
        ),
      ]),
    );
  }

  Widget _ctrlButton(String label, IconData icon, VoidCallback onPressed, bool isOff) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18, color: isOff ? Colors.red : Colors.white),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: Colors.white70, fontSize: 9)),
          ]),
        ),
      ),
    );
  }
}
