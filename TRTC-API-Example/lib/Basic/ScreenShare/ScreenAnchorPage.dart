import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:replay_kit_launcher/replay_kit_launcher.dart';

///  ScreenAnchorPage.dart
///  TRTC-API-Example-Dart
enum ScreenStatus {
  ScreenStart,
  ScreenWait,
  ScreenStop,
}

class ScreenAnchorPage extends StatefulWidget {
  final int roomId;
  final String userId;
  const ScreenAnchorPage({Key? key, required this.roomId, required this.userId})
      : super(key: key);

  @override
  _ScreenAnchorPageState createState() => _ScreenAnchorPageState();
}

const iosExtensionName = 'TRTCFlutterAPIExampleScreenCapture';

class _ScreenAnchorPageState extends State<ScreenAnchorPage> {
  bool isMuteLocalAudio = false;
  ScreenStatus screenStatus = ScreenStatus.ScreenStop;
  Map<String, String> anchorUserIdSet = {};
  int? remoteViewId;
  late TRTCCloud trtcCloud;
  TRTCVideoEncParam encParams = TRTCVideoEncParam();
  @override
  void initState() {
    startPushStream();
    super.initState();
  }

  startPushStream() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    TRTCParams params = new TRTCParams();
    params.sdkAppId = GenerateTestUserSig.sdkAppId;
    params.roomId = this.widget.roomId;
    params.userId = this.widget.userId;
    params.role = TRTCCloudDef.TRTCRoleAnchor;
    params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
    trtcCloud.enterRoom(params, TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);
    trtcCloud.callExperimentalAPI(
        "{\"api\": \"setFramework\", \"params\": {\"framework\": 7, \"component\": 2}}");
    trtcCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC);
    trtcCloud.registerListener(onTrtcListener);
  }

  onTrtcListener(type, params) async {
    switch (type) {
      case TRTCCloudListener.onError:
        break;
      case TRTCCloudListener.onWarning:
        break;
      case TRTCCloudListener.onEnterRoom:
        break;
      case TRTCCloudListener.onExitRoom:
        break;
      case TRTCCloudListener.onSwitchRole:
        break;
      case TRTCCloudListener.onRemoteUserEnterRoom:
        break;
      case TRTCCloudListener.onRemoteUserLeaveRoom:
        break;
      case TRTCCloudListener.onConnectOtherRoom:
        break;
      case TRTCCloudListener.onDisConnectOtherRoom:
        break;
      case TRTCCloudListener.onSwitchRoom:
        break;
      case TRTCCloudListener.onUserVideoAvailable:
        onUserVideoAvailable(params["userId"], params['available']);
        break;
      case TRTCCloudListener.onUserSubStreamAvailable:
        break;
      case TRTCCloudListener.onUserAudioAvailable:
        break;
      case TRTCCloudListener.onFirstVideoFrame:
        break;
      case TRTCCloudListener.onFirstAudioFrame:
        break;
      case TRTCCloudListener.onSendFirstLocalVideoFrame:
        break;
      case TRTCCloudListener.onSendFirstLocalAudioFrame:
        break;
      case TRTCCloudListener.onNetworkQuality:
        break;
      case TRTCCloudListener.onStatistics:
        break;
      case TRTCCloudListener.onConnectionLost:
        break;
      case TRTCCloudListener.onTryToReconnect:
        break;
      case TRTCCloudListener.onConnectionRecovery:
        break;
      case TRTCCloudListener.onSpeedTest:
        break;
      case TRTCCloudListener.onCameraDidReady:
        break;
      case TRTCCloudListener.onMicDidReady:
        break;
      case TRTCCloudListener.onUserVoiceVolume:
        break;
      case TRTCCloudListener.onRecvCustomCmdMsg:
        break;
      case TRTCCloudListener.onMissCustomCmdMsg:
        break;
      case TRTCCloudListener.onRecvSEIMsg:
        break;
      case TRTCCloudListener.onStartPublishing:
        break;
      case TRTCCloudListener.onStopPublishing:
        break;
      case TRTCCloudListener.onStartPublishCDNStream:
        break;
      case TRTCCloudListener.onStopPublishCDNStream:
        break;
      case TRTCCloudListener.onSetMixTranscodingConfig:
        break;
      case TRTCCloudListener.onMusicObserverStart:
        break;
      case TRTCCloudListener.onMusicObserverPlayProgress:
        break;
      case TRTCCloudListener.onMusicObserverComplete:
        break;
      case TRTCCloudListener.onSnapshotComplete:
        break;
      case TRTCCloudListener.onScreenCaptureStarted:
        onScreenCaptureStarted();
        break;
      case TRTCCloudListener.onScreenCapturePaused:
        onScreenCapturePaused();
        break;
      case TRTCCloudListener.onScreenCaptureResumed:
        onScreenCaptureResumed();
        break;
      case TRTCCloudListener.onScreenCaptureStoped:
        onScreenCaptureStoped(params['reason']);
        break;
      case TRTCCloudListener.onDeviceChange:
        break;
      case TRTCCloudListener.onTestMicVolume:
        break;
      case TRTCCloudListener.onTestSpeakerVolume:
        break;
    }
  }

  onUserVideoAvailable(String userId, bool available) {
    if (available && remoteViewId != null) {
      trtcCloud.startRemoteView(
          userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, remoteViewId);
    }
    if (!available) {
      // 需要解决最后一帧
      trtcCloud.stopRemoteView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
    }
  }

  onScreenCaptureStarted() {
    setState(() {
      screenStatus = ScreenStatus.ScreenStart;
    });
  }

  onScreenCaptureStoped(int reason) {
    setState(() {
      screenStatus = ScreenStatus.ScreenStop;
    });
  }

  onScreenCaptureResumed() {
    setState(() {
      screenStatus = ScreenStatus.ScreenStart;
    });
  }

  onScreenCapturePaused() {
    setState(() {
      screenStatus = ScreenStatus.ScreenStop;
    });
  }

  destroyRoom() async {
    await trtcCloud.stopScreenCapture();
    await trtcCloud.stopLocalAudio();
    await trtcCloud.exitRoom();
    trtcCloud.unRegisterListener(onTrtcListener);
    await TRTCCloud.destroySharedInstance();
  }

  @override
  dispose() {
    destroyRoom();
    super.dispose();
  }

  onScreenCaptureClick() {
    switch (screenStatus) {
      case ScreenStatus.ScreenStart:
        setState(() {
          trtcCloud.stopScreenCapture();
          screenStatus = ScreenStatus.ScreenStop;
        });
        break;
      case ScreenStatus.ScreenStop:
        setState(() {
          encParams.videoResolution =
              TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720;
          encParams.videoBitrate = 550;
          encParams.videoFps = 10;
          if (!kIsWeb && Platform.isIOS) {
            trtcCloud.startScreenCapture(
                TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB, encParams,
                appGroup: iosExtensionName);
            //屏幕分享功能只能在真机测试
            ReplayKitLauncher.launchReplayKitBroadcast(iosExtensionName);
          } else {
            trtcCloud.startScreenCapture(
                TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB, encParams);
          }
          screenStatus = ScreenStatus.ScreenWait;
        });
        break;
      case ScreenStatus.ScreenWait:
        if (!kIsWeb && Platform.isIOS) {
          //屏幕分享功能只能在真机测试
          ReplayKitLauncher.launchReplayKitBroadcast(iosExtensionName);
        }
        break;
    }
  }

  onMicCaptureClick() {
    bool isNowMuteLocalAudio = !isMuteLocalAudio;
    trtcCloud.muteLocalAudio(isNowMuteLocalAudio);
    setState(() {
      isMuteLocalAudio = isNowMuteLocalAudio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 30,
          height: 300,
          right: 30,
          top: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(0),
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '房间号：${this.widget.roomId}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            '用户ID：${this.widget.userId}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            '分辨率：1280 * 720',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            '请在其他设备上使用观众身份进入相同的房间进行观看',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(screenStatus == ScreenStatus.ScreenStop
                      ? ''
                      : screenStatus == ScreenStatus.ScreenWait
                          ? '等待你的屏幕分享操作'
                          : screenStatus == ScreenStatus.ScreenStart
                              ? "您在分享屏幕"
                              : "未知状态")
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(left: 40, right: 40),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green),
                        ),
                        onPressed: () {
                          onScreenCaptureClick();
                        },
                        child: Text(screenStatus == ScreenStatus.ScreenStop
                            ? '开始屏幕分享'
                            : screenStatus == ScreenStatus.ScreenWait
                                ? '等待屏幕分享'
                                : screenStatus == ScreenStatus.ScreenStart
                                    ? "停止屏幕分享"
                                    : "未知状态"),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 10,
          right: 10,
          height: 40,
          bottom: 30,
          child: Center(
            child: SizedBox(
              width: 110,
              height: 30,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
                onPressed: () {
                  onMicCaptureClick();
                },
                child: Text(isMuteLocalAudio ? '打开麦克风' : '关闭麦克风'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
