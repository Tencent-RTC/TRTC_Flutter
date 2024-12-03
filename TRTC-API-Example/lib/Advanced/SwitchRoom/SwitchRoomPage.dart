import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:trtc_api_example/Common/TXHelper.dart';
import 'package:trtc_api_example/Common/TXUpdateEvent.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///  SwitchRoomPage.dart
///  TRTC-API-Example-Dart
class SwitchRoomPage extends StatefulWidget {
  const SwitchRoomPage({Key? key}) : super(key: key);

  @override
  _SwitchRoomPageState createState() => _SwitchRoomPageState();
}

class _SwitchRoomPageState extends State<SwitchRoomPage> {
  late TRTCCloud trtcCloud;
  late TRTCCloudListener listener;
  int? localViewId;
  bool isStartPush = false;
  int roomId = int.parse(TXHelper.generateRandomStrRoomId());
  int? lastEnterRoomId;
  String userId = TXHelper.generateRandomUserId();
  Map<String, String> remoteUidSet = {};
  @override
  void initState() {
    initTRTCCloud();
    super.initState();
    eventBus.fire(TitleUpdateEvent('Room ID: $roomId'));
  }

  initTRTCCloud() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
  }

  startPushStream() async {
    trtcCloud.startLocalPreview(true, localViewId!);
    TRTCParams params = new TRTCParams();
    params.sdkAppId = GenerateTestUserSig.sdkAppId;
    params.roomId = this.roomId;
    params.userId = this.userId;
    params.role = TRTCRoleType.anchor;
    params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
    trtcCloud.enterRoom(params, TRTCAppScene.live);

    TRTCVideoEncParam encParams = new TRTCVideoEncParam();
    encParams.videoResolution = TRTCVideoResolution.res_960_540;
    // In TRTCVIDEORESOLUTION, only the horizontal screen resolution (such as 640 × 360) is defined. If you need to use a vertical screen resolution (such as 360 × 640), you need to specify the TRTCVIDEORESOLUTIONMODE to be Portrait.
    encParams.videoResolutionMode = TRTCVideoResolutionMode.portrait;
    encParams.videoFps = 24;
    trtcCloud.setVideoEncoderParam(encParams);
    trtcCloud.startLocalAudio(TRTCAudioQuality.music);
    listener = getListener();
    trtcCloud.registerListener(listener);
    lastEnterRoomId = this.roomId;
  }

  TRTCCloudListener getListener() {
    return TRTCCloudListener(
      onUserVideoAvailable: (userId, available) {
        onUserVideoAvailable(userId, available);
      }
    );
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

  destroyRoom() async {
    trtcCloud.stopLocalAudio();
    trtcCloud.stopLocalPreview();
    trtcCloud.exitRoom();
    TRTCCloud.destroySharedInstance();
  }

  @override
  dispose() {
    destroyRoom();
    super.dispose();
  }

  onPushStreamClick() {
    bool newIsStartPush = !isStartPush;
    isStartPush = newIsStartPush;
    if (isStartPush) {
      startPushStream();
    } else {
      remoteUidSet.clear();
      trtcCloud.unRegisterListener(listener);
      trtcCloud.stopLocalAudio();
      trtcCloud.stopLocalPreview();
      trtcCloud.exitRoom();
    }
    setState(() {});
  }

  onChangeRoomClick() async {
    String userSig = await GenerateTestUserSig.genTestSig(this.userId);
    TRTCSwitchRoomConfig config = new TRTCSwitchRoomConfig(
      userSig: userSig,
      roomId: roomId,
    );

    eventBus.fire(TitleUpdateEvent('Room ID: $roomId'));
    trtcCloud.switchRoom(config);
    setState(() {
      lastEnterRoomId = roomId;
      remoteUidSet.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> remoteUidList = remoteUidSet.values.toList();
    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {},
          child: TRTCCloudVideoView(
            key: ValueKey("LocalView"),
            onViewCreated: (viewId) async {
              setState(() {
                localViewId = viewId;
              });
            },
          ),
        ),
        Positioned(
          left: 10,
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
                  child: Stack(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TRTCCloudVideoView(
                          key: ValueKey('RemoteView_$userId'),
                          onViewCreated: (viewId) async {
                            trtcCloud.startRemoteView(
                                userId,
                                TRTCVideoStreamType.small,
                                viewId);
                          },
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Text(
                          userId,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          left: 0,
          height: 70,
          bottom: 15,
          child: Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          setState(() {
                            roomId = int.parse(value);
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: isStartPush &&
                                  lastEnterRoomId != null &&
                                  lastEnterRoomId != roomId
                              ? MaterialStateProperty.all(Colors.green)
                              : MaterialStateProperty.all(Colors.grey),
                        ),
                        onPressed: () {
                          if (isStartPush &&
                              lastEnterRoomId != null &&
                              lastEnterRoomId != roomId) {
                            onChangeRoomClick();
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.switchroom_switch_room),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green),
                        ),
                        onPressed: () {
                          onPushStreamClick();
                        },
                        child: Text(isStartPush ? AppLocalizations.of(context)!.stop_push : AppLocalizations.of(context)!.start_push),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
