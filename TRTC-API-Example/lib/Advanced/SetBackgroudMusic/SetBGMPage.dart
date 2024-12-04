import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:trtc_api_example/Common/TXHelper.dart';
import 'package:trtc_api_example/Common/TXUpdateEvent.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:tencent_rtc_sdk/tx_audio_effect_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///  SetBGMPage.dart
///  TRTC-API-Example-Dart
class SetBGMPage extends StatefulWidget {
  const SetBGMPage({Key? key}) : super(key: key);

  @override
  _SetBGMPageState createState() => _SetBGMPageState();
}

class _SetBGMPageState extends State<SetBGMPage> {
  late TRTCCloud trtcCloud;
  late TRTCCloudListener listener;
  late TXAudioEffectManager audioEffectManager;
  late TXMusicPlayObserver musicPlayObserver;
  int? localViewId;
  bool isStartPush = false;
  int roomId = int.parse(TXHelper.generateRandomStrRoomId());
  String userId = TXHelper.generateRandomUserId();
  Map<String, String> remoteUidSet = {};
  Map<String, TRTCRenderParams> remoteRenderParamsDic = {};
  int bgVolume = 80;
  AudioMusicParam bgmParam = new AudioMusicParam(id: -1, path: "");
  List<String> bgmURLArray = [
    "https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/PositiveHappyAdvertising.mp3",
    "https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/SadCinematicPiano.mp3",
    "https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/WonderWorld.mp3"
  ];
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
    musicPlayObserver = getMusicPlayObserver();
  }

  TRTCCloudListener getListener() {
    return TRTCCloudListener(
      onUserVideoAvailable: (userId, available) {
        onUserVideoAvailable(userId, available);
      }
    );
  }

  TXMusicPlayObserver getMusicPlayObserver() {
    return TXMusicPlayObserver(
        onStart: (id, errCode) {
          debugPrint('onStart id: $id, errCode: $errCode');
        },
        onPlayProgress: (id, curPtsMSm, durationMS) {
          debugPrint('onPlayProgress id: $id, curPtsMSm: $curPtsMSm, durationMS: $durationMS');
        },
        onComplete: (id, errCode) {
          debugPrint('onComplete id: $id, errCode: $errCode');
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

  Widget getButtonItem({
    required String tile,
    required String value,
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

  getBGWidgetList() {
    return [
      getButtonItem(
        tile: AppLocalizations.of(context)!.bgm_bgm_1,
        value: bgmURLArray[0],
        onClick: onBgmAClick,
      ),
      SizedBox(
        width: 20,
      ),
      getButtonItem(
        tile: AppLocalizations.of(context)!.bgm_bgm_2,
        value: bgmURLArray[1],
        onClick: onBgmBClick,
      ),
      SizedBox(
        width: 20,
      ),
      getButtonItem(
        tile: AppLocalizations.of(context)!.bgm_bgm_3,
        value: bgmURLArray[2],
        onClick: onBgmCClick,
      ),
    ];
  }

  bgmVolumeSliderValueChange(value) {
    if (bgmParam.id <= 0) return;

    setState(() {
      bgVolume = value;
      audioEffectManager.setMusicPlayoutVolume(bgmParam.id, bgVolume);
      audioEffectManager.setMusicPublishVolume(bgmParam.id, bgVolume);
    });
  }

  onBgmAClick(url) {
    if (bgmParam.id > 0) {
      audioEffectManager.stopPlayMusic(bgmParam.id);
    }
    setState(() {
      bgmParam.id = 1234;
      bgmParam.path = url;
      bgmParam.publish = true;
      audioEffectManager.startPlayMusic(bgmParam);
      audioEffectManager.setMusicObserver(bgmParam.id, musicPlayObserver);
    });
  }

  onBgmBClick(url) {
    if (bgmParam.id > 0) {
      audioEffectManager.stopPlayMusic(bgmParam.id);
    }
    setState(() {
      bgmParam.id = 2234;
      bgmParam.path = url;
      bgmParam.publish = true;
      audioEffectManager.startPlayMusic(bgmParam);
      audioEffectManager.setMusicObserver(bgmParam.id, musicPlayObserver);
    });
  }

  onBgmCClick(url) {
    if (bgmParam.id > 0) {
      audioEffectManager.stopPlayMusic(bgmParam.id);
    }
    setState(() {
      bgmParam.id = 3234;
      bgmParam.path = url;
      bgmParam.publish = true;
      audioEffectManager.startPlayMusic(bgmParam);
      audioEffectManager.setMusicObserver(bgmParam.id, musicPlayObserver);
    });
  }

  onPushStreamClick() {
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
          height: 190,
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
                  children: [
                    Text(AppLocalizations.of(context)!.bgm_please_select_audio_bgm),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: getBGWidgetList(),
                ),
                Row(
                  children: [
                    Text(AppLocalizations.of(context)!.bgm_please_set_volumn),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 10),
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                          max: 150,
                          min: 0,
                          divisions: 150,
                          label: bgVolume.toString(),
                          onChanged: (value) {
                            bgmVolumeSliderValueChange(value.toInt());
                          },
                          value: bgVolume.toDouble(),
                        ),
                      ),
                    ),
                    Text(
                      bgVolume.toString(),
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
