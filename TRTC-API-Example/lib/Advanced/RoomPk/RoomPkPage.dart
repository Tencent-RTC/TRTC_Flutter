import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:trtc_api_example/Common/TXHelper.dart';
import 'package:trtc_api_example/Common/TXUpdateEvent.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:trtc_api_example/generated/l10n.dart';

///  RoomPkPage.dart
///  TRTC-API-Example-Dart
class RoomPkPage extends StatefulWidget {
  const RoomPkPage({Key? key}) : super(key: key);

  @override
  _RoomPkPageState createState() => _RoomPkPageState();
}

class _RoomPkPageState extends State<RoomPkPage> {
  late TRTCCloud trtcCloud;
  late TRTCCloudListener listener;
  int? localViewId;
  bool isStartPush = false;
  bool isStartPK = false;
  int roomId = int.parse(TXHelper.generateRandomStrRoomId());
  String userId = TXHelper.generateRandomUserId();
  int? otherRoomId;
  String otherUserId = "";
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
    encParams.videoResolution = TRTCVideoResolution.res_1280_720;
    encParams.videoBitrate = 1500;
    encParams.videoFps = 24;
    trtcCloud.setVideoEncoderParam(encParams);
    trtcCloud.startLocalAudio(TRTCAudioQuality.defaultMode);
    listener = getListener();
    trtcCloud.registerListener(listener);
    eventBus.fire(TitleUpdateEvent('Room ID: $roomId'));
  }

  TRTCCloudListener getListener() {
    return TRTCCloudListener(
      onConnectOtherRoom: (userId, errCode, errMsg) {
        onConnectOtherRoom(userId, errCode, errMsg);
      },
      onUserVideoAvailable: (userId, available) {
        onUserVideoAvailable(userId, available);
      },
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

  onConnectOtherRoom(String userId, int errCode, String errMsg) {
    if (errCode != 0) {
      showToast(errMsg);
      setState(() {
        isStartPK = false;
      });
    } else {
      setState(() {
        isStartPK = true;
      });
    }
  }

  destroyRoom() {
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

  onStartPkClick() {
    if (otherRoomId == null || otherUserId == "") {
      showToast('Please enter the PK room and user ID information', dismissOtherToast: true);
      return;
    }
    bool newIsStartPK = !isStartPK;
    if (newIsStartPK) {
      Map jsonDict = new Map();
      jsonDict['roomId'] = otherRoomId;
      jsonDict['userId'] = otherUserId;
      trtcCloud.connectOtherRoom(jsonEncode(jsonDict));
    } else {
      trtcCloud.disconnectOtherRoom();
    }
    setState(() {
      isStartPK = newIsStartPK;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.only(top: 30),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 220,
                  width: 150,
                  child: Container(
                    color: Colors.grey,
                    child: TRTCCloudVideoView(
                      key: ValueKey("LocalView"),
                      onViewCreated: (viewId) async {
                        setState(() {
                          localViewId = viewId;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 220,
                  width: 150,
                  child: Container(
                    child: !isStartPK ||
                            otherUserId == '' ||
                            !remoteUidSet.containsKey(otherUserId)
                        ? Text('Waiting for PK anchor')
                        : TRTCCloudVideoView(
                            key: ValueKey("OtherlView"),
                            onViewCreated: (viewId) async {
                              trtcCloud.startRemoteView(
                                  otherUserId,
                                  TRTCVideoStreamType.small,
                                  viewId);
                            },
                          ),
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          height: 140,
          bottom: 15,
          child: Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            width: MediaQuery.of(context).size.width,
            height: 200,
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
                          hintText: TRTCAPIExampleLocalizations.current.please_input_roomid,
                          labelText: TRTCAPIExampleLocalizations.current.connectotherroom_please_input_need_pk_roomid
                        ),
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: otherRoomId == null
                                ? ''
                                : otherRoomId.toString(),
                            selection: TextSelection.fromPosition(
                              TextPosition(
                                affinity: TextAffinity.downstream,
                                offset: otherRoomId == null
                                    ? 0
                                    : otherRoomId.toString().length,
                              ),
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          otherRoomId = int.parse(value);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        autofocus: false,
                        decoration: InputDecoration(
                          labelText: TRTCAPIExampleLocalizations.current.connectotherroom_please_input_need_pk_userid,
                          hintText: TRTCAPIExampleLocalizations.current.please_input_userid,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: otherUserId,
                            selection: TextSelection.fromPosition(
                              TextPosition(
                                affinity: TextAffinity.downstream,
                                offset: this.otherUserId.length,
                              ),
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          otherUserId = value;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: isStartPush
                              ? MaterialStateProperty.all(Colors.green)
                              : MaterialStateProperty.all(Colors.grey),
                        ),
                        onPressed: () {
                          onStartPkClick();
                        },
                        child: Text(isStartPK ? TRTCAPIExampleLocalizations.current.connectotherroom_stop_pk : TRTCAPIExampleLocalizations.current.connectotherroom_start_pk),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextField(
                        autofocus: false,
                        enabled: !isStartPush,
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
                          eventBus.fire(TitleUpdateEvent('Room ID: $roomId'));
                        },
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        autofocus: false,
                        enabled: !isStartPush,
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
                      width: 100,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green),
                        ),
                        onPressed: () {
                          onPushStreamClick();
                        },
                        child: Text(isStartPush ? TRTCAPIExampleLocalizations.current.stop_push : TRTCAPIExampleLocalizations.current.start_push),
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
