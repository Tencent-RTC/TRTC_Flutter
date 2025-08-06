import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:trtc_api_example/Common/TXHelper.dart';
import 'package:trtc_api_example/Common/TXUpdateEvent.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:trtc_api_example/generated/l10n.dart';

class PublishMediaStreamAnchorPage extends StatefulWidget {
  const PublishMediaStreamAnchorPage({Key? key}) : super(key: key);

  @override
  _PublishMediaStreamAnchorPageState createState() => _PublishMediaStreamAnchorPageState();
}

class _PublishMediaStreamAnchorPageState extends State<PublishMediaStreamAnchorPage> {
  late TRTCCloud trtcCloud;
  late TRTCCloudListener listener;
  TRTCPublishMode currentMode = TRTCPublishMode.mixStreamToRoom;
  int? localViewId;
  bool isStartPush = false;
  bool isStartPublishMediaStream = false;
  bool isAudioOnlyMode = false;
  int localRoomId = int.parse(TXHelper.generateRandomStrRoomId());
  String localUserId = TXHelper.generateRandomUserId();
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
    initTRTCCloud();
    super.initState();
    eventBus.fire(TitleUpdateEvent('Room ID: $localRoomId'));
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
          height: 390,
          bottom: 15,
          child: Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(TRTCAPIExampleLocalizations.current.publish_mode),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: getBGWidgetList(),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(TRTCAPIExampleLocalizations.current.audio_only_mode),
                    SizedBox(
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
                                labelText: TRTCAPIExampleLocalizations.current.mix_room_id,
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
                                labelText: TRTCAPIExampleLocalizations.current.mix_user_id,
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
                                labelText: TRTCAPIExampleLocalizations.current.publish_url,
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
                          labelText: TRTCAPIExampleLocalizations.current.remote_room_id,
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
                          labelText: TRTCAPIExampleLocalizations.current.remote_user_id,
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
                      width: 120,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.green),
                        ),
                        onPressed: () {
                          onPublishMediaStreamClick();
                        },
                        child: Text(
                          isStartPublishMediaStream
                              ? TRTCAPIExampleLocalizations.current.stop_publish_media_stream
                              : TRTCAPIExampleLocalizations.current.start_publish_media_stream,
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
                          eventBus.fire(TitleUpdateEvent('Room ID: $localRoomId'));
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
                            ? TRTCAPIExampleLocalizations.current.stop_push
                            : TRTCAPIExampleLocalizations.current.start_push),
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

  @override
  dispose() {
    destroyRoom();
    super.dispose();
  }

  initTRTCCloud() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    listener = getListener();
    trtcCloud.registerListener(listener);
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
    trtcCloud.startLocalAudio(TRTCAudioQuality.music);
    trtcCloud.enterRoom(params, TRTCAppScene.live);
  }

  exitRoom() async {
    remoteRenderParamsDic.clear();
    remoteUidList = [];
    trtcCloud.unRegisterListener(listener);
    trtcCloud.stopLocalAudio();
    trtcCloud.stopLocalPreview();
    trtcCloud.exitRoom();
  }

  destroyRoom() async {
    trtcCloud.stopLocalAudio();
    trtcCloud.stopLocalPreview();
    trtcCloud.exitRoom();
    trtcCloud.unRegisterListener(listener);
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
        tile: TRTCAPIExampleLocalizations.current.publish_stream_to_room,
        value: TRTCPublishMode.mixStreamToRoom,
        onClick: setPublishMode,
      ),
      SizedBox(
        width: 20,
      ),
      getButtonItem(
        tile: TRTCAPIExampleLocalizations.current.publish_stream_to_cdn,
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
      TRTCUser selfUser = TRTCUser();
      selfUser.userId = localUserId;
      selfUser.intRoomId = localRoomId;

      TRTCVideoLayout selfVideoLayout = TRTCVideoLayout();
      selfVideoLayout.fixedVideoStreamType = TRTCVideoStreamType.big;
      selfVideoLayout.rect = TRTCRect(left: 0, top: 0, right: 1080, bottom: 1920);
      selfVideoLayout.zOrder = 0;
      selfVideoLayout.fixedVideoUser = selfUser;
      selfVideoLayout.fillMode = TRTCVideoFillMode.fit;

      config.videoLayoutList.add(selfVideoLayout);

      TRTCUser remoteUser = TRTCUser();
      remoteUser.userId = remoteUserId;
      remoteUser.intRoomId = remoteRoomId;

      TRTCVideoLayout remoteVideoLayout = TRTCVideoLayout();
      remoteVideoLayout.fixedVideoStreamType = TRTCVideoStreamType.big;
      remoteVideoLayout.rect = TRTCRect(left: 100, top: 50, right: 316, bottom: 384);
      remoteVideoLayout.zOrder = 1;
      remoteVideoLayout.fixedVideoUser = remoteUser;
      remoteVideoLayout.fillMode = TRTCVideoFillMode.fit;

      config.videoLayoutList.add(remoteVideoLayout);
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

  onPublishMediaStreamClick() {
    isStartPublishMediaStream = !isStartPublishMediaStream;
    if (isStartPublishMediaStream) {
      startPublishMediaStream();
    } else {
      stopPublishMediaStream();
    }
    setState(() {});
  }

  onUserVideoAvailable(String userId, bool available) {
    if (available) {
      remoteUidList.add(userId);
    } else {
      remoteUidList.remove(userId);
    }

    if (remoteUidList.length > 0) {
      setPublishMode(currentMode);
    }
    setState(() {});
  }

  TRTCCloudListener getListener() {
    return TRTCCloudListener(
      onUserVideoAvailable: (userId, available) {
        onUserVideoAvailable(userId, available);
      },
      onStartPublishMediaStream: (taskId, errCode, errMsg, extraInfo) {
        debugPrint("TRTCCloudListener.onStartPublishMediaStream: taskId:$taskId, code:$errCode, msg:$errMsg");
        publishMediaStreamTaskId = taskId;
      },
      onUpdatePublishMediaStream: (taskId, errCode, errMsg, extraInfo) {
        debugPrint("TRTCCloudListener.onUpdatePublishMediaStream: taskId:$taskId, code:$errCode, msg:$errMsg");
      },
      onStopPublishMediaStream: (taskId, errCode, errMsg, extraInfo) {
        debugPrint("TRTCCloudListener.onStopPublishMediaStream: taskId:$taskId, code:$errCode, msg:$errMsg");
      }
    );
  }
}
