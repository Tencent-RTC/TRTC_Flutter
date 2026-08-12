import 'package:flutter/material.dart';
import 'connect_other_room_page.dart';

class ConnectOtherRoomPreparePage extends StatefulWidget {
  const ConnectOtherRoomPreparePage({Key? key}) : super(key: key);

  @override
  State<ConnectOtherRoomPreparePage> createState() => _ConnectOtherRoomPreparePageState();
}

class _ConnectOtherRoomPreparePageState extends State<ConnectOtherRoomPreparePage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _roomIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect Other Room - Prepare Page')),
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
        builder: (context) => ConnectOtherRoomPage(userId: userId, roomId: roomId),
      ),
    );
  }
} 