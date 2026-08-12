import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ai_transcriber_state.dart';

class AITranscriberPage extends StatefulWidget {
  final String userId;
  final int roomId;
  final String sourceLanguage;
  final List<String> translationLanguages;

  const AITranscriberPage({
    Key? key,
    required this.userId,
    required this.roomId,
    required this.sourceLanguage,
    required this.translationLanguages,
  }) : super(key: key);

  @override
  State<AITranscriberPage> createState() => _AITranscriberPageState();
}

class _AITranscriberPageState extends State<AITranscriberPage> {
  late AITranscriberState _state;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _state = AITranscriberState();
    await _state.initialize(userId: widget.userId, roomId: widget.roomId);
    if (mounted) {
      setState(() => _isInitializing = false);
    }
  }

  @override
  void dispose() {
    _state.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ChangeNotifierProvider.value(
      value: _state,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI Transcriber'),
          actions: [
            Consumer<AITranscriberState>(
              builder: (context, state, _) => IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: state.transcripts.isEmpty ? null : state.clearTranscripts,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildStatusBar(),
            Expanded(child: _buildTranscriptList()),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Consumer<AITranscriberState>(
      builder: (context, state, _) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: state.isEnterRoomSuccess ? Colors.green.shade50 : Colors.orange.shade50,
        child: Column(
          children: [
            Text(
              'Room: ${state.roomId} | User: ${state.localUserId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              state.statusMessage,
              style: TextStyle(
                color: state.isEnterRoomSuccess ? Colors.green : Colors.orange,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranscriptList() {
    return Consumer<AITranscriberState>(
      builder: (context, state, _) {
        if (state.transcripts.isEmpty) {
          return const Center(
            child: Text(
              'No transcripts yet.\nStart transcriber and speak to see results.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: state.transcripts.length,
          itemBuilder: (context, index) {
            final item = state.transcripts[index];
            return _buildTranscriptCard(item);
          },
        );
      },
    );
  }

  Widget _buildTranscriptCard(TranscriptItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.isCompleted ? Icons.check_circle : Icons.pending,
                  size: 16,
                  color: item.isCompleted ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  item.speakerUserId,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(item.timestamp),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
            const Divider(height: 16),
            Text(
              item.sourceText,
              style: const TextStyle(fontSize: 15),
            ),
            if (item.translationTexts.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...item.translationTexts.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(e.key.toUpperCase(), style: const TextStyle(fontSize: 10)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(e.value, style: TextStyle(color: Colors.grey.shade700)),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Consumer<AITranscriberState>(
      builder: (context, state, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.isEnterRoomSuccess && !state.isTranscribing
                        ? () => _state.startTranscriber(
                              sourceLanguage: widget.sourceLanguage,
                              translationLanguages: widget.translationLanguages,
                            )
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.isTranscribing ? _state.stopTranscriber : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isTranscribing && !state.isPaused
                        ? _state.pauseReceiving
                        : null,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isTranscribing && state.isPaused
                        ? _state.resumeReceiving
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
