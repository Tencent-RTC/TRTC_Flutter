import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///  VideoCallingPage.dart
///  TRTC-API-Example-Dart
class VideoCallingPage extends StatefulWidget {
  final int roomId;
  final String userId;
  const VideoCallingPage({Key? key, required this.roomId, required this.userId})
      : super(key: key);

  @override
  _VideoCallingPageState createState() => _VideoCallingPageState();
}

class _VideoCallingPageState extends State<VideoCallingPage> {
  Map<String, String> remoteUidSet = {};
  bool isFrontCamera = true;
  bool isOpenBeauty = true;
  int? localViewId;

  bool isMuteLocalAudio = false;
  bool isSpeaker = true;
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
    params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
    trtcCloud.callExperimentalAPI(
        "{\"api\": \"setFramework\", \"params\": {\"framework\": 7, \"component\": 2}}");
    trtcCloud.enterRoom(params, TRTCAppScene.videoCall);
    
    TRTCVideoEncParam encParams = new TRTCVideoEncParam();
    encParams.videoResolution = TRTCVideoResolution.res_640_360;
    encParams.videoBitrate = 550;
    encParams.videoFps = 15;
    trtcCloud.setVideoEncoderParam(encParams);

    trtcCloud.startLocalAudio(TRTCAudioQuality.speech);
    listener = getListener();
    trtcCloud.registerListener(listener);
  }
  
  TRTCCloudListener getListener() {
    return TRTCCloudListener(
      onRemoteUserLeaveRoom: (userId, reason) {
        onRemoteUserLeaveRoom(userId, reason);
      },
      onUserVideoAvailable: (userId, available) {
        onUserVideoAvailable(userId, available);
      }
    );
  }

  onRemoteUserLeaveRoom(String userId, int reason) {
    setState(() {
      if (remoteUidSet.containsKey(userId)) {
        remoteUidSet.remove(userId);
      }
    });
  }

  onUserVideoAvailable(String userId, bool available) {
    if (available) {
      setState(() {
        remoteUidSet[userId] = userId;
      });
    }
    if (!available && remoteUidSet.containsKey(userId)) {
      setState(() {
        remoteUidSet.remove(userId);
      });
    }
  }

  _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notice'),
          content: Text('New version not supported yet'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
            ),
          ],
        );
      },
    );
  }

  destroyRoom() {
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
    List<String> remoteUidList = remoteUidSet.values.toList();
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
          right: 15,
          top: 15,
          width: 72,
          height: 370,
          child: Container(
            child: GridView.builder(
              itemCount: remoteUidList.length,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 0.6,
              ),
              itemBuilder: (BuildContext context, int index) {
                String userId = remoteUidList[index];
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 72,
                    minWidth: 72,
                    maxHeight: 120,
                    minHeight: 120,
                  ),
                  child: TRTCCloudVideoView(
                    key: ValueKey('RemoteView_$userId'),
                    onViewCreated: (viewId) {
                      trtcCloud.startRemoteView(userId,
                          TRTCVideoStreamType.small, viewId);
                    },
                  ),
                );
              },
            ),
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
                      _showDialog();
                      // if (isOpenBeauty) {
                      //   trtcCloud.enableCustomVideoProcess(true);
                      // } else {
                      //   trtcCloud.enableCustomVideoProcess(false);
                      // }
                      // setState(() {
                      //   isOpenBeauty = !isOpenBeauty;
                      // });
                    },
                    child: Text(isOpenBeauty ? AppLocalizations.of(context)!.beauty_process_open : AppLocalizations.of(context)!.beauty_process_close),
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
                  SizedBox(
                    width: 30,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                    ),
                    onPressed: () {
                      TXDeviceManager deviceManager =
                          trtcCloud.getDeviceManager();
                      bool newIsSpeaker = !isSpeaker;
                      if (newIsSpeaker) {
                        deviceManager.setAudioRoute(
                            TXAudioRoute.speakerPhone);
                      } else {
                        deviceManager.setAudioRoute(
                            TXAudioRoute.earpiece);
                      }
                      setState(() {
                        isSpeaker = newIsSpeaker;
                      });
                    },
                    child: Text(isSpeaker ? AppLocalizations.of(context)!.use_speaker : AppLocalizations.of(context)!.use_receiver),
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
