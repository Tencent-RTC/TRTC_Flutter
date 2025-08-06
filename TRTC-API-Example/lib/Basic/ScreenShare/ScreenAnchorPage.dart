import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:replay_kit_launcher/replay_kit_launcher.dart';
import 'package:trtc_api_example/generated/l10n.dart';

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
  late TRTCCloudListener listener;
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
    params.role = TRTCRoleType.anchor;
    params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
    trtcCloud.callExperimentalAPI(
        "{\"api\": \"setFramework\", \"params\": {\"framework\": 7, \"component\": 2}}");
    trtcCloud.enterRoom(params, TRTCAppScene.videoCall);

    trtcCloud.startLocalAudio(TRTCAudioQuality.music);
    listener = getListener();
    trtcCloud.registerListener(listener);
  }
  
  TRTCCloudListener getListener() {
    return TRTCCloudListener(
      onUserVideoAvailable: (userId, available) {
        onUserVideoAvailable(userId, available);
      },
      onScreenCaptureStarted: () {
        onScreenCaptureStarted();
      },
      onScreenCapturePaused: (reason) {
        onScreenCapturePaused();
      },
      onScreenCaptureResumed: (reason) {
        onScreenCaptureResumed();
      },
      onScreenCaptureStopped: (reason) {
        onScreenCaptureStoped(reason);
      }
    );
  }

  onUserVideoAvailable(String userId, bool available) {
    if (available && remoteViewId != null) {
      trtcCloud.startRemoteView(
          userId, TRTCVideoStreamType.big, remoteViewId!);
    }
    if (!available) {
      trtcCloud.stopRemoteView(userId, TRTCVideoStreamType.big);
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
    trtcCloud.stopScreenCapture();
    trtcCloud.stopLocalAudio();
    trtcCloud.exitRoom();
    trtcCloud.unRegisterListener(listener);
    TRTCCloud.destroySharedInstance();
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
              TRTCVideoResolution.res_1280_720;
          encParams.videoBitrate = 550;
          encParams.videoFps = 10;
          if (!kIsWeb && Platform.isIOS) {
            trtcCloud.startScreenCapture(0,
                TRTCVideoStreamType.sub, encParams,);
            //The screen sharing function can only be tested in the real machine
            ReplayKitLauncher.launchReplayKitBroadcast(iosExtensionName);
          } else {
            trtcCloud.startScreenCapture(0,
                TRTCVideoStreamType.sub, encParams);
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
                            TRTCAPIExampleLocalizations.current
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
                          ? TRTCAPIExampleLocalizations.current.screenshare_wait_tips
                          : screenStatus == ScreenStatus.ScreenStart
                              ? TRTCAPIExampleLocalizations.current
                                  .screenshare_ing_tips
                              : TRTCAPIExampleLocalizations.current
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
                            ? TRTCAPIExampleLocalizations.current.screenshare_start
                            : screenStatus == ScreenStatus.ScreenWait
                                ? TRTCAPIExampleLocalizations.current.screenshare_wait
                                : screenStatus == ScreenStatus.ScreenStart
                                    ? TRTCAPIExampleLocalizations.current
                                        .screenshare_stop
                                    : TRTCAPIExampleLocalizations.current
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
                    ? TRTCAPIExampleLocalizations.current.open_audio
                    : TRTCAPIExampleLocalizations.current.close_audio),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
