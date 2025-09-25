import 'package:flutter/material.dart';
import 'screen_share_page.dart';

class ScreenSharePreparePage extends StatefulWidget {
  const ScreenSharePreparePage({Key? key}) : super(key: key);

  @override
  State<ScreenSharePreparePage> createState() => _ScreenSharePreparePageState();
}

class _ScreenSharePreparePageState extends State<ScreenSharePreparePage> {
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
        builder: (_) => ScreenSharePage(userId: userId, roomId: roomId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Share - Prepare')),
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