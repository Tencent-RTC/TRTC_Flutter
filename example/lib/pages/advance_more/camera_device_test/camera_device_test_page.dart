import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';

class CameraDeviceTestPage extends StatefulWidget {
  const CameraDeviceTestPage({Key? key}) : super(key: key);

  @override
  State<CameraDeviceTestPage> createState() => _CameraDeviceTestPageState();
}

class _CameraDeviceTestPageState extends State<CameraDeviceTestPage> {
  TXDeviceManager? _deviceManager;
  int? _viewId;
  bool _isTesting = false;

  /// TRTCCloudVideoView 依赖 sharedInstance 初始化完成后才能正确读取 useTextureRender，
  /// 因此预览视图需等 _initialized 为 true 后才创建。
  bool _initialized = false;

  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final trtcCloud = await TRTCCloud.sharedInstance();
    _deviceManager = trtcCloud.getDeviceManager();
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  void dispose() {
    if (_isTesting) {
      _deviceManager?.stopCameraDeviceTest();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _startTest() {
    if (_viewId == null || _deviceManager == null) {
      _appendLog('预览尚未就绪，请稍候');
      return;
    }
    final code = _deviceManager!.startCameraDeviceTest(_viewId!);
    _appendLog('startCameraDeviceTest → code=$code');
    if (code == 0) {
      setState(() => _isTesting = true);
    }
  }

  void _stopTest() {
    _deviceManager?.stopCameraDeviceTest();
    _appendLog('stopCameraDeviceTest');
    setState(() => _isTesting = false);
  }

  void _appendLog(String msg) {
    final time = DateTime.now().toIso8601String().substring(11, 19);
    setState(() {
      _logs.add('[$time] $msg');
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Device Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 220,
                width: double.infinity,
                color: Colors.black,
                child: _initialized
                    ? TRTCCloudVideoView(
                        onViewCreated: (viewId) {
                          setState(() => _viewId = viewId);
                        },
                      )
                    : const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _startTest,
                    child: const Text('Start Test'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTesting ? _stopTest : null,
                    child: const Text('Stop Test'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Logs:'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Scrollbar(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(_logs[index], style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
