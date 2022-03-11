import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:trtc_demo/debug/GenerateTestUserSig.dart';
import 'package:trtc_demo/models/meeting.dart';
import 'package:tencent_trtc_cloud/tx_beauty_manager.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:provider/provider.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class TextureRenderPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TextureRenderState();
}

class TextureRenderState extends State<TextureRenderPage>
    with WidgetsBindingObserver {
  late TRTCCloud trtcCloud;
  late TXBeautyManager txBeautyManager;
  Map<String, int> screenUserList = {};

  int? meetId;
  var meetModel;
  var userInfo = {};
  bool isOpenMic = true;
  bool isOpenCamera = true;
  bool isFrontCamera = true;
  int quality = TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    meetModel = context.read<MeetingModel>();
    var userSetting = meetModel.getUserSetting();
    meetId = userSetting["meetId"];
    userInfo['userId'] = userSetting["userId"];
    isOpenCamera = userSetting["enabledCamera"];
    isOpenMic = userSetting["enabledMicrophone"];
    iniRoom();
  }

  @override
  dispose() {
    trtcCloud.unRegisterListener(onRtcListener);
    if (!screenUserList.isEmpty) {
      screenUserList.forEach((key, value) {
        trtcCloud.unregisterTexture(value);
      });
    }
    trtcCloud.exitRoom();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  iniRoom() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    trtcCloud.registerListener(onRtcListener);
    txBeautyManager = trtcCloud.getBeautyManager();

    enterRoom();

    initData();
    if (!kIsWeb && !Platform.isMacOS) {
      txBeautyManager.setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_PITU);
      txBeautyManager.setBeautyLevel(6);
    }
  }

  enterRoom() async {
    userInfo['userSig'] =
        await GenerateTestUserSig.genTestSig(userInfo['userId']);
    meetModel.setUserInfo(userInfo);
    await trtcCloud.enterRoom(
        TRTCParams(
            sdkAppId: GenerateTestUserSig.sdkAppId,
            userId: userInfo['userId'],
            userSig: userInfo['userSig'],
            role: TRTCCloudDef.TRTCRoleAnchor,
            roomId: meetId!),
        TRTCCloudDef.TRTC_APP_SCENE_LIVE);
    trtcCloud.setVideoEncoderParam(TRTCVideoEncParam(
        videoResolution: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_480_360,
        videoResolutionMode: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT));
  }

  initData() async {
    if (isOpenCamera) {
      int? textureId =
          await trtcCloud.setLocalVideoRenderListener(CustomLocalRender(
        userId: userInfo['userId'],
        isFront: true,
        streamType: TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
        width: 360,
        height: 480,
      ));
      if (textureId != null) {
        setState(() {
          screenUserList[userInfo['userId']] = textureId;
        });
      }
    }
    if (isOpenMic) {
      await trtcCloud.startLocalAudio(quality);
    }

    this.setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        {
          if (isOpenCamera) {
            int? textureId =
                await trtcCloud.setLocalVideoRenderListener(CustomLocalRender(
              userId: userInfo['userId'],
              isFront: true,
              streamType: TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
              width: 360,
              height: 480,
            ));

            if (textureId != null) {
              setState(() {
                screenUserList[userInfo['userId']] = textureId;
              });
            }
          }
        }
        break;
      case AppLifecycleState.paused:
        if (isOpenCamera) {
          trtcCloud.stopLocalPreview();
          if (screenUserList.containsKey(userInfo['userId'])) {
            removeViedo(userInfo['userId']);
          }
        }

        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  removeViedo(String userId) async {
    if (screenUserList.containsKey(userId)) {
      setState(() {
        int textureID = screenUserList[userId]!;
        screenUserList.remove(userId);
        trtcCloud.unregisterTexture(textureID);
      });
    }
  }

  onRtcListener(type, param) async {
    if (type == TRTCCloudListener.onEnterRoom) {
      if (param > 0) {
        showToastText('enter room success');
      }
    }
    if (type == TRTCCloudListener.onExitRoom) {
      if (param > 0) {
        showToastText('exit room success');
      }
    }
    if (type == TRTCCloudListener.onUserSubStreamAvailable) {
      String userId = param["userId"];
      if (param["available"]) {
        int? textureId =
            await trtcCloud.setRemoteVideoRenderListener(CustomRemoteRender(
          userId: userId,
          streamType: TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB,
          width: 360,
          height: 480,
        ));
        if (textureId != null) {
          String userIdSub = userId + '_sub';
          setState(() {
            screenUserList[userIdSub] = textureId;
          });
        }
      } else {
        await trtcCloud.stopRemoteView(
            userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
        removeViedo(userId + '_sub');
      }
    }
    if (type == TRTCCloudListener.onRemoteUserLeaveRoom) {
      String userId = param['userId'];
      removeViedo(userId);
    }
    if (type == TRTCCloudListener.onUserVideoAvailable) {
      String userId = param['userId'];
      if (param['available']) {
        int? textureId =
            await trtcCloud.setRemoteVideoRenderListener(CustomRemoteRender(
          userId: userId,
          streamType: TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
          width: 360,
          height: 480,
        ));
        if (textureId != null) {
          setState(() {
            screenUserList[userId] = textureId;
          });
        }
      } else {
        await trtcCloud.stopRemoteView(
            userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
        removeViedo(userId);
      }
    }
  }

  showToastText(text) {
    showToast(
      text,
      context: context,
      duration: Duration(seconds: 3),
    );
  }

  Widget itemBuilder(BuildContext context, index) {
    int screenItem = screenUserList.values.toList()[index];
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          width: 360,
          height: 480,
          child: Texture(
            textureId: screenItem,
          ),
        ),
        Positioned(
          bottom: 5,
          left: 5,
          child: Text(
            screenUserList.keys.toList()[index],
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meetId.toString()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromRGBO(14, 25, 44, 1),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 0.7,
        ),
        itemCount: screenUserList.length,
        itemBuilder: itemBuilder,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 20, left: 50, right: 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                icon: Icon(
                  isOpenMic ? Icons.mic : Icons.mic_off,
                  color: Colors.blue,
                  size: 45.0,
                ),
                onPressed: () {
                  if (isOpenMic) {
                    trtcCloud.stopLocalAudio();
                  } else {
                    trtcCloud.startLocalAudio(quality);
                  }
                  setState(() {
                    isOpenMic = !isOpenMic;
                  });
                }),
            IconButton(
              icon: Icon(
                isOpenCamera ? Icons.videocam : Icons.videocam_off,
                color: Colors.blue,
                size: 45.0,
              ),
              onPressed: () async {
                if (isOpenCamera) {
                  trtcCloud.stopLocalPreview();
                  removeViedo(userInfo['userId']);
                } else {
                  int? textureId = await trtcCloud
                      .setLocalVideoRenderListener(CustomLocalRender(
                    userId: userInfo['userId'],
                    isFront: true,
                    streamType: TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
                    width: 360,
                    height: 480,
                  ));
                  if (textureId != null) {
                    setState(() {
                      screenUserList[userInfo['userId']] = textureId;
                    });
                  }
                }
                setState(() {
                  isOpenCamera = !isOpenCamera;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
