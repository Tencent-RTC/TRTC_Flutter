import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:trtc_api_example/Common/TXHelper.dart';
import 'package:trtc_api_example/Common/TXUpdateEvent.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:trtc_api_example/generated/l10n.dart';

///  SetAudioQualityPage.dart
///  TRTC-API-Example-Dart
class SetAudioQualityPage extends StatefulWidget {
  const SetAudioQualityPage({Key? key}) : super(key: key);

  @override
  _SetAudioQualityPageState createState() => _SetAudioQualityPageState();
}

class _SetAudioQualityPageState extends State<SetAudioQualityPage> {
  late TRTCCloud trtcCloud;
  late TRTCCloudListener listener;
  int? localViewId;
  bool isStartPush = false;
  int roomId = int.parse(TXHelper.generateRandomStrRoomId());
  String userId = TXHelper.generateRandomUserId();
  Map<String, String> remoteUidSet = {};
  TRTCAudioQuality audioQuality = TRTCAudioQuality.defaultMode;
  int audioCaptureVolume = 100;
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
    trtcCloud.enterRoom(params, TRTCAppScene.audioCall);

    TRTCVideoEncParam encParams = new TRTCVideoEncParam();
    encParams.videoResolution = TRTCVideoResolution.res_640_360;
    encParams.videoBitrate = 550;
    encParams.videoFps = 15;
    trtcCloud.setVideoEncoderParam(encParams);
    listener = getListener();
    trtcCloud.registerListener(listener);
    trtcCloud.startLocalAudio(audioQuality);
    trtcCloud.setAudioCaptureVolume(audioCaptureVolume);
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
      remoteUidSet.clear();
      trtcCloud.stopLocalAudio();
      trtcCloud.unRegisterListener(listener);
      trtcCloud.stopLocalPreview();
      trtcCloud.exitRoom();
    }
    setState(() {});
  }

  onSpeechButtonClick() {
    setState(() {
      audioQuality = TRTCAudioQuality.speech;
      trtcCloud.startLocalAudio(audioQuality);
    });
  }

  onDefaultButtonClick() {
    setState(() {
      audioQuality = TRTCAudioQuality.defaultMode;
      trtcCloud.startLocalAudio(audioQuality);
    });
  }

  onMusicButtonClick() {
    setState(() {
      audioQuality = TRTCAudioQuality.music;
      trtcCloud.startLocalAudio(audioQuality);
    });
  }

  onVolumeChanged(value) {
    setState(() {
      audioCaptureVolume = value;
      trtcCloud.setAudioCaptureVolume(audioCaptureVolume);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> remoteUidList = remoteUidSet.values.toList();
    MaterialStateProperty<Color> greenColor =
        MaterialStateProperty.all(Colors.green);
    MaterialStateProperty<Color> greyColor =
        MaterialStateProperty.all(Colors.grey);
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
                  child: TRTCCloudVideoView(
                    key: ValueKey('RemoteView_$userId'),
                    onViewCreated: (viewId) async {
                      trtcCloud.startRemoteView(userId,
                          TRTCVideoStreamType.small, viewId);
                    },
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          left: 0,
          height: 120,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 195,
                      child: Text(TRTCAPIExampleLocalizations.current.audioquality_please_select_audio_quality),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(TRTCAPIExampleLocalizations.current.audioquality_please_set_volumn),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 25,
                      width: 60,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: MaterialStateProperty.all(
                            TextStyle(fontSize: 12),
                          ),
                          padding: MaterialStateProperty.all(
                            EdgeInsets.only(left: 0, right: 0),
                          ),
                          backgroundColor: audioQuality ==
                                  TRTCAudioQuality.defaultMode
                              ? greenColor
                              : greyColor,
                        ),
                        onPressed: () {
                          onDefaultButtonClick();
                        },
                        child: Text(TRTCAPIExampleLocalizations.current.audioquality_quality_default),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      height: 25,
                      width: 60,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                            TextStyle(fontSize: 12),
                          ),
                          padding: MaterialStateProperty.all(
                            EdgeInsets.only(left: 0, right: 0),
                          ),
                          backgroundColor: audioQuality ==
                                  TRTCAudioQuality.speech
                              ? greenColor
                              : greyColor,
                        ),
                        onPressed: () {
                          onSpeechButtonClick();
                        },
                        child: Text(TRTCAPIExampleLocalizations.current.audioquality_quality_speech),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      height: 25,
                      width: 60,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                            TextStyle(fontSize: 12),
                          ),
                          padding: MaterialStateProperty.all(
                            EdgeInsets.only(left: 0, right: 0),
                          ),
                          backgroundColor: audioQuality ==
                                  TRTCAudioQuality.music
                              ? greenColor
                              : greyColor,
                        ),
                        onPressed: () {
                          onMusicButtonClick();
                        },
                        child: Text(TRTCAPIExampleLocalizations.current.audioquality_quality_music),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      flex: 1,
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
                                max: 100,
                                min: 0,
                                divisions: 100,
                                label: audioCaptureVolume.toString(),
                                onChanged: (value) {
                                  onVolumeChanged(value.toInt());
                                },
                                value: audioCaptureVolume.toDouble(),
                              ),
                            ),
                          ),
                          Text(
                            audioCaptureVolume.toString(),
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
