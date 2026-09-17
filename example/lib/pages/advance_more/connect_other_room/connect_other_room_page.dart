import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'connect_other_room_state.dart';

class ConnectOtherRoomPage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const ConnectOtherRoomPage({Key? key, required this.userId, required this.roomIdSpec})
      : super(key: key);

  @override
  State<ConnectOtherRoomPage> createState() => _ConnectOtherRoomPageState();
}

class _ConnectOtherRoomPageState extends State<ConnectOtherRoomPage> {
  late ConnectOtherRoomState _state;
  final TextEditingController _targetRoomController = TextEditingController();
  final TextEditingController _targetUserIdController = TextEditingController();
  static const _accentColor = Color(0xFF00897B);

  @override
  void initState() {
    super.initState();
    _state = ConnectOtherRoomState(userId: widget.userId, roomIdSpec: widget.roomIdSpec);
    _state.addListener(_onChanged);
    _state.resultEvent.addListener(_onResultEvent);
    _state.initialize();
  }

  void _onChanged() => mounted ? setState(() {}) : null;

  void _onResultEvent() {
    final event = _state.resultEvent.value;
    if (event == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    String msg;
    Color color;

    if (event == 'connect_success') {
      msg = l10n.connectOtherRoomSuccess;
      color = Colors.green;
    } else if (event == 'disconnect_success') {
      msg = l10n.disconnectOtherRoomSuccess;
      color = Colors.green;
    } else if (event.startsWith('connect_failed:')) {
      final parts = event.split(':');
      final errCode = parts.length > 1 ? parts[1] : '';
      final errMsg = parts.length > 2 ? parts.sublist(2).join(':') : '';
      msg = l10n.connectOtherRoomFailed(errMsg, errCode);
      color = Colors.red;
    } else if (event.startsWith('disconnect_failed:')) {
      final parts = event.split(':');
      final errCode = parts.length > 1 ? parts[1] : '';
      final errMsg = parts.length > 2 ? parts.sublist(2).join(':') : '';
      msg = l10n.disconnectOtherRoomFailed(errMsg, errCode);
      color = Colors.red;
    } else {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2)),
    );
    _state.resultEvent.value = null;
  }

  @override
  void dispose() {
    _state.resultEvent.removeListener(_onResultEvent);
    _state.removeListener(_onChanged);
    _targetRoomController.dispose();
    _targetUserIdController.dispose();
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
          title: Text(l10n.connectOtherRoomPageTitle),
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
          _buildVideoArea(l10n),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _buildInfoCard(l10n),
              const SizedBox(height: 10),
              _buildConnectCard(l10n),
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

  // ─── Video area ──────────────────────────────────────────────

  Widget _buildVideoArea(AppLocalizations l10n) {
    final remotes = _state.remoteUsers.where((u) => u.isVideoAvailable).toList();
    final hasRemote = remotes.isNotEmpty;
    final height = hasRemote ? 280.0 : 180.0;

    return SizedBox(
      height: height,
      child: hasRemote ? _buildGrid(l10n, remotes) : _buildLocalOnly(l10n),
    );
  }

  Widget _buildLocalOnly(AppLocalizations l10n) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(children: [
            TRTCCloudVideoView(onViewCreated: (v) => _state.setLocalViewId(v)),
            Positioned(top: 6, left: 10, child: _label(l10n.localPreview, _accentColor)),
            if (!_state.isEnterRoom)
              Center(
                child: Text(l10n.noRemoteUser,
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
              ),
          ]),
        ),
      );

  Widget _buildGrid(AppLocalizations l10n, List<PkRemoteUser> remotes) {
    final tiles = [
      _Tile(isLocal: true, label: l10n.localPreview),
      ...remotes.map((u) =>
          _Tile(isLocal: false, label: '${l10n.remoteUser}: ${u.userId}', userId: u.userId)),
    ];
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: tiles.length,
      itemBuilder: (_, i) => _buildTile(tiles[i]),
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
            Positioned(top: 6, left: 10,
                child: _label(t.label, t.isLocal ? _accentColor : Colors.teal)),
          ]),
        ),
      );

  Widget _label(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  // ─── Info card ───────────────────────────────────────────────

  Widget _buildInfoCard(AppLocalizations l10n) {
    final connected = _state.isConnected.value;
    final connectedUser = _state.connectedUserId;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _infoRow(l10n.pkCurrentRoom, widget.roomIdSpec.display,
            icon: Icons.meeting_room_outlined),
        const SizedBox(height: 10),
        _infoRow(l10n.pkCurrentUserId, widget.userId, icon: Icons.person_outline),
        if (connected && connectedUser != null) ...[
          const SizedBox(height: 10),
          _infoRow(l10n.remoteUser, connectedUser,
              icon: Icons.videocam_outlined, color: Colors.green),
        ],
      ]),
    );
  }

  Widget _infoRow(String label, String value, {IconData? icon, Color? color}) => Row(children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: color ?? _accentColor),
          const SizedBox(width: 8),
        ],
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
              overflow: TextOverflow.ellipsis),
        ),
      ]);

  // ─── Connect card ────────────────────────────────────────────

  Widget _buildConnectCard(AppLocalizations l10n) {
    final connecting = _state.isConnecting.value;
    final connected = _state.isConnected.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.pkInputHint,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(height: 12),
        TextField(
          controller: _targetRoomController,
          decoration: InputDecoration(
            labelText: l10n.pkTargetRoom,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            prefixIcon: const Icon(Icons.meeting_room, size: 20),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _targetUserIdController,
          decoration: InputDecoration(
            labelText: l10n.pkTargetUserId,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            prefixIcon: const Icon(Icons.person, size: 20),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: FilledButton.icon(
                onPressed: connecting || connected ? null : _doConnect,
                icon: Icon(connecting ? Icons.hourglass_top : Icons.link, size: 18),
                label: Text(l10n.pkConnectButton),
                style: FilledButton.styleFrom(
                  backgroundColor: _accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 46,
              child: OutlinedButton.icon(
                onPressed: (connecting || !connected) ? null : _state.disconnectOtherRoom,
                icon: const Icon(Icons.link_off, size: 18),
                label: Text(l10n.pkDisconnectButton),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  void _doConnect() {
    FocusScope.of(context).unfocus();
    final targetRoom = _targetRoomController.text.trim();
    final targetUser = _targetUserIdController.text.trim();
    if (targetRoom.isNotEmpty && targetUser.isNotEmpty) {
      _state.connectOtherRoom(targetRoom, targetUser);
    }
  }
}

class _Tile {
  final bool isLocal;
  final String label;
  final String? userId;
  _Tile({required this.isLocal, required this.label, this.userId});
}
