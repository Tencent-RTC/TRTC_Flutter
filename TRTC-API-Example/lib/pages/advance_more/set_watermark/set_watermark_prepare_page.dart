import 'package:flutter/material.dart';
import 'set_watermark_page.dart';

class SetWatermarkPreparePage extends StatefulWidget {
  const SetWatermarkPreparePage({Key? key}) : super(key: key);

  @override
  State<SetWatermarkPreparePage> createState() => _SetWatermarkPreparePageState();
}

class _SetWatermarkPreparePageState extends State<SetWatermarkPreparePage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _roomIdController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    _roomIdController.dispose();
    super.dispose();
  }

  void _onEnter() {
    final userId = _userIdController.text;
    final roomId = _roomIdController.text;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SetWatermarkPage(
          userId: userId,
          roomId: roomId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Watermark Prepare')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('User ID'),
            TextField(controller: _userIdController),
            const SizedBox(height: 16),
            const Text('Room ID'),
            TextField(controller: _roomIdController),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onEnter,
                child: const Text('Enter Room'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 