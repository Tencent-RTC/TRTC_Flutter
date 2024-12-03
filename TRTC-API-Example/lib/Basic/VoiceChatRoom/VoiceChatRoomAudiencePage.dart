import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';

///  VoiceChatRoomAudiencePage.dart
///  TRTC-API-Example-Dart
class VoiceChatRoomAudiencePage extends StatefulWidget {
  final int roomId;
  final String userId;
  const VoiceChatRoomAudiencePage(
      {Key? key, required this.roomId, required this.userId})
      : super(key: key);

  @override
  _VoiceChatRoomAudiencePageState createState() =>
      _VoiceChatRoomAudiencePageState();
}

class _VoiceChatRoomAudiencePageState extends State<VoiceChatRoomAudiencePage> {
  late TRTCCloud trtcCloud;
  late TRTCCloudListener listener;
  Map<String, String> anchorUserIdSet = {};
  bool isAllUserMute = false;
  bool isUpMic = false;
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
    params.role = TRTCRoleType.audience;
    params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
    trtcCloud.callExperimentalAPI(
        "{\"api\": \"setFramework\", \"params\": {\"framework\": 7, \"component\": 2}}");
    trtcCloud.enterRoom(params, TRTCAppScene.voiceChatRoom);
    listener = getListener();
    trtcCloud.registerListener(listener);
  }

  TRTCCloudListener getListener() {
    return TRTCCloudListener(
      onUserAudioAvailable: (userId, available) {
        onUserAudioAvailable(userId, available);
      }
    );
  }

  onUserAudioAvailable(String userId, bool available) {
    if (available) {
      anchorUserIdSet[userId] = userId;
    } else {
      if (anchorUserIdSet.containsKey(userId)) anchorUserIdSet.remove(userId);
    }
  }

  // Mute
  onMuteClick() {
    bool nowAllUserMute = !isAllUserMute;
    anchorUserIdSet.forEach((key, value) {
      trtcCloud.muteRemoteAudio(key, nowAllUserMute);
    });
    setState(() {
      isAllUserMute = nowAllUserMute;
    });
  }

  // Take seat
  onUpMicClick() {
    bool nowIsUpMic = !isUpMic;
    if (nowIsUpMic) {
      trtcCloud.switchRole(TRTCRoleType.anchor);
      trtcCloud.startLocalAudio(TRTCAudioQuality.music);
    } else {
      trtcCloud.switchRole(TRTCRoleType.audience);
      trtcCloud.stopLocalAudio();
    }
    setState(() {
      isUpMic = nowIsUpMic;
    });
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        Container(),
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
                    'Audience operation',
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
                      this.onMuteClick();
                    },
                    child: Text(isAllUserMute ? 'Cancel mute' : 'Mute'),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                    ),
                    onPressed: () {
                      this.onUpMicClick();
                    },
                    child: Text(isUpMic ? 'Leave Seat' : 'Take Seat'),
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
