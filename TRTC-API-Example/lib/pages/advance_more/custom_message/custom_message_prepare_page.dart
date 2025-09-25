import 'package:flutter/material.dart';
import 'custom_message.dart';

class CustomMessagePreparePage extends StatefulWidget {
  const CustomMessagePreparePage({Key? key}) : super(key: key);

  @override
  State<CustomMessagePreparePage> createState() => _CustomMessagePreparePageState();
}

class _CustomMessagePreparePageState extends State<CustomMessagePreparePage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _roomIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Message/SEI - Prepare Page')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
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
              onPressed: _onEnterRoom,
              child: const Text('Enter Room'),
            ),
          ],
        ),
      ),
    );
  }

  void _onEnterRoom() {
    final userId = _userIdController.text.trim();
    final roomId = int.tryParse(_roomIdController.text.trim());
    if (userId.isEmpty || roomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter User ID and Room ID')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomMessagePage(userId: userId, roomId: roomId),
      ),
    );
  }
} 