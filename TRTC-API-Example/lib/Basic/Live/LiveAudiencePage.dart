import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:trtc_api_example/generated/l10n.dart';

///  LiveAudiencePage.dart
///  TRTC-API-Example-Dart
class LiveAudiencePage extends StatefulWidget {
  final int roomId;
  final String userId;
  const LiveAudiencePage({Key? key, required this.roomId, required this.userId})
      : super(key: key);

  @override
  _LiveAudiencePageState createState() => _LiveAudiencePageState();
}

class _LiveAudiencePageState extends State<LiveAudiencePage> {
  bool isMuteAudio = false;
  Map<String, String> anchorUserIdSet = {};
  int? remoteViewId;
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
    params.role = TRTCRoleType.audience;
    params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
    trtcCloud.callExperimentalAPI(
        "{\"api\": \"setFramework\", \"params\": {\"framework\": 7, \"component\": 2}}");
    trtcCloud.enterRoom(params, TRTCAppScene.live);
    listener = getListener();
    trtcCloud.registerListener(listener);
  }

  TRTCCloudListener getListener() {
    return TRTCCloudListener(
      onUserVideoAvailable: (userId, available) {
        onUserVideoAvailable(userId, available);
      },
      onUserAudioAvailable: (userId, available) {
        onUserAudioAvailable(userId, available);
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

  onUserAudioAvailable(String userId, bool available) {
    if (available) {
      anchorUserIdSet[userId] = userId;
    } else {
      if (anchorUserIdSet.containsKey(userId)) anchorUserIdSet.remove(userId);
    }
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
        Container(
          child: TRTCCloudVideoView(
            key: ValueKey("remoteViewId"),
            onViewCreated: (viewId) async {
              setState(() {
                remoteViewId = viewId;
              });
            },
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
                    TRTCAPIExampleLocalizations.current.live_operator,
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
                      bool newIsMuteAudio = !isMuteAudio;
                      anchorUserIdSet.forEach((key, value) {
                        trtcCloud.muteRemoteAudio(key, newIsMuteAudio);
                      });
                      setState(() {
                        isMuteAudio = newIsMuteAudio;
                      });
                    },
                    child: Text(isMuteAudio ? TRTCAPIExampleLocalizations.current.unmute_audio : TRTCAPIExampleLocalizations.current.mute_audio),
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
