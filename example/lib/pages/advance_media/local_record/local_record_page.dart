import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'local_record_state.dart';

class LocalRecordPage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const LocalRecordPage({
    Key? key,
    required this.userId,
    required this.roomIdSpec,
  }) : super(key: key);

  @override
  State<LocalRecordPage> createState() => _LocalRecordPageState();
}

class _LocalRecordPageState extends State<LocalRecordPage> {
  late LocalRecordState _state;

  static const _accentColor = Color(0xFFE64A19);

  @override
  void initState() {
    super.initState();
    _state = LocalRecordState(
      userId: widget.userId,
      roomIdSpec: widget.roomIdSpec,
    );
    _state.addListener(_onStateChanged);
    _state.recordEvent.addListener(_onRecordEvent);
    _state.initialize();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _onRecordEvent() {
    final event = _state.recordEvent.value;
    if (event == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;

    final parts = event.split(':');
    final type = parts[0];
    String msg;
    switch (type) {
      case 'begin':
        msg = l10n.localRecordBeginMsg(int.tryParse(parts[1]) ?? 0, parts.sublist(2).join(':'));
        break;
      case 'progress':
        msg = l10n.localRecordingMsg(int.tryParse(parts[1]) ?? 0, parts.sublist(2).join(':'));
        break;
      case 'fragment':
        msg = l10n.localRecordFragmentMsg(parts.sublist(1).join(':'));
        break;
      case 'complete':
        msg = l10n.localRecordCompleteMsg(int.tryParse(parts[1]) ?? 0, parts.sublist(2).join(':'));
        break;
      case 'error':
        msg = parts[1] == 'interval'
            ? l10n.recordingIntervalInvalid
            : l10n.maxFileDurationInvalid;
        break;
      default:
        msg = event;
    }
    Fluttertoast.showToast(msg: msg);
    _state.recordEvent.value = null;
  }

  @override
  void dispose() {
    _state.recordEvent.removeListener(_onRecordEvent);
    _state.removeListener(_onStateChanged);
    _state.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
    );
  }

  String _recordTypeLabel(TRTCLocalRecordType t, AppLocalizations l10n) {
    switch (t) {
      case TRTCLocalRecordType.audio:
        return l10n.recordTypeAudio;
      case TRTCLocalRecordType.video:
        return l10n.recordTypeVideo;
      case TRTCLocalRecordType.both:
        return l10n.recordTypeBoth;
      default:
        return l10n.recordTypeBoth;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider.value(
      value: _state,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.localRecordTitle),
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
                    _buildRecordSwitch(l10n),
                    const SizedBox(height: 12),
                    _buildFilePathCard(l10n),
                    const SizedBox(height: 10),
                    _buildRecordTypeCard(l10n),
                    const SizedBox(height: 10),
                    _buildIntervalCard(l10n),
                    const SizedBox(height: 10),
                    _buildMaxDurationCard(l10n),
                  ],
                ),
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

  // ── Video area ──

  Widget _buildVideoArea(AppLocalizations l10n) {
    final remotes = _state.remoteUsers.where((u) => u.isVideoAvailable).toList();
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

  Widget _buildVideoGrid(AppLocalizations l10n, List<RemoteRecordUser> remotes) {
    final all = [
      _VideoTileData(isLocal: true, label: l10n.localPreview),
      ...remotes.map((u) => _VideoTileData(
            isLocal: false,
            label: '${l10n.remoteUser}: ${u.userId}',
            userId: u.userId,
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
                    _state.setRemoteViewId(data.userId!, viewId),
              ),
            Positioned(
              top: 6,
              left: 10,
              child: _videoLabel(
                data.label,
                data.isLocal ? _accentColor : Colors.deepOrange,
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
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  // ── Record settings ──

  Widget _buildRecordSwitch(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_state.isRecording.value ? Icons.fiber_manual_record : Icons.videocam,
              size: 22, color: _state.isRecording.value ? Colors.red : _accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(l10n.startRecording, style: const TextStyle(fontSize: 15)),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _state.isRecording,
            builder: (context, value, _) {
              return Switch(
                value: value,
                activeColor: Colors.red,
                onChanged: (_) => _state.toggleRecording(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilePathCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: ValueListenableBuilder<String>(
        valueListenable: _state.filePath,
        builder: (context, value, _) {
          return TextFormField(
            initialValue: value,
            decoration: _decoration(l10n.filePathLabel, icon: Icons.folder),
            onChanged: (v) => _state.filePath.value = v,
          );
        },
      ),
    );
  }

  Widget _buildRecordTypeCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: ValueListenableBuilder<TRTCLocalRecordType>(
        valueListenable: _state.recordType,
        builder: (context, value, _) {
          return DropdownButtonFormField<TRTCLocalRecordType>(
            value: value,
            decoration: _decoration(l10n.recordingSettingsTab, icon: Icons.mic),
            items: TRTCLocalRecordType.values
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(_recordTypeLabel(t, l10n),
                          style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) _state.recordType.value = v;
            },
          );
        },
      ),
    );
  }

  Widget _buildIntervalCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: _state.interval,
        builder: (context, value, _) {
          return TextFormField(
            initialValue: value == -1 ? '' : value.toString(),
            decoration: _decoration(l10n.recordingIntervalLabel, icon: Icons.timer),
            keyboardType: TextInputType.number,
            onChanged: (v) => _state.interval.value = int.tryParse(v) ?? -1,
          );
        },
      ),
    );
  }

  Widget _buildMaxDurationCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: _state.maxDurationPerFile,
        builder: (context, value, _) {
          return TextFormField(
            initialValue: value == 0 ? '' : value.toString(),
            decoration: _decoration(l10n.maxFileDurationLabel, icon: Icons.schedule),
            keyboardType: TextInputType.number,
            onChanged: (v) => _state.maxDurationPerFile.value = int.tryParse(v) ?? 0,
          );
        },
      ),
    );
  }
}

class _VideoTileData {
  final bool isLocal;
  final String label;
  final String? userId;

  _VideoTileData({required this.isLocal, required this.label, this.userId});
}
