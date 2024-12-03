import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///  LiveAnchorPage.dart
///  TRTC-API-Example-Dart
class LiveAnchorPage extends StatefulWidget {
  final int roomId;
  final String userId;
  const LiveAnchorPage({Key? key, required this.roomId, required this.userId})
      : super(key: key);

  @override
  _LiveAnchorPageState createState() => _LiveAnchorPageState();
}

class _LiveAnchorPageState extends State<LiveAnchorPage> {
  bool isFrontCamera = true;
  bool isOpenCamera = true;
  int? localViewId;

  bool isMuteLocalAudio = false;
  late TRTCCloud trtcCloud;
  late TRTCCloudListener listener;

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
    trtcCloud.enterRoom(params, TRTCAppScene.live);
    
    TRTCVideoEncParam encParams = new TRTCVideoEncParam();
    encParams.videoResolution = TRTCVideoResolution.res_960_540;
    encParams.videoFps = 24;
    // In TRTCVIDEORESOLUTION, only the horizontal screen resolution (such as 640 × 360) is defined. If you need to use a vertical screen resolution (such as 360 × 640), you need to specify the TRTCVIDEORESOLUTIONMODE to be Portrait.
    encParams.videoResolutionMode = TRTCVideoResolutionMode.portrait;
    trtcCloud.setVideoEncoderParam(encParams);

    trtcCloud.startLocalAudio(TRTCAudioQuality.music);
    listener = getListener();
    trtcCloud.registerListener(listener);
  }

  TRTCCloudListener getListener() {
    return TRTCCloudListener();
  }

  destroyRoom() async {
    trtcCloud.stopLocalAudio();
    trtcCloud.stopLocalPreview();
    trtcCloud.exitRoom();
    trtcCloud.unRegisterListener(listener);
    TRTCCloud.destroySharedInstance();
  }

  @override
  dispose() {
    destroyRoom();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        Container(
          child: TRTCCloudVideoView(
            key: ValueKey("LocalView"),
            onViewCreated: (viewId) async {
              setState(() {
                localViewId = viewId;
              });
              trtcCloud.startLocalPreview(isFrontCamera, viewId);
            },
          ),
        ),
        Positioned(
          left: 30,
          height: 80,
          bottom: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.videocall_video_item,
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                    ),
                    onPressed: () {
                      bool newIsFrontCamera = !isFrontCamera;
                      TXDeviceManager deviceManager =
                          trtcCloud.getDeviceManager();
                      deviceManager.switchCamera(newIsFrontCamera);
                      setState(() {
                        isFrontCamera = newIsFrontCamera;
                      });
                    },
                    child: Text(isFrontCamera ? AppLocalizations.of(context)!.videocall_user_back_camera : AppLocalizations.of(context)!.videocall_user_front_camera),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                    ),
                    onPressed: () {
                      bool newIsOpenCamera = !isOpenCamera;
                      if (newIsOpenCamera) {
                        trtcCloud.startLocalPreview(isFrontCamera, localViewId!);
                      } else {
                        trtcCloud.stopLocalPreview();
                      }
                      setState(() {
                        isOpenCamera = newIsOpenCamera;
                      });
                    },
                    child: Text(isOpenCamera ? AppLocalizations.of(context)!.videocall_close_camera : AppLocalizations.of(context)!.videocall_open_camera),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 30,
          height: 80,
          width: 500,
          bottom: 35,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.videocall_audio_item,
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                    ),
                    onPressed: () {
                      bool newIsMuteLocalAudio = !isMuteLocalAudio;
                      trtcCloud.muteLocalAudio(newIsMuteLocalAudio);
                      setState(() {
                        isMuteLocalAudio = newIsMuteLocalAudio;
                      });
                    },
                    child: Text(isMuteLocalAudio ? AppLocalizations.of(context)!.open_audio : AppLocalizations.of(context)!.close_audio),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
