import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:trtc_api_example/Common/TXHelper.dart';
import 'package:trtc_api_example/Common/TXUpdateEvent.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///  SetRenderParamsPage.dart
///  TRTC-API-Example-Dart
class SetRenderParamsPage extends StatefulWidget {
  const SetRenderParamsPage({Key? key}) : super(key: key);

  @override
  _SetRenderParamsPageState createState() => _SetRenderParamsPageState();
}

class _SetRenderParamsPageState extends State<SetRenderParamsPage> {
  late TRTCCloud trtcCloud;
  int? localViewId;
  bool isStartPush = false;
  int roomId = int.parse(TXHelper.generateRandomStrRoomId());
  String userId = TXHelper.generateRandomUserId();
  Map<String, String> remoteUidSet = {};

  int localFillMode = TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL;
  int localMirroType = TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_AUTO;
  int localRotation = TRTCCloudDef.TRTC_VIDEO_ROTATION_0;
  String selectedRemoteUser = "";
  int selectedRemoteFillMode = TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL;
  int selectedRemoteRotation = TRTCCloudDef.TRTC_VIDEO_ROTATION_0;
  Map<String, TRTCRenderParams> remoteRenderParamsDic = {};

  @override
  void initState() {
    initTRTCCloud();
    super.initState();
    eventBus.fire(TitleUpdateEvent('Room ID: $roomId'));
  }

