import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';

class NetworkSpeedTestState {
  int sdkAppId;
  String userId;
  String userSig;
  int expectedUpBandwidth;
  int expectedDownBandwidth;
  TRTCSpeedTestScene scene;
  List<TRTCSpeedTestResult> results;
  bool testing;

  NetworkSpeedTestState({
    this.sdkAppId = 0,
    this.userId = '',
    this.userSig = '',
    this.expectedUpBandwidth = 0,
    this.expectedDownBandwidth = 0,
    this.scene = TRTCSpeedTestScene.delayAndBandwidthTesting,
    this.results = const [],
    this.testing = false,
  });

  NetworkSpeedTestState copyWith({
    int? sdkAppId,
    String? userId,
    String? userSig,
    int? expectedUpBandwidth,
    int? expectedDownBandwidth,
    TRTCSpeedTestScene? scene,
    List<TRTCSpeedTestResult>? results,
    bool? testing,
  }) {
    return NetworkSpeedTestState(
      sdkAppId: sdkAppId ?? this.sdkAppId,
      userId: userId ?? this.userId,
      userSig: userSig ?? this.userSig,
      expectedUpBandwidth: expectedUpBandwidth ?? this.expectedUpBandwidth,
      expectedDownBandwidth: expectedDownBandwidth ?? this.expectedDownBandwidth,
      scene: scene ?? this.scene,
      results: results ?? this.results,
      testing: testing ?? this.testing,
    );
  }
} 