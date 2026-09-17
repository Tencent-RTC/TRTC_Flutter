import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'screen_share_state.dart';

class _ResolutionOption {
  final TRTCVideoResolution resolution;
  final String label;
  const _ResolutionOption(this.resolution, this.label);
}

class ScreenSharePage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const ScreenSharePage({Key? key, required this.userId, required this.roomIdSpec})
      : super(key: key);

  @override
  State<ScreenSharePage> createState() => _ScreenSharePageState();
}

class _ScreenSharePageState extends State<ScreenSharePage> {
  late ScreenShareState _state;
  static const _accentColor = Color(0xFF00695C);

  @override
  void initState() {
    super.initState();
    _state = ScreenShareState(userId: widget.userId, roomIdSpec: widget.roomIdSpec);
    _state.addListener(_onChanged);
    _state.shareEvent.addListener(_onShareEvent);
    _state.selectedRemoteUserId.addListener(_onChanged);
    _state.initialize();
    if (_state.isDesktop) _state.refreshShareSources();
  }

  void _onChanged() => mounted ? setState(() {}) : null;

  void _onShareEvent() {
    final event = _state.shareEvent.value;
    if (event == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final parts = event.split(':');
    final type = parts[0];
    final reason = parts.length > 1 ? parts[1] : '';
    String msg;
    Color color;
    switch (type) {
      case 'started':
        msg = l10n.screenShareEventStarted;
        color = Colors.green;
        break;
      case 'paused':
        msg = l10n.screenShareEventPaused(reason);
        color = Colors.orange;
        break;
      case 'resumed':
        msg = l10n.screenShareEventResumed(reason);
        color = Colors.green;
        break;
      case 'stopped':
        msg = l10n.screenShareEventStopped(reason);
        color = Colors.grey;
        break;
      case 'covered':
        msg = l10n.screenShareEventCovered;
        color = Colors.red;
        break;
      case 'loopback_error':
        msg = l10n.screenShareEventLoopbackError(reason);
        color = Colors.red;
        break;
      default:
        return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2)),
    );
    _state.shareEvent.value = null;
  }

  @override
  void dispose() {
    _state.selectedRemoteUserId.removeListener(_onChanged);
    _state.shareEvent.removeListener(_onShareEvent);
    _state.removeListener(_onChanged);
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
          title: Text(l10n.screenShareTitle),
          actions: [
            Container(
              width: 10, height: 10, margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(color: _state.isEnterRoom ? Colors.green : Colors.grey, shape: BoxShape.circle),
            ),
          ],
        ),
        body: Column(children: [
          _buildLocalPreview(l10n),
          _buildRemoteSubStream(l10n),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _buildStatusCard(l10n),
              const SizedBox(height: 10),
              if (_state.isDesktop) _buildSourceSelector(l10n),
              _buildControlButtons(l10n),
              const SizedBox(height: 10),
              _buildSubEncParamCard(l10n),
              if (_state.isDesktop) ...[
                const SizedBox(height: 10),
                _buildLoopbackVolumeCard(l10n),
                const SizedBox(height: 10),
                _buildWindowMgmtCard(l10n),
              ],
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

  // ─── Local camera preview ───────────────────────────────────

  Widget _buildLocalPreview(AppLocalizations l10n) => Container(
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        height: 180,
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(children: [
            TRTCCloudVideoView(onViewCreated: (v) => _state.setLocalViewId(v)),
            Positioned(top: 6, left: 10, child: _label(l10n.localPreview, _accentColor)),
          ]),
        ),
      );

  // ─── Remote sub-stream (screen share) selector + preview ─────

  Widget _buildRemoteSubStream(AppLocalizations l10n) {
    final subUsers = _state.subStreamUsers;
    final selected = _state.selectedRemoteUserId.value;
    final hasSelection = selected != null && selected.isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasSelection ? _accentColor.withOpacity(0.5) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(children: [
        // Dropdown selector
        if (subUsers.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: DropdownButton<String?>(
              value: selected,
              isExpanded: true,
              underline: const SizedBox(),
              hint: Text(l10n.screenShareSubPreview,
                  style: TextStyle(color: Colors.teal[200], fontSize: 13, fontWeight: FontWeight.w600)),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.screenShareSubPreviewHint,
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ),
                ...subUsers.map((u) => DropdownMenuItem<String?>(
                  value: u.userId,
                  child: Text('${l10n.remoteUser}: ${u.userId}',
                      style: const TextStyle(color: Colors.white, fontSize: 13)),
                )),
              ],
              onChanged: (v) => _state.selectRemoteUser(v),
              dropdownColor: const Color(0xFF1E1E1E),
              icon: Icon(Icons.expand_more, color: Colors.teal[200], size: 20),
            ),
          ),
        // Preview view
        SizedBox(
          height: subUsers.isNotEmpty ? 150 : 80,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              bottom: const Radius.circular(12),
              top: subUsers.isNotEmpty ? Radius.zero : const Radius.circular(12),
            ),
            child: Stack(children: [
              if (hasSelection)
                TRTCCloudVideoView(onViewCreated: (v) => _state.setRemoteSubViewId(v))
              else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      subUsers.isEmpty
                          ? l10n.screenShareSubPreviewHint
                          : l10n.screenShareSubPreview,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _label(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  // ─── Status card ─────────────────────────────────────────────

  Widget _buildStatusCard(AppLocalizations l10n) {
    final sharing = _state.isSharing.value;
    final paused = _state.isPaused.value;
    final statusText = !sharing
        ? l10n.screenShareStatusIdle
        : (paused ? l10n.screenShareStatusPaused : l10n.screenShareStatusSharing);
    final statusColor = !sharing ? Colors.grey : (paused ? Colors.orange : Colors.green);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _cardDec(),
      child: Row(children: [
        Icon(Icons.screen_share_rounded, size: 20, color: statusColor),
        const SizedBox(width: 10),
        Expanded(child: Text(statusText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: statusColor))),
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
      ]),
    );
  }

  // ─── Desktop source selector (getScreenCaptureSources / selectScreenCaptureTarget) ─

  Widget _buildSourceSelector(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _cardDec(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(l10n.screenShareSourceSection, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => setState(() => _state.refreshShareSources()),
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(l10n.screenShareRefreshSources, style: const TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(foregroundColor: _accentColor, padding: EdgeInsets.zero),
            ),
          ]),
          const SizedBox(height: 8),
          if (_state.shareSources.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l10n.screenShareNoSource,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            )
          else
            SizedBox(
              height: 88,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _state.shareSources.length,
                itemBuilder: (_, i) {
                  final source = _state.shareSources[i];
                  final isSelected = _state.selectedSource?.viewId == source.viewId &&
                      _state.selectedSource?.type == source.type;
                  return GestureDetector(
                    onTap: () => setState(() => _state.selectShareSource(source)),
                    child: Container(
                      width: 96,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? _accentColor : Colors.transparent, width: 2),
                        color: Colors.grey.withOpacity(0.08),
                      ),
                      child: Column(children: [
                        Icon(
                          source.type == TRTCScreenCaptureSourceType.screen
                              ? Icons.desktop_windows_outlined
                              : Icons.window_outlined,
                          size: 28,
                          color: isSelected ? _accentColor : Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          source.sourceName.isEmpty
                              ? (source.type == TRTCScreenCaptureSourceType.screen
                                  ? l10n.screenShareSourceScreen
                                  : l10n.screenShareSourceWindow)
                              : source.sourceName,
                          style: const TextStyle(fontSize: 10),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ─── Control buttons ────────────────────────────────────────

  Widget _buildControlButtons(AppLocalizations l10n) {
    final sharing = _state.isSharing.value;
    final paused = _state.isPaused.value;
    return Column(children: [
      SizedBox(
        width: double.infinity, height: 48,
        child: FilledButton.icon(
          onPressed: sharing ? _state.stopScreenShare : _state.startScreenShare,
          icon: Icon(sharing ? Icons.stop_screen_share : Icons.screen_share, size: 20),
          label: Text(sharing ? l10n.stopScreenShare : l10n.startScreenShare),
          style: FilledButton.styleFrom(
            backgroundColor: sharing ? Colors.red : _accentColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      if (sharing) ...[
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity, height: 44,
          child: OutlinedButton.icon(
            onPressed: _state.togglePause,
            icon: Icon(paused ? Icons.play_arrow : Icons.pause, size: 18),
            label: Text(paused ? l10n.resumeScreenShare : l10n.pauseScreenShare),
            style: OutlinedButton.styleFrom(
              foregroundColor: _accentColor,
              side: BorderSide(color: _accentColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    ]);
  }

  // ─── Sub-stream encoding params card ─────────────────────────

  Widget _buildSubEncParamCard(AppLocalizations l10n) {
    final resolutions = [
      _ResolutionOption(TRTCVideoResolution.res_1920_1080, '1920×1080'),
      _ResolutionOption(TRTCVideoResolution.res_1280_720, '1280×720'),
      _ResolutionOption(TRTCVideoResolution.res_640_480, '640×480'),
      _ResolutionOption(TRTCVideoResolution.res_960_540, '960×540'),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(l10n.screenShareSubEncParam, Icons.settings_outlined),
        const SizedBox(height: 12),
        Text(l10n.screenShareResolution, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 6, children: resolutions.map((r) {
          final selected = _state.subStreamResolution == r.resolution;
          return GestureDetector(
            onTap: () => _state.setSubStreamResolution(r.resolution),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? _accentColor.withOpacity(0.12) : Colors.grey.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: selected ? _accentColor : Colors.transparent),
              ),
              child: Text(r.label, style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: selected ? _accentColor : Colors.grey.shade700,
              )),
            ),
          );
        }).toList()),
        const SizedBox(height: 12),
        _sliderRow(l10n.screenShareBitrate, _state.subStreamBitrate.toDouble(), 100, 5000, 49,
            (v) => _state.setSubStreamBitrate(v.round())),
        const SizedBox(height: 8),
        _sliderRow(l10n.screenShareFps, _state.subStreamFps.toDouble(), 5, 30, 25,
            (v) => _state.setSubStreamFps(v.round())),
      ]),
    );
  }

  Widget _sliderRow(String label, double value, double min, double max, int divisions,
      ValueChanged<double> onChanged) {
    return Row(children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      Expanded(
        child: Slider(
          value: value, min: min, max: max, divisions: divisions,
          activeColor: _accentColor,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ),
      SizedBox(width: 40, child: Text(value.round().toString(),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _accentColor))),
    ]);
  }

  // ─── System audio loopback volume card ───────────────────────

  Widget _buildLoopbackVolumeCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(l10n.screenShareLoopbackVolume, Icons.volume_up_outlined),
        const SizedBox(height: 8),
        _sliderRow(l10n.screenShareLoopbackVolume, _state.loopbackVolume.toDouble(), 0, 200, 200,
            (v) => _state.setLoopbackVolume(v.round())),
      ]),
    );
  }

  // ─── Window exclusion/inclusion card (desktop only) ──────────

  Widget _buildWindowMgmtCard(AppLocalizations l10n) {
    final windowSources = _state.shareSources
        .where((s) => s.type == TRTCScreenCaptureSourceType.window)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(l10n.screenShareWindowMgmt, Icons.filter_alt_outlined),
        const SizedBox(height: 8),
        if (windowSources.isEmpty)
          Text(l10n.screenShareNoWindowsSelected,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500))
        else
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: windowSources.length,
              itemBuilder: (_, i) {
                final source = windowSources[i];
                final isExcluded = _state.excludedWindows.contains(source.viewId);
                final isIncluded = _state.includedWindows.contains(source.viewId);
                final highlight = isExcluded ? Colors.red : (isIncluded ? Colors.green : null);
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: highlight ?? Colors.grey.shade300,
                      width: highlight != null ? 2 : 1),
                    color: highlight != null ? highlight.withOpacity(0.06) : null,
                  ),
                  child: Column(children: [
                    Expanded(child: Text(
                      source.sourceName.isEmpty ? 'Window ${source.viewId}' : source.sourceName,
                      style: const TextStyle(fontSize: 10), maxLines: 2,
                      overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                    )),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      GestureDetector(
                        onTap: () => isExcluded
                            ? _state.removeExcludedWindow(source.viewId)
                            : _state.addExcludedWindow(source.viewId),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text(l10n.screenShareExcludeBtn,
                              style: TextStyle(fontSize: 9, color: isExcluded ? Colors.red : Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => isIncluded
                            ? _state.removeIncludedWindow(source.viewId)
                            : _state.addIncludedWindow(source.viewId),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text(l10n.screenShareIncludeBtn,
                              style: TextStyle(fontSize: 9, color: isIncluded ? Colors.green : Colors.grey)),
                        ),
                      ),
                    ]),
                  ]),
                );
              },
            ),
          ),
        if (_state.excludedWindows.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(children: [
            Text('${l10n.screenShareExcludedWindows} (${_state.excludedWindows.length})',
                style: TextStyle(fontSize: 11, color: Colors.red.shade700, fontWeight: FontWeight.w600)),
            const Spacer(),
            TextButton(
              onPressed: _state.clearExcludedWindows,
              child: Text(l10n.screenShareClearBtn, style: const TextStyle(fontSize: 10)),
              style: TextButton.styleFrom(foregroundColor: Colors.red, padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 24)),
            ),
          ]),
          Wrap(spacing: 4, runSpacing: 4, children: _state.excludedWindows.map((id) =>
            Chip(label: Text('$id', style: const TextStyle(fontSize: 10)),
              backgroundColor: Colors.red.withOpacity(0.1),
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => _state.removeExcludedWindow(id),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ).toList()),
        ],
        if (_state.includedWindows.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(children: [
            Text('${l10n.screenShareIncludedWindows} (${_state.includedWindows.length})',
                style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
            const Spacer(),
            TextButton(
              onPressed: _state.clearIncludedWindows,
              child: Text(l10n.screenShareClearBtn, style: const TextStyle(fontSize: 10)),
              style: TextButton.styleFrom(foregroundColor: Colors.green, padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 24)),
            ),
          ]),
          Wrap(spacing: 4, runSpacing: 4, children: _state.includedWindows.map((id) =>
            Chip(label: Text('$id', style: const TextStyle(fontSize: 10)),
              backgroundColor: Colors.green.withOpacity(0.1),
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => _state.removeIncludedWindow(id),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ).toList()),
        ],
      ]),
    );
  }

  Widget _cardHeader(String title, IconData icon) => Row(children: [
        Icon(icon, size: 18, color: _accentColor),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ]);
}
