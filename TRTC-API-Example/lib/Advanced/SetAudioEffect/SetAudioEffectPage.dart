import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:tencent_rtc_sdk/tx_audio_effect_manager.dart';
import 'package:trtc_api_example/Common/TXHelper.dart';
import 'package:trtc_api_example/Common/TXUpdateEvent.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:trtc_api_example/generated/l10n.dart';

///  SetAudioEffectPage.dart
///  TRTC-API-Example-Dart
class SetAudioEffectPage extends StatefulWidget {
  const SetAudioEffectPage({Key? key}) : super(key: key);

  @override
  _SetAudioEffectPageState createState() => _SetAudioEffectPageState();
}

class _SetAudioEffectPageState extends State<SetAudioEffectPage> {
  late TRTCCloud trtcCloud;
  late TRTCCloudListener listener;
  late TXAudioEffectManager audioEffectManager;
  int? localViewId;
  bool isStartPush = false;
  int roomId = int.parse(TXHelper.generateRandomStrRoomId());
  String userId = TXHelper.generateRandomUserId();
  Map<String, String> remoteUidSet = {};
  Map<String, TRTCRenderParams> remoteRenderParamsDic = {};
  @override
  void initState() {
    initTRTCCloud();
    super.initState();
    eventBus.fire(TitleUpdateEvent('Room ID: $roomId'));
  }

  initTRTCCloud() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    audioEffectManager = trtcCloud.getAudioEffectManager();
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

  onStartButtonClick() {
    bool newIsStartPush = !isStartPush;
    isStartPush = newIsStartPush;
    if (isStartPush) {
      startPushStream();
    } else {
      remoteRenderParamsDic.clear();
      remoteUidSet.clear();
      trtcCloud.unRegisterListener(listener);
      trtcCloud.stopLocalAudio();
      trtcCloud.stopLocalPreview();
      trtcCloud.exitRoom();
    }
    setState(() {});
  }

  Widget getButtonItem({
    required String tile,
    required dynamic value,
    required Function onClick,
  }) {
    MaterialStateProperty<Color> greenColor =
        MaterialStateProperty.all(Colors.green);

    return ElevatedButton(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(
          TextStyle(fontSize: 12),
        ),
        padding: MaterialStateProperty.all(
          EdgeInsets.only(left: 0, right: 0),
        ),
        backgroundColor: greenColor,
      ),
      onPressed: () {
        onClick(value);
      },
      child: Text(tile),
    );
  }

  onVoiceChangerClick(value) {
    if (!isStartPush) return;
    audioEffectManager.setVoiceChangerType(value);
  }

  getVoiceChangerWidget() {
    return [
      getButtonItem(
        tile: "Native",
        value: TXVoiceChangerType.type0,
        onClick: onVoiceChangerClick,
      ),
      getButtonItem(
        tile: "bad boy",
        value: TXVoiceChangerType.type1,
        onClick: onVoiceChangerClick,
      ),
      getButtonItem(
        tile: "Loli",
        value: TXVoiceChangerType.type2,
        onClick: onVoiceChangerClick,
      ),
      getButtonItem(
        tile: "Heavy metal",
        value: TXVoiceChangerType.type4,
        onClick: onVoiceChangerClick,
      ),
      getButtonItem(
        tile: "Uncle",
        value: TXVoiceChangerType.type3,
        onClick: onVoiceChangerClick,
      ),
    ];
  }

  onVoiceReverbClick(value) {
    if (!isStartPush) return;
    audioEffectManager.setVoiceReverbType(value);
  }

  getVoiceReverbWidget() {
    return [
      getButtonItem(
        tile: "no effect",
        value: TXVoiceReverbType.type0,
        onClick: onVoiceReverbClick,
      ),
      getButtonItem(
        tile: "KTV",
        value: TXVoiceReverbType.type1,
        onClick: onVoiceReverbClick,
      ),
      getButtonItem(
        tile: "small room",
        value: TXVoiceReverbType.type2,
        onClick: onVoiceReverbClick,
      ),
      getButtonItem(
        tile: "Gorgeous hall",
        value: TXVoiceReverbType.type3,
        onClick: onVoiceReverbClick,
      ),
      getButtonItem(
        tile: "Low",
        value: TXVoiceReverbType.type4,
        onClick: onVoiceReverbClick,
      ),
    ];
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
          height: 220,
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
                  children: [
                    Text(TRTCAPIExampleLocalizations.current.audioeffect_please_select_effect),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: getVoiceChangerWidget(),
                ),
                Row(
                  children: [
                    Text(TRTCAPIExampleLocalizations.current.audioeffect_please_select_reverb),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: getVoiceReverbWidget(),
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
