import 'package:flutter/material.dart';
import 'network_speed_test_page.dart';

class NetworkSpeedTestPreparePage extends StatefulWidget {
  const NetworkSpeedTestPreparePage({Key? key}) : super(key: key);

  @override
  State<NetworkSpeedTestPreparePage> createState() => _NetworkSpeedTestPreparePageState();
}

class _NetworkSpeedTestPreparePageState extends State<NetworkSpeedTestPreparePage> {
  final TextEditingController _roomIdController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();

  @override
  void dispose() {
    _roomIdController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  void _onStartTest() {
    final roomId = _roomIdController.text;
    final userId = _userIdController.text;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NetworkSpeedTestPage(
          roomId: roomId,
          userId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network Speed Test Prepare')),
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
                onPressed: _onStartTest,
                child: const Text('Start Speed Test'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TRTCSpeedTestScene 枚举需要在 network_speed_test_page.dart 或公共文件中定义/导入。 