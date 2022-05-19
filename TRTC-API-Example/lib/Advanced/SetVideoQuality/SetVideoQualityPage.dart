import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:trtc_api_example/Common/TXHelper.dart';
import 'package:trtc_api_example/Common/TXUpdateEvent.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///  SetVideoQualityPage.dart
///  TRTC-API-Example-Dart∏
class BitrateRange {
  int minBitrate;
  int maxBitrate;
  int defaultBitrate;
  BitrateRange(this.minBitrate, this.maxBitrate, this.defaultBitrate);
}

class SetVideoQualityPage extends StatefulWidget {
  const SetVideoQualityPage({Key? key}) : super(key: key);

  @override
  _SetVideoQualityPageState createState() => _SetVideoQualityPageState();
}

class _SetVideoQualityPageState extends State<SetVideoQualityPage> {
  late TRTCCloud trtcCloud;
  int? localViewId;
  bool isStartPush = false;
  int roomId = int.parse(TXHelper.generateRandomStrRoomId());
  String userId = TXHelper.generateRandomUserId();
  Map<String, String> remoteUidSet = {};
  Map<int, BitrateRange> bitrateDic = {
    TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360: BitrateRange(200, 1000, 800),
    TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540: BitrateRange(400, 1600, 900),
    TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720: BitrateRange(500, 2000, 1250),
    TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1920_1080: BitrateRange(800, 3000, 1900),
  };
  int videoFps = 15;
  int videoBitrate = 900;
  int videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540;
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
    trtcCloud.startLocalPreview(true, localViewId);
    TRTCParams params = new TRTCParams();
    params.sdkAppId = GenerateTestUserSig.sdkAppId;
    params.roomId = this.roomId;
    params.userId = this.userId;
    params.role = TRTCCloudDef.TRTCRoleAnchor;
    params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
    trtcCloud.enterRoom(params, TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);

    TRTCVideoEncParam encParams = new TRTCVideoEncParam();
    encParams.videoResolution = videoResolution;
    encParams.videoBitrate = videoBitrate;
    encParams.videoFps = videoFps;
    trtcCloud.setVideoEncoderParam(encParams);
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

  onVideo360PClick() {
    videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360;
    refreshBitrateSlider();
    refreshEncParam();
  }

  onVideo540PClick() {
    videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540;
    refreshBitrateSlider();
    refreshEncParam();
  }

  onVideo720PClick() {
    videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720;
    refreshBitrateSlider();
    refreshEncParam();
  }

  onVideo1080PClick() {
    videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1920_1080;
    refreshBitrateSlider();
    refreshEncParam();
  }

  refreshBitrateSlider() {
    BitrateRange currentBitrate =
        bitrateDic[TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540]!;
    if (bitrateDic.containsKey(videoResolution)) {
      currentBitrate = bitrateDic[videoResolution]!;
    }
    videoBitrate = currentBitrate.defaultBitrate;
    setState(() {});
  }

  refreshEncParam() {
    TRTCVideoEncParam encParams = new TRTCVideoEncParam();
    encParams.videoResolution = videoResolution;
    encParams.videoBitrate = videoBitrate;
    encParams.videoFps = videoFps;
    trtcCloud.setVideoEncoderParam(encParams);
  }

  onStartButtonClick() {
    bool newIsStartPush = !isStartPush;
    isStartPush = newIsStartPush;
    if (isStartPush) {
      startPushStream();
    } else {
      remoteUidSet.clear();
      trtcCloud.unRegisterListener(onTrtcListener);
      trtcCloud.stopLocalPreview();
      trtcCloud.exitRoom();
    }
    setState(() {});
  }

  onBitrateChanged(double value) {
    videoBitrate = value.toInt();
    refreshEncParam();
    setState(() {});
  }

  onFpsChanged(double value) {
    videoFps = value.toInt();
    refreshEncParam();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<String> remoteUidList = remoteUidSet.values.toList();
    MaterialStateProperty<Color> greenColor =
        MaterialStateProperty.all(Colors.green);
    MaterialStateProperty<Color> greyColor =
        MaterialStateProperty.all(Colors.grey);
    BitrateRange currentBitrate =
        bitrateDic[TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540]!;
    if (bitrateDic.containsKey(videoResolution)) {
      currentBitrate = bitrateDic[videoResolution]!;
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
                  child: TRTCCloudVideoView(
                    key: ValueKey('RemoteView_$userId'),
                    viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
                    onViewCreated: (viewId) async {
                      trtcCloud.startRemoteView(userId,
                          TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL, viewId);
                    },
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          left: 0,
          height: 180,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Resolution ratio'),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 25,
                      width: 55,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                            TextStyle(fontSize: 12),
                          ),
                          padding: MaterialStateProperty.all(
                            EdgeInsets.only(left: 0, right: 0),
                          ),
                          backgroundColor: videoResolution ==
                                  TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360
                              ? greenColor
                              : greyColor,
                        ),
                        onPressed: () {
                          onVideo360PClick();
                        },
                        child: Text('360P'),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    SizedBox(
                      height: 25,
                      width: 55,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                            TextStyle(fontSize: 12),
                          ),
                          padding: MaterialStateProperty.all(
                            EdgeInsets.only(left: 0, right: 0),
                          ),
                          backgroundColor: videoResolution ==
                                  TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540
                              ? greenColor
                              : greyColor,
                        ),
                        onPressed: () {
                          onVideo540PClick();
                        },
                        child: Text('540P'),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    SizedBox(
                      height: 25,
                      width: 55,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                            TextStyle(fontSize: 12),
                          ),
                          padding: MaterialStateProperty.all(
                            EdgeInsets.only(left: 0, right: 0),
                          ),
                          backgroundColor: videoResolution ==
                                  TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720
                              ? greenColor
                              : greyColor,
                        ),
                        onPressed: () {
                          onVideo720PClick();
                        },
                        child: Text('720P'),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    SizedBox(
                      height: 25,
                      width: 55,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                            TextStyle(fontSize: 12),
                          ),
                          padding: MaterialStateProperty.all(
                            EdgeInsets.only(left: 0, right: 0),
                          ),
                          backgroundColor: videoResolution ==
                                  TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1920_1080
                              ? greenColor
                              : greyColor,
                        ),
                        onPressed: () {
                          onVideo1080PClick();
                        },
                        child: Text('1080P'),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 160,
                      child: Text(
                        'Bitrate',
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Text(
                        'Frame Rate',
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 160,
                      padding: EdgeInsets.all(0),
                      margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 10),
                                overlayShape: SliderComponentShape.noOverlay,
                              ),
                              child: Slider(
                                max: currentBitrate.maxBitrate.toDouble(),
                                min: currentBitrate.minBitrate.toDouble(),
                                divisions: currentBitrate.maxBitrate -
                                    currentBitrate.minBitrate,
                                onChanged: (value) {
                                  onBitrateChanged(value);
                                },
                                value: videoBitrate.toDouble(),
                                label: '$videoBitrate kbps',
                              ),
                            ),
                          ),
                          Text('$videoBitrate kbps'),
                        ],
                      ),
                    ),
                    Container(
                      width: 150,
                      padding: EdgeInsets.all(0),
                      margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 10),
                                overlayShape: SliderComponentShape.noOverlay,
                              ),
                              child: Slider(
                                max: 24,
                                min: 10,
                                divisions: 14,
                                label: "$videoFps fps",
                                onChanged: (value) {
                                  onFpsChanged(value);
                                },
                                value: videoFps.toDouble(),
                              ),
                            ),
                          ),
                          Text('$videoFps fps'),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
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
