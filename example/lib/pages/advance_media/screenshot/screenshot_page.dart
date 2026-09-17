import 'dart:io';

import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'screenshot_state.dart';

class ScreenshotPage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const ScreenshotPage({Key? key, required this.userId, required this.roomIdSpec})
      : super(key: key);

  @override
  State<ScreenshotPage> createState() => _ScreenshotPageState();
}

class _ScreenshotPageState extends State<ScreenshotPage> {
  late ScreenshotState _state;
  String? _targetUserId; // null = local
  TRTCVideoStreamType _streamType = TRTCVideoStreamType.big;
  TRTCSnapshotSourceType _sourceType = TRTCSnapshotSourceType.stream;

  static const _accentColor = Color(0xFFF57C00);

  @override
  void initState() {
    super.initState();
    _state = ScreenshotState(userId: widget.userId, roomIdSpec: widget.roomIdSpec);
    _state.addListener(_onStateChanged);
    _state.snapshotResult.addListener(_onSnapshotResult);
    _state.initialize();
  }

  void _onStateChanged() {
    if (!mounted) return;
    // If the selected target user has left the room, reset selection to local
    // to avoid DropdownButtonFormField assertion (stale value not in items).
    if (_targetUserId != null &&
        !_state.remoteUsers.any((u) => u.userId == _targetUserId)) {
      _targetUserId = null;
    }
    setState(() {});
  }

  void _onSnapshotResult() {
    final result = _state.snapshotResult.value;
    if (result == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.snapshotSuccess}: ${result.path}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.snapshotFailed(result.errMsg)} (code: ${result.errCode})'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _state.snapshotResult.removeListener(_onSnapshotResult);
    _state.removeListener(_onStateChanged);
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

  String _streamTypeLabel(TRTCVideoStreamType t, AppLocalizations l10n) {
    switch (t) {
      case TRTCVideoStreamType.big:
        return l10n.streamTypeBig;
      case TRTCVideoStreamType.small:
        return l10n.streamTypeSmall;
      case TRTCVideoStreamType.sub:
        return l10n.streamTypeSub;
    }
  }

  String _sourceTypeLabel(TRTCSnapshotSourceType s, AppLocalizations l10n) {
    switch (s) {
      case TRTCSnapshotSourceType.stream:
        return l10n.screenshotSourceStream;
      case TRTCSnapshotSourceType.view:
        return l10n.screenshotSourceView;
      case TRTCSnapshotSourceType.capture:
        return l10n.screenshotSourceCapture;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider.value(
      value: _state,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.sceneSnapshot),
          actions: [
            Container(
              width: 10, height: 10,
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
            Expanded(child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _buildSettings(l10n),
                const SizedBox(height: 12),
                _buildPreview(l10n),
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
          ],
        ),
      ),
    );
  }

  // ─── Video area ────────────────────────────────────────────

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
        decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(12),
          border: !t.isLocal && t.userId == _targetUserId
              ? Border.all(color: _accentColor, width: 2) : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(children: [
            t.isLocal
                ? TRTCCloudVideoView(onViewCreated: (v) => _state.setLocalViewId(v))
                : TRTCCloudVideoView(onViewCreated: (v) => _state.setRemoteViewId(t.userId!, v)),
            Positioned(top: 6, left: 10,
                child: _label(t.label, t.isLocal ? _accentColor : Colors.amber)),
          ]),
        ),
      );

  Widget _label(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  // ─── Settings ──────────────────────────────────────────────

  Widget _buildSettings(AppLocalizations l10n) => Column(children: [
        // Target user selector
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: _cardDec(),
          child: DropdownButtonFormField<String>(
            value: _targetUserId,
            decoration: _dec(l10n.screenshotTarget, icon: Icons.person_outline),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.localPreview, style: const TextStyle(fontSize: 13))),
              ..._state.remoteUsers.map((u) => DropdownMenuItem(
                    value: u.userId, child: Text(u.userId, style: const TextStyle(fontSize: 13)))),
            ],
            onChanged: (v) => setState(() => _targetUserId = v),
          ),
        ),
        // Stream type
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: _cardDec(),
          child: DropdownButtonFormField<TRTCVideoStreamType>(
            value: _streamType,
            decoration: _dec(l10n.screenshotStreamType, icon: Icons.stream),
            items: TRTCVideoStreamType.values
                .map((t) => DropdownMenuItem(value: t, child: Text(_streamTypeLabel(t, l10n), style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (v) => setState(() => _streamType = v ?? TRTCVideoStreamType.big),
          ),
        ),
        // Source type
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: _cardDec(),
          child: DropdownButtonFormField<TRTCSnapshotSourceType>(
            value: _sourceType,
            decoration: _dec(l10n.screenshotSourceType, icon: Icons.image),
            items: TRTCSnapshotSourceType.values
                .map((t) => DropdownMenuItem(value: t, child: Text(_sourceTypeLabel(t, l10n), style: const TextStyle(fontSize: 12))))
                .toList(),
            onChanged: (v) => setState(() => _sourceType = v ?? TRTCSnapshotSourceType.stream),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity, height: 48,
          child: FilledButton.icon(
            onPressed: () => _state.takeSnapshot(
                _targetUserId, _streamType, _sourceType),
            icon: const Icon(Icons.camera_alt, size: 20),
            label: Text(l10n.screenshotTakeBtn),
            style: FilledButton.styleFrom(
              backgroundColor: _accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ]);

  // ─── Snapshot preview ──────────────────────────────────────

  Widget _buildPreview(AppLocalizations l10n) {
    final result = _state.snapshotResult.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: _cardDec(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.photo_library, size: 18, color: _accentColor),
            const SizedBox(width: 8),
            Text(l10n.screenshotPreview, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 10),
          if (result == null)
            _emptyPreview(l10n)
          else if (result.isSuccess && result.fileExists)
            _imagePreview(result, l10n)
          else
            _errorPreview(result, l10n),
        ],
      ),
    );
  }

  Widget _emptyPreview(AppLocalizations l10n) => Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined, size: 40, color: Colors.grey.withOpacity(0.5)),
              const SizedBox(height: 8),
              Text(l10n.screenshotNoImage, style: TextStyle(fontSize: 12, color: Colors.grey.withOpacity(0.7))),
            ],
          ),
        ),
      );

  Widget _imagePreview(SnapshotResult result, AppLocalizations l10n) => Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(File(result.path), fit: BoxFit.contain, height: 200, width: double.infinity),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Icon(Icons.check_circle, size: 16, color: Colors.green),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${l10n.screenshotSavedPath}: ${result.path}',
                style: TextStyle(fontSize: 11, color: Colors.green[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
        ),
      ]);

  Widget _errorPreview(SnapshotResult result, AppLocalizations l10n) => Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 32, color: Colors.red.withOpacity(0.7)),
              const SizedBox(height: 6),
              Text(
                '${l10n.snapshotFailed(result.errMsg)} (code: ${result.errCode})',
                style: TextStyle(fontSize: 12, color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

class _Tile {
  final bool isLocal;
  final String label;
  final String? userId;
  _Tile({required this.isLocal, required this.label, this.userId});
}
