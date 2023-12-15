import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PublishMediaStreamAudiencePage extends StatefulWidget {
  const PublishMediaStreamAudiencePage({Key? key}) : super(key: key);

  @override
  _PublishMediaStreamAudiencePageState createState() => _PublishMediaStreamAudiencePageState();
}

class _PublishMediaStreamAudiencePageState extends State<PublishMediaStreamAudiencePage> {
  int roomId = 0;
  String userId = '0';
  Map<String, String> remoteUidSet = {};
  bool isEnterRoom = false;
  late TRTCCloud trtcCloud;

  @override
  void initState() {
    super.initState();
  }


  @override
  dispose() {
    exitRoom();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> remoteUidList = remoteUidSet.values.toList();

    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        (remoteUidList.length > 0)
            ? Container(
          child: TRTCCloudVideoView(
            viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
            onViewCreated: (viewId) async {
              setState(() {
                trtcCloud.startRemoteView(remoteUidList[0], TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL, viewId);
              });
            },
          ),
        )
            : Container(),
        Positioned(
          right: 15,
          top: 15,
          width: 72,
          height: 370,
          child: (remoteUidList.length > 1)
              ? Container(
            child: GridView.builder(
              itemCount: remoteUidList.length - 1,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 0.6,
              ),
              itemBuilder: (BuildContext context, int index) {
                String userId = remoteUidList[index + 1];
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 72,
                    minWidth: 72,
                    maxHeight: 120,
                    minHeight: 120,
                  ),
                  child: TRTCCloudVideoView(
                    key: ValueKey('RemoteView_$userId'),
                    viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
                    onViewCreated: (viewId) async {
                      trtcCloud.startRemoteView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL, viewId);
                    },
                  ),
                );
              },
            ),
          )
              : Container(),
        ),
        Positioned(
          left: 30,
          height: 80,
          width: 500,
          bottom: 35,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: "Room ID",
                  ),
                  controller: TextEditingController.fromValue(
                    TextEditingValue(
                      text: this.roomId.toString(),
                      selection: TextSelection.fromPosition(
                        TextPosition(
                          affinity: TextAffinity.downstream,
                          offset: this.roomId.toString().length,
                        ),
                      ),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    roomId = int.parse(value);
                  },
                ),
              ),
              SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: "User ID",
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  controller: TextEditingController.fromValue(
                    TextEditingValue(
                      text: this.userId,
                      selection: TextSelection.fromPosition(
                        TextPosition(
                          affinity: TextAffinity.downstream,
                          offset: this.userId.length,
                        ),
                      ),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    userId = value;
                  },
                ),
              ),
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                  ),
                  onPressed: () {
                    onStartPushClick();
                  },
                  child: Text(
                      isEnterRoom ? AppLocalizations.of(context)!.stop_push : AppLocalizations.of(context)!.start_push),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  enterRoom() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    TRTCParams params = new TRTCParams();
    params.sdkAppId = GenerateTestUserSig.sdkAppId;
    params.roomId = this.roomId;
    params.userId = this.userId;
    params.role = TRTCCloudDef.TRTCRoleAudience;
    params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
    trtcCloud.callExperimentalAPI("{\"api\": \"setFramework\", \"params\": {\"framework\": 7, \"component\": 2}}");
    trtcCloud.enterRoom(params, TRTCCloudDef.TRTC_APP_SCENE_LIVE);
    trtcCloud.registerListener(onTrtcListener);
  }

  exitRoom() async {
    remoteUidSet.clear();
    await trtcCloud.exitRoom();
    trtcCloud.unRegisterListener(onTrtcListener);
    await TRTCCloud.destroySharedInstance();
  }

  onStartPushClick() {
    isEnterRoom = !isEnterRoom;
    if (isEnterRoom) {
      enterRoom();
    } else {
      exitRoom();
    }
    setState(() {});
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
        onRemoteUserLeaveRoom(params["userId"], params['reason']);
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
        break;
      case TRTCCloudListener.onScreenCapturePaused:
        break;
      case TRTCCloudListener.onScreenCaptureResumed:
        break;
      case TRTCCloudListener.onScreenCaptureStoped:
        break;
      case TRTCCloudListener.onDeviceChange:
        break;
      case TRTCCloudListener.onTestMicVolume:
        break;
      case TRTCCloudListener.onTestSpeakerVolume:
        break;
    }
  }
}
