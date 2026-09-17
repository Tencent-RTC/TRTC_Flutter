import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'custom_message_state.dart';

class CustomMessagePage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const CustomMessagePage({Key? key, required this.userId, required this.roomIdSpec})
      : super(key: key);

  @override
  State<CustomMessagePage> createState() => _CustomMessagePageState();
}

class _CustomMessagePageState extends State<CustomMessagePage> {
  late CustomMessageState _state;
  final TextEditingController _cmdMsgController = TextEditingController();
  final TextEditingController _cmdIdController = TextEditingController(text: '1');
  final TextEditingController _seiMsgController = TextEditingController();
  final TextEditingController _seiRepeatController = TextEditingController(text: '1');
  bool _cmdReliable = true;
  bool _cmdOrdered = true;
  static const _accentColor = Color(0xFF5E35B1);

  @override
  void initState() {
    super.initState();
    _state = CustomMessageState(userId: widget.userId, roomIdSpec: widget.roomIdSpec);
    _state.addListener(_onChanged);
    _state.initialize();
  }

  void _onChanged() => mounted ? setState(() {}) : null;

  @override
  void dispose() {
    _state.removeListener(_onChanged);
    _cmdMsgController.dispose();
    _cmdIdController.dispose();
    _seiMsgController.dispose();
    _seiRepeatController.dispose();
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
          title: Text(l10n.customMessagePageTitle),
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
              _buildCmdCard(l10n),
              const SizedBox(height: 10),
              _buildSeiCard(l10n),
              const SizedBox(height: 10),
              _buildMessageList(l10n),
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
    final height = hasRemote ? 280.0 : 160.0;

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
          ]),
        ),
      );

  Widget _buildGrid(AppLocalizations l10n, List<MsgRemoteUser> remotes) {
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
                child: _label(t.label, t.isLocal ? _accentColor : Colors.deepPurpleAccent)),
          ]),
        ),
      );

  Widget _label(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  // ─── Custom CMD message card ─────────────────────────────────

  Widget _buildCmdCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.code, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Text('CMD', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _accentColor)),
        ]),
        const SizedBox(height: 12),
        TextField(
          controller: _cmdMsgController,
          decoration: InputDecoration(
            labelText: l10n.customMessageContentLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          SizedBox(
            width: 80,
            child: TextField(
              controller: _cmdIdController,
              decoration: InputDecoration(
                labelText: l10n.idLabel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 12),
          _toggleItem(l10n.reliableLabel, _cmdReliable, (v) => setState(() => _cmdReliable = v)),
          const SizedBox(width: 12),
          _toggleItem(l10n.orderedLabel, _cmdOrdered, (v) => setState(() => _cmdOrdered = v)),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity, height: 44,
          child: FilledButton.icon(
            onPressed: _sendCmd,
            icon: const Icon(Icons.send, size: 18),
            label: Text(l10n.sendCustomButton),
            style: FilledButton.styleFrom(
              backgroundColor: _accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _toggleItem(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: const TextStyle(fontSize: 12)),
      Switch(value: value, onChanged: onChanged, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
    ]);
  }

  void _sendCmd() {
    FocusScope.of(context).unfocus();
    final msg = _cmdMsgController.text.trim();
    final cmdId = int.tryParse(_cmdIdController.text.trim()) ?? 1;
    if (msg.isNotEmpty) {
      _state.sendCustomCmdMsg(cmdId, msg, _cmdReliable, _cmdOrdered);
    }
  }

  // ─── SEI message card ────────────────────────────────────────

  Widget _buildSeiCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.videocam, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Text('SEI', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _accentColor)),
        ]),
        const SizedBox(height: 12),
        TextField(
          controller: _seiMsgController,
          decoration: InputDecoration(
            labelText: l10n.seiMessageContentLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 100,
          child: TextField(
            controller: _seiRepeatController,
            decoration: InputDecoration(
              labelText: l10n.repeatLabel,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              isDense: true,
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity, height: 44,
          child: FilledButton.icon(
            onPressed: _sendSei,
            icon: const Icon(Icons.send, size: 18),
            label: Text(l10n.sendSeiButton),
            style: FilledButton.styleFrom(
              backgroundColor: _accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ]),
    );
  }

  void _sendSei() {
    FocusScope.of(context).unfocus();
    final msg = _seiMsgController.text.trim();
    final repeat = int.tryParse(_seiRepeatController.text.trim()) ?? 1;
    if (msg.isNotEmpty) {
      _state.sendSEIMsg(msg, repeat);
    }
  }

  // ─── Received messages list ──────────────────────────────────

  Widget _buildMessageList(AppLocalizations l10n) {
    final msgs = _state.messages;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.inbox, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Text(l10n.receivedMessages,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          if (_state.missedMsgCount > 0)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.missedMsgLabel(_state.missedMsgCount),
                style: const TextStyle(fontSize: 11, color: Colors.orange),
              ),
            ),
          const Spacer(),
          if (msgs.isNotEmpty)
            TextButton.icon(
              onPressed: _state.clearMessages,
              icon: const Icon(Icons.clear_all, size: 16),
              label: Text(l10n.clearButton, style: const TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(foregroundColor: Colors.red, padding: EdgeInsets.zero),
            ),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: msgs.isEmpty
              ? Center(child: Text('—', style: TextStyle(color: Colors.grey.shade400, fontSize: 24)))
              : ListView.separated(
                  reverse: true,
                  itemCount: msgs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final msg = msgs[msgs.length - 1 - index];
                    return _buildMessageItem(msg);
                  },
                ),
        ),
      ]),
    );
  }

  Widget _buildMessageItem(MessageEntry msg) {
    final isSent = msg.direction == MessageDirection.sent;
    final isCmd = msg.type == MessageType.cmd;
    final time = '${msg.timestamp.hour.toString().padLeft(2, '0')}:'
        '${msg.timestamp.minute.toString().padLeft(2, '0')}:'
        '${msg.timestamp.second.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: (isCmd ? Colors.blue : Colors.orange).withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            isCmd ? 'CMD' : 'SEI',
            style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: isCmd ? Colors.blue : Colors.orange,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
            const SizedBox(width: 6),
            Icon(isSent ? Icons.arrow_upward : Icons.arrow_downward, size: 10,
                color: isSent ? Colors.green : Colors.teal),
            const SizedBox(width: 4),
            Text(isSent ? msg.userId : '${msg.userId}',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            if (isCmd && msg.cmdId != null)
              Text('  id:${msg.cmdId}', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
            if (!isCmd && msg.repeatCount != null)
              Text('  ×${msg.repeatCount}', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
          ]),
          const SizedBox(height: 2),
          Text(msg.data, style: const TextStyle(fontSize: 13)),
        ])),
      ]),
    );
  }
}

class _Tile {
  final bool isLocal;
  final String label;
  final String? userId;
  _Tile({required this.isLocal, required this.label, this.userId});
}
