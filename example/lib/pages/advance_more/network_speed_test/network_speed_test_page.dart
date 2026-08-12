import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';

class NetworkSpeedTestPage extends StatefulWidget {
  final String roomId;
  final String userId;

  const NetworkSpeedTestPage({
    Key? key,
    required this.roomId,
    required this.userId,
  }) : super(key: key);

  @override
  State<NetworkSpeedTestPage> createState() => _NetworkSpeedTestPageState();
}

class _NetworkSpeedTestPageState extends State<NetworkSpeedTestPage> {
  late TRTCCloud _trtcCloud;
  bool _testing = false;
  final List<String> _resultLogs = [];
  final ScrollController _scrollController = ScrollController();
  late final TRTCCloudListener _listener;

  @override
  void initState() {
    super.initState();
    _initTRTC();
  }

  Future<void> _initTRTC() async {
    _trtcCloud = await TRTCCloud.sharedInstance();
    _listener = TRTCCloudListener(
      onSpeedTestResult: (result) {
        final log = _formatResult(result);
        setState(() {
          _resultLogs.add(log);
        });
        _scrollToBottom();
      },
    );
    _trtcCloud.registerListener(_listener);
  }

  @override
  void dispose() {
    _trtcCloud.unRegisterListener(_listener);
    _scrollController.dispose();
    super.dispose();
  }

  void _startSpeedTest() {
    final params = TRTCSpeedTestParams(
      sdkAppId: GenerateTestUserSig.sdkAppId,
      userId: widget.userId,
      userSig: GenerateTestUserSig.genTestSig(widget.userId),
      expectedUpBandwidth: 1000,
      expectedDownBandwidth: 1000,
      scene: TRTCSpeedTestScene.delayAndBandwidthTesting,
    );
    final ret = _trtcCloud.startSpeedTest(params);
    setState(() {
      _testing = true;
      _resultLogs.clear();
    });
    Fluttertoast.showToast(msg: 'Speed test started: ret=$ret');
  }

  void _stopSpeedTest() {
    _trtcCloud.stopSpeedTest();
    setState(() {
      _testing = false;
    });
    Fluttertoast.showToast(msg: 'Speed test stopped');
  }

  String _formatResult(TRTCSpeedTestResult result) {
    return '[${DateTime.now().toIso8601String()}] '
        'Success: ${result.success}, '
        'Error: ${result.errMsg}, '
        'IP: ${result.ip}, '
        'Quality: ${result.quality}, '
        'UpLostRate: ${result.upLostRate}, DownLostRate: ${result.downLostRate}, '
        'RTT: ${result.rtt}, UpBW: ${result.availableUpBandwidth}, DownBW: ${result.availableDownBandwidth}, '
        'UpJitter: ${result.upJitter}, DownJitter: ${result.downJitter}';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network Speed Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testing ? null : _startSpeedTest,
                    child: const Text('Start Speed Test'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testing ? _stopSpeedTest : null,
                    child: const Text('Stop Speed Test'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Speed Test Results (Real-time):'),
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
                    itemCount: _resultLogs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        child: Text(_resultLogs[index], style: const TextStyle(fontSize: 12)),
                      );
                    },
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