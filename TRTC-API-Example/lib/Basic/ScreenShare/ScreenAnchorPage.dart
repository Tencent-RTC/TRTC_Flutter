import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:replay_kit_launcher/replay_kit_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    trtcCloud.callExperimentalAPI(
        "{\"api\": \"setFramework\", \"params\": {\"framework\": 7, \"component\": 2}}");
    trtcCloud.enterRoom(params, TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);

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
            //The screen sharing function can only be tested in the real machine
            ReplayKitLauncher.launchReplayKitBroadcast(iosExtensionName);
          } else {
            trtcCloud.startScreenCapture(
                TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB, encParams);
          }
          screenStatus = ScreenStatus.ScreenWait;
        });
        break;
      case ScreenStatus.ScreenWait:
        if (Platform.isIOS) {
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
                            'Room ID：${this.widget.roomId}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'User ID：${this.widget.userId}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Resolution ratio：1280 * 720',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            AppLocalizations.of(context)!
                                .screenshare_watch_tips,
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
                          ? AppLocalizations.of(context)!.screenshare_wait_tips
                          : screenStatus == ScreenStatus.ScreenStart
                              ? AppLocalizations.of(context)!
                                  .screenshare_ing_tips
                              : AppLocalizations.of(context)!
                                  .screenshare_unknow_tips)
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
                            ? AppLocalizations.of(context)!.screenshare_start
                            : screenStatus == ScreenStatus.ScreenWait
                                ? AppLocalizations.of(context)!.screenshare_wait
                                : screenStatus == ScreenStatus.ScreenStart
                                    ? AppLocalizations.of(context)!
                                        .screenshare_stop
                                    : AppLocalizations.of(context)!
                                        .screenshare_unknow_tips),
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
                child: Text(isMuteLocalAudio
                    ? AppLocalizations.of(context)!.open_audio
                    : AppLocalizations.of(context)!.close_audio),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
