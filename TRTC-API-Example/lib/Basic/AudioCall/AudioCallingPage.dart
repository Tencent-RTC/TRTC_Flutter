import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:tencent_trtc_cloud/tx_device_manager.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';

///  AudioCallingPage.dart
///  TRTC-API-Example-Dart
class CustomRemoteInfo {
  int volume = 0;
  int quality = 0;
  final String userId;
  CustomRemoteInfo(this.userId, {this.volume = 0, this.quality = 0});
}

class AudioCallingPage extends StatefulWidget {
  final int roomId;
  final String userId;
  const AudioCallingPage({Key? key, required this.roomId, required this.userId})
      : super(key: key);

  @override
  _AudioCallingPageState createState() => _AudioCallingPageState();
}

class _AudioCallingPageState extends State<AudioCallingPage> {
  Map<String, CustomRemoteInfo> remoteInfoDictionary = {};
  Map<String, String> remoteUidSet = {};
  bool isSpeaker = true;
  bool isMuteLocalAudio = false;
  late TRTCCloud trtcCloud;

  @override
  void initState() {
    super.initState();
    startPushStream();
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
    trtcCloud.enterRoom(params, TRTCCloudDef.TRTC_APP_SCENE_AUDIOCALL);
    trtcCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH);
    trtcCloud.enableAudioVolumeEvaluation(1000);

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
        onRemoteUserEnterRoom(params);
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
        onNetworkQuality(params);
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
        onUserVoiceVolume(params);
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

  destroyRoom() async {
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

  onRemoteUserEnterRoom(String userId) {
    setState(() {
      remoteUidSet[userId] = userId;
      remoteInfoDictionary[userId] = CustomRemoteInfo(userId);
    });
  }

  onRemoteUserLeaveRoom(String userId, int reason) {
    setState(() {
      if (remoteUidSet.containsKey(userId)) {
        setState(() {
          remoteUidSet.remove(userId);
        });
      }
      if (remoteInfoDictionary.containsKey(userId)) {
        setState(() {
          remoteInfoDictionary.remove(userId);
        });
      }
    });
  }

  onNetworkQuality(params) {
    List<dynamic> list = params["remoteQuality"] as List<dynamic>;
    list.forEach((item) {
      int quality = int.tryParse(item["quality"].toString())!;
      if (item['userId'] != null && item['userId'] != "") {
        String userId = item['userId'];
        if (remoteInfoDictionary.containsKey(userId)) {
          setState(() {
            remoteInfoDictionary[userId]!.quality = quality;
          });
        }
      }
    });
  }

  // 注意，该功能在ios的模拟器是无效的
  onUserVoiceVolume(params) {
    List<dynamic> list = params["userVolumes"] as List<dynamic>;
    list.forEach((item) {
      int volme = int.tryParse(item["volume"].toString())!;
      if (item['userId'] != null && item['userId'] != "") {
        String userId = item['userId'];
        if (remoteInfoDictionary.containsKey(userId)) {
          setState(() {
            remoteInfoDictionary[userId]!.volume = volme;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> remoteUidList = remoteUidSet.values.toList();
    print("=remoteUidList=" + remoteUidList.toString());
    List<CustomRemoteInfo> remoteInfoList =
        remoteInfoDictionary.values.toList();
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.all(30),
            child: GridView.builder(
              itemCount: remoteUidList.length,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (BuildContext context, int index) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 120,
                    minWidth: 120,
                    maxHeight: 120,
                    minHeight: 120,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.asset(
                              "assets/images/avatar/2.jpeg",
                              height: 80,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Text(remoteUidList[index],
                                style: TextStyle(fontSize: 12.0)),
                          )
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 0,
          child: Container(
            color: Colors.white24,
            height: 300,
            width: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '信息面板',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text('音量信息'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: remoteInfoList.length,
                    cacheExtent: 0,
                    itemBuilder: (BuildContext context, int index) {
                      CustomRemoteInfo remoteInfo = remoteInfoList[index];
                      return Text('${remoteInfo.userId}:${remoteInfo.volume}');
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text('网络信息'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: remoteInfoList.length,
                    cacheExtent: 0,
                    itemBuilder: (BuildContext context, int index) {
                      CustomRemoteInfo remoteInfo = remoteInfoList[index];
                      String quality = "未知";
                      switch (remoteInfo.quality) {
                        case 1:
                          quality = "最好";
                          break;
                        case 2:
                          quality = "好";
                          break;
                        case 3:
                          quality = "一般";
                          break;
                        case 4:
                          quality = "差";
                          break;
                        case 5:
                          quality = "很差";
                          break;
                        case 6:
                          quality = "不可用";
                          break;
                      }
                      return Text('${remoteInfo.userId}:$quality');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 45,
        ),
        Expanded(
          flex: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
                onPressed: () {
                  TXDeviceManager deviceManager = trtcCloud.getDeviceManager();
                  bool newIsSpeaker = !isSpeaker;
                  if (newIsSpeaker) {
                    deviceManager
                        .setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
                  } else {
                    deviceManager
                        .setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE);
                  }
                  setState(() {
                    isSpeaker = newIsSpeaker;
                  });
                },
                child: Text(isSpeaker ? "使用扬声器" : "使用听筒"),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
                onPressed: () {
                  bool newIsMuteLocalAudio = !isMuteLocalAudio;
                  if (newIsMuteLocalAudio) {
                    trtcCloud.muteLocalAudio(true);
                  } else {
                    trtcCloud.muteLocalAudio(false);
                  }
                  setState(() {
                    isMuteLocalAudio = newIsMuteLocalAudio;
                  });
                },
                child: Text(isMuteLocalAudio ? "打开麦克风" : "关闭麦克风"),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("挂断"),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
