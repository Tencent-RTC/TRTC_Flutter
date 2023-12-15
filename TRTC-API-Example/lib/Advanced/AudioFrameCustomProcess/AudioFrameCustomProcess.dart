import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';

class AudioFrameCustomProcessPage extends StatefulWidget {
  const AudioFrameCustomProcessPage({Key? key}) : super(key: key);

  @override
  State<AudioFrameCustomProcessPage> createState() => _AudioFrameCustomProcessPageState();
}

class _AudioFrameCustomProcessPageState extends State<AudioFrameCustomProcessPage> {
  final channel = MethodChannel('TRCT_FLUTTER_EXAMPLE');
  late TRTCCloud trtcCloud;

  String userId = '1234';
  int roomId = 888888;
  int localViewId = 0;

  bool isEnterRoom = false;
  bool isEnableProcess = false;

  @override
  void initState() {
    // TODO: implement initState
    _initTRTC();
  }
   _initTRTC() async {
     trtcCloud = (await TRTCCloud.sharedInstance())!;
   }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        TRTCCloudVideoView(
          key: ValueKey("LocalView"),
          viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
          onViewCreated: (viewId) async {
            setState(() {
              localViewId = viewId;
            });
          },
        ),
        Positioned(
          left: 0,
          bottom: 20,
          child: Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextField(
                        autofocus: false,
                        decoration: InputDecoration(
                          labelText: "Room ID",
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: this.userId,
                            selection: TextSelection.fromPosition(
                              TextPosition(
                                  affinity: TextAffinity.downstream,
                                  offset: '${this.userId}'.length),
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          roomId = int.fromEnvironment(value);
                        },
                      ),
                    ),
                    SizedBox(width: 20),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        autofocus: false,
                        decoration: InputDecoration(
                          labelText: "User ID",
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: this.roomId.toString(),
                            selection: TextSelection.fromPosition(
                              TextPosition(
                                  affinity: TextAffinity.downstream,
                                  offset: '${this.userId}'.length),
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
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 0,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.green),
                          ),
                          onPressed: () => isEnterRoom ? exitRoom() : enterRoom(),
                          child: isEnterRoom ? Text('ExitRoom') : Text('EnterRoom'),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 0,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.green),
                          ),
                          onPressed: () => isEnableProcess ? _disableAudioFrameCustomProcess() : _enableAudioFrameCustomProcess(),
                          child: isEnableProcess ? Text('DisableProcess') : Text('EnableProcess'),
                        ),
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

  enterRoom() async {
    TRTCParams params = new TRTCParams();
    params.sdkAppId = GenerateTestUserSig.sdkAppId;
    params.roomId = roomId;
    params.userId = userId;
    params.role = TRTCCloudDef.TRTCRoleAnchor;
    params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
    trtcCloud.callExperimentalAPI(
        "{\"api\": \"setFramework\", \"params\": {\"framework\": 7, \"component\": 2}}");
    trtcCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC);
    trtcCloud.enterRoom(params, TRTCCloudDef.TRTC_APP_SCENE_LIVE);

    trtcCloud.startLocalPreview(true, localViewId);
    isEnterRoom = true;
    setState(() {});
  }

  exitRoom() async {
    trtcCloud.stopLocalAudio();
    trtcCloud.stopLocalPreview();
    trtcCloud.exitRoom();

    isEnterRoom = false;
    setState(() {});
  }

  destroyRoom() async {
    await TRTCCloud.destroySharedInstance();
  }

  _enableAudioFrameCustomProcess() async {
    await channel.invokeMethod('enableTRTCAudioFrameDelegate');
    isEnableProcess = true;
    setState(() {});
  }

  _disableAudioFrameCustomProcess() async {
    await channel.invokeMethod('disableTRTCAudioFrameDelegate');
    isEnableProcess = false;
    setState(() {});
  }
}
