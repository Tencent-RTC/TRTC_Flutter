import 'package:flutter/material.dart';
import 'voice_room_page.dart';

class VoiceRoomPreparePage extends StatefulWidget {
  const VoiceRoomPreparePage({Key? key}) : super(key: key);

  @override
  State<VoiceRoomPreparePage> createState() => _VoiceRoomPreparePageState();
}

class _VoiceRoomPreparePageState extends State<VoiceRoomPreparePage> {
  final _userIdController = TextEditingController();
  final _roomIdController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    _roomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Chat Room Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _roomIdController,
              decoration: const InputDecoration(
                labelText: 'Room ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _startVoiceChat,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text('Join Voice Room'),
            ),
          ],
        ),
      ),
    );
  }

  void _startVoiceChat() {
    final userId = _userIdController.text.trim();
    final roomId = _roomIdController.text.trim();

    if (userId.isEmpty || roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter user ID and room ID')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoiceRoomPage(
          userId: userId,
          roomId: int.parse(roomId),
        ),
      ),
    );
  }
}
