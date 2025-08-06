import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:trtc_api_example/Common/TXHelper.dart';
import 'package:trtc_api_example/Common/TXUpdateEvent.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:trtc_api_example/generated/l10n.dart';

///  StringRoomIdPage.dart
///  TRTC-API-Example-Dart
class StringRoomIdPage extends StatefulWidget {
  const StringRoomIdPage({Key? key}) : super(key: key);

  @override
  _StringRoomIdPageState createState() => _StringRoomIdPageState();
}

class _StringRoomIdPageState extends State<StringRoomIdPage> {
  late TRTCCloud trtcCloud;
  int? localViewId;
  bool isStartPush = false;
  String strRoomId = "abc123";
  String userId = TXHelper.generateRandomUserId();
  @override
  void initState() {
    initTRTCCloud();
    super.initState();
    eventBus.fire(TitleUpdateEvent('Room ID: $strRoomId'));
  }

  initTRTCCloud() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
  }

  destroyRoom() async {
    trtcCloud.stopLocalAudio();
    trtcCloud.stopLocalPreview();
    trtcCloud.exitRoom();
    TRTCCloud.destroySharedInstance();
  }

  @override
  dispose() {
    unFocus();
    destroyRoom();
    super.dispose();
  }

  startPushStream() async {
    trtcCloud.startLocalPreview(true, localViewId!);
    TRTCParams params = new TRTCParams();
    params.sdkAppId = GenerateTestUserSig.sdkAppId;
    params.strRoomId = this.strRoomId;
    params.userId = this.userId;
    params.role = TRTCRoleType.anchor;
    params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
    trtcCloud.enterRoom(params, TRTCAppScene.live);

    TRTCVideoEncParam encParams = new TRTCVideoEncParam();
    encParams.videoResolution = TRTCVideoResolution.res_960_540;
    encParams.videoResolutionMode = TRTCVideoResolutionMode.portrait;
    encParams.videoFps = 24;
    trtcCloud.setVideoEncoderParam(encParams);

    trtcCloud.startLocalAudio(TRTCAudioQuality.music);
  }

  stopPushStream() async {
    trtcCloud.stopLocalAudio();
    trtcCloud.stopLocalPreview();
    trtcCloud.exitRoom();
  }

  final roomIdFocusNode = FocusNode();
  final userIdFocusNode = FocusNode();
  // Hide the bottom input box
  unFocus() {
    if (roomIdFocusNode.hasFocus) {
      roomIdFocusNode.unfocus();
    } else if (userIdFocusNode.hasFocus) {
      userIdFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            unFocus();
          },
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
          left: 0,
          height: 85,
          bottom: 10,
          child: Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        'Room ID',
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        'User ID',
                      ),
                    ),
                    SizedBox(
                      width: 100,
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
                        enabled: !isStartPush,
                        autofocus: false,
                        focusNode: roomIdFocusNode,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.5),
                          ),
                        ),
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: this.strRoomId,
                            selection: TextSelection.fromPosition(
                              TextPosition(
                                affinity: TextAffinity.downstream,
                                offset: this.strRoomId.length,
                              ),
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          strRoomId = value;
                          eventBus.fire(TitleUpdateEvent('Room ID: $strRoomId'));
                        },
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        autofocus: false,
                        enabled: !isStartPush,
                        focusNode: userIdFocusNode,
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
                          unFocus();
                          bool newIsStartPush = !isStartPush;
                          if (newIsStartPush)
                            startPushStream();
                          else
                            stopPushStream();
                          setState(() {
                            isStartPush = newIsStartPush;
                          });
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
