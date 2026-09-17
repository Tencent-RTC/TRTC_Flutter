import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ai_transcriber_state.dart';

class _StatusVisual {
  final Color color;
  final IconData icon;
  final String text;
  const _StatusVisual(this.color, this.icon, this.text);
}

class AITranscriberPage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;
  final String sourceLanguage;
  final List<String> translationLanguages;

  const AITranscriberPage({
    Key? key,
    required this.userId,
    required this.roomIdSpec,
    required this.sourceLanguage,
    required this.translationLanguages,
  }) : super(key: key);

  @override
  State<AITranscriberPage> createState() => _AITranscriberPageState();
}

class _AITranscriberPageState extends State<AITranscriberPage>
    with SingleTickerProviderStateMixin {
  late AITranscriberState _state;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _state = AITranscriberState(
      userId: widget.userId,
      roomIdSpec: widget.roomIdSpec,
      sourceLanguage: widget.sourceLanguage,
      translationLanguages: widget.translationLanguages,
    );
    _state.addListener(_onChanged);
    _state.eventMessage.addListener(_onEventMessage);
    _state.initialize();
  }

  void _onChanged() {
    if (!mounted) return;
    // Pulse animation when transcribing
    if (_state.status == TranscriberStatus.transcribing ||
        _state.status == TranscriberStatus.starting ||
        _state.status == TranscriberStatus.enteringRoom) {
      _pulseController.repeat();
    } else {
      _pulseController.stop();
    }
    setState(() {});
  }

  void _onEventMessage() {
    final event = _state.eventMessage.value;
    if (event == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    String msg;
    Color color;

    if (event == 'room_success') {
      return; // No toast for room entry, status card handles it
    } else if (event.startsWith('room_failed:')) {
      msg = 'Enter room failed: ${event.split(':')[1]}';
      color = Colors.red;
    } else if (event.startsWith('started:')) {
      msg = l10n.transcriberStarted(event.split(':').sublist(1).join(':'));
      color = Colors.green;
    } else if (event.startsWith('stopped:')) {
      msg = l10n.transcriberStopped(event.split(':').sublist(1).join(':'));
      color = Colors.grey;
    } else if (event == 'paused') {
      msg = l10n.pausedReceiving;
      color = Colors.orange;
    } else if (event == 'resumed') {
      msg = l10n.resumedReceiving;
      color = Colors.green;
    } else if (event.startsWith('error:')) {
      msg = event.substring(6);
      color = Colors.red;
    } else {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    _state.eventMessage.value = null;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _state.eventMessage.removeListener(_onEventMessage);
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
        appBar: AppBar(
          title: Text(l10n.aiTranscriberTitle),
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
          _buildStatusCard(l10n),
          _buildStatsBar(l10n),
          Expanded(child: _buildTranscriptList(l10n)),
          _buildControls(l10n),
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

  // ─── Status card with pulse animation ────────────────────────

  Widget _buildStatusCard(AppLocalizations l10n) {
    final status = _state.status;
    final visual = _statusVisual(status, l10n);
    final color = visual.color, icon = visual.icon, text = visual.text;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(children: [
        // Pulse animation indicator
        if (status == TranscriberStatus.transcribing ||
            status == TranscriberStatus.starting ||
            status == TranscriberStatus.enteringRoom)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, child) => Opacity(
              opacity: 0.4 + 0.6 * _pulseController.value,
              child: child,
            ),
            child: Container(
              width: 14, height: 14,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          )
        else
          Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
          if (_state.robotId != null && status == TranscriberStatus.transcribing)
            Text('Robot: ${_state.robotId}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          if (_state.errorMessage != null && status == TranscriberStatus.error)
            Text(_state.errorMessage!,
                style: TextStyle(fontSize: 11, color: Colors.red),
                maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
        // Room info badge
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(l10n.roomUserStatusDisplay(
              _state.roomIdSpec.display, _state.userId),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ]),
      ]),
    );
  }

  _StatusVisual _statusVisual(TranscriberStatus status, AppLocalizations l10n) {
    switch (status) {
      case TranscriberStatus.enteringRoom:
        return _StatusVisual(Colors.blue, Icons.wifi_protected_setup, l10n.enteringRoomLabel);
      case TranscriberStatus.idle:
        return _StatusVisual(Colors.grey, Icons.mic_none_outlined, l10n.startButton);
      case TranscriberStatus.starting:
        return _StatusVisual(Colors.orange, Icons.mic_none, l10n.startingTranscriber);
      case TranscriberStatus.transcribing:
        return _StatusVisual(Colors.green, Icons.graphic_eq, l10n.transcribingLabel);
      case TranscriberStatus.paused:
        return _StatusVisual(Colors.orange, Icons.pause_circle_outline, l10n.pausedReceiving);
      case TranscriberStatus.stopping:
        return _StatusVisual(Colors.grey, Icons.stop_circle_outlined, l10n.stoppingTranscriber);
      case TranscriberStatus.error:
        return _StatusVisual(Colors.red, Icons.error_outline, l10n.transcriberError(0, _state.errorMessage ?? ''));
    }
  }

  // ─── Stats bar ───────────────────────────────────────────────

  Widget _buildStatsBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(children: [
        _statChip(Icons.check_circle_outline, '${_state.completedCount}',
            l10n.transcriptCompleted, Colors.green),
        const SizedBox(width: 8),
        _statChip(Icons.pending, '${_state.pendingCount}',
            l10n.transcriptPending, Colors.orange),
        const Spacer(),
        if (_state.transcripts.isNotEmpty)
          TextButton.icon(
            onPressed: _state.clearTranscripts,
            icon: const Icon(Icons.clear_all, size: 16),
            label: Text(l10n.clearButton, style: const TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(foregroundColor: Colors.red, padding: EdgeInsets.zero),
          ),
      ]),
    );
  }

  Widget _statChip(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ]),
    );
  }

  // ─── Transcript list with animations ─────────────────────────

  Widget _buildTranscriptList(AppLocalizations l10n) {
    if (_state.transcripts.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.subtitles_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(l10n.noTranscriptsYet,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      itemCount: _state.transcripts.length,
      itemBuilder: (context, index) {
        final item = _state.transcripts[index];
        return _buildTranscriptCard(item, l10n);
      },
    );
  }

  Widget _buildTranscriptCard(TranscriptItem item, AppLocalizations l10n) {
    final isLocal = item.speakerUserId == _state.userId;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey('${item.segmentId}_${item.isCompleted}'),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.isCompleted
              ? (isLocal ? Colors.blue.withOpacity(0.04) : Colors.green.withOpacity(0.04))
              : Colors.orange.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isCompleted
                ? (isLocal ? Colors.blue.withOpacity(0.2) : Colors.green.withOpacity(0.2))
                : Colors.orange.withOpacity(0.3),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header: speaker + status + time
          Row(children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isLocal ? Colors.blue : Colors.green,
              child: Text(item.speakerUserId.isNotEmpty ? item.speakerUserId[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            Text(item.speakerUserId,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: isLocal ? Colors.blue : Colors.green)),
            const SizedBox(width: 6),
            // Status badge
            if (!item.isCompleted)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, child) => Opacity(
                  opacity: 0.5 + 0.5 * _pulseController.value,
                  child: child,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.edit, size: 10, color: Colors.orange.shade700),
                    const SizedBox(width: 3),
                    Text('...', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.orange.shade700)),
                  ]),
                ),
              )
            else
              Icon(Icons.check_circle, size: 14, color: Colors.green.shade400),
            const Spacer(),
            Text(_formatTime(item.timestamp),
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
          ]),
          const SizedBox(height: 8),
          // Source text
          Text(item.sourceText.isEmpty ? '...' : item.sourceText,
              style: TextStyle(fontSize: 14, color: item.isCompleted ? Colors.black87 : Colors.black54)),
          // Translations
          if (item.translationTexts.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...item.translationTexts.entries.map((e) => Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(e.key.toUpperCase(),
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.blue)),
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(e.value,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
              ]),
            )),
          ],
        ]),
      ),
    );
  }

  // ─── Controls ────────────────────────────────────────────────

  Widget _buildControls(AppLocalizations l10n) {
    final status = _state.status;
    final canStart = _state.isEnterRoom &&
        (status == TranscriberStatus.idle || status == TranscriberStatus.error);
    final canStop = status == TranscriberStatus.transcribing ||
        status == TranscriberStatus.paused;
    final canPause = status == TranscriberStatus.transcribing;
    final canResume = status == TranscriberStatus.paused;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.3))),
      ),
      child: Row(children: [
        // Start / Stop
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 44,
            child: canStop
                ? FilledButton.icon(
                    onPressed: _state.stopTranscriber,
                    icon: const Icon(Icons.stop, size: 18),
                    label: Text(l10n.stopButton),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  )
                : FilledButton.icon(
                    onPressed: canStart ? _state.startTranscriber : null,
                    icon: status == TranscriberStatus.starting
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.mic, size: 18),
                    label: Text(l10n.startButton),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        // Pause
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: canPause ? _state.pauseReceiving : null,
              icon: const Icon(Icons.pause, size: 16),
              label: Text(l10n.pauseButton, style: const TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: BorderSide(color: canPause ? Colors.orange : Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Resume
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: canResume ? _state.resumeReceiving : null,
              icon: const Icon(Icons.play_arrow, size: 16),
              label: Text(l10n.resumeButton, style: const TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: BorderSide(color: canResume ? Colors.green : Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  String _formatTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }
}
