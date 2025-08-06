import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:trtc_api_example/generated/l10n.dart';

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
  late TRTCCloudListener listener;

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
    params.role = TRTCRoleType.anchor;
    params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
    trtcCloud.callExperimentalAPI(
        "{\"api\": \"setFramework\", \"params\": {\"framework\": 7, \"component\": 2}}");
    trtcCloud.enterRoom(params, TRTCAppScene.audioCall);
    trtcCloud.startLocalAudio(TRTCAudioQuality.speech);
    TRTCAudioVolumeEvaluateParams evaluateParams = TRTCAudioVolumeEvaluateParams(
      enableVadDetection: true,
      enableSpectrumCalculation: true,
      interval: 1000,
    );
    trtcCloud.enableAudioVolumeEvaluation(true, evaluateParams);
    listener = getListener();
    trtcCloud.registerListener(listener);
  }

  TRTCCloudListener getListener() {
    return TRTCCloudListener(
      onRemoteUserEnterRoom: (userId) {
        onRemoteUserEnterRoom(userId);
      },
      onRemoteUserLeaveRoom: (userId, reason) {
        onRemoteUserLeaveRoom(userId, reason);
      },
      onUserVoiceVolume: (list, totalVolume) {
        onUserVoiceVolume(list);
      }
    );
  }

  destroyRoom() async {
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

  // Note that the simulator of this function in iOS is invalid
  onUserVoiceVolume(List<TRTCVolumeInfo> list) {
    list.forEach((item) {
      int volume = item.volume;
      if (item.userId != "") {
        String userId = item.userId;
        if (remoteInfoDictionary.containsKey(userId)) {
          setState(() {
            remoteInfoDictionary[userId]!.volume = volume;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> remoteUidList = remoteUidSet.values.toList();
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
                      child: Text(TRTCAPIExampleLocalizations.current.audiocall_voice_info),
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
                      child: Text(TRTCAPIExampleLocalizations.current.audiocall_net_info),
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
                      String quality = "unknown";
                      switch (remoteInfo.quality) {
                        case 1:
                          quality = "best";
                          break;
                        case 2:
                          quality = "good";
                          break;
                        case 3:
                          quality = "commonly";
                          break;
                        case 4:
                          quality = "bad";
                          break;
                        case 5:
                          quality = "very bad";
                          break;
                        case 6:
                          quality = "not available";
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
                        .setAudioRoute(TXAudioRoute.speakerPhone);
                  } else {
                    deviceManager
                        .setAudioRoute(TXAudioRoute.earpiece);
                  }
                  setState(() {
                    isSpeaker = newIsSpeaker;
                  });
                },
                child: Text(isSpeaker ? TRTCAPIExampleLocalizations.current.use_speaker : TRTCAPIExampleLocalizations.current.use_receiver),
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
                child: Text(isMuteLocalAudio ? TRTCAPIExampleLocalizations.current.open_audio : TRTCAPIExampleLocalizations.current.close_audio),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(TRTCAPIExampleLocalizations.current.audiocall_hang_up),
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
