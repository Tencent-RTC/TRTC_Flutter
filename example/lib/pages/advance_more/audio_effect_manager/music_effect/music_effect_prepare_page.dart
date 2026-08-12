import 'package:flutter/material.dart';
import 'music_effect_page.dart';

class MusicEffectPreparePage extends StatefulWidget {
  const MusicEffectPreparePage({Key? key}) : super(key: key);

  @override
  State<MusicEffectPreparePage> createState() => _MusicEffectPreparePageState();
}

class _MusicEffectPreparePageState extends State<MusicEffectPreparePage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _roomIdController = TextEditingController();
  String? _error;

  void _onEnter() {
    final userId = _userIdController.text.trim();
    final roomId = _roomIdController.text.trim();
    if (userId.isEmpty || roomId.isEmpty) {
      setState(() {
        _error = 'User ID and Room ID cannot be empty.';
      });
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MusicEffectPage(userId: userId, roomId: roomId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music Effect Test - Prepare')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('User ID'),
            TextField(controller: _userIdController),
            const SizedBox(height: 16),
            const Text('Room ID'),
            TextField(controller: _roomIdController, keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onEnter,
                child: const Text('Enter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 