import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';

///  ScreenAudiencePage.dart
///  TRTC-API-Example-Dart
class ScreenAudiencePage extends StatefulWidget {
  final int roomId;
  final String userId;
  const ScreenAudiencePage(
      {Key? key, required this.roomId, required this.userId})
      : super(key: key);

  @override
  _ScreenAudiencePageState createState() => _ScreenAudiencePageState();
}

class _ScreenAudiencePageState extends State<ScreenAudiencePage> {
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
    trtcCloud.enterRoom(params, TRTCAppScene.videoCall);
    trtcCloud.startLocalAudio(TRTCAudioQuality.music);
    listener = getListener();
    trtcCloud.registerListener(listener);
  }

  TRTCCloudListener getListener() {
    return TRTCCloudListener(
      onUserSubStreamAvailable: (userId, available) {
        onUserSubAvailable(userId, available);
      }
    );
  }

  onUserSubAvailable(String userId, bool available) {
    if (available && remoteViewId != null) {
      trtcCloud.startRemoteView(
          userId, TRTCVideoStreamType.sub, remoteViewId!);
    }
    if (!available) {
      trtcCloud.stopRemoteView(userId, TRTCVideoStreamType.sub);
    }
  }

  destroyRoom() async {
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
      ],
    );
  }
}
