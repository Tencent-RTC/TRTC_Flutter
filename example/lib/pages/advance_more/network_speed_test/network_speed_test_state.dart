import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import '../../../debug/generate_test_user_sig.dart';

class NetworkSpeedTestState extends ChangeNotifier {
  final String userId;

  NetworkSpeedTestState({required this.userId});

  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;

  ValueNotifier<bool> isTesting = ValueNotifier(false);

  /// Configurable parameters
  TRTCSpeedTestScene scene = TRTCSpeedTestScene.delayAndBandwidthTesting;
  int expectedUpBandwidth = 1000;
  int expectedDownBandwidth = 1000;

  /// Latest result (for summary card) and full history.
  TRTCSpeedTestResult? lastResult;
  final List<TRTCSpeedTestResult> _results = [];
  List<TRTCSpeedTestResult> get results => List.unmodifiable(_results);

  Future<void> initialize() async {
    _trtcCloud = await TRTCCloud.sharedInstance();
    _listener = TRTCCloudListener(
      onSpeedTestResult: (result) {
        lastResult = result;
        _results.add(result);
        if (_results.length > 50) {
          _results.removeAt(0);
        }
        notifyListeners();
      },
    );
    _trtcCloud?.registerListener(_listener!);
    notifyListeners();
  }

  bool startSpeedTest() {
    if (_trtcCloud == null) return false;
    final params = TRTCSpeedTestParams(
      sdkAppId: GenerateTestUserSig.sdkAppId,
      userId: userId,
      userSig: GenerateTestUserSig.genTestSig(userId),
      expectedUpBandwidth: expectedUpBandwidth,
      expectedDownBandwidth: expectedDownBandwidth,
      scene: scene,
    );
    final ret = _trtcCloud!.startSpeedTest(params);
    if (ret == 0) {
      isTesting.value = true;
      _results.clear();
      lastResult = null;
      notifyListeners();
    }
    return ret == 0;
  }

  void stopSpeedTest() {
    _trtcCloud?.stopSpeedTest();
    isTesting.value = false;
    notifyListeners();
  }

  void setScene(TRTCSpeedTestScene value) {
    scene = value;
    notifyListeners();
  }

  void setUpBandwidth(int value) {
    expectedUpBandwidth = value.clamp(0, 5000);
    notifyListeners();
  }

  void setDownBandwidth(int value) {
    expectedDownBandwidth = value.clamp(0, 5000);
    notifyListeners();
  }

  void clearResults() {
    _results.clear();
    lastResult = null;
    notifyListeners();
  }

  @override
  void dispose() {
    if (isTesting.value) {
      _trtcCloud?.stopSpeedTest();
    }
    if (_listener != null) _trtcCloud?.unRegisterListener(_listener!);
    super.dispose();
  }
}