  initTRTCCloud() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    trtcCloud.setGSensorMode(TRTCCloudDef.TRTC_GSENSOR_MODE_DISABLE);
  }

  startPushStream() async {
    trtcCloud.startLocalPreview(true, localViewId);
    TRTCParams params = new TRTCParams();
    params.sdkAppId = GenerateTestUserSig.sdkAppId;
    params.roomId = this.roomId;
    params.userId = this.userId;
    params.role = TRTCCloudDef.TRTCRoleAnchor;
    params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
    trtcCloud.enterRoom(params, TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);

    TRTCVideoEncParam encParams = new TRTCVideoEncParam();
    encParams.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360;
    encParams.videoBitrate = 550;
    encParams.videoFps = 15;
    trtcCloud.setVideoEncoderParam(encParams);
    trtcCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC);
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
        break;
      case TRTCCloudListener.onRemoteUserLeaveRoom:
        break;
      case TRTCCloudListener.onConnectOtherRoom:
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
        TRTCRenderParams renderParams = new TRTCRenderParams();
        renderParams.fillMode = selectedRemoteFillMode;
        renderParams.rotation = selectedRemoteRotation;
        remoteRenderParamsDic[userId] = renderParams;

        remoteUidSet[userId] = userId;
        if (remoteUidSet.length == 1) {
          selectedRemoteUser = userId;
          reloadRenderParamsWithIsLocal(false);
        }
      });
    }
    if (!available && remoteUidSet.containsKey(userId)) {
      setState(() {
        remoteUidSet.remove(userId);
        remoteUidSet.remove(userId);
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

  onStartButtonClick() {
    bool newIsStartPush = !isStartPush;
    isStartPush = newIsStartPush;
    if (isStartPush) {
      startPushStream();
    } else {
      selectedRemoteUser = "";
      remoteRenderParamsDic.clear();
      remoteUidSet.clear();
      trtcCloud.unRegisterListener(onTrtcListener);
      trtcCloud.stopLocalAudio();
      trtcCloud.stopLocalPreview();
      trtcCloud.exitRoom();
    }
    setState(() {});
  }

  reloadRenderParamsWithIsLocal(isLocal) {
    TRTCRenderParams renderParams = new TRTCRenderParams();

    if (isLocal) {
      renderParams.fillMode = localFillMode;
      renderParams.rotation = localRotation;
      renderParams.mirrorType = localMirroType;
      trtcCloud.setLocalRenderParams(renderParams);
    } else {
      if (remoteRenderParamsDic.containsKey(selectedRemoteUser)) {
        renderParams = remoteRenderParamsDic[selectedRemoteUser]!;
      }
      trtcCloud.setRemoteRenderParams(selectedRemoteUser,
          TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL, renderParams);
    }
  }

  onLocalFillModeClick(value) {
    setState(() {
      localFillMode = value;
      reloadRenderParamsWithIsLocal(true);
    });
  }

  onLocalMirrorModeClick(value) {
    setState(() {
      localMirroType = value;
      reloadRenderParamsWithIsLocal(true);
    });
  }

  onLocalRateButtonClick(value) {
    setState(() {
      localRotation = value;
      reloadRenderParamsWithIsLocal(true);
    });
  }

  onRemoteUserIdClick(value) {
    if (userId == "") {
      return;
    }
    setState(() {
      selectedRemoteUser = value;
      TRTCRenderParams renderParams = new TRTCRenderParams();
      renderParams.fillMode = selectedRemoteFillMode;
      renderParams.rotation = selectedRemoteRotation;
      remoteRenderParamsDic[selectedRemoteUser] = renderParams;
      reloadRenderParamsWithIsLocal(false);
    });
  }

  onRemoteFillModeClick(value) {
    if (userId == "") {
      return;
    }
    setState(() {
      selectedRemoteFillMode = value;
      TRTCRenderParams renderParams = new TRTCRenderParams();
      renderParams.fillMode = selectedRemoteFillMode;
      renderParams.rotation = selectedRemoteRotation;
      remoteRenderParamsDic[selectedRemoteUser] = renderParams;
      reloadRenderParamsWithIsLocal(false);
    });
  }

  onRemoteRotationClick(value) {
    if (userId == "") {
      return;
    }
    setState(() {
      selectedRemoteRotation = value;
      TRTCRenderParams renderParams = new TRTCRenderParams();
      renderParams.fillMode = selectedRemoteFillMode;
      renderParams.rotation = selectedRemoteRotation;
      remoteRenderParamsDic[selectedRemoteUser] = renderParams;
      reloadRenderParamsWithIsLocal(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> remoteUidList = remoteUidSet.values.toList();
    TRTCRenderParams remoteRenderParams = TRTCRenderParams();
    remoteRenderParams.fillMode = TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL;
    remoteRenderParams.rotation = TRTCCloudDef.TRTC_VIDEO_ROTATION_0;
    if (remoteRenderParamsDic.containsKey(selectedRemoteUser)) {
      remoteRenderParams = remoteRenderParamsDic[selectedRemoteUser]!;
    }
    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {},
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
        Positioned(
          right: 15,
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
                          viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
                          onViewCreated: (viewId) async {
                            trtcCloud.startRemoteView(
                                userId,
                                TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL,
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
          height: 280,
          bottom: 15,
          child: Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 20,
                            child: Text(
                              '设置预览图像渲染模式',
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: DropdownButton(
                              value: localFillMode,
                              hint: Text('请选择渲染模式'),
                              onChanged: (value) {
                                onLocalFillModeClick(value);
                              },
                              items: [
                                DropdownMenuItem(
                                  value:
                                      TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL,
                                  child: Container(
                                    child: Text('填充'),
                                    width: 125,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value:
                                      TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT,
                                  child: Container(
                                    width: 125,
                                    child: Text('适应'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            height: 20,
                            child: Text(
                              '设置预览镜像模式',
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: DropdownButton(
                              value: localMirroType,
                              hint: Text('请选择镜像模式'),
                              onChanged: (value) {
                                onLocalMirrorModeClick(value);
                              },
                              items: [
                                DropdownMenuItem(
                                  value:
                                      TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_AUTO,
                                  child: Container(
                                    width: 125,
                                    child: Text('前摄开启'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TRTCCloudDef
                                      .TRTC_VIDEO_MIRROR_TYPE_ENABLE,
                                  child: Container(
                                    width: 125,
                                    child: Text('前后摄均开启'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TRTCCloudDef
                                      .TRTC_VIDEO_MIRROR_TYPE_DISABLE,
                                  child: Container(
                                    width: 125,
                                    child: Text('前后摄均关闭'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            height: 20,
                            child: Text(
                              '设置预览图像旋转角度(顺时针)',
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: DropdownButton(
                              value: localRotation,
                              hint: Text('请选择旋转角度'),
                              onChanged: (value) {
                                onLocalRateButtonClick(value);
                              },
                              items: [
                                DropdownMenuItem(
                                  value: TRTCCloudDef.TRTC_VIDEO_ROTATION_0,
                                  child: Container(
                                    width: 125,
                                    child: Text('0度'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TRTCCloudDef.TRTC_VIDEO_ROTATION_90,
                                  child: Container(
                                    width: 125,
                                    child: Text(
                                      '90度',
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TRTCCloudDef.TRTC_VIDEO_ROTATION_180,
                                  child: Container(
                                    width: 125,
                                    child: Text('180度'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TRTCCloudDef.TRTC_VIDEO_ROTATION_270,
                                  child: Container(
                                    width: 125,
                                    child: Text('270度'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 20,
                            child: Text(
                              '远端用户ID',
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: DropdownButton(
                              value: selectedRemoteUser,
                              hint: Container(
                                width: 125,
                                child: Text('请选择'),
                              ),
                              onChanged: (value) {
                                onRemoteUserIdClick(value);
                              },
                              items: remoteUidList
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Container(
                                          child: Text(e),
                                          width: 125,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            height: 20,
                            child: Text(
                              '设置远端图像渲染模式',
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: DropdownButton(
                              value: remoteRenderParams.fillMode,
                              hint: Text('请选择渲染模式'),
                              onChanged: (value) {
                                onRemoteFillModeClick(value);
                              },
                              items: [
                                DropdownMenuItem(
                                  value:
                                      TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL,
                                  child: Container(
                                    child: Text('填充'),
                                    width: 125,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value:
                                      TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT,
                                  child: Container(
                                    width: 125,
                                    child: Text('适应'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            height: 20,
                            child: Text(
                              '设置预览图像旋转角度(顺时针)',
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: DropdownButton(
                              value: remoteRenderParams.rotation,
                              hint: Text('请选择旋转角度'),
                              onChanged: (value) {
                                onRemoteRotationClick(value);
                              },
                              items: [
                                DropdownMenuItem(
                                  value: TRTCCloudDef.TRTC_VIDEO_ROTATION_0,
                                  child: Container(
                                    width: 125,
                                    child: Text('0度'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TRTCCloudDef.TRTC_VIDEO_ROTATION_90,
                                  child: Container(
                                    width: 125,
                                    child: Text(
                                      '90度',
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TRTCCloudDef.TRTC_VIDEO_ROTATION_180,
                                  child: Container(
                                    width: 125,
                                    child: Text('180度'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TRTCCloudDef.TRTC_VIDEO_ROTATION_270,
                                  child: Container(
                                    width: 125,
                                    child: Text('270度'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                          onStartButtonClick();
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
