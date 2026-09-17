import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'switch_room_state.dart';

class SwitchRoomPage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const SwitchRoomPage({Key? key, required this.userId, required this.roomIdSpec})
      : super(key: key);

  @override
  State<SwitchRoomPage> createState() => _SwitchRoomPageState();
}

class _SwitchRoomPageState extends State<SwitchRoomPage> {
  late SwitchRoomState _state;
  final TextEditingController _targetRoomController = TextEditingController();
  static const _accentColor = Color(0xFF3F51B5);

  @override
  void initState() {
    super.initState();
    _state = SwitchRoomState(userId: widget.userId, roomIdSpec: widget.roomIdSpec);
    _state.addListener(_onChanged);
    _state.switchResult.addListener(_onSwitchResult);
    _state.initialize();
  }

  void _onChanged() => mounted ? setState(() {}) : null;

  void _onSwitchResult() {
    final result = _state.switchResult.value;
    if (result == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    if (result == 'success') {
      // Update current room display
      final input = _targetRoomController.text.trim();
      final parsed = int.tryParse(input);
      _state.updateCurrentRoomId(RoomIdSpec(
        roomId: parsed ?? 0,
        strRoomId: parsed != null ? '' : input,
      ));
      _targetRoomController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.switchRoomSuccess),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // format: "failed:errCode:errMsg"
      final parts = result.split(':');
      final errCode = parts.length > 1 ? parts[1] : '';
      final errMsg = parts.length > 2 ? parts.sublist(2).join(':') : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.switchRoomFailed(errMsg, errCode)),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    _state.switchResult.value = null;
  }

  @override
  void dispose() {
    _state.switchResult.removeListener(_onSwitchResult);
    _state.removeListener(_onChanged);
    _targetRoomController.dispose();
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
          title: Text(l10n.switchRoomPageTitle),
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
              _buildRoomInfoCard(l10n),
              const SizedBox(height: 10),
              _buildSwitchCard(l10n),
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

  Widget _buildGrid(AppLocalizations l10n, List<RemoteUser> remotes) {
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
                child: _label(t.label, t.isLocal ? _accentColor : Colors.indigoAccent)),
          ]),
        ),
      );

  Widget _label(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  // ─── Room info card ──────────────────────────────────────────

  Widget _buildRoomInfoCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _infoRow(l10n.switchRoomCurrentRoom, _state.currentRoomSpec.display,
            icon: Icons.meeting_room_outlined),
        const SizedBox(height: 10),
        _infoRow(l10n.switchRoomCurrentUserId, _state.userId,
            icon: Icons.person_outline),
      ]),
    );
  }

  Widget _infoRow(String label, String value, {IconData? icon}) => Row(children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: _accentColor),
          const SizedBox(width: 8),
        ],
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
        ),
      ]);

  // ─── Switch card ─────────────────────────────────────────────

  Widget _buildSwitchCard(AppLocalizations l10n) {
    final switching = _state.isSwitching.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.switchRoomTargetRoom,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _targetRoomController,
              decoration: InputDecoration(
                hintText: l10n.switchRoomInputHint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                prefixIcon: const Icon(Icons.swap_horiz, size: 20),
              ),
              onSubmitted: (_) => _doSwitch(),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: switching ? null : _doSwitch,
              style: FilledButton.styleFrom(
                backgroundColor: _accentColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: switching
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(l10n.switchRoomButton),
            ),
          ),
        ]),
      ]),
    );
  }

  void _doSwitch() {
    FocusScope.of(context).unfocus();
    final newRoomId = _targetRoomController.text.trim();
    if (newRoomId.isNotEmpty) {
      _state.switchRoom(newRoomId);
    }
  }
}

class _Tile {
  final bool isLocal;
  final String label;
  final String? userId;
  _Tile({required this.isLocal, required this.label, this.userId});
}
