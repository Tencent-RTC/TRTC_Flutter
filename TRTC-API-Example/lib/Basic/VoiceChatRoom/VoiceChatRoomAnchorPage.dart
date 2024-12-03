import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///  VoiceChatRoomAnchorPage.dart
///  TRTC-API-Example-Dart
class VoiceChatRoomAnchorPage extends StatefulWidget {
  final int roomId;
  final String userId;
  const VoiceChatRoomAnchorPage(
      {Key? key, required this.roomId, required this.userId})
      : super(key: key);

  @override
  _VoiceChatRoomAnchorPageState createState() =>
      _VoiceChatRoomAnchorPageState();
}

class _VoiceChatRoomAnchorPageState extends State<VoiceChatRoomAnchorPage> {
  late TRTCCloud trtcCloud;
  late TRTCCloudListener listener;
  Map<String, String> anchorUserIdSet = {};
  bool isAllUserMute = false;
  bool isDownMic = false;
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
    trtcCloud.enterRoom(params, TRTCAppScene.voiceChatRoom);
    trtcCloud.startLocalAudio(TRTCAudioQuality.music);

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

  // Leave seat
  onDownMicClick() {
    bool nowIsDownMic = !isDownMic;
    if (nowIsDownMic) {
      trtcCloud.switchRole(TRTCRoleType.audience);
      trtcCloud.stopLocalAudio();
    } else {
      trtcCloud.switchRole(TRTCRoleType.anchor);
      trtcCloud.startLocalAudio(TRTCAudioQuality.music);
    }
    setState(() {
      isDownMic = nowIsDownMic;
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
                    AppLocalizations.of(context)!.voicechatroom_anchor_operator,
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
                    child: Text(isAllUserMute ? AppLocalizations.of(context)!.unmute_audio : AppLocalizations.of(context)!.mute_audio),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                    ),
                    onPressed: () {
                      this.onDownMicClick();
                    },
                    child: Text(isDownMic ? AppLocalizations.of(context)!.voicechatroom_up_mic : AppLocalizations.of(context)!.voicechatroom_down_mic)
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
