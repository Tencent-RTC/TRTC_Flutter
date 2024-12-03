import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
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
  late TRTCCloudListener listener;

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
            onViewCreated: (viewId) async {
              setState(() {
                trtcCloud.startRemoteView(remoteUidList[0], TRTCVideoStreamType.small, viewId);
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
                    onViewCreated: (viewId) async {
                      trtcCloud.startRemoteView(userId, TRTCVideoStreamType.small, viewId);
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
    params.role = TRTCRoleType.audience;
    params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
    trtcCloud.callExperimentalAPI("{\"api\": \"setFramework\", \"params\": {\"framework\": 7, \"component\": 2}}");
    trtcCloud.enterRoom(params, TRTCAppScene.live);
    listener = getListener();
    trtcCloud.registerListener(listener);
  }

  exitRoom() async {
    remoteUidSet.clear();
    trtcCloud.exitRoom();
    trtcCloud.unRegisterListener(listener);
    TRTCCloud.destroySharedInstance();
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
}
