import 'package:flutter/material.dart';
import 'set_beauty_style_page.dart';

class SetBeautyStylePreparePage extends StatefulWidget {
  const SetBeautyStylePreparePage({Key? key}) : super(key: key);

  @override
  State<SetBeautyStylePreparePage> createState() => _SetBeautyStylePreparePageState();
}

class _SetBeautyStylePreparePageState extends State<SetBeautyStylePreparePage> {
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
        builder: (_) => SetBeautyStylePage(
          userId: userId,
          roomId: roomId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Beauty Style Prepare')),
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