import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import '../../../debug/generate_test_user_sig.dart';

class PublishMediaStreamAnchorPage extends StatefulWidget {
  const PublishMediaStreamAnchorPage({Key? key}) : super(key: key);

  @override
  _PublishMediaStreamAnchorPageState createState() => _PublishMediaStreamAnchorPageState();
}

class _PublishMediaStreamAnchorPageState extends State<PublishMediaStreamAnchorPage> {
  late TRTCCloud trtcCloud;
  late final TRTCCloudListener _trtcCloudListener;
  TRTCPublishMode currentMode = TRTCPublishMode.mixStreamToRoom;
  int? localViewId;
  bool isStartPush = false;
  bool isStartPublishMediaStream = false;
  bool isAudioOnlyMode = false;
  late int localRoomId = int.parse(_generateRandomStrRoomId());
  late String localUserId = _generateRandomUserId();
  int remoteRoomId = 0;
  String remoteUserId = '0';
  int mixRoomId = 0;
  String mixUserId = '0';
  String cndUrlList = 'http://';
  String publishMediaStreamTaskId = '';
  List<String> remoteUidList = [];
  Map<String, TRTCRenderParams> remoteRenderParamsDic = {};

  @override
  void initState() {
    _trtcCloudListener = TRTCCloudListener(
      onUserVideoAvailable: (userId, available) {
        _onUserVideoAvailable(userId, available);
      },
    );
    initTRTCCloud();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anchor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            // stop mix then exit room before leaving page
            if (isStartPublishMediaStream) {
              try { stopPublishMediaStream(); } catch (_) {}
              isStartPublishMediaStream = false;
            }
            if (isStartPush) {
              try { await exitRoom(); } catch (_) {}
              isStartPush = false;
            }
            if (mounted) Navigator.of(context).maybePop();
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
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
                      TRTCCloudVideoView(
                        key: ValueKey('RemoteView_$userId'),
                        onViewCreated: (viewId) async {
                          trtcCloud.startRemoteView(userId, TRTCVideoStreamType.big, viewId);
                        },
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
          height: 400,
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text('publish_mode',
                    style: TextStyle(fontSize: 15, inherit: false)),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: getBGWidgetList(),
                ),

                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text('only audio',
                        style: TextStyle(fontSize: 15, inherit: false, color: Colors.white)
                    ),
                    const SizedBox(
                      width: 10,
                    ),

                    Switch(
                      value: isAudioOnlyMode,
                      activeColor: Colors.green,
                      onChanged: (bool value) {
                        setState(() {
                          isAudioOnlyMode = value;
                        });
                      },
                    )

                  ],
                ),

                currentMode == TRTCPublishMode.mixStreamToRoom
                    ? Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: TextField(
                              autofocus: false,
                              enabled: !isStartPublishMediaStream,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(color: Colors.white),
                                labelText: 'mix room id',
                              ),
                              controller: TextEditingController.fromValue(
                                TextEditingValue(
                                  text: this.mixRoomId.toString(),
                                  selection: TextSelection.fromPosition(
                                    TextPosition(
                                      affinity: TextAffinity.downstream,
                                      offset: this.mixRoomId.toString().length,
                                    ),
                                  ),
                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                mixRoomId = int.parse(value);
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
                              enabled: !isStartPublishMediaStream,
                              decoration: InputDecoration(
                                labelText: 'mix user id',
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                              controller: TextEditingController.fromValue(
                                TextEditingValue(
                                  text: this.mixUserId,
                                  selection: TextSelection.fromPosition(
                                    TextPosition(
                                      affinity: TextAffinity.downstream,
                                      offset: this.mixUserId.length,
                                    ),
                                  ),
                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                              keyboardType: TextInputType.text,
                              onChanged: (value) {
                                mixUserId = value;
                              },
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 180,
                            child: TextField(
                              autofocus: false,
                              enabled: !isStartPublishMediaStream,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(color: Colors.white),
                                labelText: 'publish url',
                              ),
                              controller: TextEditingController.fromValue(
                                TextEditingValue(
                                  text: cndUrlList,
                                  selection: TextSelection.fromPosition(
                                    TextPosition(
                                      affinity: TextAffinity.downstream,
                                      offset: this.cndUrlList.toString().length,
                                    ),
                                  ),
                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                              keyboardType: TextInputType.text,
                              onChanged: (value) {
                                cndUrlList = value;
                              },
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextField(
                        autofocus: false,
                        enabled: !isStartPublishMediaStream,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.white),
                          labelText: 'remote room id',
                        ),
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: this.remoteRoomId.toString(),
                            selection: TextSelection.fromPosition(
                              TextPosition(
                                affinity: TextAffinity.downstream,
                                offset: this.remoteRoomId.toString().length,
                              ),
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          remoteRoomId = int.parse(value);
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
                        enabled: !isStartPublishMediaStream,
                        decoration: InputDecoration(
                          labelText: 'remote user id',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: this.remoteUserId,
                            selection: TextSelection.fromPosition(
                              TextPosition(
                                affinity: TextAffinity.downstream,
                                offset: this.remoteUserId.length,
                              ),
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          remoteUserId = value;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.green),
                        ),
                        onPressed: () {
                          _onPublishMediaStreamClick();
                        },
                        child: Text(
                          isStartPublishMediaStream
                              ? 'StopPublish'
                              : 'Publish',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
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
                            text: this.localRoomId.toString(),
                            selection: TextSelection.fromPosition(
                              TextPosition(
                                affinity: TextAffinity.downstream,
                                offset: this.localRoomId.toString().length,
                              ),
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          localRoomId = int.parse(value);

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
                        enabled: !isStartPush,
                        decoration: InputDecoration(
                          labelText: "User ID",
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: this.localUserId,
                            selection: TextSelection.fromPosition(
                              TextPosition(
                                affinity: TextAffinity.downstream,
                                offset: this.localUserId.length,
                              ),
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          localUserId = value;
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
                        child: Text(isStartPush
                            ? 'ExitRoom'
                            : 'EnterRoom'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        ),
      ],
    ),
    );
  }

  @override
  void dispose() {
    destroyRoom();
    super.dispose();
  }

  initTRTCCloud() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    trtcCloud.registerListener(_trtcCloudListener);
  }

  enterRoom() async {
    trtcCloud.startLocalPreview(true, localViewId!);
    TRTCParams params = new TRTCParams();
    params.sdkAppId = GenerateTestUserSig.sdkAppId;
    params.roomId = this.localRoomId;
    params.userId = this.localUserId;
    params.role = TRTCRoleType.anchor;
    params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
    params.streamId = getStreamId();
    trtcCloud.callExperimentalAPI("{\"api\": \"setFramework\", \"params\": {\"framework\": 7, \"component\": 2}}");
    trtcCloud.startLocalAudio(TRTCAudioQuality.defaultMode);
    trtcCloud.enterRoom(params, TRTCAppScene.live);
  }

  exitRoom() async {
    // stop mix publishing before exit room when exiting internally
    if (isStartPublishMediaStream) {
      try { stopPublishMediaStream(); } catch (_) {}
      isStartPublishMediaStream = false;
    }
    remoteRenderParamsDic.clear();
    remoteUidList = [];
    trtcCloud.unRegisterListener(_trtcCloudListener);
    trtcCloud.stopLocalAudio();
    trtcCloud.stopLocalPreview();
    trtcCloud.exitRoom();
  }

  destroyRoom() async {
    trtcCloud.stopLocalAudio();
    trtcCloud.stopLocalPreview();
    trtcCloud.exitRoom();
    trtcCloud.unRegisterListener(_trtcCloudListener);
    TRTCCloud.destroySharedInstance();
  }

  String getStreamId() {
    String streamId =
        GenerateTestUserSig.sdkAppId.toString() + '_' + this.localRoomId.toString() + '_' + this.localUserId + '_main';
    return streamId;
  }

  Widget getButtonItem({
    required String tile,
    required TRTCPublishMode value,
    required Function onClick,
  }) {
    MaterialStateProperty<Color> greenColor =
        currentMode == value ? MaterialStateProperty.all(Colors.green) : MaterialStateProperty.all(Colors.grey);

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

  setPublishMode(value) {
    setState(() {
      currentMode = value;
    });
  }

  getBGWidgetList() {
    return [
      getButtonItem(
        tile: 'To Room',
        value: TRTCPublishMode.mixStreamToRoom,
        onClick: setPublishMode,
      ),
      const SizedBox(
        width: 20,
      ),
      getButtonItem(
        tile: 'To CDN',
        value: TRTCPublishMode.mixStreamToCdn,
        onClick: setPublishMode,
      ),
    ];
  }

  void startPublishMediaStream() {
    TRTCPublishTarget target = TRTCPublishTarget();
    target.mode = currentMode;

    if (target.mode == TRTCPublishMode.mixStreamToRoom) {
      TRTCUser trtcUser = TRTCUser();
      trtcUser.userId = mixUserId;
      trtcUser.intRoomId = mixRoomId;

      target.mixStreamIdentity = trtcUser;
    } else if (target.mode == TRTCPublishMode.mixStreamToCdn) {
      var urlList = cndUrlList.split(',');
      if (urlList.isNotEmpty) {
        target.cdnUrlList = <TRTCPublishCdnUrl>[];
        for (String url in urlList) {
          TRTCPublishCdnUrl cdnUrlEntity = new TRTCPublishCdnUrl();
          cdnUrlEntity.rtmpUrl = url;

          target.cdnUrlList?.add(cdnUrlEntity);
        }
      }
    }

    TRTCStreamMixingConfig config = TRTCStreamMixingConfig();

    if (!isAudioOnlyMode) {
      List<TRTCVideoLayout> videoLayoutList = [];
      
      TRTCUser selfUser = TRTCUser();
      selfUser.userId = localUserId;
      selfUser.intRoomId = localRoomId;

      TRTCVideoLayout selfVideoLayout = TRTCVideoLayout();
      selfVideoLayout.fixedVideoStreamType = TRTCVideoStreamType.big;
      selfVideoLayout.rect = TRTCRect(left: 0, top: 0, right: 1080, bottom: 1920);
      selfVideoLayout.zOrder = 0;
      selfVideoLayout.fixedVideoUser = selfUser;
      selfVideoLayout.fillMode = TRTCVideoFillMode.fit;

      videoLayoutList.add(selfVideoLayout);

      TRTCUser remoteUser = TRTCUser();
      remoteUser.userId = remoteUserId;
      remoteUser.intRoomId = remoteRoomId;

      TRTCVideoLayout remoteVideoLayout = TRTCVideoLayout();
      remoteVideoLayout.fixedVideoStreamType = TRTCVideoStreamType.big;
      remoteVideoLayout.rect = TRTCRect(left: 50, top: 900, right: 250, bottom: 1300);
      remoteVideoLayout.zOrder = 1;
      remoteVideoLayout.fixedVideoUser = remoteUser;
      remoteVideoLayout.fillMode = TRTCVideoFillMode.scaleFill;

      videoLayoutList.add(remoteVideoLayout);
      
      config.videoLayoutList = videoLayoutList;
    }

    TRTCStreamEncoderParam param = TRTCStreamEncoderParam();
    if (isAudioOnlyMode) {
      param.videoEncodedWidth = 0;
      param.videoEncodedHeight = 0;
    } else {
      param.videoEncodedWidth = 1080;
      param.videoEncodedHeight = 1920;
      param.videoEncodedKbps = 5000;
      param.videoEncodedFPS = 30;
      param.videoEncodedGOP = 3;
    }
    param.audioEncodedSampleRate = 48000;
    param.audioEncodedChannelNum = 2;
    param.audioEncodedKbps = 128;
    param.audioEncodedCodecType = 2;

    trtcCloud.startPublishMediaStream(target, param, config);
  }

  void stopPublishMediaStream() {
    trtcCloud.stopPublishMediaStream(publishMediaStreamTaskId);
  }

  onStartPushClick() {
    bool newIsStartPush = !isStartPush;
    isStartPush = newIsStartPush;
    if (isStartPush) {
      enterRoom();
    } else {
      exitRoom();
    }
    setState(() {});
  }

  _onPublishMediaStreamClick() {
    isStartPublishMediaStream = !isStartPublishMediaStream;
    setState(() {});
    if (isStartPublishMediaStream) {
      startPublishMediaStream();
    } else {
      stopPublishMediaStream();
    }
  }

  _onUserVideoAvailable(String userId, bool available) {
    if (available) {
      remoteUidList.add(userId);
    } else {
      remoteUidList.remove(userId);
    }

    if (remoteUidList.length > 0) {
      setPublishMode(currentMode);
    } else {
    }
    setState(() {});
  }

  String _generateRandomUserId() {
    String line = "";
    var rng = new Random();
    for (var i = 0; i < 6; i++) {
      int num = rng.nextInt(10);
      if (num <= 0) num = rng.nextInt(10);
      line += num.toString();
    }
    return line;
  }

  String _generateRandomStrRoomId() {
    String line = "";
    var rng = new Random();
    for (var i = 0; i < 7; i++) {
      int num = rng.nextInt(10);
      if (num <= 0) num = rng.nextInt(10);
      line += num.toString();
    }
    return line;
  }
}
