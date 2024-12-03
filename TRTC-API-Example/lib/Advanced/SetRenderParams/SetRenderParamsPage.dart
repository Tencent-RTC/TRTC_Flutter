import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
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
  late TRTCCloudListener listener;
  int? localViewId;
  bool isStartPush = false;
  int roomId = int.parse(TXHelper.generateRandomStrRoomId());
  String userId = TXHelper.generateRandomUserId();
  Map<String, String> remoteUidSet = {};

  TRTCVideoFillMode localFillMode = TRTCVideoFillMode.fill;
  TRTCVideoMirrorType localMirroType = TRTCVideoMirrorType.auto;
  TRTCVideoRotation localRotation = TRTCVideoRotation.rotation0;
  String selectedRemoteUser = "";
  TRTCVideoFillMode selectedRemoteFillMode = TRTCVideoFillMode.fill;
  TRTCVideoRotation selectedRemoteRotation = TRTCVideoRotation.rotation0;
  Map<String, TRTCRenderParams> remoteRenderParamsDic = {};

  @override
  void initState() {
    initTRTCCloud();
    super.initState();
    eventBus.fire(TitleUpdateEvent('Room ID: $roomId'));
  }

  initTRTCCloud() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    trtcCloud.setGravitySensorAdaptiveMode(TRTCGSensorMode.disable);
  }

  startPushStream() async {
    trtcCloud.startLocalPreview(true, localViewId!);
    TRTCParams params = new TRTCParams();
    params.sdkAppId = GenerateTestUserSig.sdkAppId;
    params.roomId = this.roomId;
    params.userId = this.userId;
    params.role = TRTCRoleType.anchor;
    params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
    trtcCloud.enterRoom(params, TRTCAppScene.videoCall);

    TRTCVideoEncParam encParams = new TRTCVideoEncParam();
    encParams.videoResolution = TRTCVideoResolution.res_640_360;
    encParams.videoBitrate = 550;
    encParams.videoFps = 15;
    trtcCloud.setVideoEncoderParam(encParams);
    trtcCloud.startLocalAudio(TRTCAudioQuality.music);
    listener = getListener();
    trtcCloud.registerListener(listener);
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

  onStartButtonClick() {
    bool newIsStartPush = !isStartPush;
    isStartPush = newIsStartPush;
    if (isStartPush) {
      startPushStream();
    } else {
      selectedRemoteUser = "";
      remoteRenderParamsDic.clear();
      remoteUidSet.clear();
      trtcCloud.unRegisterListener(listener);
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
          TRTCVideoStreamType.small, renderParams);
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
    remoteRenderParams.fillMode = TRTCVideoFillMode.fill;
    remoteRenderParams.rotation = TRTCVideoRotation.rotation0;
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
                              'Set preview image rendering mode',
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: DropdownButton(
                              value: localFillMode,
                              hint: Text('Please select the rendering mode'),
                              onChanged: (value) {
                                onLocalFillModeClick(value);
                              },
                              items: [
                                DropdownMenuItem(
                                  value:
                                      TRTCVideoFillMode.fill,
                                  child: Container(
                                    child: Text('filling'),
                                    width: 125,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value:
                                      TRTCVideoFillMode.fit,
                                  child: Container(
                                    width: 125,
                                    child: Text('adapt'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            height: 20,
                            child: Text(
                              'Set preview mirror mode',
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: DropdownButton(
                              value: localMirroType,
                              hint: Text('Please select mirror mode'),
                              onChanged: (value) {
                                onLocalMirrorModeClick(value);
                              },
                              items: [
                                DropdownMenuItem(
                                  value:
                                      TRTCVideoMirrorType.auto,
                                  child: Container(
                                    width: 125,
                                    child: Text('Kaishi'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TRTCVideoMirrorType.enable,
                                  child: Container(
                                    width: 125,
                                    child: Text('Turn on the front and rear'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TRTCVideoMirrorType.disable,
                                  child: Container(
                                    width: 125,
                                    child: Text('Turn on the front and rear camera'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            height: 20,
                            child: Text(
                              'Set preview image rotation angle (clockwise)',
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: DropdownButton(
                              value: localRotation,
                              hint: Text('Please select the angle of the spinning angle'),
                              onChanged: (value) {
                                onLocalRateButtonClick(value);
                              },
                              items: [
                                DropdownMenuItem(
                                  value: TRTCVideoRotation.rotation0,
                                  child: Container(
                                    width: 125,
                                    child: Text('0 degrees'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TRTCVideoRotation.rotation90,
                                  child: Container(
                                    width: 125,
                                    child: Text(
                                      '90 degree',
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TRTCVideoRotation.rotation180,
                                  child: Container(
                                    width: 125,
                                    child: Text('180 degrees'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TRTCVideoRotation.rotation270,
                                  child: Container(
                                    width: 125,
                                    child: Text('270 degrees'),
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
                              'Remote user ID',
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: DropdownButton(
                              value: selectedRemoteUser,
                              hint: Container(
                                width: 125,
                                child: Text('please choose'),
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
                              'Set the remote image rendering mode',
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: DropdownButton(
                              value: remoteRenderParams.fillMode,
                              hint: Text('Please select the rendering mode'),
                              onChanged: (value) {
                                onRemoteFillModeClick(value);
                              },
                              items: [
                                DropdownMenuItem(
                                  value:
                                      TRTCVideoFillMode.fill,
                                  child: Container(
                                    child: Text('filling'),
                                    width: 125,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value:
                                      TRTCVideoFillMode.fit,
                                  child: Container(
                                    width: 125,
                                    child: Text('adapt'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            height: 20,
                            child: Text(
                              'Set preview image rotation angle (clockwise)',
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: DropdownButton(
                              value: remoteRenderParams.rotation,
                              hint: Text('Please select the angle of the spinning angle'),
                              onChanged: (value) {
                                onRemoteRotationClick(value);
                              },
                              items: [
                                DropdownMenuItem(
                                  value: TRTCVideoRotation.rotation0,
                                  child: Container(
                                    width: 125,
                                    child: Text('0 degrees'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TRTCVideoRotation.rotation90,
                                  child: Container(
                                    width: 125,
                                    child: Text(
                                      '90 degree',
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TRTCVideoRotation.rotation180,
                                  child: Container(
                                    width: 125,
                                    child: Text('180 degrees'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TRTCVideoRotation.rotation270,
                                  child: Container(
                                    width: 125,
                                    child: Text('270 degrees'),
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
