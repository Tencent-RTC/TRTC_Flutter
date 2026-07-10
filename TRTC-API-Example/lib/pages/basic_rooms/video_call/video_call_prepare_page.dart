import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'video_call_page.dart';
import 'package:api_example/common/app_config.dart';

class VideoCallPreparePage extends StatefulWidget {
  const VideoCallPreparePage({Key? key}) : super(key: key);

  @override
  State<VideoCallPreparePage> createState() => _VideoCallPreparePageState();
}

class _VideoCallPreparePageState extends State<VideoCallPreparePage> {
  final _userIdController = TextEditingController(text: AppConfig.userId);
  final _roomIdController = TextEditingController(text: AppConfig.roomId);
  final _formKey = GlobalKey<FormState>();
  bool _sdkReady = false;

  @override
  void initState() {
    super.initState();
    _initSdk();
  }

  Future<void> _initSdk() async {
    await TRTCCloud.sharedInstance();
    if (mounted) setState(() => _sdkReady = true);
  }

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
        title: const Text('Video Call Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter user ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _roomIdController,
                decoration: const InputDecoration(
                  labelText: 'Room ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter room ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Spacer(),
              ElevatedButton(
                onPressed: _startCall,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Start Call'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startCall() {
    if (_formKey.currentState!.validate()) {
      AppConfig.roomId = _roomIdController.text;
      AppConfig.userId = _userIdController.text;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallPage(
            userId: _userIdController.text,
            roomId: _roomIdController.text,
          ),
        ),
      );
    }
  }
}
