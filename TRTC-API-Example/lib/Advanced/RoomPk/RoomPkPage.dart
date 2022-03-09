import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:trtc_api_example/Common/TXHelper.dart';
import 'package:trtc_api_example/Common/TXUpdateEvent.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';

///  RoomPkPage.dart
///  TRTC-API-Example-Dart
///  Created by gavinwjwang on 2022/2/28.
class RoomPkPage extends StatefulWidget {
  const RoomPkPage({Key? key}) : super(key: key);

  @override
  _RoomPkPageState createState() => _RoomPkPageState();
}

class _RoomPkPageState extends State<RoomPkPage> {
  late TRTCCloud trtcCloud;
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
    eventBus.fire(TitleUpdateEvent('房间号: $roomId'));
  }

  initTRTCCloud() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
  }

  startPushStream() async {
    trtcCloud.startLocalPreview(true, localViewId);
    TRTCParams params = new TRTCParams();
    params.sdkAppId = GenerateTestUserSig.sdkAppId;
    params.roomId = this.roomId;
    params.userId = this.userId;
    params.role = TRTCCloudDef.TRTCRoleAnchor;
    params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
    trtcCloud.enterRoom(params, TRTCCloudDef.TRTC_APP_SCENE_LIVE);

    TRTCVideoEncParam encParams = new TRTCVideoEncParam();
    encParams.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720;
    encParams.videoBitrate = 1500;
    encParams.videoFps = 24;
    trtcCloud.setVideoEncoderParam(encParams);
    trtcCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
    trtcCloud.registerListener(onTrtcListener);
    eventBus.fire(TitleUpdateEvent('房间号: $roomId'));
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
        break;
      case TRTCCloudListener.onConnectOtherRoom:
        onConnectOtherRoom(
            params['userId'], params['errCode'], params['errMsg']);
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

  destroyRoom() async {
    await trtcCloud.stopLocalAudio();
    await trtcCloud.stopLocalPreview();
    await trtcCloud.exitRoom();
    await TRTCCloud.destroySharedInstance();
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
      trtcCloud.unRegisterListener(onTrtcListener);
      trtcCloud.stopLocalAudio();
      trtcCloud.stopLocalPreview();
      trtcCloud.exitRoom();
    }
    setState(() {});
  }

  onStartPkClick() {
    if (otherRoomId == null || otherUserId == "") {
      showToast('请输入PK房间和用户ID信息', dismissOtherToast: true);
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
                      viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
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
                        ? Text('等待PK主播')
                        : TRTCCloudVideoView(
                            key: ValueKey("OtherlView"),
                            viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
                            onViewCreated: (viewId) async {
                              trtcCloud.startRemoteView(
                                  otherUserId,
                                  TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL,
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
                          hintText: "请输入房间号",
                          labelText: "PK主播的房间号",
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
                          labelText: "PK主播的用户ID",
                          hintText: "请输入用户ID",
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
                        child: Text(isStartPK ? '停止PK' : '开始PK'),
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
                          labelText: "房间号",
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
                          eventBus.fire(TitleUpdateEvent('房间号: $roomId'));
                        },
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        autofocus: false,
                        enabled: !isStartPush,
                        decoration: InputDecoration(
                          labelText: "用户ID",
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
                        child: Text(isStartPush ? '停止推流' : '开始推流'),
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
